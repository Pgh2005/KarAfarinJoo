import 'package:flutter/material.dart';
import 'package:karafarini/core/theme/app_theme.dart';

/// A themed progress bar widget that shows fill percentage.
/// Wrapped in a subtle gradient container for form pages.
class FormProgressBar extends StatelessWidget {
  final double percent;
  final double height;
  final bool showLabel;
  final bool compact;
  final String? label;

  const FormProgressBar({
    super.key,
    required this.percent,
    this.height = 8,
    this.showLabel = true,
    this.compact = false,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = percent.clamp(0.0, 100.0);
    final color = _progressColor(clamped);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.06),
            AppTheme.cardBg,
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLabel)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label ?? 'پیشرفت فرم',
                    style: TextStyle(
                      fontSize: compact ? 11 : 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${clamped.round()}%',
                      style: TextStyle(
                        fontSize: compact ? 11 : 13,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ClipRRect(
            borderRadius: BorderRadius.circular(height / 2 + 1),
            child: SizedBox(
              height: height,
              child: Stack(
                children: [
                  // Background
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.divider,
                      borderRadius: BorderRadius.circular(height / 2),
                    ),
                  ),
                  // Filled portion with gradient
                  AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    widthFactor: clamped / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color.withValues(alpha: 0.7),
                            color,
                          ],
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                        ),
                        borderRadius: BorderRadius.circular(height / 2),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _progressColor(double percent) {
    if (percent >= 100) return AppTheme.success;
    if (percent >= 60) return AppTheme.primary;
    if (percent >= 30) return AppTheme.warning;
    return const Color(0xFFEF4444); // red for low progress
  }
}

/// A compact circular progress indicator for the form list.
class FormCircularProgress extends StatelessWidget {
  final double percent;
  final double size;

  const FormCircularProgress({
    super.key,
    required this.percent,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = percent.clamp(0.0, 100.0);
    final color = _progressColor(clamped);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 4,
              color: AppTheme.divider,
            ),
          ),
          // Progress circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: clamped / 100,
              strokeWidth: 4,
              color: color,
              strokeCap: StrokeCap.round,
            ),
          ),
          // Percentage text
          Text(
            '${clamped.round()}',
            style: TextStyle(
              fontSize: size * 0.25,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _progressColor(double percent) {
    if (percent >= 100) return AppTheme.success;
    if (percent >= 60) return AppTheme.primary;
    if (percent >= 30) return AppTheme.warning;
    return const Color(0xFFEF4444);
  }
}
