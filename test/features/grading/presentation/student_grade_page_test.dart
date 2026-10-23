import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karafarini/core/providers/session_providers.dart';
import 'package:karafarini/features/classes/models/class_member_model.dart';
import 'package:karafarini/features/classes/models/class_model.dart';
import 'package:karafarini/features/grading/presentation/student_grade_page.dart';
import 'package:karafarini/features/grading/providers/gradebook_provider.dart';
import 'package:karafarini/features/profile/providers/current_session_profile_provider.dart';

void main() {
  testWidgets('shows the nested rubric and class-session date control', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserIdProvider.overrideWith((ref) => 'teacher-1'),
          isProfessorProvider.overrideWith((ref) => true),
          studentGradeProvider((
            classId: 'class-1',
            studentId: 'student-1',
          )).overrideWith((ref) async => null),
        ],
        child: MaterialApp(
          home: StudentGradePage(classModel: _classModel(), member: _member()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final sloganTile = find.text('شعار (2 نمره)');
    await tester.ensureVisible(sloganTile);
    await tester.tap(sloganTile);
    await tester.pumpAndSettle();

    expect(find.text('زندگی'), findsOneWidget);
    expect(find.text('کسب'), findsOneWidget);

    final sessionButton = find.text('افزودن تاریخ جلسه');
    await tester.scrollUntilVisible(
      sessionButton,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(sessionButton, findsOneWidget);
    await tester.tap(sessionButton);
    await tester.pumpAndSettle();

    expect(find.text('تاریخ جلسه'), findsOneWidget);
    expect(find.text('تاریخ برگزاری کلاس را انتخاب کنید'), findsOneWidget);
  });

  testWidgets('shows uncapped extracurricular scoring and 110-point total', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserIdProvider.overrideWith((ref) => 'teacher-1'),
          isProfessorProvider.overrideWith((ref) => true),
          studentGradeProvider((
            classId: 'class-1',
            studentId: 'student-1',
          )).overrideWith((ref) async => null),
        ],
        child: MaterialApp(
          home: StudentGradePage(classModel: _classModel(), member: _member()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final extracurricularField = find.text('فوق‌برنامه');
    await tester.scrollUntilVisible(
      extracurricularField,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    final totalLabel = find.textContaining('معادل از ۲۲');
    await tester.scrollUntilVisible(
      totalLabel,
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(extracurricularField, findsOneWidget);
    expect(totalLabel, findsOneWidget);
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
);
