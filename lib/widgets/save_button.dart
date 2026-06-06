import 'package:flutter/material.dart';
import 'package:karafarini/core/theme/AppTheme.dart';

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
      height: 52,
      child: ElevatedButton.icon(
        onPressed: isEnabled && !isLoading ? onSave : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),

        label: Text(
          isLoading ? 'در حال ذخیره...' : 'ذخیره اطلاعات',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),

        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.save_alt_rounded, size: 20),
      ),
    );
  }
}
