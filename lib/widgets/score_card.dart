import 'package:flutter/material.dart';
import 'package:karafarini/core/theme/app_theme.dart';

class ScoreCard extends StatelessWidget {
  final String name;
  final double score;
  final double percent;
  final double maxScore;
  final bool isWinner;
  final String winnerLabel;

  const ScoreCard({
    super.key,
    required this.name,
    required this.score,
    required this.percent,
    required this.maxScore,
    required this.isWinner,
    this.winnerLabel = 'این گزینه بالاترین امتیاز را دارد',
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isWinner
            ? AppTheme.primary.withValues(alpha: 0.07)
            : AppTheme.divider,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWinner ? AppTheme.primary : AppTheme.border,
          width: isWinner ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (isWinner)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.emoji_events_rounded,
                    color: Color(0xFFF59E0B),
                    size: 20,
                  ),
                ),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isWinner ? AppTheme.primary : AppTheme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isWinner ? AppTheme.primary : AppTheme.textHint,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${percent.toStringAsFixed(1)}٪',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: maxScore > 0 ? (score / maxScore).clamp(0.0, 1.0) : 0,
              minHeight: 8,
              backgroundColor: AppTheme.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                isWinner ? AppTheme.primary : AppTheme.textHint,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'امتیاز: ${score.toStringAsFixed(1)} از ${maxScore.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          if (isWinner) ...[
            const SizedBox(height: 6),
            Text(
              '✓ $winnerLabel',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
