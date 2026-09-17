import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/widgets/glass_sheet.dart';
import '../application/sync_controller.dart';
import '../domain/sync_models.dart';

/// Opens the cloud sync sheet from the Profile settings list.
void showCloudSyncSheet(BuildContext context) {
  showGlassSheet(context, builder: (_) => const _CloudSyncSheet());
}

class _CloudSyncSheet extends ConsumerStatefulWidget {
  const _CloudSyncSheet();

  @override
  ConsumerState<_CloudSyncSheet> createState() => _CloudSyncSheetState();
}

class _CloudSyncSheetState extends ConsumerState<_CloudSyncSheet> {
  late final TextEditingController _endpoint;
  late final TextEditingController _projectId;
  late final TextEditingController _databaseId;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  bool _codeSent = false;
  bool _busy = false;
  String _email = '';

  @override
  void initState() {
    super.initState();
    final config = ref.read(cloudConfigProvider);
    _endpoint = TextEditingController(text: config.endpoint ?? defaultEndpoint);
    _projectId = TextEditingController(text: config.projectId ?? '');
    _databaseId = TextEditingController(
      text: config.databaseId ?? defaultDatabaseId,
    );
  }

  @override
  void dispose() {
    _endpoint.dispose();
    _projectId.dispose();
    _databaseId.dispose();
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status =
        ref.watch(syncProvider).valueOrNull ?? const CloudSyncStatus();

    return GlassSheet(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('CLOUD SYNC', style: AppType.eyebrow),
            const SizedBox(height: Gap.sm),
            Text(
              'Your quests and progress, safe in the cloud.',
              style: AppType.body,
            ),

            const SizedBox(height: Gap.lg),

            // Status card
            _StatusCard(status: status),

            const SizedBox(height: Gap.lg),

            if (status.state == CloudConnectionState.disconnected ||
                status.state == CloudConnectionState.error) ...[
              Text('APPWRITE PROJECT', style: AppType.eyebrow),
              const SizedBox(height: Gap.sm),
              _Field(
                controller: _endpoint,
                label: 'ENDPOINT',
                hint: defaultEndpoint,
              ),
              const SizedBox(height: Gap.md),
              _Field(
                controller: _projectId,
                label: 'PROJECT ID',
                hint: 'Paste from the Appwrite console',
              ),
              const SizedBox(height: Gap.md),
              _Field(
                controller: _databaseId,
                label: 'DATABASE ID',
                hint: defaultDatabaseId,
              ),
              const SizedBox(height: Gap.lg),
              _PrimaryButton(
                label: _busy ? 'Connecting…' : 'Connect',
                enabled: !_busy && _projectId.text.trim().isNotEmpty,
                onTap: _connect,
              ),
              const SizedBox(height: Gap.md),
              Text(
                'Creates a private anonymous workspace for this device. Add '
                'an email below to carry your adventure across devices.',
                style: AppType.bodySmall.copyWith(color: AppColors.muted),
              ),
            ] else ...[
              _PrimaryButton(
                label: _busy ? 'Working…' : 'Sync now',
                enabled: !_busy,
                onTap: _syncNow,
              ),
              const SizedBox(height: Gap.sm),
              _SecondaryButton(
                label: 'Disconnect',
                onTap: _busy ? null : _disconnect,
              ),
            ],

            if (status.errorMessage != null) ...[
              const SizedBox(height: Gap.md),
              Text(
                status.errorMessage!,
                style: AppType.bodySmall.copyWith(
                  color: AppColors.difficultyEpic,
                ),
              ),
            ],

            const SizedBox(height: Gap.xl),
            Divider(color: AppColors.borderHairline, height: 1),
            const SizedBox(height: Gap.lg),

            // Email sign-in / linking — makes the workspace portable.
            if (status.accountEmail != null) ...[
              Text('SIGNED IN', style: AppType.eyebrow),
              const SizedBox(height: Gap.sm),
              Text(status.accountEmail!, style: AppType.cardTitle),
              const SizedBox(height: Gap.sm),
              Text(
                'Your adventure follows this account on every device.',
                style: AppType.bodySmall.copyWith(color: AppColors.muted),
              ),
            ] else if (_codeSent) ...[
              Text('CHECK YOUR INBOX', style: AppType.eyebrow),
              const SizedBox(height: Gap.sm),
              Text(
                'We sent a 6-digit code to $_email. Enter it to link this '
                'device — your quests come with you.',
                style: AppType.body,
              ),
              const SizedBox(height: Gap.md),
              _Field(
                controller: _codeController,
                label: 'CODE',
                hint: '123456',
              ),
              const SizedBox(height: Gap.lg),
              _PrimaryButton(
                label: _busy ? 'Linking…' : 'Verify & link',
                enabled: !_busy && _codeController.text.trim().isNotEmpty,
                onTap: _verifyCode,
              ),
            ] else ...[
              Text('CARRY YOUR ADVENTURE', style: AppType.eyebrow),
              const SizedBox(height: Gap.sm),
              Text(
                'Add your email and we will send a one-time code. Link this '
                'device to that account — no password, ever.',
                style: AppType.bodySmall.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: Gap.md),
              _Field(
                controller: _emailController,
                label: 'EMAIL',
                hint: 'you@example.com',
              ),
              const SizedBox(height: Gap.lg),
              _PrimaryButton(
                label: _busy ? 'Sending…' : 'Email me a code',
                enabled: !_busy && _emailController.text.trim().isNotEmpty,
                onTap: _sendCode,
              ),
            ],

            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  Future<void> _connect() async {
    AppHaptics.selection();
    setState(() => _busy = true);
    await ref
        .read(cloudConfigProvider)
        .save(
          endpoint: _endpoint.text.trim(),
          projectId: _projectId.text.trim(),
          databaseId: _databaseId.text.trim(),
        );
    await ref.read(syncProvider.notifier).connect();
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _syncNow() async {
    AppHaptics.selection();
    setState(() => _busy = true);
    await ref.read(syncProvider.notifier).flushQueued();
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _disconnect() async {
    AppHaptics.selection();
    setState(() => _busy = true);
    await ref.read(syncProvider.notifier).disconnect();
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _sendCode() async {
    AppHaptics.selection();
    final email = _emailController.text.trim();
    if (email.isEmpty) return;
    setState(() {
      _busy = true;
      _email = email;
    });
    try {
      await ref.read(syncProvider.notifier).sendSignInCode(email: email);
      if (mounted) setState(() => _codeSent = true);
    } catch (_) {
      // Error state is surfaced by the sheet via the status.
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verifyCode() async {
    AppHaptics.selection();
    final code = _codeController.text.trim();
    if (code.isEmpty) return;
    setState(() => _busy = true);
    try {
      await ref.read(syncProvider.notifier).signInWithCode(code: code);
      await ref
          .read(syncProvider.notifier)
          .rememberAccountEmail(_emailController.text.trim());
      if (mounted) setState(() => _codeSent = false);
    } catch (_) {
      // Error state is surfaced by the sheet via the status.
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.status});

  final CloudSyncStatus status;

  @override
  Widget build(BuildContext context) {
    final ok = status.state == CloudConnectionState.connected;
    final attention =
        status.state == CloudConnectionState.error || status.pendingCount > 0;
    final dot = ok
        ? AppColors.accent
        : attention
        ? AppColors.difficultyEpic
        : AppColors.slate;
    return Container(
      padding: const EdgeInsets.all(Pad.card),
      decoration: BoxDecoration(
        color: ok ? AppColors.accentSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(Radii.trailCard),
        border: Border.all(
          color: ok ? AppColors.accentBorder : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(shape: BoxShape.circle, color: dot),
          ),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  switch (status.state) {
                    CloudConnectionState.disconnected => 'Not connected',
                    CloudConnectionState.connecting => 'Linking…',
                    CloudConnectionState.connected => 'Connected',
                    CloudConnectionState.syncing => 'Syncing…',
                    CloudConnectionState.error => 'Needs attention',
                  },
                  style: AppType.cardTitle.copyWith(
                    color: ok ? AppColors.accent : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(switch (status.state) {
                  CloudConnectionState.disconnected =>
                    'Local only. Nothing leaves this device.',
                  CloudConnectionState.connecting =>
                    'Creating your private workspace…',
                  CloudConnectionState.connected =>
                    status.lastSyncedAt == null
                        ? 'Connected. No sync yet.'
                        : 'Last sync '
                              '${_clock(status.lastSyncedAt!)}',
                  CloudConnectionState.syncing =>
                    '${status.pendingCount} change(s) in flight…',
                  CloudConnectionState.error => 'Will retry automatically.',
                }, style: AppType.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _clock(DateTime at) =>
      '${at.hour.toString().padLeft(2, '0')}:'
      '${at.minute.toString().padLeft(2, '0')}';
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
  });

  final TextEditingController controller;
  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppType.microLabel),
        const SizedBox(height: Gap.xs),
        TextField(
          controller: controller,
          style: AppType.body.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}

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
        padding: const EdgeInsets.symmetric(vertical: 14),
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

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Radii.buttonLarge),
          border: Border.all(color: AppColors.borderStrong),
        ),
        child: Text(label, style: AppType.buttonSecondary),
      ),
    );
  }
}
