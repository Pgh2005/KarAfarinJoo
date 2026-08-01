import 'package:flutter/material.dart';
import 'package:karafarini/core/theme/app_theme.dart';
import 'package:karafarini/core/widgets/loading_indicator.dart';

class SaveButton extends StatelessWidget {
  final VoidCallback onSave;
  final bool isLoading;
  final bool isEnabled;

  const SaveButton({
    super.key,
    required this.onSave,
    this.isLoading = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        onPressed: isEnabled && !isLoading ? onSave : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18),
        ),
        label: Text(
          isLoading ? 'در حال ذخیره...' : 'ذخیره اطلاعات',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        icon: isLoading
            ? const AppLoadingIndicator(
                size: 20,
                strokeWidth: 2,
                color: Colors.white,
              )
            : const Icon(Icons.save_alt_rounded, size: 20),
      ),
    );
  }
}
