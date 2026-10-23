import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:karafarini/core/providers/session_providers.dart';
import 'package:karafarini/features/classes/models/class_member_model.dart';
import 'package:karafarini/features/classes/models/class_model.dart';
import 'package:karafarini/features/classes/providers/classes_provider.dart';
import 'package:karafarini/features/grading/models/student_grade.dart';
import 'package:karafarini/features/grading/presentation/gradebook_page.dart';
import 'package:karafarini/features/grading/providers/gradebook_provider.dart';
import 'package:karafarini/features/profile/providers/current_session_profile_provider.dart';

void main() {
  testWidgets('hides empty-grade status and opens grade entry from the card', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/gradebook',
      routes: [
        GoRoute(
          path: '/gradebook',
          builder: (context, state) => GradebookPage(classModel: _classModel()),
        ),
        GoRoute(
          path: '/student-grade',
          name: 'student-grade',
          builder: (context, state) =>
              const Scaffold(body: Text('صفحهٔ ثبت نمره')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserIdProvider.overrideWith((ref) => 'teacher-1'),
          isProfessorProvider.overrideWith((ref) => true),
          classMembersProvider(
            'class-1',
          ).overrideWith((ref) async => [_member()]),
          classGradesProvider(
            'class-1',
          ).overrideWith((ref) async => <String, StudentGrade>{}),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('دانشجوی آزمایشی'), findsOneWidget);
    expect(find.text('۱۲۳۴۵'), findsOneWidget);
    expect(find.text('ثبت نشده'), findsNothing);
    expect(find.byTooltip('مشاهده پروفایل دانشجو'), findsNothing);
    expect(find.text('—'), findsOneWidget);
    expect(find.text('از ۲۲'), findsOneWidget);
    expect(find.textContaining('از ۲۲ •'), findsNothing);

    await tester.tap(find.text('دانشجوی آزمایشی'));
    await tester.pumpAndSettle();

    expect(find.text('صفحهٔ ثبت نمره'), findsOneWidget);
    router.dispose();
  });

  testWidgets('shows the grade out of 22 separately from the student details', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/gradebook',
      routes: [
        GoRoute(
          path: '/gradebook',
          builder: (context, state) => GradebookPage(classModel: _classModel()),
        ),
      ],
    );
    final grade = StudentGrade(
      classId: 'class-1',
      studentId: 'student-1',
      scores: {'slogan_life': 1},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserIdProvider.overrideWith((ref) => 'teacher-1'),
          isProfessorProvider.overrideWith((ref) => true),
          classMembersProvider(
            'class-1',
          ).overrideWith((ref) async => [_member()]),
          classGradesProvider(
            'class-1',
          ).overrideWith((ref) async => {'student-1': grade}),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('0.20'), findsOneWidget);
    expect(find.text('از ۲۲'), findsOneWidget);
    expect(find.textContaining('0.20 از ۲۲'), findsNothing);

    router.dispose();
  });
}

ClassModel _classModel() => ClassModel(
  id: 'class-1',
  teacherId: 'teacher-1',
  title: 'کلاس آزمایشی',
  courseCode: 'TEST-1',
  semester: 'ترم جاری',
  joinCode: 'JOIN-1',
  maxStudents: 20,
  isActive: true,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

ClassMemberModel _member() => ClassMemberModel(
  id: 'member-1',
  classId: 'class-1',
  studentId: 'student-1',
  joinedAt: DateTime(2026),
  studentName: 'دانشجوی آزمایشی',
  studentNumber: '۱۲۳۴۵',
);
