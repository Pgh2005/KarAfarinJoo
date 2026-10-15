import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:karafarini/core/providers/session_providers.dart';
import 'package:karafarini/features/classes/data/class_service.dart';
import 'package:karafarini/features/classes/models/class_member_model.dart';
import 'package:karafarini/features/classes/models/class_model.dart';
import 'package:karafarini/features/classes/presentation/pages/class_detail_page.dart';
import 'package:karafarini/features/classes/providers/classes_provider.dart';
import 'package:karafarini/features/profile/providers/current_session_profile_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  testWidgets('class owner archives only after confirming', (tester) async {
    const teacherId = 'teacher-1';
    final classModel = _classModel();
    final service = _FakeClassService();
    final router = await _pumpClassDetail(
      tester,
      classModel: classModel,
      service: service,
      currentUserId: teacherId,
      isProfessor: true,
    );

    await tester.tap(find.byTooltip('آرشیو کلاس'));
    await tester.pumpAndSettle();

    expect(find.textContaining('سوابق موجود حذف نمی‌شوند'), findsOneWidget);
    expect(service.archivedClassId, isNull);

    await tester.tap(find.text('آرشیو کلاس').last);
    await tester.pumpAndSettle();

    expect(service.archivedClassId, classModel.id);
    expect(service.archivedTeacherId, teacherId);
    expect(find.text('خانه'), findsOneWidget);

    router.dispose();
  });

  testWidgets('non-owner professor cannot archive a class', (tester) async {
    final service = _FakeClassService();
    final router = await _pumpClassDetail(
      tester,
      classModel: _classModel(),
      service: service,
      currentUserId: 'another-teacher',
      isProfessor: true,
    );

    expect(find.byTooltip('آرشیو کلاس'), findsNothing);
    expect(service.archivedClassId, isNull);

    router.dispose();
  });
}

ClassModel _classModel() => ClassModel(
  id: 'class-1',
  teacherId: 'teacher-1',
  title: 'کلاس آزمایشی',
  courseCode: 'TEST-1',
  semester: 'ترم جاری',
  joinCode: 'ABC123',
  maxStudents: 20,
  isActive: true,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

Future<GoRouter> _pumpClassDetail(
  WidgetTester tester, {
  required ClassModel classModel,
  required _FakeClassService service,
  required String? currentUserId,
  required bool isProfessor,
}) async {
  final router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) => const Scaffold(body: Text('خانه')),
      ),
      GoRoute(
        path: '/class',
        builder: (context, state) => ClassDetailPage(classModel: classModel),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentUserIdProvider.overrideWith((ref) => currentUserId),
        isProfessorProvider.overrideWith((ref) => isProfessor),
        classActionsProvider.overrideWith((ref) => service),
        classServiceProvider.overrideWith((ref) => service),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );

  unawaited(router.push('/class'));
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

  String? archivedClassId;
  String? archivedTeacherId;

  @override
  Future<void> archiveClass({
    required String classId,
    required String teacherId,
  }) async {
    archivedClassId = classId;
    archivedTeacherId = teacherId;
  }

  @override
  Future<List<ClassMemberModel>> getClassMembers(String classId) async => [];
}
