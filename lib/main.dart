import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karafarini/core/router/app_route.dart';
import 'package:karafarini/core/theme/app_theme.dart';
import 'package:karafarini/core/utils/platform_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Web-specific: set system UI overlay for web
  if (isWeb) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        themeMode: ThemeMode.light,
        routerConfig: appRouter,
        builder: (context, child) => _ResponsiveBuilder(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          ),
        ),
      ),
    );
  }
}

/// Wraps the app with web-specific responsive behavior.
class _ResponsiveBuilder extends StatelessWidget {
  final Widget child;

  const _ResponsiveBuilder({required this.child});

  @override
  Widget build(BuildContext context) {
    if (!isWeb) return child;

    final width = MediaQuery.sizeOf(context).width;
    final isWideScreen = width > Breakpoints.maxContentWidth;

    // On wide web screens, add a subtle background
    if (isWideScreen) {
      return ColoredBox(
        color: const Color(0xFFF0F2F5),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: Breakpoints.maxContentWidth,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.zero,
              child: child,
            ),
          ),
        ),
      );
    }

    return child;
  }
}
