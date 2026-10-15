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

  /// Get pending join requests created by a student.
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
        .eq('status', JoinRequestStatus.pending.value)
        .order('created_at', ascending: false);

    return (response as List)
        .map(
          (item) =>
              JoinRequestWithProfile.fromMap(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> approveRequest({
    required String requestId,
  }) async {
    await _reviewRequest(requestId, JoinRequestStatus.approved);
  }

  Future<void> rejectRequest({required String requestId}) async {
    await _reviewRequest(requestId, JoinRequestStatus.rejected);
  }

  Future<void> _reviewRequest(
    String requestId,
    JoinRequestStatus decision,
  ) async {
    await _supabase.rpc(
      'review_class_join_request',
      params: {
        'p_request_id': requestId,
        'p_decision': decision.value,
      },
    );
  }
}
