import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/auth_state.dart';
import '../providers/auth_provider.dart';

class MfaChallengeScreen extends ConsumerStatefulWidget {
  const MfaChallengeScreen({
    super.key,
    required this.challengeToken,
    required this.email,
  });

  final String challengeToken;
  final String email;

  @override
  ConsumerState<MfaChallengeScreen> createState() => _MfaChallengeScreenState();
}

class _MfaChallengeScreenState extends ConsumerState<MfaChallengeScreen> {
  final _totpCtrl = TextEditingController();
  final _recoveryCtrl = TextEditingController();

  bool _loading = false;
  int _attempts = 0;
  bool _locked = false;

  // Countdown timer
  Timer? _timer;
  int _secondsLeft = 30;

  static const int _maxAttempts = 5;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsLeft = 30 - (DateTime.now().second % 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final secs = 30 - (DateTime.now().second % 30);
      setState(() => _secondsLeft = secs == 0 ? 30 : secs);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _totpCtrl.dispose();
    _recoveryCtrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_locked) return;

    final totp = _totpCtrl.text.trim();
    if (totp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a 6-digit code.')),
      );
      return;
    }

    setState(() => _loading = true);
    await ref.read(authProvider.notifier).completeMfa(
          challengeToken: widget.challengeToken,
          totp: totp,
        );
    if (!mounted) return;
    setState(() => _loading = false);

    final authState = ref.read(authProvider).value;
    if (authState is AuthAuthenticated) {
      context.go(AppRoutes.dashboard);
    } else if (authState is AuthError) {
      final newAttempts = _attempts + 1;
      setState(() {
        _attempts = newAttempts;
        _locked = newAttempts >= _maxAttempts;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _locked
                ? 'Too many failed attempts. Please use a recovery code or contact support.'
                : '${authState.message} (${_maxAttempts - newAttempts} attempts left)',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      _totpCtrl.clear();
    }
  }

  void _showRecoveryCodeDialog() {
    _recoveryCtrl.clear();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Use Recovery Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter one of your backup recovery codes to sign in without your authenticator app.',
              style: Theme.of(ctx).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _recoveryCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Recovery Code',
                hintText: 'XXXX-XXXX-XXXX',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final code = _recoveryCtrl.text.trim();
              Navigator.of(ctx).pop();
              if (code.isEmpty) return;
              // Mock: accept any non-empty recovery code
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Recovery code accepted. Signing you in…'),
                  backgroundColor: AppColors.success,
                ),
              );
              Future.delayed(const Duration(milliseconds: 800), () {
                if (mounted) context.go(AppRoutes.dashboard);
              });
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final timerFraction = _secondsLeft / 30;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Two-Factor Authentication'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                'Enter verification code',
                style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Open your authenticator app and enter the 6-digit code for\n${widget.email}',
                style: tt.bodyMedium,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _totpCtrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                autofocus: true,
                textAlign: TextAlign.center,
                enabled: !_locked,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Authentication Code',
                  hintText: '000000',
                  counterText: '',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _verify(),
              ),
              const SizedBox(height: 16),

              // Countdown indicator
              if (!_locked)
                Row(
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        value: timerFraction,
                        strokeWidth: 3,
                        color: _secondsLeft <= 5
                            ? AppColors.error
                            : AppColors.primary,
                        backgroundColor: cs.outlineVariant,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Code refreshes in ${_secondsLeft}s',
                      style: tt.bodySmall?.copyWith(
                        color: _secondsLeft <= 5
                            ? AppColors.error
                            : cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),

              // Lockout banner
              if (_locked) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline, color: AppColors.error),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Account temporarily locked after $_maxAttempts failed attempts.',
                          style: tt.bodySmall?.copyWith(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: (_loading || _locked) ? null : _verify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text('Verify', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),

              // Recovery code link
              Center(
                child: TextButton.icon(
                  onPressed: _showRecoveryCodeDialog,
                  icon: const Icon(Icons.vpn_key_outlined, size: 16),
                  label: const Text("Can't access your authenticator?"),
                  style: TextButton.styleFrom(
                    foregroundColor: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
