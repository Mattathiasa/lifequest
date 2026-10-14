import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/glass_sheet.dart';
import '../../../core/widgets/segment_tabs.dart';
import '../application/backup_service.dart';
import '../domain/backup_data.dart';

/// Opens the Data & Backup sheet for offline JSON export and restore.
void showDataBackupSheet(BuildContext context) {
  showGlassSheet(context, builder: (_) => const DataBackupSheet());
}

/// Sheet enabling full game state export to clipboard and JSON restoration.
class DataBackupSheet extends ConsumerStatefulWidget {
  const DataBackupSheet({super.key});

  @override
  ConsumerState<DataBackupSheet> createState() => _DataBackupSheetState();
}

class _DataBackupSheetState extends ConsumerState<DataBackupSheet> {
  int _activeTab = 0; // 0: Export, 1: Restore
  BackupData? _backupData;
  bool _loading = true;
  bool _copied = false;

  final TextEditingController _restoreController = TextEditingController();
  String? _restoreError;
  bool _restoring = false;

  @override
  void initState() {
    super.initState();
    _loadExport();
  }

  @override
  void dispose() {
    _restoreController.dispose();
    super.dispose();
  }

  Future<void> _loadExport() async {
    setState(() => _loading = true);
    final data = await BackupService.createBackup(ref);
    if (mounted) {
      setState(() {
        _backupData = data;
        _loading = false;
      });
    }
  }

  Future<void> _copyToClipboard() async {
    if (_backupData == null) return;
    final jsonStr = _backupData!.toFormattedJson();
    await Clipboard.setData(ClipboardData(text: jsonStr));
    AppHaptics.complete();
    if (mounted) {
      setState(() => _copied = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Game data copied to clipboard',
            style: AppType.bodySmall.copyWith(color: AppColors.canvas),
          ),
          backgroundColor: AppColors.accent,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _attemptRestore() async {
    final raw = _restoreController.text.trim();
    if (raw.isEmpty) {
      setState(() => _restoreError = 'Please paste a backup JSON payload.');
      return;
    }

    BackupData parsed;
    try {
      parsed = BackupData.fromJsonString(raw);
    } catch (e) {
      setState(() => _restoreError = 'Invalid JSON: ${e.toString()}');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.sheetTop,
        title: Text('Replace Local Data?', style: AppType.sheetTitle),
        content: Text(
          'Restoring will overwrite current progression, quests, and settings with this backup.\n\n'
          'Backup Level: ${parsed.progression.level}\n'
          'Quests: ${parsed.quests.length}\n'
          'History events: ${parsed.history.length}',
          style: AppType.body.copyWith(color: AppColors.slate),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: AppType.bodySmall.copyWith(color: AppColors.muted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Overwrite & Restore',
              style: AppType.bodySmall.copyWith(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _restoring = true;
      _restoreError = null;
    });

    try {
      await BackupService.restoreBackup(ref, parsed);
      AppHaptics.levelUp();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Game data restored successfully!',
              style: AppType.bodySmall.copyWith(color: AppColors.canvas),
            ),
            backgroundColor: AppColors.accent,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _restoring = false;
          _restoreError = 'Restore failed: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DATA & BACKUP', style: AppType.eyebrow),
          const SizedBox(height: Gap.md),
          SegmentTabs(
            tabs: const ['Export', 'Restore'],
            activeIndex: _activeTab,
            onTap: (index) {
              setState(() {
                _activeTab = index;
                _copied = false;
                _restoreError = null;
              });
            },
          ),
          const SizedBox(height: Gap.lg),
          if (_activeTab == 0) _buildExportTab() else _buildRestoreTab(),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Widget _buildExportTab() {
    if (_loading || _backupData == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    final data = _backupData!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary stats container
        Container(
          padding: const EdgeInsets.all(Pad.card),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(Radii.card),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('PLAYER LEVEL', style: AppType.metaLabel),
                  Text(
                    'LVL ${data.progression.level}',
                    style: AppType.cardTitle.copyWith(color: AppColors.accent),
                  ),
                ],
              ),
              const SizedBox(height: Gap.xs),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('SAVED QUESTS', style: AppType.metaLabel),
                  Text('${data.quests.length}', style: AppType.body),
                ],
              ),
              const SizedBox(height: Gap.xs),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('COMPLETION LOGS', style: AppType.metaLabel),
                  Text('${data.history.length}', style: AppType.body),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: Gap.md),
        Text(
          'Export a portable JSON archive of your entire journey. Store it safely or transfer it to another device.',
          style: AppType.bodySmall.copyWith(color: AppColors.slate),
        ),
        const SizedBox(height: Gap.lg),
        GestureDetector(
          onTap: _copyToClipboard,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(Radii.buttonLarge),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _copied ? Icons.check : Icons.copy,
                  size: 18,
                  color: AppColors.canvas,
                ),
                const SizedBox(width: Gap.sm),
                Text(
                  _copied ? 'Copied to Clipboard!' : 'Copy Backup JSON',
                  style: AppType.buttonPrimary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRestoreTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Paste a LifeQuest backup JSON payload below to restore your progress, quests, and settings.',
          style: AppType.bodySmall.copyWith(color: AppColors.slate),
        ),
        const SizedBox(height: Gap.md),
        Container(
          height: 140,
          padding: const EdgeInsets.all(Pad.card),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(Radii.input),
            border: Border.all(
              color: _restoreError != null ? AppColors.error : AppColors.border,
            ),
          ),
          child: TextField(
            controller: _restoreController,
            maxLines: null,
            style: AppType.code.copyWith(
              color: AppColors.textPrimary,
              fontSize: 12,
            ),
            decoration: InputDecoration(
              hintText: 'Paste backup JSON here...',
              hintStyle: AppType.bodySmall.copyWith(color: AppColors.muted),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
        if (_restoreError != null) ...[
          const SizedBox(height: Gap.xs),
          Text(
            _restoreError!,
            style: AppType.metaLabel.copyWith(color: AppColors.error),
          ),
        ],
        const SizedBox(height: Gap.lg),
        GestureDetector(
          onTap: _restoring ? null : _attemptRestore,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _restoring ? AppColors.muted : AppColors.accent,
              borderRadius: BorderRadius.circular(Radii.buttonLarge),
            ),
            child: _restoring
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.canvas,
                    ),
                  )
                : Text('Validate & Restore', style: AppType.buttonPrimary),
          ),
        ),
      ],
    );
  }
}
