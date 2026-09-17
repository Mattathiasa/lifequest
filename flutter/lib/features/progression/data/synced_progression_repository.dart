import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/attributes.dart';
import '../domain/completion_event.dart';
import '../domain/progression_state.dart';
import 'progression_repository.dart';

import '../../sync/application/sync_controller.dart';
import '../../sync/domain/sync_models.dart';

/// Wraps the local game-state store with cloud sync: every persist is
/// mirrored to the cloud through [SyncController] (queued when offline), and
/// a remote snapshot can be applied over the local store.
class SyncedProgressionRepository implements ProgressionRepository {
  SyncedProgressionRepository({required this.local, required this.sync});

  final ProgressionRepository local;
  final SyncController sync;

  /// Track the latest snapshot so [applyRemote] and [_push] agree on what
  /// "current" means without re-reading prefs on every call.
  GameSnapshot? _lastKnown;

  @override
  Future<GameSnapshot> load() async {
    final snap = await local.load();
    _lastKnown = snap;
    return snap;
  }

  @override
  Future<void> save(GameSnapshot snapshot) async {
    _lastKnown = snapshot;
    await local.save(snapshot);
    await sync.queuePush(gameStateStoreKey, {
      'progression': snapshot.progression.toJson(),
      'attributes': snapshot.attributes.toJson(),
      'history': snapshot.history.map((e) => e.toJson()).toList(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Called by the sync controller with the remote snapshot.
  Future<void> applyRemote(Map<String, dynamic> data) async {
    final localSnap = _lastKnown ?? await local.load();
    final remoteProgression = (data['progression'] as Map?)
        ?.cast<String, dynamic>();
    if (remoteProgression == null) return;
    final remote = ProgressionState.fromJson(remoteProgression);

    // Last-write-wins at field-group level: the remote progression wins if
    // it is at least as far along (level + lifetime XP heuristic); otherwise
    // the local state stands. History and attributes always merge from both.
    final mergedProgression = _mergeProgression(localSnap.progression, remote);
    final remoteHistory = [
      for (final e in (data['history'] as List?) ?? const [])
        CompletionEvent.fromJson((e as Map).cast<String, dynamic>()),
    ];
    final mergedHistory = _mergeHistory(localSnap.history, remoteHistory);
    final remoteAttributes = (data['attributes'] as Map?)
        ?.cast<String, dynamic>();
    final merged = GameSnapshot(
      progression: mergedProgression,
      attributes: remoteAttributes == null
          ? localSnap.attributes
          : Attributes.fromJson(remoteAttributes),
      history: mergedHistory,
    );
    _lastKnown = merged;
    // Persist locally without re-triggering a push loop: write through the
    // local store only.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'game.progression',
      _encode(merged.progression.toJson()),
    );
    await prefs.setString(
      'game.attributes',
      _encode(merged.attributes.toJson()),
    );
    await prefs.setString(
      'game.history',
      _encode(merged.history.map((e) => e.toJson()).toList()),
    );
  }

  static String _encode(Object json) => jsonEncode(json);

  static ProgressionState _mergeProgression(
    ProgressionState local,
    ProgressionState remote,
  ) {
    final localScore = local.lifetimeXp + local.level * 1000;
    final remoteScore = remote.lifetimeXp + remote.level * 1000;
    return remoteScore > localScore ? remote : local;
  }

  static List<CompletionEvent> _mergeHistory(
    List<CompletionEvent> local,
    List<CompletionEvent> remote,
  ) {
    if (remote.isEmpty) return local;
    final seen = <String>{};
    final merged = <CompletionEvent>[];
    for (final e in [...local, ...remote]) {
      final k =
          '${e.questId}|${e.category.name}|${e.xp}|${e.at.toIso8601String()}';
      if (seen.add(k)) merged.add(e);
    }
    return merged;
  }
}
