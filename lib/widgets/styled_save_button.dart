import 'package:flutter/material.dart';
import 'package:karafarini/core/theme/AppTheme.dart';

class StyledSaveButton extends StatelessWidget {
  final VoidCallback onSave;
  final String label;

  const StyledSaveButton({
    super.key,
    required this.onSave,
    this.label = 'ذخیره اطلاعات',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: const Icon(Icons.save_alt_rounded, size: 20),
        label: Text(
          label,
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
