import 'package:flutter/material.dart';
import 'package:karafarini/core/theme/app_theme.dart';
import 'package:karafarini/core/widgets/loading_indicator.dart';

class StyledSaveButton extends StatelessWidget {
  final VoidCallback onSave;
  final String label;
  final bool isLoading;

  const StyledSaveButton({
    super.key,
    required this.onSave,
    this.label = 'ذخیره اطلاعات',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: isLoading
            ? const AppLoadingIndicator(size: 20, strokeWidth: 2, color: Colors.white)
            : const Icon(Icons.save_alt_rounded, size: 20),
        label: Text(
          isLoading ? 'در حال ذخیره...' : label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
