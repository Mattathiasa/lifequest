import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/progression/application/progression_controller.dart';
import '../../features/progression/presentation/complete_overlay.dart';
import '../../features/progression/presentation/level_up_overlay.dart';
import '../../features/trail/presentation/trail_page.dart';
import '../../features/placeholder/presentation/quests_page.dart';
import '../../features/placeholder/presentation/character_page.dart';
import '../../features/placeholder/presentation/progress_page.dart';
import '../../features/placeholder/presentation/profile_page.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/haptics.dart';

/// The five tabs. Order matches the prototype.
enum _Tab {
  trail('Trail', Icons.explore),
  quests('Quests', Icons.list_alt),
  character('Character', Icons.person),
  progress('Progress', Icons.bar_chart),
  profile('Profile', Icons.settings);

  const _Tab(this.label, this.icon);
  final String label;
  final IconData icon;
}

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _activeIndex = 0;

  static final _pages = <Widget>[
    const TrailPage(),
    const QuestsPage(),
    const CharacterPage(),
    const ProgressPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final overlay = ref.watch(overlayProvider);

    // Schedule overlay events after the current frame to avoid setState-during-build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ctrl = ref.read(progressionProvider.notifier);
      if (overlay.flash != null) {
        _showCompleteOverlay(overlay.flash!);
        ctrl.clearFlash();
      }
      if (overlay.levelUp != null) {
        _showLevelUpOverlay(overlay.levelUp!);
        ctrl.clearLevelUp();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        children: [
          // Pages
          IndexedStack(index: _activeIndex, children: _pages),
          // Overlays are managed via Navigator (showDialog) in the callback above.
        ],
      ),
      bottomNavigationBar: _BottomNav(
        activeIndex: _activeIndex,
        onTap: (i) => setState(() => _activeIndex = i),
      ),
    );
  }

  void _showCompleteOverlay(({int xp, String name}) flash) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      builder: (_) => QuestCompleteOverlay(
        xp: flash.xp,
        name: flash.name,
        onDismiss: () => Navigator.of(context, rootNavigator: true).pop(),
      ),
    );
  }

  void _showLevelUpOverlay(int previousLevel) {
    final prog = ref.read(progressionProvider);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => LevelUpOverlay(
        oldLevel: previousLevel,
        newLevel: prog.progression.level,
        onDismiss: () => Navigator.of(context, rootNavigator: true).pop(),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.activeIndex, required this.onTap});

  final int activeIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.canvas,
        border: Border(
          top: BorderSide(color: AppColors.borderHairline, width: 1),
        ),
      ),
      padding: const EdgeInsets.only(top: 10, left: 18, right: 18, bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_Tab.values.length, (i) {
          final tab = _Tab.values[i];
          final isActive = i == activeIndex;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              AppHaptics.selection();
              onTap(i);
            },
            child: SizedBox(
              width: 56,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Accent dot
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? AppColors.accent : Colors.transparent,
                    ),
                  ),
                  Icon(
                    tab.icon,
                    size: 20,
                    color: isActive ? AppColors.accent : AppColors.muted,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    tab.label,
                    style:
                        (isActive ? AppType.navLabelActive : AppType.navLabel)
                            .copyWith(
                              color: isActive
                                  ? AppColors.accent
                                  : AppColors.muted,
                            ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
