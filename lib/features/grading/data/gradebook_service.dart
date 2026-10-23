import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/student_grade.dart';

class GradebookService {
  final SupabaseClient _client;

  GradebookService(this._client);

  Future<Map<String, StudentGrade>> getGradesForClass(String classId) async {
    final rows = await _client
        .from('class_student_grades')
        .select()
        .eq('class_id', classId);

    return {
      for (final row in rows)
        (row['student_id'] as String): StudentGrade.fromMap(
          Map<String, dynamic>.from(row),
        ),
    };
  }

  Future<StudentGrade?> getStudentGrade({
    required String classId,
    required String studentId,
  }) async {
    final row = await _client
        .from('class_student_grades')
        .select()
        .eq('class_id', classId)
        .eq('student_id', studentId)
        .maybeSingle();

    if (row == null) return null;
    return StudentGrade.fromMap(Map<String, dynamic>.from(row));
  }

  Future<void> saveGrade(StudentGrade grade) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('برای ثبت نمره باید وارد حساب کاربری باشید.');
    }

    final validationError = grade.validate();
    if (validationError != null) {
      throw ArgumentError(validationError);
    }

    await _client
        .from('class_student_grades')
        .upsert(
          grade.toMap(updatedBy: userId),
          onConflict: 'class_id,student_id',
        );
  }
}
