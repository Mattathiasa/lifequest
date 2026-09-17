import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:appwrite/appwrite.dart' as aw;
import 'package:crypto/crypto.dart' show sha1;
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/cloud_gateway.dart';
import '../domain/sync_models.dart';

/// Where the Appwrite project coordinates come from (settings UI or env).
abstract interface class CloudConfigSource {
  String? get endpoint;
  String? get projectId;
  String? get databaseId;
}

/// Appwrite project coordinates for LifeQuest Cloud.
///
/// The settings sheet persists them via [save]; the gateway reads them
/// synchronously through the getters.
class PrefsCloudConfigSource implements CloudConfigSource {
  static const _kEndpoint = 'cloud.endpoint';
  static const _kProjectId = 'cloud.projectId';
  static const _kDatabaseId = 'cloud.databaseId';

  String? _endpoint;
  String? _projectId;
  String? _databaseId;

  @override
  String? get endpoint => _endpoint;

  @override
  String? get projectId => _projectId;

  @override
  String? get databaseId => _databaseId;

  bool get isConfigured => _projectId != null && _projectId!.isNotEmpty;

  /// Load any previously saved config without awaiting the caller.
  void loadUnawaited() {
    unawaited(load());
  }

  /// Load any previously saved config. Call once at startup.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _endpoint = prefs.getString(_kEndpoint);
    _projectId = prefs.getString(_kProjectId);
    _databaseId = prefs.getString(_kDatabaseId);
  }

  /// Persist new config (called by the settings sheet).
  Future<void> save({
    required String endpoint,
    required String projectId,
    required String databaseId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    _endpoint = endpoint;
    _projectId = projectId;
    _databaseId = databaseId;
    await prefs.setString(_kEndpoint, endpoint);
    await prefs.setString(_kProjectId, projectId);
    await prefs.setString(_kDatabaseId, databaseId);
  }

  /// Remove stored config on disconnect.
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    _endpoint = null;
    _projectId = null;
    _databaseId = null;
    await prefs.remove(_kEndpoint);
    await prefs.remove(_kProjectId);
    await prefs.remove(_kDatabaseId);
  }
}

/// Appwrite DocumentsDB-backed gateway. One document per game store per
/// player; document ids are deterministic (`<playerId>-<key>`) so
/// [fetch]/[put] never need a query index.
class AppwriteCloudGateway implements CloudGateway {
  AppwriteCloudGateway._(this._configSource);

  factory AppwriteCloudGateway({required CloudConfigSource configSource}) =>
      AppwriteCloudGateway._(configSource);

  final CloudConfigSource _configSource;

  aw.Client? _client;
  aw.Account? _account;
  aw.DocumentsDB? _documents;
  String? _playerId;

  bool get _configured =>
      _configSource.projectId != null && _configSource.projectId!.isNotEmpty;

  String get _databaseId {
    final id = _configSource.databaseId;
    return id == null || id.isEmpty ? defaultDatabaseId : id;
  }

  void _ensureClient() {
    if (!_configured) {
      throw const CloudConfigException('Cloud project is not configured.');
    }
    _client ??= aw.Client()
        .setEndpoint(_configSource.endpoint ?? defaultEndpoint)
        .setProject(_configSource.projectId!);
    _account ??= aw.Account(_client!);
    _documents ??= aw.DocumentsDB(_client!);
  }

  @override
  Future<String> connect() async {
    _ensureClient();
    try {
      final user = await _account!.get();
      _playerId = user.$id;
      return _playerId!;
    } on aw.AppwriteException catch (e) {
      if (e.code == 401) {
        // No usable session on this device — create an anonymous one.
        await _account!.createAnonymousSession();
        final user = await _account!.get();
        _playerId = user.$id;
        return _playerId!;
      }
      rethrow;
    }
  }

  @override
  Future<bool> hasSession() async {
    if (!_configured) return false;
    try {
      _ensureClient();
      await _account!.get();
      return true;
    } on aw.AppwriteException {
      return false;
    } on CloudConfigException {
      return false;
    }
  }

  @override
  Future<StoreDocument?> fetch(String key) async {
    _ensureClient();
    final playerId = _playerId ?? await connect();
    try {
      final doc = await _documents!.getDocument(
        databaseId: _databaseId,
        collectionId: defaultCollectionId,
        documentId: _docId(playerId, key),
      );
      return StoreDocument(key: key, data: doc.data);
    } on aw.AppwriteException catch (e) {
      if (e.code == 404) return null;
      rethrow;
    }
  }

  @override
  Future<void> put(StoreDocument doc) async {
    _ensureClient();
    final playerId = _playerId ?? await connect();
    await _documents!.upsertDocument(
      databaseId: _databaseId,
      collectionId: defaultCollectionId,
      documentId: _docId(playerId, doc.key),
      data: doc.data,
    );
  }

  @override
  Future<void> disconnect() async {
    if (_account != null) {
      try {
        await _account!.deleteSession(sessionId: 'current');
      } on aw.AppwriteException {
        // Session may already be gone; clearing local state is enough.
      }
    }
    _client = null;
    _account = null;
    _documents = null;
    _playerId = null;
  }

  @override
  Future<({String userId, String secret})> sendSignInCode({
    required String email,
  }) async {
    _ensureClient();
    // Always mint a fresh OTP user: on a fresh device there is no account yet,
    // and when linking from an anonymous session the code must belong to the
    // account that will be signed in, not the current one.
    final user = await _account!.create(
      userId: aw.ID.custom(await _otpUserId(email)),
      email: email,
      password: _otpPassword(email),
    );
    final token = await _account!.createEmailToken(
      userId: user.$id,
      email: email,
    );
    return (userId: token.userId, secret: token.secret);
  }

  @override
  Future<void> signInWithCode({
    required ({String userId, String secret}) handle,
    required String code,
  }) async {
    _ensureClient();
    await _account!.createSession(userId: handle.userId, secret: code);
    final user = await _account!.get();
    _playerId = user.$id;
  }

  /// Stable per-email user id so repeat sign-ins reuse the same account.
  static Future<String> _otpUserId(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'cloud.otpUserId.$email';
    final existing = prefs.getString(key);
    if (existing != null) return existing;
    // Non-guessable, deterministic-per-device handle for this email.
    final id =
        'lq_${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}'
        '${Random().nextInt(0x7FFFFFFF).toRadixString(36)}';
    await prefs.setString(key, id);
    return id;
  }

  /// OTP users are email-code-only; the password is never typed by anyone.
  static String _otpPassword(String email) =>
      'lq-otp:${sha1.convert(utf8.encode(email))}';

  static String _docId(String playerId, String key) => '$playerId-$key';
}

/// Thrown when the gateway is used without a configured project.
class CloudConfigException implements Exception {
  const CloudConfigException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Route a generic cloud failure to a user-presentable message.
String describeCloudError(Object error) {
  if (error is CloudConfigException) return error.message;
  if (error is aw.AppwriteException) {
    final code = error.code;
    if (code == 401) return 'Sign-in expired — reconnect.';
    if (code == 429) return 'Cloud rate limit reached — try again shortly.';
    if (code != null && code >= 500) return 'Cloud service unavailable.';
    if (code == 404) {
      return 'Cloud database not found — check the collection setup.';
    }
    final msg = error.message ?? '';
    return msg.isEmpty ? 'Cloud error.' : 'Cloud error: $msg';
  }
  return 'Something went wrong. Try again.';
}
