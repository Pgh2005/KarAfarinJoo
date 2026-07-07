import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karafarini/core/providers/session_providers.dart';
import 'package:karafarini/features/classes/data/class_service.dart';
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

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:karafarini/features/classes/data/class_service.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// import '../models/class_model.dart';

// final supabaseProvider = Provider<SupabaseClient>((ref) {
//   return Supabase.instance.client;
// });

// final classServiceProvider = Provider<ClassService>((ref) {
//   return ClassService(ref.watch(supabaseProvider));
// });

// final currentUserIdProvider = Provider<String?>((ref) {
//   return ref.watch(supabaseProvider).auth.currentUser?.id;
// });

// final teacherClassesProvider = FutureProvider.autoDispose<List<ClassModel>>((
//   ref,
// ) async {
//   final userId = ref.watch(currentUserIdProvider);
//   if (userId == null) return [];

//   return ref.watch(classServiceProvider).getTeacherClasses(userId);
// });

// final studentClassesProvider = FutureProvider.autoDispose<List<ClassModel>>((
//   ref,
// ) async {
//   final userId = ref.watch(currentUserIdProvider);
//   if (userId == null) return [];

//   return ref.watch(classServiceProvider).getStudentClasses(userId);
// });

// final classActionsProvider = Provider<ClassService>((ref) {
//   return ref.watch(classServiceProvider);
// });
