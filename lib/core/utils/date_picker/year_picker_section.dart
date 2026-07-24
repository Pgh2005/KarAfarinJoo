import 'package:flutter/material.dart';
import 'package:karafarini/core/theme/app_Theme.dart';

/// انتخاب سال — لیست افقی، سال جاری ± ۵ سال
class YearPickerSection extends StatelessWidget {
  final int selectedYear;
  final int currentYear;
  final ValueChanged<int> onYearSelected;

  const YearPickerSection({
    super.key,
    required this.selectedYear,
    required this.currentYear,
    required this.onYearSelected,
  });

  @override
  Widget build(BuildContext context) {
    final years = List.generate(11, (i) => currentYear - 5 + i);

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: years.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final year = years[index];
          final isSelected = year == selectedYear;

          return GestureDetector(
            onTap: () => onYearSelected(year),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppTheme.primary : AppTheme.surface,
                  width: 1.5,
                ),
              ),
              child: Text(
                '$year',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
