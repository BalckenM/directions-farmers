import 'package:flutter/material.dart';

/// Circular avatar that shows a network image when [imageUrl] is provided,
/// falling back to a coloured circle with initials.
class AvatarWidget extends StatelessWidget {
  const AvatarWidget({
    super.key,
    this.imageUrl,
    required this.initials,
    this.radius = 20,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String? imageUrl;
  final String initials;
  final double radius;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = backgroundColor ?? cs.primaryContainer;
    final fg = foregroundColor ?? cs.onPrimaryContainer;
    final size = radius * 2;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return SizedBox(
        width: size,
        height: size,
        child: ClipOval(
          child: Image.network(
            imageUrl!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                _Initials(initials: initials, fg: fg, bg: bg, radius: radius),
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return _Initials(initials: initials, fg: fg, bg: bg, radius: radius);
            },
          ),
        ),
      );
    }

    return _Initials(initials: initials, fg: fg, bg: bg, radius: radius);
  }
}

class _Initials extends StatelessWidget {
  const _Initials({
    required this.initials,
    required this.fg,
    required this.bg,
    required this.radius,
  });

  final String initials;
  final Color fg;
  final Color bg;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      child: Text(
        initials.length > 2 ? initials.substring(0, 2) : initials,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.7,
        ),
      ),
    );
  }
}
