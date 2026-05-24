import 'package:flutter/material.dart';

// ── Provider enum ─────────────────────────────────────────────────────────────

enum SocialProvider { google, apple, facebook }

// ── Horizontal row of 3 social buttons ───────────────────────────────────────

/// Three compact icon+label buttons (Google, Apple, Facebook) in a row.
class SocialAuthRow extends StatelessWidget {
  const SocialAuthRow({
    super.key,
    required this.onGoogle,
    required this.onApple,
    required this.onFacebook,
  });

  final VoidCallback onGoogle;
  final VoidCallback onApple;
  final VoidCallback onFacebook;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SocialBtn(
            provider: SocialProvider.google,
            onPressed: onGoogle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SocialBtn(provider: SocialProvider.apple, onPressed: onApple),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SocialBtn(
            provider: SocialProvider.facebook,
            onPressed: onFacebook,
          ),
        ),
      ],
    );
  }
}

// ── Individual compact button ─────────────────────────────────────────────────

class _SocialBtn extends StatelessWidget {
  const _SocialBtn({required this.provider, required this.onPressed});

  final SocialProvider provider;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: BorderSide(
          color: isDark
              ? Colors.white.withAlpha(28)
              : Colors.black.withAlpha(18),
        ),
        backgroundColor: isDark
            ? Colors.white.withAlpha(8)
            : const Color(0xFFF7F8F9),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _ProviderLogo(provider: provider, isDark: isDark),
          const SizedBox(width: 8),
          Text(
            _shortName,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : const Color(0xFF444444),
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  String get _shortName => switch (provider) {
    SocialProvider.google => 'Google',
    SocialProvider.apple => 'Apple',
    SocialProvider.facebook => 'Facebook',
  };
}

// ── Provider logos ────────────────────────────────────────────────────────────

class _ProviderLogo extends StatelessWidget {
  const _ProviderLogo({required this.provider, required this.isDark});

  final SocialProvider provider;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    switch (provider) {
      case SocialProvider.google:
        return const _GoogleLogo();
      case SocialProvider.apple:
        return Icon(
          Icons.apple,
          size: 26,
          color: isDark ? Colors.white : Colors.black87,
        );
      case SocialProvider.facebook:
        return const _FacebookLogo();
    }
  }
}

/// Google "G" logo rendered via CustomPainter — 4-colour ring + horizontal bar.
class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(painter: _GoogleGPainter()),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double outerR = size.width * 0.45;
    final double innerR = size.width * 0.27;
    final double strokeW = outerR - innerR;
    final Offset center = Offset(cx, cy);
    final double midR = (outerR + innerR) / 2;
    final Rect arcRect = Rect.fromCircle(center: center, radius: midR);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.butt;

    // Blue arc  (right → top-right)  ~−10° to ~88°
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(arcRect, -0.18, 1.72, false, paint);

    // Red arc   (top-left)            ~88° to ~188°
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(arcRect, 1.54, 1.75, false, paint);

    // Yellow arc (bottom-left)         ~188° to ~278°
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(arcRect, 3.29, 1.57, false, paint);

    // Green arc  (bottom-right)        ~278° to ~350°
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(arcRect, 4.86, 1.26, false, paint);

    // Horizontal bar of the G (blue)
    final double barH = strokeW * 0.86;
    canvas.drawRect(
      Rect.fromLTRB(
        cx - strokeW * 0.12,
        cy - barH / 2,
        cx + outerR + strokeW * 0.05,
        cy + barH / 2,
      ),
      Paint()..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Facebook "f" on a blue rounded square.
class _FacebookLogo extends StatelessWidget {
  const _FacebookLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: const Color(0xFF1877F2),
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: const Text(
        'f',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w900,
          height: 1.15,
        ),
      ),
    );
  }
}

// ── Divider ───────────────────────────────────────────────────────────────────

/// Horizontal "or continue with email" divider.
class SocialAuthDivider extends StatelessWidget {
  const SocialAuthDivider({super.key, this.label = 'or continue with email'});

  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(child: Divider(color: cs.outlineVariant)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            label,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: cs.outlineVariant)),
      ],
    );
  }
}

// ── Legacy single-button (kept for backward compatibility) ────────────────────

class SocialAuthButton extends StatelessWidget {
  const SocialAuthButton({
    super.key,
    required this.label,
    required this.provider,
    required this.onPressed,
  });

  final String label;
  final SocialProvider provider;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? Colors.white : Colors.black87,
          side: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: isDark
              ? Colors.white.withAlpha(8)
              : const Color(0xFFF7F8F9),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ProviderLogo(provider: provider, isDark: isDark),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
