import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:karafarini/features/classes/data/class_service.dart';
import 'package:karafarini/features/classes/models/class_member_model.dart';
import 'package:karafarini/features/classes/providers/classes_provider.dart';
import 'package:karafarini/features/forms/pages/page_list/form_list.dart';
import 'package:karafarini/features/forms/widgets/form_progress.dart';
import 'package:karafarini/features/forms/widgets/form_progress_provider.dart';
import 'package:karafarini/features/profile/providers/current_session_profile_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  testWidgets('professor can remove the student from the forms app bar', (
    tester,
  ) async {
    final service = _FakeClassService();
    final router = await _pumpFormList(
      tester,
      service: service,
      isProfessor: true,
    );

    expect(find.text('دانشجوی آزمایشی'), findsOneWidget);
    expect(find.byTooltip('مشاهده پروفایل دانشجو'), findsOneWidget);
    expect(find.byTooltip('حذف دانشجو از کلاس'), findsOneWidget);

    await tester.tap(find.byTooltip('مشاهده پروفایل دانشجو'));
    await tester.pumpAndSettle();
    expect(find.text('پروفایل class-1/student-1'), findsOneWidget);
    router.pop();
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('حذف دانشجو از کلاس'));
    await tester.pumpAndSettle();
    expect(find.textContaining('پاسخ‌های فرم‌ها'), findsOneWidget);
    await tester.tap(find.text('انصراف'));
    await tester.pumpAndSettle();
    expect(service.removedStudentId, isNull);

    await tester.tap(find.byTooltip('حذف دانشجو از کلاس'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حذف از کلاس'));
    await tester.pumpAndSettle();

    expect(service.removedClassId, 'class-1');
    expect(service.removedStudentId, 'student-1');
    expect(find.text('صفحهٔ قبل'), findsOneWidget);
    router.dispose();
  });

  testWidgets('student does not see class membership removal action', (
    tester,
  ) async {
    final router = await _pumpFormList(
      tester,
      service: _FakeClassService(),
      isProfessor: false,
    );

    expect(find.byTooltip('حذف دانشجو از کلاس'), findsNothing);
    expect(find.byTooltip('مشاهده پروفایل دانشجو'), findsNothing);
    router.dispose();
  });
}

Future<GoRouter> _pumpFormList(
  WidgetTester tester, {
  required _FakeClassService service,
  required bool isProfessor,
}) async {
  final router = GoRouter(
    initialLocation: '/previous',
    routes: [
      GoRoute(
        path: '/previous',
        builder: (context, state) => const Scaffold(body: Text('صفحهٔ قبل')),
      ),
      GoRoute(
        path: '/forms',
        builder: (context, state) => const FormList(
          classId: 'class-1',
          studentId: 'student-1',
          studentName: 'دانشجوی آزمایشی',
        ),
      ),
      GoRoute(
        path: '/student-profile',
        name: 'student-profile',
        builder: (context, state) => Scaffold(
          body: Text(
            'پروفایل '
            '${state.uri.queryParameters['classId']}/'
            '${state.uri.queryParameters['studentId']}',
          ),
        ),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        isProfessorProvider.overrideWith((ref) => isProfessor),
        classServiceProvider.overrideWith((ref) => service),
        classActionsProvider.overrideWith((ref) => service),
        allFormsProgressProvider.overrideWith(
          (ref, params) => const AllFormsProgress(
            page1: FormProgress(filled: 1, total: 1),
            page2: FormProgress(filled: 0, total: 1),
            page3: FormProgress(filled: 0, total: 1),
            page4: FormProgress(filled: 0, total: 1),
            page5: FormProgress(filled: 0, total: 1),
            page6: FormProgress(filled: 0, total: 1),
          ),
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );

  unawaited(router.push('/forms'));
  await tester.pumpAndSettle();
  return router;
}

class _FakeClassService extends ClassService {
  _FakeClassService()
    : super(
        SupabaseClient(
          'https://example.com',
          'test-key',
          authOptions: const AuthClientOptions(autoRefreshToken: false),
        ),
      );

  String? removedClassId;
  String? removedStudentId;

  @override
  Future<List<ClassMemberModel>> getClassMembers(String classId) async => [];

  @override
  Future<void> removeStudentFromClass({
    required String classId,
    required String studentId,
  }) async {
    removedClassId = classId;
    removedStudentId = studentId;
  }
}
