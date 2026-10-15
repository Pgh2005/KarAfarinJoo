import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:karafarini/features/profile/data/profile_photo_service.dart';

import '../models/class_member_model.dart';
import '../models/class_model.dart';
import '../models/join_request_model.dart';

class ClassService {
  final SupabaseClient _supabase;
  final ProfilePhotoService _profilePhotoService;

  ClassService(this._supabase, [ProfilePhotoService? profilePhotoService])
    : _profilePhotoService =
          profilePhotoService ?? ProfilePhotoService(_supabase);

  String _generateJoinCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  Future<void> createClass({
    required String teacherId,
    required String title,
    required String courseCode,
    required String semester,
    required int maxStudents,
    String? description,
  }) async {
    for (var attempt = 0; attempt < 5; attempt++) {
      final joinCode = _generateJoinCode();

      try {
        await _supabase.from('classes').insert({
          'teacher_id': teacherId,
          'title': title.trim(),
          'course_code': courseCode.trim(),
          'semester': semester.trim(),
          'description': description?.trim().isEmpty == true
              ? null
              : description?.trim(),
          'join_code': joinCode,
          'max_students': maxStudents,
          'is_active': true,
        });

        return;
      } on PostgrestException catch (e) {
        if (e.code == '23505') {
          continue;
        }
        rethrow;
      }
    }

    throw Exception('ساخت کلاس ناموفق بود. دوباره تلاش کنید.');
  }

  Future<List<ClassModel>> getTeacherClasses(String teacherId) async {
    final response = await _supabase
        .from('classes')
        .select()
        .eq('teacher_id', teacherId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => ClassModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<ClassModel>> getStudentClasses(String studentId) async {
    final response = await _supabase
        .from('class_members')
        .select('classes(*)')
        .eq('student_id', studentId)
        .order('joined_at', ascending: false);

    return (response as List)
        .map((item) => item['classes'])
        .whereType<Map<String, dynamic>>()
        .map(ClassModel.fromMap)
        .toList();
  }

  Future<void> deleteClass({required String classId}) async {
    await _supabase.rpc(
      'delete_class_with_data',
      params: {'p_class_id': classId},
    );
  }

  Future<void> removeStudentFromClass({
    required String classId,
    required String studentId,
  }) async {
    await _supabase.rpc(
      'remove_student_from_class',
      params: {'p_class_id': classId, 'p_student_id': studentId},
    );
  }

  Future<void> sendJoinRequest({
    required String joinCode,
    required String studentId,
    String? message,
  }) async {
    final normalizedJoinCode = joinCode.trim().toUpperCase();

    final classRow = await _supabase
        .from('classes')
        .select('id, is_active, max_students, teacher_id')
        .eq('join_code', normalizedJoinCode)
        .maybeSingle();

    if (classRow == null) {
      throw Exception('کلاسی با این کد پیدا نشد.');
    }

    if ((classRow['is_active'] as bool?) == false) {
      throw Exception('این کلاس غیرفعال است.');
    }

    final classId = classRow['id'] as String;
    final maxStudents = (classRow['max_students'] as int?) ?? 0;

    final existingMembership = await _supabase
        .from('class_members')
        .select('id')
        .eq('class_id', classId)
        .eq('student_id', studentId)
        .maybeSingle();

    if (existingMembership != null) {
      throw Exception('شما قبلاً عضو این کلاس شده‌اید.');
    }

    final existingPendingRequest = await _supabase
        .from('class_join_requests')
        .select('id, status')
        .eq('class_id', classId)
        .eq('student_id', studentId)
        .eq('status', 'pending')
        .maybeSingle();

    if (existingPendingRequest != null) {
      throw Exception('درخواست عضویت شما قبلاً ثبت شده و در انتظار بررسی است.');
    }

    if (maxStudents > 0) {
      final memberRows = await _supabase
          .from('class_members')
          .select('id')
          .eq('class_id', classId);

      if ((memberRows as List).length >= maxStudents) {
        throw Exception('ظرفیت این کلاس تکمیل شده است.');
      }
    }

    await _supabase.from('class_join_requests').insert({
      'class_id': classId,
      'student_id': studentId,
      'teacher_id': classRow['teacher_id'],
      'status': JoinRequestStatus.pending.value,
      'message': message?.trim().isEmpty == true ? null : message?.trim(),
    });
  }

  Future<List<JoinRequestModel>> getPendingRequestsForTeacher(
    String teacherId,
  ) async {
    final response = await _supabase
        .from('class_join_requests')
        .select('''
          *,
          classes!inner(id, title, teacher_id)
        ''')
        .eq('classes.teacher_id', teacherId)
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => JoinRequestModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<ClassMemberModel>> getClassMembers(String classId) async {
    final response = await _supabase
        .from('class_members')
        .select('''
          id,
          class_id,
          student_id,
          approved_by,
          request_id,
          joined_at,
          profiles:student_id (
            full_name,
            email,
            student_number,
            avatar_url
          )
        ''')
        .eq('class_id', classId)
        .order('joined_at', ascending: false);

    final members = (response as List)
        .map((item) => ClassMemberModel.fromMap(item as Map<String, dynamic>))
        .toList();
    final displayUrls = await _profilePhotoService.getDisplayUrls(
      members.map((member) => member.avatarUrl),
    );

    return members
        .map((member) => member.withAvatarUrl(displayUrls[member.avatarUrl]))
        .toList();
  }
}
