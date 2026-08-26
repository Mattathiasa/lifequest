import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/category_chip.dart';
import '../../../core/widgets/glass_sheet.dart';
import '../../progression/domain/xp_rules.dart';
import '../../quests/application/quest_providers.dart';
import '../../quests/domain/quest.dart';

/// Opens the create quest sheet.
void showCreateQuestSheet(BuildContext context) {
  showGlassSheet(context, builder: (_) => const _CreateQuestSheetContent());
}

class _CreateQuestSheetContent extends ConsumerStatefulWidget {
  const _CreateQuestSheetContent();

  @override
  ConsumerState<_CreateQuestSheetContent> createState() =>
      _CreateQuestSheetContentState();
}

class _CreateQuestSheetContentState
    extends ConsumerState<_CreateQuestSheetContent> {
  final _nameController = TextEditingController();
  QuestCategory _category = QuestCategory.productivity;
  QuestDifficulty _difficulty = QuestDifficulty.medium;
  bool _aiGenerated = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassSheet(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // AI row
            _AiRow(
              generated: _aiGenerated,
              onTryIt: () => setState(() => _aiGenerated = true),
              onRedo: () => setState(() => _aiGenerated = false),
            ),

            const SizedBox(height: Gap.lg),
            Divider(color: AppColors.borderHairline),
            const SizedBox(height: Gap.lg),

            // Manual form
            Text('QUEST NAME', style: AppType.eyebrow),
            const SizedBox(height: Gap.sm),
            TextField(
              controller: _nameController,
              style: AppType.body.copyWith(color: AppColors.textPrimary),
              decoration: const InputDecoration(hintText: 'Run 5 KM'),
            ),

            const SizedBox(height: Gap.lg),

            // Category chips
            Text('CATEGORY', style: AppType.eyebrow),
            const SizedBox(height: Gap.sm),
            Wrap(
              spacing: Gap.xs,
              runSpacing: Gap.xs,
              children: QuestCategory.values.map((cat) {
                return CategoryChip(
                  label: cat.label,
                  selected: _category == cat,
                  onTap: () => setState(() => _category = cat),
                );
              }).toList(),
            ),

            const SizedBox(height: Gap.lg),

            // Difficulty tiles
            Text('DIFFICULTY SETS THE REWARD', style: AppType.eyebrow),
            const SizedBox(height: Gap.sm),
            Row(
              children: QuestDifficulty.values.map((diff) {
                final isSelected = _difficulty == diff;
                final reward = XpRules.reward(diff, DifficultyMode.balanced);
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      AppHaptics.selection();
                      setState(() => _difficulty = diff);
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                        right: diff != QuestDifficulty.epic ? 6 : 0,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accent
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(Radii.input),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.borderStrong,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            diff.numeral,
                            style: AppType.metaLabel.copyWith(
                              color: isSelected
                                  ? AppColors.canvas
                                  : AppColors.difficulty[diff.index],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            diff.label,
                            style: AppType.buttonPrimary.copyWith(
                              color: isSelected
                                  ? AppColors.canvas
                                  : AppColors.textPrimary,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '+$reward',
                            style: AppType.metaLabel.copyWith(
                              color: isSelected
                                  ? AppColors.canvas.withValues(alpha: 0.7)
                                  : AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: Gap.lg),

            // Due & Repeat fields
            Row(
              children: [
                Expanded(
                  child: _FieldTile(label: 'DUE', value: 'Today · 8:00 PM'),
                ),
                const SizedBox(width: Gap.sm),
                Expanded(
                  child: _FieldTile(label: 'REPEAT', value: 'Daily'),
                ),
              ],
            ),

            const SizedBox(height: Gap.xl),

            // Add to trail button
            GestureDetector(
              onTap: _nameController.text.isNotEmpty ? _addQuest : null,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _nameController.text.isNotEmpty
                      ? AppColors.accent
                      : AppColors.trackInactive,
                  borderRadius: BorderRadius.circular(Radii.buttonLarge),
                ),
                child: Text(
                  'Add to trail',
                  style: AppType.buttonPrimary.copyWith(
                    color: _nameController.text.isNotEmpty
                        ? AppColors.canvas
                        : AppColors.muted,
                  ),
                ),
              ),
            ),

            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  void _addQuest() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final quest = Quest(
      id: DateTime.now().millisecondsSinceEpoch,
      code: name.substring(0, name.length.clamp(0, 3)).toUpperCase(),
      name: name,
      desc: 'Created by you.',
      category: _category,
      difficulty: _difficulty,
      time: '30 min',
      due: 'Today',
      schedule: QuestSchedule.today,
    );

    ref.read(questListProvider.notifier).add(quest);
    Navigator.of(context).pop();
  }
}

class _AiRow extends StatelessWidget {
  const _AiRow({
    required this.generated,
    required this.onTryIt,
    required this.onRedo,
  });

  final bool generated;
  final VoidCallback onTryIt;
  final VoidCallback onRedo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Radii.trailCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Accent icon tile
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accentBorder),
            ),
            child: const Text(
              '✦',
              style: TextStyle(color: AppColors.accent, fontSize: 14),
            ),
          ),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Generate with AI',
                  style: AppType.trailTitle.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Describe a goal, get a quest chain back.',
                  style: AppType.bodySmall,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: generated ? onRedo : onTryIt,
            child: Text(
              generated ? 'Redo' : 'Try it',
              style: AppType.buttonSecondary.copyWith(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldTile extends StatelessWidget {
  const _FieldTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(Radii.input),
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppType.eyebrow),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppType.body.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
