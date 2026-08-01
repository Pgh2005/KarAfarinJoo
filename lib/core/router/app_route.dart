import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:karafarini/features/auth/presentation/pages/login_page.dart';
import 'package:karafarini/features/auth/presentation/pages/signup_page.dart';
import 'package:karafarini/features/auth/presentation/pages/splash_screen.dart';
import 'package:karafarini/features/classes/presentation/pages/create_class_page.dart';
import 'package:karafarini/features/classes/presentation/pages/join_class_page.dart';
import 'package:karafarini/features/classes/presentation/pages/invite_requests_page.dart';
import 'package:karafarini/features/classes/presentation/pages/class_detail_page.dart';
import 'package:karafarini/features/forms/pages/page_list/form_list.dart';
import 'package:karafarini/features/profile/presentation/profile_page.dart';
import 'package:karafarini/features/home/presentation/pages/home_page.dart';
import 'package:karafarini/features/classes/models/class_model.dart';
import 'package:karafarini/core/widgets/app_bar_builder.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

final appRouter = GoRouter(
  initialLocation: '/splash',
  refreshListenable: GoRouterRefreshStream(supabase.auth.onAuthStateChange),
  redirect: (context, state) {
    final loggedIn = supabase.auth.currentSession != null;

    final isSplash = state.matchedLocation == '/splash';
    final isLogin = state.matchedLocation == '/login';
    final isSignup = state.matchedLocation == '/signup';
    final isAuthPage = isLogin || isSignup;

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
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignupPage(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: '/create-class',
      name: 'create-class',
      builder: (context, state) => const CreateClassPage(),
    ),
    GoRoute(
      path: '/join-class',
      name: 'join-class',
      builder: (context, state) => const JoinClassPage(),
    ),
    GoRoute(
      path: '/invite-requests',
      name: 'invite-requests',
      builder: (context, state) => const InviteRequestsPage(),
    ),
    GoRoute(
      path: '/class-detail',
      name: 'class-detail',
      builder: (context, state) {
        final extra = state.extra;
        if (extra is ClassModel) {
          return ClassDetailPage(classModel: extra);
        }
        return Scaffold(
          appBar: const AppBarBuilder(title: 'جزئیات کلاس'),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'اطلاعات کلاس نامعتبر است.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'لطفاً از صفحه خانه وارد جزئیات کلاس شوید.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
    GoRoute(
      path: '/form-list',
      name: 'form-list',
      builder: (context, state) {
        final classId = state.uri.queryParameters['classId'] ?? '';
        final studentId = state.uri.queryParameters['studentId'] ?? '';
        final studentName = state.uri.queryParameters['studentName'] ?? '';

        return FormList(
          classId: classId,
          studentId: studentId,
          studentName: studentName,
        );
      },
    ),
  ],
);

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) {
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
