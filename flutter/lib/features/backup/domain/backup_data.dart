import 'dart:convert';

import '../../progression/domain/attributes.dart';
import '../../progression/domain/completion_event.dart';
import '../../progression/domain/progression_state.dart';
import '../../quests/domain/quest.dart';
import '../../settings/domain/app_settings.dart';

/// Full game snapshot used for offline export, backup, and restore.
class BackupData {
  const BackupData({
    this.version = 1,
    required this.exportedAt,
    required this.progression,
    required this.attributes,
    required this.history,
    required this.quests,
    required this.settings,
  });

  final int version;
  final DateTime exportedAt;
  final ProgressionState progression;
  final Attributes attributes;
  final List<CompletionEvent> history;
  final List<Quest> quests;
  final AppSettings settings;

  Map<String, dynamic> toJson() => {
    'version': version,
    'exportedAt': exportedAt.toIso8601String(),
    'progression': progression.toJson(),
    'attributes': attributes.toJson(),
    'history': history.map((e) => e.toJson()).toList(),
    'quests': quests.map((q) => q.toJson()).toList(),
    'settings': settings.toJson(),
  };

  /// Serializes into pretty-printed, indented JSON string.
  String toFormattedJson() =>
      const JsonEncoder.withIndent('  ').convert(toJson());

  factory BackupData.fromJson(Map<String, dynamic> json) {
    final v = (json['version'] as num?)?.toInt() ?? 1;
    final exported = json['exportedAt'] != null
        ? DateTime.tryParse(json['exportedAt'] as String) ?? DateTime.now()
        : DateTime.now();
    final prog = ProgressionState.fromJson(
      (json['progression'] as Map<String, dynamic>?) ?? {},
    );
    final attr = Attributes.fromJson(
      (json['attributes'] as Map<String, dynamic>?) ?? {},
    );
    final historyList = (json['history'] as List?) ?? [];
    final hist = historyList
        .whereType<Map<String, dynamic>>()
        .map(CompletionEvent.fromJson)
        .toList();
    final questsList = (json['quests'] as List?) ?? [];
    final qList = questsList
        .whereType<Map<String, dynamic>>()
        .map(Quest.fromJson)
        .toList();
    final sett = AppSettings.fromJson(
      (json['settings'] as Map<String, dynamic>?) ?? {},
    );

    return BackupData(
      version: v,
      exportedAt: exported,
      progression: prog,
      attributes: attr,
      history: hist,
      quests: qList,
      settings: sett,
    );
  }

  static BackupData fromJsonString(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid backup format: root must be a JSON object',
      );
    }
    return BackupData.fromJson(decoded);
  }
}
