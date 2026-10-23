import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/attendance_models.dart';

class AttendanceService {
  final SupabaseClient _client;

  AttendanceService(this._client);

  Future<AttendanceOverview> getOverview(String classId) async {
    final datesResult = await _client.rpc(
      'get_my_class_attendance_score',
      params: {'p_class_id': classId},
    );
    final studentAttendanceDates = (datesResult as List<dynamic>? ?? const [])
        .map((date) => DateTime.parse(date as String))
        .toList(growable: false);
    final scheduleRows = await _client
        .from('class_attendance_schedules')
        .select()
        .eq('class_id', classId)
        .order('weekday');
    final schedules = (scheduleRows as List)
        .map(
          (row) => AttendanceSchedule.fromMap(
            Map<String, dynamic>.from(row as Map),
          ),
        )
        .toList(growable: false);

    final sessionResult = await _client.rpc(
      'get_or_create_today_attendance_session',
      params: {'p_class_id': classId},
    );
    final session = sessionResult == null
        ? null
        : AttendanceSession.fromMap(
            Map<String, dynamic>.from(sessionResult as Map),
          );

    if (session == null) {
      return AttendanceOverview(
        schedules: schedules,
        todaySession: null,
        records: const [],
        studentAttendanceDates: studentAttendanceDates,
      );
    }

    final recordRows = await _client
        .from('class_attendance_records')
        .select()
        .eq('session_id', session.id)
        .order('requested_at');

    return AttendanceOverview(
      schedules: schedules,
      todaySession: session,
      records: (recordRows as List)
          .map(
            (row) => AttendanceRecord.fromMap(
              Map<String, dynamic>.from(row as Map),
            ),
          )
          .toList(growable: false),
      studentAttendanceDates: studentAttendanceDates,
    );
  }

  Future<void> saveSchedule({
    required String classId,
    required int weekday,
    required String startsAt,
    required String endsAt,
    required bool isActive,
  }) async {
    await _client.from('class_attendance_schedules').upsert({
      'class_id': classId,
      'weekday': weekday,
      'starts_at': startsAt,
      'ends_at': endsAt,
      'is_active': isActive,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'class_id,weekday');
  }

  Future<void> requestAttendance(String sessionId) async {
    await _client.rpc(
      'request_class_attendance',
      params: {'p_session_id': sessionId},
    );
  }

  Future<void> reviewAttendance({
    required String recordId,
    required String status,
  }) async {
    await _client.rpc(
      'review_class_attendance',
      params: {'p_record_id': recordId, 'p_status': status},
    );
  }

  Future<void> setAttendance({
    required String sessionId,
    required String studentId,
    required String status,
  }) async {
    await _client.rpc(
      'set_class_attendance',
      params: {
        'p_session_id': sessionId,
        'p_student_id': studentId,
        'p_status': status,
      },
    );
  }
}
