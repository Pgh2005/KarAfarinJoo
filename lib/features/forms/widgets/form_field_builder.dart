import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:karafarini/core/theme/app_theme.dart';

class FormBuilder {
  static InputDecoration inputDecoration({
    required String label,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool enabled = true,
    String? errorText,
    bool isDense = false,
    EdgeInsetsGeometry? contentPadding,
    double borderRadius = 18,
    Color? fillColor,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      labelStyle: TextStyle(
        color: enabled
            ? AppTheme.textSecondary
            : AppTheme.textSecondary.withValues(alpha: 0.6),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: const TextStyle(color: AppTheme.textHint, fontSize: 13),
      errorText: errorText,
      filled: true,
      fillColor: fillColor ?? AppTheme.cardBg,
      isDense: isDense,
      contentPadding:
          contentPadding ??
          EdgeInsets.symmetric(
            horizontal: isDense ? 14 : 18,
            vertical: isDense ? 12 : 16,
          ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: AppTheme.border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: AppTheme.border, width: 1),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(
          color: AppTheme.border.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: AppTheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: Colors.red[400]!, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: Colors.red[700]!, width: 2),
      ),
      prefixIconColor: enabled ? AppTheme.primary : AppTheme.textHint,
      suffixIconColor: enabled ? AppTheme.primary : AppTheme.textHint,
    );
  }

  static Widget buildTextField(
    String label,
    String value,
    ValueChanged<String>? onChanged, {
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool enabled = true,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? hintText,
    String? errorText,
    bool isDense = false,
    EdgeInsetsGeometry? contentPadding,
    TextAlign textAlign = TextAlign.start,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
    double borderRadius = 18,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: AppTheme.cardShadow,
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          initialValue: controller == null ? value : null,
          onChanged: enabled ? onChanged : null,
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: enabled,
          readOnly: readOnly,
          inputFormatters: inputFormatters,
          textAlign: textAlign,
          cursorColor: AppTheme.primary,
          decoration: inputDecoration(
            label: label,
            hintText: hintText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            enabled: enabled,
            errorText: errorText,
            isDense: isDense,
            contentPadding: contentPadding,
            borderRadius: borderRadius,
          ),
        ),
      ),
    );
  }

  static Widget buildDropdown<T>(
    String label,
    T value,
    List<DropdownMenuItem<T>> items,
    ValueChanged<T?>? onChanged, {
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        dropdownColor: AppTheme.cardBg,
        decoration: inputDecoration(
          label: label,
          enabled: enabled,
          borderRadius: 16,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
        items: items,
        onChanged: enabled ? onChanged : null,
      ),
    );
  }

  static Widget buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
