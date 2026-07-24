import 'package:flutter/material.dart';
import 'package:karafarini/core/theme/app_theme.dart';

class FormBuilder {
  static Widget buildTextField(
    String label,
    String value,
    ValueChanged<String>? onChanged, {
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        initialValue: controller == null ? value : null,
        onChanged: enabled ? onChanged : null,
        keyboardType: keyboardType,
        maxLines: maxLines,
        enabled: enabled,
        cursorColor: AppTheme.primary,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: enabled
                ? AppTheme.textSecondary
                : AppTheme.textSecondary.withValues(alpha: 0.6),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppTheme.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
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
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: enabled
                ? AppTheme.textSecondary
                : AppTheme.textSecondary.withValues(alpha: 0.6),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppTheme.primary, width: 2),
          ),
          enabled: enabled,
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

// ----------

// import 'package:flutter/material.dart';
// import 'package:karafarini/core/theme/app_theme.dart';

// class FormBuilder {
//   static Widget buildTextField(
//     String label,
//     String value,
//     ValueChanged<String> onChanged, {
//     TextInputType keyboardType = TextInputType.text,
//     int maxLines = 1,
//     bool enabled = true,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 14),
//       child: TextFormField(
//         initialValue: value,
//         onChanged: onChanged,
//         keyboardType: keyboardType,
//         maxLines: maxLines,
//         enabled: enabled,
//         cursorColor: AppTheme.primary,
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: const TextStyle(color: AppTheme.textSecondary),
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: const BorderSide(color: AppTheme.primary, width: 2),
//           ),
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 14,
//             vertical: 12,
//           ),
//         ),
//       ),
//     );
//   }

//   static Widget buildDropdown<T>(
//     String label,
//     T value,
//     List<DropdownMenuItem<T>> items,
//     ValueChanged<T?>? onChanged, {
//     bool enabled = true,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 14),
//       child: DropdownButtonFormField<T>(
//         initialValue: value,
//         dropdownColor: AppTheme.cardBg,
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: TextStyle(
//             color: enabled
//                 ? AppTheme.textSecondary
//                 : AppTheme.textSecondary.withValues(alpha: 0.6),
//           ),
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 14,
//             vertical: 12,
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(10),
//             borderSide: const BorderSide(color: AppTheme.primary, width: 2),
//           ),
//           enabled: enabled,
//         ),
//         items: items,
//         onChanged: enabled ? onChanged : null,
//       ),
//     );
//   }

//   static Widget buildSectionHeader(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 16, bottom: 12),
//       child: Text(
//         title,
//         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//       ),
//     );
//   }
// }
