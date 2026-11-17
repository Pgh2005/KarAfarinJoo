import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:karafarini/core/providers/session_providers.dart';
import 'package:karafarini/features/attendance/models/attendance_models.dart';
import 'package:karafarini/features/attendance/presentation/class_attendance_page.dart';
import 'package:karafarini/features/attendance/providers/attendance_provider.dart';
import 'package:karafarini/features/classes/models/class_model.dart';
import 'package:karafarini/features/profile/providers/current_session_profile_provider.dart';

void main() {
  testWidgets('refreshes attendance when returning from another page', (
    tester,
  ) async {
    var fetchCount = 0;
    final router = GoRouter(
      initialLocation: '/attendance',
      observers: [attendanceRouteObserver],
      routes: [
        GoRoute(
          path: '/attendance',
          builder: (context, state) =>
              ClassAttendancePage(classModel: _classModel()),
        ),
        GoRoute(
          path: '/other',
          builder: (context, state) => const Scaffold(body: Text('صفحهٔ دیگر')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserIdProvider.overrideWith((ref) => 'student-1'),
          isProfessorProvider.overrideWith((ref) => false),
          attendanceOverviewProvider('class-1').overrideWith((ref) async {
            fetchCount++;
            return const AttendanceOverview(
              schedules: [],
              todaySession: null,
              records: [],
              studentAttendanceDates: [],
            );
          }),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    expect(fetchCount, 1);

    unawaited(router.push('/other'));
    await tester.pumpAndSettle();
    expect(find.text('صفحهٔ دیگر'), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();
    expect(fetchCount, 2);

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
