import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karafarini/core/providers/session_providers.dart';

import '../data/gradebook_service.dart';
import '../models/student_grade.dart';

final gradebookServiceProvider = Provider<GradebookService>((ref) {
  return GradebookService(ref.watch(supabaseProvider));
});

final classGradesProvider = FutureProvider.autoDispose
    .family<Map<String, StudentGrade>, String>((ref, classId) {
      return ref.watch(gradebookServiceProvider).getGradesForClass(classId);
    });

final studentGradeProvider = FutureProvider.autoDispose
    .family<StudentGrade?, ({String classId, String studentId})>((ref, params) {
      return ref
          .watch(gradebookServiceProvider)
          .getStudentGrade(
            classId: params.classId,
            studentId: params.studentId,
          );
    });
