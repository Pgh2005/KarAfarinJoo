import 'package:flutter/foundation.dart' show kIsWeb;

/// Whether the app is running on the web platform.
const bool isWeb = kIsWeb;

/// Breakpoint constants for responsive layouts.
class Breakpoints {
  Breakpoints._();

  /// Mobile: up to 600px
  static const double mobile = 600;

  /// Tablet: 600px – 1024px
  static const double tablet = 1024;

  /// Desktop: 1024px+
  static const double desktop = 1200;

  /// Maximum content width on web for a centered layout.
  static const double maxContentWidth = 900;
}
