import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/navigation/nav_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/category_chip.dart';
import '../../../core/widgets/glass_sheet.dart';
import '../../progression/domain/xp_rules.dart';
import '../../quests/application/quest_providers.dart';
import '../../quests/domain/quest.dart';
import '../../settings/application/settings_controller.dart';

/// The (stubbed) AI prompt and the quest chain it "returns". No backend yet —
/// deterministic sample so the generated-list UI is real and reviewable.
const _aiPrompt = 'I want to become healthier';
const _generated = <({String code, String name, QuestDifficulty diff})>[
  (code: 'HYD', name: 'Drink 2L water', diff: QuestDifficulty.easy),
  (code: 'MOV', name: '20-minute walk', diff: QuestDifficulty.easy),
  (code: 'SLP', name: 'Lights out by 11', diff: QuestDifficulty.medium),
  (code: 'VEG', name: 'One green meal', diff: QuestDifficulty.easy),
];

/// Opens the create quest sheet.
void showCreateQuestSheet(BuildContext context, {Quest? quest}) {
  showGlassSheet(
    context,
    builder: (_) => _CreateQuestSheetContent(questToEdit: quest),
  );
}

class _CreateQuestSheetContent extends ConsumerStatefulWidget {
  const _CreateQuestSheetContent({this.questToEdit});

  final Quest? questToEdit;

  @override
  ConsumerState<_CreateQuestSheetContent> createState() =>
      _CreateQuestSheetContentState();
}

class _CreateQuestSheetContentState
    extends ConsumerState<_CreateQuestSheetContent> {
  late final TextEditingController _nameController;
  late QuestCategory _category;
  late QuestDifficulty _difficulty;
  bool _aiGenerated = false;

  bool get _isEditing => widget.questToEdit != null;

  @override
  void initState() {
    super.initState();
    final quest = widget.questToEdit;
    _nameController = TextEditingController(text: quest?.name ?? '');
    _category = quest?.category ?? QuestCategory.productivity;
    _difficulty = quest?.difficulty ?? QuestDifficulty.medium;
    _nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() => setState(() {});

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(difficultyModeProvider);
    return GlassSheet(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              _isEditing ? 'Edit quest' : 'Create quest',
              style: AppType.screenTitle,
            ),

            const SizedBox(height: Gap.lg),

            // AI row — only for create
            if (!_isEditing) ...[
              _AiRow(
                generated: _aiGenerated,
                onTryIt: () => setState(() => _aiGenerated = true),
                onRedo: () => setState(() => _aiGenerated = false),
              ),

              // Generated quest chain
              if (_aiGenerated)
                _GeneratedList(mode: mode, onAddAll: _addAllGenerated),

              const SizedBox(height: Gap.lg),
              Divider(color: AppColors.borderHairline),
              const SizedBox(height: Gap.lg),
            ],

            // Quest name
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
                final reward = XpRules.reward(diff, mode);
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

            const SizedBox(height: Gap.xl),

            // Action button
            GestureDetector(
              onTap: _nameController.text.isNotEmpty
                  ? (_isEditing ? _updateQuest : _addQuest)
                  : null,
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
                  _isEditing ? 'Save changes' : 'Add to trail',
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
      code: _codeFor(name),
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

  void _updateQuest() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final original = widget.questToEdit!;
    final updated = original.copyWith(
      code: _codeFor(name),
      name: name,
      category: _category,
      difficulty: _difficulty,
    );

    ref.read(questListProvider.notifier).update(updated);
    Navigator.of(context).pop();
  }

  /// Adds the generated chain as recurring quests and lands on Quests →
  /// Recurring, per the spec.
  void _addAllGenerated() {
    final notifier = ref.read(questListProvider.notifier);
    final base = DateTime.now().millisecondsSinceEpoch;
    for (var i = 0; i < _generated.length; i++) {
      final g = _generated[i];
      notifier.add(
        Quest(
          id: base + i,
          code: g.code,
          name: g.name,
          desc: 'From your AI goal · $_aiPrompt.',
          category: QuestCategory.health,
          difficulty: g.diff,
          time: '15 min',
          due: 'Daily',
          schedule: QuestSchedule.recurring,
        ),
      );
    }
    ref.read(boardTabProvider.notifier).state = 2; // Recurring
    ref.read(navIndexProvider.notifier).state = 1; // Quests tab
    Navigator.of(context).pop();
  }

  /// A stable three-letter mono code from the quest name (letters only, padded).
  static String _codeFor(String name) {
    final letters = name.toUpperCase().replaceAll(RegExp('[^A-Z]'), '');
    if (letters.length >= 3) return letters.substring(0, 3);
    return letters.padRight(3, 'X');
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
                  generated ? 'From "$_aiPrompt"' : 'Generate with AI',
                  style: AppType.trailTitle.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  generated
                      ? 'Edit anything before it joins your trail.'
                      : 'Describe a goal, get a quest chain back.',
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

/// The four AI-generated quests plus the "Add all four" action.
class _GeneratedList extends StatelessWidget {
  const _GeneratedList({required this.mode, required this.onAddAll});

  final DifficultyMode mode;
  final VoidCallback onAddAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: Gap.md),
        ..._generated.map((g) {
          final reward = XpRules.reward(g.diff, mode);
          return Container(
            margin: const EdgeInsets.only(bottom: Gap.xs),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(Radii.trailCard),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Text(
                  g.code,
                  style: AppType.code.copyWith(
                    color: AppColors.difficulty[g.diff.index],
                  ),
                ),
                const SizedBox(width: Gap.md),
                Expanded(
                  child: Text(
                    g.name,
                    style: AppType.trailTitle.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '+$reward',
                  style: AppType.value.copyWith(color: AppColors.accent),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: Gap.sm),
        GestureDetector(
          onTap: onAddAll,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 13),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(Radii.button),
            ),
            child: Text('Add all four', style: AppType.buttonPrimary),
          ),
        ),
      ],
    );
  }
}
