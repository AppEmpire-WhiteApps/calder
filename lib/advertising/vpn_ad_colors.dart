import 'package:flutter/material.dart';

/// Advertising uses the same semantic colors as the surrounding app.
class VpnAdColors {
  VpnAdColors(ThemeData theme)
    : background = theme.scaffoldBackgroundColor,
      surface = theme.colorScheme.surface,
      primary = theme.colorScheme.primary,
      onPrimary = theme.colorScheme.onPrimary,
      text = theme.colorScheme.onSurface,
      textSecondary = theme.colorScheme.onSurfaceVariant,
      outline = theme.colorScheme.outline.withValues(alpha: 0.5),
      shadow = theme.colorScheme.shadow.withValues(alpha: 0.35);

  final Color background;
  final Color surface;
  final Color primary;
  final Color onPrimary;
  final Color text;
  final Color textSecondary;
  final Color outline;
  final Color shadow;

  Color get accentSurface =>
      Color.alphaBlend(primary.withValues(alpha: 0.1), surface);

  Color get iconSurface =>
      Color.alphaBlend(primary.withValues(alpha: 0.12), surface);

  Color get shimmer => primary.withValues(alpha: 0.08);

  List<Color> get cardGradient => [surface, accentSurface, surface, background];

  List<Color> get fullscreenGradient => [background, surface, accentSurface];
}
