import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karafarini/features/profile/models/profile.dart';
import 'package:karafarini/features/profile/presentation/profile_page.dart';
import 'package:karafarini/features/profile/providers/current_session_profile_provider.dart';
import 'package:karafarini/features/profile/providers/student_profile_provider.dart';

void main() {
  testWidgets('student profile displays profile details without logout', (
    tester,
  ) async {
    final profile = Profile(
      id: 'student-1',
      role: UserRole.student,
      email: 'student@example.com',
      fullName: 'دانشجوی آزمایشی',
      studentNumber: '12345',
      phone: '09120000000',
      major: 'مهندسی',
      department: 'فنی',
      bio: 'درباره دانشجو',
      isActive: true,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studentProfileProvider((
            classId: 'class-1',
            studentId: 'student-1',
          )).overrideWith((ref) async => profile),
        ],
        child: const MaterialApp(
          home: ProfilePage(classId: 'class-1', studentId: 'student-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('پروفایل دانشجو'), findsOneWidget);
    expect(find.text('دانشجوی آزمایشی'), findsOneWidget);
    expect(find.text('student@example.com'), findsOneWidget);
    expect(find.text('12345'), findsOneWidget);
    expect(find.text('خروج از حساب کاربری'), findsNothing);
    expect(find.byTooltip('افزودن یا تغییر عکس پروفایل'), findsNothing);
  });

  testWidgets('a student can access the profile photo control on own profile', (
    tester,
  ) async {
    final profile = Profile(
      id: 'student-1',
      role: UserRole.student,
      email: 'student@example.com',
      fullName: 'دانشجوی آزمایشی',
      isActive: true,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentSessionProfileProvider.overrideWith((ref) async => profile),
        ],
        child: const MaterialApp(home: ProfilePage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('افزودن یا تغییر عکس پروفایل'), findsOneWidget);
  });
}
