import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/brand_mark.dart';
import '../../../core/widgets/category_chip.dart';
import '../../progression/domain/xp_rules.dart';
import '../../quests/domain/quest.dart';
import '../../settings/application/settings_controller.dart';
import '../../settings/domain/app_settings.dart';

/// First-run onboarding: welcome → goals → difficulty → character.
///
/// On finish it writes the chosen difficulty + name to [settingsProvider],
/// which flips `onboarded` and hands control to the app shell.
class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  static const _stepCount = 4;

  int _step = 0;
  final Set<QuestCategory> _goals = {};
  DifficultyMode _difficulty = DifficultyMode.balanced;
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _canAdvance => switch (_step) {
    1 => _goals.isNotEmpty, // must pick at least one focus area
    _ => true,
  };

  String get _primaryLabel {
    if (_step == 0) return 'Get started';
    if (_step == _stepCount - 1) return 'Enter LifeQuest';
    return 'Continue';
  }

  void _next() {
    AppHaptics.selection();
    if (_step < _stepCount - 1) {
      setState(() => _step++);
    } else {
      _finish();
    }
  }

  void _back() {
    AppHaptics.selection();
    setState(() => _step--);
  }

  Future<void> _finish() async {
    await ref
        .read(settingsProvider.notifier)
        .completeOnboarding(
          difficulty: _difficulty,
          name: _nameController.text,
        );
    // Save the selected focus goals
    await ref
        .read(settingsProvider.notifier)
        .setFocusGoals(_goals.toList());
    // The app shell takes over once `onboarded` flips; no navigation needed.
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.screen),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Gap.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: Gap.md),
              // Top bar: back + progress dots
              Row(
                children: [
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: _step > 0
                        ? GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _back,
                            child: Text(
                              '‹',
                              style: AppType.screenTitle.copyWith(
                                color: AppColors.slate,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const Spacer(),
                  Row(
                    children: List.generate(_stepCount, (i) {
                      final active = i == _step;
                      return AnimatedContainer(
                        duration: Motion.state,
                        margin: const EdgeInsets.only(left: 6),
                        width: active ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i <= _step
                              ? AppColors.accent
                              : AppColors.trackInactive,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                  const Spacer(),
                  const SizedBox(width: 32),
                ],
              ),
              const SizedBox(height: Gap.xl),
              // Step body
              Expanded(
                child: AnimatedSwitcher(
                  duration: Motion.rise,
                  switchInCurve: Curves.easeOut,
                  child: SingleChildScrollView(
                    key: ValueKey(_step),
                    child: _buildStep(),
                  ),
                ),
              ),
              // Primary action
              Padding(
                padding: const EdgeInsets.only(bottom: Gap.lg, top: Gap.md),
                child: _PrimaryButton(
                  label: _primaryLabel,
                  enabled: _canAdvance,
                  onTap: _next,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep() => switch (_step) {
    0 => _WelcomeStep(),
    1 => _GoalsStep(
      selected: _goals,
      onToggle: (c) => setState(() {
        _goals.contains(c) ? _goals.remove(c) : _goals.add(c);
      }),
    ),
    2 => _DifficultyStep(
      selected: _difficulty,
      onSelect: (m) => setState(() => _difficulty = m),
    ),
    _ => _CharacterStep(controller: _nameController),
  };
}

// ── Step 0: Welcome ─────────────────────────────────────────────────────────

class _WelcomeStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: Gap.xl),
        const Center(child: BrandMark(size: 88, wordmark: true)),
        const SizedBox(height: 40),
        Text('LEVEL UP YOUR REAL LIFE', style: AppType.eyebrow),
        const SizedBox(height: Gap.md),
        Text('Turn your goals into an adventure.', style: AppType.screenTitle),
        const SizedBox(height: Gap.md),
        Text(
          'Clear quests, earn XP, and watch your character grow as you build '
          'the habits you actually want. Three quick questions and your trail '
          'is ready.',
          style: AppType.body,
        ),
      ],
    );
  }
}

// ── Step 1: Goals ───────────────────────────────────────────────────────────

class _GoalsStep extends StatelessWidget {
  const _GoalsStep({required this.selected, required this.onToggle});

  final Set<QuestCategory> selected;
  final ValueChanged<QuestCategory> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STEP 1 · GOALS', style: AppType.eyebrow),
        const SizedBox(height: Gap.md),
        Text('What are you here to grow?', style: AppType.screenTitle),
        const SizedBox(height: Gap.sm),
        Text(
          'Pick the areas that matter most. Your trail leans into these.',
          style: AppType.body,
        ),
        const SizedBox(height: Gap.xl),
        Wrap(
          spacing: Gap.sm,
          runSpacing: Gap.sm,
          children: QuestCategory.values.map((c) {
            return CategoryChip(
              label: c.label,
              selected: selected.contains(c),
              onTap: () => onToggle(c),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Step 2: Difficulty ──────────────────────────────────────────────────────

class _DifficultyStep extends StatelessWidget {
  const _DifficultyStep({required this.selected, required this.onSelect});

  final DifficultyMode selected;
  final ValueChanged<DifficultyMode> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STEP 2 · DIFFICULTY', style: AppType.eyebrow),
        const SizedBox(height: Gap.md),
        Text('How hard should it hit?', style: AppType.screenTitle),
        const SizedBox(height: Gap.sm),
        Text(
          'This scales every reward. You can change it later in Profile.',
          style: AppType.body,
        ),
        const SizedBox(height: Gap.xl),
        ...DifficultyMode.values.map((m) {
          final isSelected = m == selected;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              AppHaptics.selection();
              onSelect(m);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: Gap.sm),
              padding: const EdgeInsets.all(Pad.card),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accentSurface : AppColors.surface,
                borderRadius: BorderRadius.circular(Radii.card),
                border: Border.all(
                  color: isSelected ? AppColors.accent : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.label,
                          style: AppType.cardTitle.copyWith(
                            color: isSelected
                                ? AppColors.accent
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(m.blurb, style: AppType.bodySmall),
                      ],
                    ),
                  ),
                  Text(
                    '×${m.multiplier}',
                    style: AppType.metaLabel.copyWith(
                      color: isSelected ? AppColors.accent : AppColors.slate,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ── Step 3: Character ───────────────────────────────────────────────────────

class _CharacterStep extends StatelessWidget {
  const _CharacterStep({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final initials = AppSettings(displayName: controller.text).initials;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('STEP 3 · CHARACTER', style: AppType.eyebrow),
        const SizedBox(height: Gap.md),
        Text('Name your adventurer.', style: AppType.screenTitle),
        const SizedBox(height: Gap.xl),
        Center(
          child: Container(
            width: 88,
            height: 88,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: AppColors.heroCard,
              borderRadius: BorderRadius.circular(Radii.hero),
              border: Border.all(color: AppColors.accentBorder),
            ),
            child: Text(
              controller.text.trim().isEmpty ? '?' : initials,
              style: AppType.heroLevel.copyWith(
                color: AppColors.accent,
                fontSize: 26,
              ),
            ),
          ),
        ),
        const SizedBox(height: Gap.xl),
        Text('YOUR NAME', style: AppType.eyebrow),
        const SizedBox(height: Gap.sm),
        TextField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          style: AppType.body.copyWith(color: AppColors.textPrimary),
          decoration: const InputDecoration(hintText: 'Adventurer'),
        ),
        const SizedBox(height: Gap.md),
        Text(
          'CLASS · SCHOLAR · LVL 12',
          style: AppType.metaLabel.copyWith(color: AppColors.slate),
        ),
      ],
    );
  }
}

// ── Shared primary button ───────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? AppColors.accent : AppColors.trackInactive,
          borderRadius: BorderRadius.circular(Radii.buttonLarge),
        ),
        child: Text(
          label,
          style: AppType.buttonPrimary.copyWith(
            color: enabled ? AppColors.canvas : AppColors.muted,
          ),
        ),
      ),
    );
  }
}
