import 'package:flutter/material.dart';
import 'package:karafarini/core/theme/app_Theme.dart';

/// انتخاب ماه — گرید ۱۲ ماه شمسی
class MonthPickerSection extends StatelessWidget {
  final int selectedMonth; // 1..12
  final ValueChanged<int> onMonthSelected;

  const MonthPickerSection({
    super.key,
    required this.selectedMonth,
    required this.onMonthSelected,
  });

  static const List<String> months = [
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'مرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند',
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.6,
      ),
      itemCount: months.length,
      itemBuilder: (context, index) {
        final monthNumber = index + 1;
        final isSelected = monthNumber == selectedMonth;

        return GestureDetector(
          onTap: () => onMonthSelected(monthNumber),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primary : AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppTheme.primary : AppTheme.surface,
                width: 1.5,
              ),
            ),
            child: Text(
              months[index],
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppTheme.textPrimary,
              ),
            ),
          ),
        );
      },
    );
  }
}
