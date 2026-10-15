import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karafarini/features/classes/data/class_service.dart';
import 'package:karafarini/features/classes/models/class_member_model.dart';
import 'package:karafarini/features/classes/presentation/widgets/class_detail/class_members_section.dart';
import 'package:karafarini/features/classes/providers/classes_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  testWidgets(
    'removing a student requires confirmation and refreshes members',
    (tester) async {
      final service = _FakeClassService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            classServiceProvider.overrideWith((ref) => service),
            classActionsProvider.overrideWith((ref) => service),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ClassMembersSection(classId: 'class-1'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('دانشجوی آزمایشی'), findsOneWidget);

      await tester.tap(find.byTooltip('حذف دانشجو از کلاس'));
      await tester.pumpAndSettle();

      expect(find.textContaining('حساب دانشجو حذف نخواهند شد'), findsOneWidget);
      await tester.tap(find.text('انصراف'));
      await tester.pumpAndSettle();

      expect(service.removedStudentId, isNull);
      expect(find.text('دانشجوی آزمایشی'), findsOneWidget);

      await tester.tap(find.byTooltip('حذف دانشجو از کلاس'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('حذف از کلاس'));
      await tester.pumpAndSettle();

      expect(service.removedClassId, 'class-1');
      expect(service.removedStudentId, 'student-1');
      expect(find.text('دانشجوی آزمایشی'), findsNothing);
    },
  );
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

  bool _hasMember = true;
  String? removedClassId;
  String? removedStudentId;

  @override
  Future<List<ClassMemberModel>> getClassMembers(String classId) async =>
      _hasMember
      ? [
          ClassMemberModel(
            id: 'membership-1',
            classId: classId,
            studentId: 'student-1',
            joinedAt: DateTime(2026),
            studentName: 'دانشجوی آزمایشی',
            studentNumber: '12345',
          ),
        ]
      : [];

  @override
  Future<void> removeStudentFromClass({
    required String classId,
    required String studentId,
  }) async {
    removedClassId = classId;
    removedStudentId = studentId;
    _hasMember = false;
  }
}
