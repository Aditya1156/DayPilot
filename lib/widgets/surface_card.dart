import 'package:flutter/material.dart';

/// A lightweight animated surface card used across the app to provide
/// a consistent elevated, textured look with smooth implicit animations.
class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry borderRadius;
  final Gradient? gradient;
  final double elevation;
  final VoidCallback? onTap;

  const SurfaceCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
    this.gradient,
    this.elevation = 8,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Prefer surfaceContainerHighest for Material 3 surface layering
    final Color top = theme.colorScheme.surfaceContainerHighest;
    final Color bottom = theme.colorScheme.surface;
    final Gradient defaultGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        top,
        bottom,
      ],
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: gradient ?? defaultGradient,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withAlpha(35),
            blurRadius: elevation,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: theme.dividerColor.withAlpha(15),
          width: 0.6,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
