import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:karafarini/core/state/app_state.dart';
import 'package:karafarini/features/auth/presentation/pages/login_page.dart';
import 'package:karafarini/features/auth/presentation/pages/signup_page.dart';
import 'package:karafarini/pages/home_page.dart';
import 'package:karafarini/features/auth/presentation/pages/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

final appRouter = GoRouter(
  initialLocation: '/splash',
  refreshListenable: GoRouterRefreshStream(supabase.auth.onAuthStateChange),
  redirect: (context, state) {
    final session = supabase.auth.currentSession;
    final loggedIn = session != null;

    final isSplash = state.matchedLocation == '/splash';
    final isAuthPage =
        state.matchedLocation == '/login' || state.matchedLocation == '/signup';

    if (isSplash) return null;

    if (!loggedIn && !isAuthPage) {
      return '/login';
    }

    if (loggedIn && isAuthPage) {
      return '/home';
    }

    return null;
  },
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupPage()),
    GoRoute(
      path: '/home',
      builder: (context, state) => HomePage(appState: AppState()),
    ),
  ],
);

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
