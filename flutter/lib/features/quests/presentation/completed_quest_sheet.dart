import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/glass_sheet.dart';
import '../../progression/domain/xp_rules.dart';
import '../application/quest_providers.dart';
import '../domain/quest.dart';

/// Detail sheet for a completed quest — shows timestamp, stats, and lets the
/// player restore the quest back to the active board or clone it as a new one.
class CompletedQuestSheet extends ConsumerWidget {
  const CompletedQuestSheet({super.key, required this.quest});

  final Quest quest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diffColor = AppColors.difficulty[quest.difficulty.index];
    final reward = quest.xp;
    final completedAt = quest.completedAt;

    return GlassSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top eyebrow
          Row(
            children: [
              Text('COMPLETED QUEST', style: AppType.eyebrow),
              const Spacer(),
              if (completedAt != null)
                Text(_formatDate(completedAt), style: AppType.metaLabel),
            ],
          ),
          const SizedBox(height: Gap.md),

          // Code + name
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.accentSurface,
                  borderRadius: BorderRadius.circular(Radii.iconTile),
                  border: Border.all(color: AppColors.accentBorder),
                ),
                child: Text(
                  quest.code,
                  style: AppType.code.copyWith(color: diffColor),
                ),
              ),
              const SizedBox(width: Gap.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(quest.name, style: AppType.sheetTitle),
                    const SizedBox(height: 4),
                    Text(quest.desc, style: AppType.body),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: Gap.xl),

          // Stats row
          Row(
            children: [
              _StatChip(
                label: 'CATEGORY',
                value: quest.category.label.toUpperCase(),
              ),
              const SizedBox(width: Gap.sm),
              _StatChip(
                label: 'DIFFICULTY',
                value:
                    '${quest.difficulty.numeral} ${quest.difficulty.label.toUpperCase()}',
                valueColor: diffColor,
              ),
              const SizedBox(width: Gap.sm),
              _StatChip(
                label: 'XP EARNED',
                value: '+$reward XP',
                valueColor: AppColors.accent,
              ),
            ],
          ),

          const SizedBox(height: Gap.sm),

          Row(
            children: [
              _StatChip(label: 'TIME', value: quest.time),
              const SizedBox(width: Gap.sm),
              if (completedAt != null)
                _StatChip(
                  label: 'COMPLETED AT',
                  value: _formatTime(completedAt),
                ),
            ],
          ),

          const SizedBox(height: Gap.xxl),

          // Action buttons
          Row(
            children: [
              // Clone as new quest
              Expanded(
                child: GestureDetector(
                  onTap: () => _cloneQuest(context, ref),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Radii.button),
                      border: Border.all(color: AppColors.borderStrong),
                    ),
                    alignment: Alignment.center,
                    child: Text('Clone quest', style: AppType.buttonSecondary),
                  ),
                ),
              ),
              const SizedBox(width: Gap.md),
              // Restore to active board
              Expanded(
                child: GestureDetector(
                  onTap: () => _restore(context, ref),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(Radii.button),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Restore to active',
                      style: AppType.buttonPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    await AppHaptics.complete();
    await ref.read(questListProvider.notifier).restore(quest.id);
    if (context.mounted) Navigator.of(context).pop();
  }

  Future<void> _cloneQuest(BuildContext context, WidgetRef ref) async {
    await AppHaptics.selection();
    final existing = ref.read(questListProvider);
    final nextId = existing.isEmpty
        ? 1
        : existing.map((q) => q.id).reduce((a, b) => a > b ? a : b) + 1;
    final clone = quest.copyWith(
      done: false,
      schedule: QuestSchedule.today,
      completedAt: null,
    );
    // Use a new id for the clone
    final cloned = Quest(
      id: nextId,
      code: clone.code,
      name: clone.name,
      desc: clone.desc,
      category: clone.category,
      difficulty: clone.difficulty,
      time: clone.time,
      due: clone.due,
      schedule: clone.schedule,
    );
    await ref.read(questListProvider.notifier).add(cloned);
    if (context.mounted) Navigator.of(context).pop();
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[local.month - 1]} ${local.day}, ${local.year}';
  }

  String _formatTime(DateTime dt) {
    final local = dt.toLocal();
    final h = local.hour;
    final m = local.minute.toString().padLeft(2, '0');
    final ampm = h >= 12 ? 'PM' : 'AM';
    final hour = h % 12 == 0 ? 12 : h % 12;
    return '$hour:$m $ampm';
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Gap.md, vertical: Gap.xs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Radii.chip),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppType.microLabel),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppType.code.copyWith(
              color: valueColor ?? AppColors.textPrimary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

/// Opens the [CompletedQuestSheet] for the given [quest].
Future<void> showCompletedQuestSheet(BuildContext context, Quest quest) {
  return showGlassSheet(
    context,
    builder: (_) => CompletedQuestSheet(quest: quest),
  );
}
