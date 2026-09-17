import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/cloud_gateway.dart';
import '../data/appwrite_cloud_gateway.dart';
import '../domain/sync_models.dart';

/// Persisted sync bookkeeping (never game data itself).
class _SyncPrefs {
  static const _kStatus = 'sync.status';
  static const _kLastSync = 'sync.lastSyncAt';
  static const _kPending = 'sync.pending';
  static const _kAccountEmail = 'sync.accountEmail';

  Future<void> saveStatus(CloudConnectionState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kStatus, state.name);
  }

  Future<CloudConnectionState> loadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kStatus);
    return CloudConnectionState.values
        .where((s) => s.name == raw)
        .firstOr(CloudConnectionState.disconnected);
  }

  Future<void> saveLastSync(DateTime? at) async {
    final prefs = await SharedPreferences.getInstance();
    if (at == null) {
      await prefs.remove(_kLastSync);
    } else {
      await prefs.setString(_kLastSync, at.toIso8601String());
    }
  }

  Future<DateTime?> loadLastSync() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kLastSync);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  Future<void> savePending(List<PendingChange> pending) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kPending,
      pending.map((p) => '${p.key}|${p.queuedAt.toIso8601String()}').join(';'),
    );
  }

  Future<List<PendingChange>> loadPending() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kPending);
    if (raw == null || raw.isEmpty) return [];
    return [
      for (final part in raw.split(';'))
        if (part.isNotEmpty)
          PendingChange(
            key: part.split('|').first,
            queuedAt:
                DateTime.tryParse(part.split('|').skip(1).join('|')) ??
                DateTime.now(),
          ),
    ];
  }

  Future<void> saveAccountEmail(String? email) async {
    final prefs = await SharedPreferences.getInstance();
    if (email == null) {
      await prefs.remove(_kAccountEmail);
    } else {
      await prefs.setString(_kAccountEmail, email);
    }
  }

  Future<String?> loadAccountEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kAccountEmail);
  }
}

extension _FirstOr<T> on Iterable<T> {
  T firstOr(T fallback) => isEmpty ? fallback : first;
}

/// Owns the connection to the player's cloud workspace and the offline-first
/// push/pull loop for the game stores.
///
/// Repositories call [queuePush] after every local write and [pullStore] at
/// startup. The controller never invents payloads — it moves opaque JSON
/// documents the repositories own.
class SyncController extends AsyncNotifier<CloudSyncStatus> {
  final _SyncPrefs _prefs = _SyncPrefs();

  // Latest payloads, kept so a queued change can be re-pushed as one
  // collapsed write per key (last-write-wins).
  final Map<String, Map<String, dynamic>> _latest = {};
  List<PendingChange> _pending = [];
  Timer? _retryTimer;

  CloudGateway get _gateway => ref.read(cloudGatewayProvider);

  @override
  Future<CloudSyncStatus> build() async {
    ref.onDispose(() => _retryTimer?.cancel());
    final savedState = await _prefs.loadStatus();
    final lastSync = await _prefs.loadLastSync();
    _pending = await _prefs.loadPending();
    final accountEmail = await _prefs.loadAccountEmail();
    final stillConnected =
        savedState == CloudConnectionState.connected ||
        savedState == CloudConnectionState.syncing;
    if (stillConnected) {
      // Auto-reconnect: the sheet says "connected", so actually connect at
      // startup — pull fresh cloud data and flush anything queued offline.
      unawaited(_autoReconnect());
      return CloudSyncStatus(
        state: CloudConnectionState.connecting,
        lastSyncedAt: lastSync,
        pendingCount: _pending.length,
        accountEmail: accountEmail,
      );
    }
    return CloudSyncStatus(
      state: savedState,
      lastSyncedAt: lastSync,
      pendingCount: _pending.length,
      accountEmail: accountEmail,
    );
  }

  /// Startup reconnection. Failures keep the saved "connected" preference so
  /// the next launch tries again; the UI reports the error in the sheet.
  Future<void> _autoReconnect() async {
    try {
      await _gateway.connect();
      _set(_current.copyWith(state: CloudConnectionState.connected));
      await pullAllStores();
      await flushQueued();
    } catch (e) {
      _set(
        _current.copyWith(
          state: CloudConnectionState.error,
          errorMessage: describeCloudError(e),
        ),
      );
    }
  }

  CloudSyncStatus get _current => state.valueOrNull ?? const CloudSyncStatus();

  void _set(CloudSyncStatus status) => state = AsyncData(status);

  // ── Connection ────────────────────────────────────────────────────────────

  /// Connect (or re-connect) the device to a cloud workspace.
  Future<void> connect() async {
    await future; // never race our own async build
    _set(
      _current.copyWith(
        state: CloudConnectionState.connecting,
        clearError: true,
      ),
    );
    try {
      await _gateway.connect();
      _set(_current.copyWith(state: CloudConnectionState.connected));
      await _prefs.saveStatus(CloudConnectionState.connected);
      // Bring the device up to date, then flush anything queued offline.
      await pullAllStores();
      await flushQueued();
    } catch (e) {
      _set(
        _current.copyWith(
          state: CloudConnectionState.error,
          errorMessage: describeCloudError(e),
        ),
      );
    }
  }

  /// Disconnect (sign out) or simply go offline; keeps cloud data.
  Future<void> disconnect({bool keepAccount = false}) async {
    try {
      await _gateway.disconnect();
    } catch (_) {
      // Disconnecting must always succeed locally.
    }
    _latest.clear();
    _pending = [];
    await _prefs.savePending(_pending);
    await _prefs.saveLastSync(null);
    if (!keepAccount) {
      await _prefs.saveAccountEmail(null);
    }
    await _prefs.saveStatus(CloudConnectionState.disconnected);
    _set(
      CloudSyncStatus(accountEmail: keepAccount ? _current.accountEmail : null),
    );
  }

  /// Clear the error and try the queued writes again.
  Future<void> retry() => flushQueued();

  // ── Email OTP sign-in / linking ─────────────────────────────────────────

  /// Handle returned by [sendSignInCode], consumed by [signInWithCode].
  ({String userId, String secret})? _pendingHandle;

  /// Send a one-time code to [email]. The device keeps its local data; the
  /// code is exchanged via [signInWithCode].
  Future<void> sendSignInCode({required String email}) async {
    await future; // never race our own async build
    try {
      _pendingHandle = await _gateway.sendSignInCode(email: email);
      _set(_current.copyWith(clearError: true));
    } catch (e) {
      _set(
        _current.copyWith(
          state: CloudConnectionState.error,
          errorMessage: describeCloudError(e),
        ),
      );
      rethrow;
    }
  }

  /// Exchange the emailed code for a session, adopt that account's namespace,
  /// pull its cloud stores (so another device's data arrives), then push the
  /// local stores so this device's latest changes upload.
  Future<void> signInWithCode({required String code}) async {
    await future; // never race our own async build
    final gateway = _gateway;
    try {
      await gateway.connect(); // OTP flow requires an Appwrite session
      await gateway.signInWithCode(code: code, handle: _pendingHandle!);
      _set(
        _current.copyWith(
          state: CloudConnectionState.connected,
          clearError: true,
        ),
      );
      await pullAllStores();
      await flushQueued();
      // The local stores push their own snapshots in flushQueued above; the
      // account email is remembered for the Profile row.
    } catch (e) {
      _set(
        _current.copyWith(
          state: CloudConnectionState.error,
          errorMessage: describeCloudError(e),
        ),
      );
      rethrow;
    }
  }

  /// The signed-in account email, shown in the sync sheet after linking.
  String? get accountEmail => _current.accountEmail;

  /// Remember the signed-in account email (called by the sheet after a
  /// successful code exchange). Display-only; never synced.
  Future<void> rememberAccountEmail(String email) async {
    await _prefs.saveAccountEmail(email);
    _set(_current.copyWith(accountEmail: email));
  }

  // ── Pull ──────────────────────────────────────────────────────────────────

  /// Fetch [key] from the cloud and hand it to [apply] so the owning
  /// repository can merge it into local state.
  Future<void> pullStore(
    String key,
    Future<void> Function(Map<String, dynamic> data) apply,
  ) async {
    if (_current.state == CloudConnectionState.disconnected) return;
    try {
      final doc = await _gateway.fetch(key);
      if (doc != null) {
        _lastFetched[key] = doc.data;
        await apply(doc.data);
      }
    } catch (e) {
      _set(
        _current.copyWith(
          state: CloudConnectionState.error,
          errorMessage: describeCloudError(e),
        ),
      );
    }
  }

  /// Pull every registered store (called right after connect).
  Future<void> pullAllStores() async {
    for (final key in _registeredKeys.toList()) {
      final apply = _registeredApplies[key];
      if (apply != null) await pullStore(key, apply);
    }
  }

  final Map<String, Future<void> Function(Map<String, dynamic>)>
  _registeredApplies = {};
  final Set<String> _registeredKeys = {};

  /// Last remote snapshot seen per store, so a repository that registers
  /// after a pull already happened (lazy provider creation) still receives
  /// its remote data immediately.
  final Map<String, Map<String, dynamic>> _lastFetched = {};

  /// Register a store so [pullAllStores] includes it. Repositories register
  /// lazily (when a screen first reads them), so they can come online after
  /// a connect: if a remote snapshot for [key] was already pulled it is
  /// replayed, and when the controller is already connected a fresh pull is
  /// fired so the repository still receives its cloud data immediately.
  void registerStore(
    String key,
    Future<void> Function(Map<String, dynamic>) apply,
  ) {
    _registeredKeys.add(key);
    _registeredApplies[key] = apply;
    final cached = _lastFetched[key];
    if (cached != null) {
      unawaited(apply(cached));
    } else if (_current.state == CloudConnectionState.connected ||
        _current.state == CloudConnectionState.syncing) {
      unawaited(pullStore(key, apply));
    }
  }

  // ── Push ──────────────────────────────────────────────────────────────────

  /// Queue a store payload for push. Returns immediately; the actual network
  /// write happens in [flushQueued] (fired right after, or on retry).
  Future<void> queuePush(String key, Map<String, dynamic> data) async {
    await future; // never race our own async build
    _latest[key] = data;
    if (_current.state == CloudConnectionState.disconnected) return;
    if (!_pending.any((p) => p.key == key)) {
      _pending = [
        ..._pending,
        PendingChange(key: key, queuedAt: DateTime.now()),
      ];
      await _prefs.savePending(_pending);
      _set(
        _current.copyWith(
          pendingCount: _pending.length,
          state: _current.state == CloudConnectionState.connected
              ? CloudConnectionState.syncing
              : _current.state,
        ),
      );
    }
    // Fire-and-forget: flush on the next microtask so callers never await
    // the network on a quest tap.
    unawaited(flushQueued());
  }

  /// Push all queued changes. Collapses to one write per key (LWW).
  Future<void> flushQueued() async {
    await future; // never race our own async build
    if (_current.state == CloudConnectionState.disconnected) return;
    if (_pending.isEmpty && _latest.isEmpty) return;
    if (_current.state == CloudConnectionState.error) {
      _set(
        _current.copyWith(
          state: CloudConnectionState.syncing,
          clearError: true,
        ),
      );
    }
    try {
      // One attempt per queued key; failures stay queued. Keys live in
      // _pending, but an offline queuePush may only have reached _latest.
      final keys = {..._pending.map((p) => p.key), ..._latest.keys};
      for (final key in keys) {
        final data = _latest[key];
        if (data == null) {
          _pending = [
            for (final p in _pending)
              if (p.key != key) p,
          ];
          continue;
        }
        await _gateway.put(StoreDocument(key: key, data: data));
        _pending = [
          for (final p in _pending)
            if (p.key != key) p,
        ];
      }
      await _prefs.savePending(_pending);
      _set(
        _current.copyWith(
          state: CloudConnectionState.connected,
          lastSyncedAt: DateTime.now(),
          pendingCount: _pending.length,
          clearError: true,
        ),
      );
      await _prefs.saveStatus(CloudConnectionState.connected);
    } catch (e) {
      _set(
        _current.copyWith(
          state: CloudConnectionState.error,
          errorMessage: describeCloudError(e),
        ),
      );
      _scheduleRetry();
    }
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(seconds: 20), () {
      if (_current.state == CloudConnectionState.error) {
        unawaited(flushQueued());
      }
    });
  }
}

/// The Appwrite config source — a singleton the settings sheet writes to and
/// the gateway reads from.
final cloudConfigProvider = Provider<PrefsCloudConfigSource>((ref) {
  return PrefsCloudConfigSource()..loadUnawaited();
});

/// The cloud gateway in use. Tests override this with a [FakeCloudGateway].
final cloudGatewayProvider = Provider<CloudGateway>((ref) {
  return AppwriteCloudGateway(configSource: ref.watch(cloudConfigProvider));
});

final syncProvider = AsyncNotifierProvider<SyncController, CloudSyncStatus>(
  SyncController.new,
);

/// Convenience: current connection state for widgets.
final cloudConnectionStateProvider = Provider<CloudConnectionState>((ref) {
  return ref.watch(syncProvider).valueOrNull?.state ??
      CloudConnectionState.disconnected;
});

/// One-line status for the Profile settings row.
final cloudSyncHintProvider = Provider<String>((ref) {
  final status = ref.watch(syncProvider).valueOrNull;
  final state = status?.state ?? CloudConnectionState.disconnected;
  return switch (state) {
    CloudConnectionState.disconnected => 'Off — local only',
    CloudConnectionState.connecting => 'Linking…',
    CloudConnectionState.connected =>
      status!.pendingCount > 0
          ? 'On — ${status.pendingCount} pending'
          : 'On — synced',
    CloudConnectionState.syncing => 'Syncing…',
    CloudConnectionState.error => 'Attention needed',
  };
});

/// Whether the Profile settings row should carry the accent tint.
final cloudSyncAccentProvider = Provider<bool>((ref) {
  final state = ref.watch(cloudConnectionStateProvider);
  return state == CloudConnectionState.connected ||
      state == CloudConnectionState.syncing;
});
