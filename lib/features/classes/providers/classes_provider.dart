import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karafarini/core/providers/session_providers.dart';
import 'package:karafarini/features/classes/data/class_service.dart';
import 'package:karafarini/features/classes/models/class_member_model.dart';
import 'package:karafarini/features/classes/models/class_model.dart';

final classServiceProvider = Provider<ClassService>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return ClassService(supabase);
});

final teacherClassesProvider = FutureProvider.autoDispose<List<ClassModel>>((
  ref,
) async {
  final service = ref.watch(classServiceProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) return [];

  return service.getTeacherClasses(userId);
});

final studentClassesProvider = FutureProvider.autoDispose<List<ClassModel>>((
  ref,
) async {
  final service = ref.watch(classServiceProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) return [];

  return service.getStudentClasses(userId);
});

final classActionsProvider = Provider<ClassService>((ref) {
  return ref.watch(classServiceProvider);
});

final classMembersProvider = FutureProvider.family
    .autoDispose<List<ClassMemberModel>, String>((ref, classId) async {
      final service = ref.watch(classServiceProvider);
      return service.getClassMembers(classId);
    });
