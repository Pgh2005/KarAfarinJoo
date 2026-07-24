import 'package:flutter/material.dart';
import 'package:karafarini/core/theme/app_Theme.dart';

/// انتخاب روز — گرید روزها بر اساس طول ماه انتخاب‌شده
class DayPickerSection extends StatelessWidget {
  final int selectedDay;
  final int daysInMonth;
  final ValueChanged<int> onDaySelected;

  const DayPickerSection({
    super.key,
    required this.selectedDay,
    required this.daysInMonth,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: daysInMonth,
      itemBuilder: (context, index) {
        final day = index + 1;
        final isSelected = day == selectedDay;

        return GestureDetector(
          onTap: () => onDaySelected(day),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primary : AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppTheme.primary : AppTheme.surface,
                width: 1.5,
              ),
            ),
            child: Text(
              '$day',
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
