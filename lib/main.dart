import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app_state.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final appState = AppState();
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    final lightColorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2563EB),
      brightness: Brightness.light,
    );

    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF60A5FA),
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: 'کارآفرین جو',
      debugShowCheckedModeBanner: false,
      locale: const Locale('fa', 'IR'),
      supportedLocales: const [Locale('fa', 'IR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      // theme: ThemeData(
      //   useMaterial3: true,
      //   colorScheme: lightColorScheme,
      //   fontFamily: 'sans-serif',
      //   appBarTheme: AppBarTheme(
      //     backgroundColor: lightColorScheme.primary,
      //     foregroundColor: Colors.white,
      //     elevation: 4,
      //     centerTitle: true,
      //   ),
      //   cardTheme: CardTheme(
      //     elevation: 3,
      //     shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(12),
      //     ),
      //   ),
      //   elevatedButtonTheme: ElevatedButtonThemeData(
      //     style: ElevatedButton.styleFrom(
      //       padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      //       shape: RoundedRectangleBorder(
      //         borderRadius: BorderRadius.circular(10),
      //       ),
      //       backgroundColor: lightColorScheme.primary,
      //       foregroundColor: Colors.white,
      //     ),
      //   ),
      // ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
        fontFamily: 'sans-serif',
        appBarTheme: AppBarTheme(
          backgroundColor: darkColorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          centerTitle: true,
        ),
        // cardTheme: CardTheme(
        //   elevation: 3,
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(12),
        //   ),
        // ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: darkColorScheme.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: HomePage(appState: appState, toggleTheme: toggleTheme),
    );
  }

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }
}
