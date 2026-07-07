import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/class_model.dart';
import '../models/class_member_model.dart';

class ClassService {
  final SupabaseClient _supabase;

  ClassService(this._supabase);

  Future<List<ClassModel>> getTeacherClasses(String teacherId) async {
    final response = await _supabase
        .from('classes')
        .select()
        .eq('teacher_id', teacherId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => ClassModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ClassModel>> getStudentClasses(String studentId) async {
    final response = await _supabase
        .from('class_members')
        .select('joined_at, classes(*)')
        .eq('student_id', studentId);

    return (response as List)
        .map((e) => ClassModel.fromMap(e['classes'] as Map<String, dynamic>))
        .toList();
  }

  Future<void> createClass({
    required String teacherId,
    required String title,
    required String courseCode,
    required String semester,
    required String joinCode,
    int maxStudents = 40,
    String? description,
  }) async {
    await _supabase.from('classes').insert({
      'teacher_id': teacherId,
      'title': title,
      'course_code': courseCode,
      'semester': semester,
      'join_code': joinCode,
      'max_students': maxStudents,
      'description': description,
      'is_active': true,
    });
  }

  Future<void> sendJoinRequest({
    required String joinCode,
    required String studentId,
    String? message,
  }) async {
    final classResult = await _supabase
        .from('classes')
        .select('id')
        .eq('join_code', joinCode)
        .maybeSingle();

    if (classResult == null) {
      throw Exception('کلاسی با این کد پیدا نشد');
    }

    await _supabase.from('class_join_requests').insert({
      'class_id': classResult['id'],
      'student_id': studentId,
      'status': 'pending',
      'message': message,
    });
  }

  Future<void> approveJoinRequest({
    required String requestId,
    required String classId,
    required String studentId,
    required String teacherId,
  }) async {
    await _supabase.from('class_members').insert({
      'class_id': classId,
      'student_id': studentId,
      'approved_by': teacherId,
      'request_id': requestId,
    });

    await _supabase
        .from('class_join_requests')
        .update({
          'status': 'approved',
          'reviewed_by': teacherId,
          'reviewed_at': DateTime.now().toIso8601String(),
        })
        .eq('id', requestId);
  }

  Future<void> rejectJoinRequest(String requestId, String teacherId) async {
    await _supabase
        .from('class_join_requests')
        .update({
          'status': 'rejected',
          'reviewed_by': teacherId,
          'reviewed_at': DateTime.now().toIso8601String(),
        })
        .eq('id', requestId);
  }

  Future<List<ClassMemberModel>> getClassMembers(String classId) async {
    final response = await _supabase
        .from('class_members')
        .select('*, profiles:student_id(*)')
        .eq('class_id', classId)
        .order('joined_at', ascending: false);

    return (response as List)
        .map((e) => ClassMemberModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}
