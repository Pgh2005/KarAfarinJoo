import 'package:flutter/material.dart';
import 'package:karafarini/core/theme/AppTheme.dart';

class InfoHintBox extends StatelessWidget {
  final String text;

  const InfoHintBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppTheme.primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.primaryDark,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
