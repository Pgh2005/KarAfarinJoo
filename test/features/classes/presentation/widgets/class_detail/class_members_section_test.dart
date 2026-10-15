import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:karafarini/features/classes/data/class_service.dart';
import 'package:karafarini/features/classes/models/class_member_model.dart';
import 'package:karafarini/features/classes/presentation/widgets/class_detail/class_members_section.dart';
import 'package:karafarini/features/classes/providers/classes_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  testWidgets('student card opens forms and has no removal action', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/class',
      routes: [
        GoRoute(
          path: '/class',
          builder: (context, state) => const Scaffold(
            body: SingleChildScrollView(
              child: ClassMembersSection(classId: 'class-1'),
            ),
          ),
        ),
        GoRoute(
          path: '/forms',
          name: 'form-list',
          builder: (context, state) => Scaffold(
            body: Text('فرم‌های ${state.uri.queryParameters['studentName']}'),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          classServiceProvider.overrideWith((ref) => _FakeClassService()),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('دانشجوی آزمایشی'), findsOneWidget);
    expect(find.byTooltip('حذف دانشجو از کلاس'), findsNothing);

    await tester.tap(find.text('دانشجوی آزمایشی'));
    await tester.pumpAndSettle();

    expect(find.text('فرم‌های دانشجوی آزمایشی'), findsOneWidget);
    router.dispose();
  });
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

  @override
  Future<List<ClassMemberModel>> getClassMembers(String classId) async => [
    ClassMemberModel(
      id: 'membership-1',
      classId: classId,
      studentId: 'student-1',
      joinedAt: DateTime(2026),
      studentName: 'دانشجوی آزمایشی',
      studentNumber: '12345',
    ),
  ];
}
