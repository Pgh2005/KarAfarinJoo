import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/join_request_model.dart';
import '../models/join_request_with_profile_model.dart';

class InviteService {
  final SupabaseClient _supabase;

  InviteService(this._supabase);

  Future<List<JoinRequestWithProfile>> getPendingRequestsForTeacher(
    String teacherId,
  ) async {
    final response = await _supabase
        .from('class_join_requests')
        .select('''
      *,
      profiles:student_id (
        full_name,
        email
      ),
      classes!inner (
        id,
        title,
        teacher_id
      )
    ''')
        .eq('classes.teacher_id', teacherId)
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return (response as List)
        .map(
          (item) =>
              JoinRequestWithProfile.fromMap(item as Map<String, dynamic>),
        )
        .toList();
  }

  /// Get join requests created by a student (their own requests). This is used
  /// so students can view the status of their requests.
  Future<List<JoinRequestWithProfile>> getRequestsForStudent(
    String studentId,
  ) async {
    final response = await _supabase
        .from('class_join_requests')
        .select('''
      *,
      profiles:student_id (
        full_name,
        email
      ),
      classes!inner (
        id,
        title,
        teacher_id
      )
    ''')
        .eq('student_id', studentId)
        .inFilter('status', ['pending', 'rejected'])
        .order('created_at', ascending: false);

    return (response as List)
        .map(
          (item) =>
              JoinRequestWithProfile.fromMap(item as Map<String, dynamic>),
        )
        .toList();
  }

  /// Delete a join request (students can dismiss their rejected requests)
  Future<void> deleteRequest({
    required String requestId,
    required String studentId,
  }) async {
    await _supabase
        .from('class_join_requests')
        .delete()
        .eq('id', requestId)
        .eq('student_id', studentId);
  }

  Future<void> approveRequest({
    required String requestId,
    required String classId,
    required String studentId,
    required String teacherId,
  }) async {
    final updatedRequest = await _supabase
        .from('class_join_requests')
        .update({
          'status': JoinRequestStatus.approved.value,
          'reviewed_by': teacherId,
          'reviewed_at': DateTime.now().toIso8601String(),
          'rejection_reason': null,
        })
        .eq('id', requestId)
        .eq('status', JoinRequestStatus.pending.value)
        .select()
        .maybeSingle();

    if (updatedRequest == null) {
      throw Exception('این درخواست قبلاً بررسی شده یا دیگر معتبر نیست.');
    }

    try {
      await _supabase.from('class_members').insert({
        'class_id': classId,
        'student_id': studentId,
        'approved_by': teacherId,
        'request_id': requestId,
        'joined_at': DateTime.now().toIso8601String(),
      });
    } on PostgrestException catch (_) {
      await _supabase
          .from('class_join_requests')
          .update({
            'status': JoinRequestStatus.pending.value,
            'reviewed_by': null,
            'reviewed_at': null,
          })
          .eq('id', requestId);

      rethrow;
    }
  }

  Future<void> rejectRequest({
    required String requestId,
    required String teacherId,
    String? rejectionReason,
  }) async {
    final updated = await _supabase
        .from('class_join_requests')
        .update({
          'status': JoinRequestStatus.rejected.value,
          'reviewed_by': teacherId,
          'reviewed_at': DateTime.now().toIso8601String(),
          'rejection_reason': rejectionReason?.trim().isEmpty == true
              ? null
              : rejectionReason?.trim(),
        })
        .eq('id', requestId)
        .eq('status', JoinRequestStatus.pending.value)
        .select()
        .maybeSingle();

    if (updated == null) {
      throw Exception('این درخواست قبلاً بررسی شده یا دیگر معتبر نیست.');
    }
  }
}
