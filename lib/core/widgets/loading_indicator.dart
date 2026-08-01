import 'package:flutter/material.dart';

class AppLoadingIndicator extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color? color;
  final Color? trackColor;

  const AppLoadingIndicator({
    super.key,
    this.size = 36,
    this.strokeWidth = 4.5,
    this.color,
    this.trackColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = color ?? theme.colorScheme.primary;
    final backgroundColor = trackColor ?? activeColor.withValues(alpha: 0.18);

    return SizedBox.square(
      dimension: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        color: activeColor,
        backgroundColor: backgroundColor,
      ),
    );
  }
}
