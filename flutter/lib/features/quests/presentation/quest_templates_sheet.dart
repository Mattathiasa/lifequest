import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/glass_sheet.dart';
import '../application/quest_providers.dart';
import '../domain/quest_template.dart';

/// Bottom sheet that displays all curated quest packs and lets the player
/// import any pack in one tap.
class QuestTemplatesSheet extends ConsumerStatefulWidget {
  const QuestTemplatesSheet({super.key});

  @override
  ConsumerState<QuestTemplatesSheet> createState() =>
      _QuestTemplatesSheetState();
}

class _QuestTemplatesSheetState extends ConsumerState<QuestTemplatesSheet> {
  final Set<String> _imported = {};
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return GlassSheet(
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.82,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Pad.sheetH),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('STARTER PACKS', style: AppType.eyebrow),
                  const SizedBox(height: Gap.xs),
                  Text('Quest templates', style: AppType.sheetTitle),
                  const SizedBox(height: Gap.xs),
                  Text(
                    'Tap any pack to add all quests to your board instantly.',
                    style: AppType.body,
                  ),
                  const SizedBox(height: Gap.lg),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: Pad.sheetH,
                  vertical: 4,
                ),
                itemCount: QuestPacks.all.length,
                separatorBuilder: (_, _) => const SizedBox(height: Gap.md),
                itemBuilder: (ctx, i) {
                  final pack = QuestPacks.all[i];
                  final isImported = _imported.contains(pack.id);
                  return _PackCard(
                    pack: pack,
                    imported: isImported,
                    busy: _busy,
                    onImport: () => _importPack(pack),
                  );
                },
              ),
            ),
            const SizedBox(height: Gap.md),
          ],
        ),
      ),
    );
  }

  Future<void> _importPack(QuestPack pack) async {
    if (_imported.contains(pack.id) || _busy) return;
    setState(() => _busy = true);

    try {
      final notifier = ref.read(questListProvider.notifier);
      final existing = ref.read(questListProvider);
      var nextId = existing.isEmpty
          ? 1
          : existing.map((q) => q.id).reduce((a, b) => a > b ? a : b) + 1;

      for (final template in pack.templates) {
        await notifier.add(template.toQuest(nextId));
        nextId++;
      }

      await AppHaptics.complete();
      if (mounted) {
        setState(() => _imported.add(pack.id));
        _showToast('${pack.templates.length} quests added to your board!');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showToast(String message) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(builder: (_) => _Toast(message: message));
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), entry.remove);
  }
}

class _PackCard extends StatelessWidget {
  const _PackCard({
    required this.pack,
    required this.imported,
    required this.busy,
    required this.onImport,
  });

  final QuestPack pack;
  final bool imported;
  final bool busy;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Radii.card),
        border: Border.all(
          color: imported ? AppColors.accentBorder : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pack header
          Padding(
            padding: const EdgeInsets.all(Pad.card),
            child: Row(
              children: [
                Text(pack.emoji, style: const TextStyle(fontSize: 26)),
                const SizedBox(width: Gap.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pack.name, style: AppType.cardTitle),
                      const SizedBox(height: 2),
                      Text(pack.description, style: AppType.bodySmall),
                    ],
                  ),
                ),
                // XP badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Gap.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentSurface,
                    borderRadius: BorderRadius.circular(Radii.chip),
                    border: Border.all(color: AppColors.accentBorder),
                  ),
                  child: Text(
                    '+${pack.totalXp} XP',
                    style: AppType.value.copyWith(color: AppColors.accent),
                  ),
                ),
              ],
            ),
          ),

          // Template list preview
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Pad.card),
            child: Column(
              children: pack.templates
                  .map((t) => _TemplateRow(template: t))
                  .toList(),
            ),
          ),

          // Divider
          Divider(color: AppColors.border, height: 1),

          // Import button
          Padding(
            padding: const EdgeInsets.all(Pad.card),
            child: GestureDetector(
              onTap: busy ? null : onImport,
              child: AnimatedContainer(
                duration: Motion.state,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: imported ? AppColors.accentSurface : AppColors.accent,
                  borderRadius: BorderRadius.circular(Radii.button),
                  border: imported
                      ? Border.all(color: AppColors.accentBorder)
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  imported ? '✓ Added to board' : 'Add to board',
                  style: imported
                      ? AppType.buttonPrimary.copyWith(color: AppColors.accent)
                      : AppType.buttonPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TemplateRow extends StatelessWidget {
  const _TemplateRow({required this.template});
  final QuestTemplate template;

  @override
  Widget build(BuildContext context) {
    final diffColor = AppColors.difficulty[template.difficulty.index];
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.xs),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceIcon,
              borderRadius: BorderRadius.circular(Radii.iconTile),
            ),
            child: Text(
              template.code,
              style: AppType.code.copyWith(color: diffColor, fontSize: 9),
            ),
          ),
          const SizedBox(width: Gap.sm),
          Expanded(child: Text(template.name, style: AppType.bodySmall)),
          Text(
            template.time,
            style: AppType.metaLabel.copyWith(color: AppColors.faint),
          ),
        ],
      ),
    );
  }
}

class _Toast extends StatelessWidget {
  const _Toast({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 100,
      left: 24,
      right: 24,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Gap.lg,
            vertical: Gap.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.sheetTop,
            borderRadius: BorderRadius.circular(Radii.card),
            border: Border.all(color: AppColors.accentBorder),
          ),
          child: Text(
            message,
            style: AppType.body.copyWith(color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

/// Shows the [QuestTemplatesSheet] as a glass modal bottom sheet.
Future<void> showQuestTemplatesSheet(BuildContext context) {
  return showGlassSheet(context, builder: (_) => const QuestTemplatesSheet());
}
