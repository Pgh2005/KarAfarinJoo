class AttendanceSchedule {
  final int id;
  final String classId;
  final int weekday;
  final String startsAt;
  final String endsAt;
  final bool isActive;

  const AttendanceSchedule({
    required this.id,
    required this.classId,
    required this.weekday,
    required this.startsAt,
    required this.endsAt,
    required this.isActive,
  });

  factory AttendanceSchedule.fromMap(Map<String, dynamic> map) =>
      AttendanceSchedule(
        id: map['id'] as int,
        classId: map['class_id'] as String,
        weekday: map['weekday'] as int,
        startsAt: map['starts_at'] as String,
        endsAt: map['ends_at'] as String,
        isActive: map['is_active'] as bool,
      );

  Map<String, dynamic> toMap() => {
    'id': id,
    'class_id': classId,
    'weekday': weekday,
    'starts_at': startsAt,
    'ends_at': endsAt,
    'is_active': isActive,
  };
}

class AttendanceSession {
  final String id;
  final String classId;
  final DateTime startsAt;
  final DateTime endsAt;
  final bool isRequestOpen;
  final bool isEnded;

  const AttendanceSession({
    required this.id,
    required this.classId,
    required this.startsAt,
    required this.endsAt,
    required this.isRequestOpen,
    required this.isEnded,
  });

  factory AttendanceSession.fromMap(Map<String, dynamic> map) =>
      AttendanceSession(
        id: map['id'] as String,
        classId: map['class_id'] as String,
        startsAt: DateTime.parse(map['starts_at'] as String),
        endsAt: DateTime.parse(map['ends_at'] as String),
        isRequestOpen: map['request_open'] as bool? ?? false,
        isEnded: map['session_ended'] as bool? ?? false,
      );
}

class AttendanceRecord {
  final String id;
  final String classId;
  final String sessionId;
  final String studentId;
  final String status;
  final DateTime requestedAt;
  final DateTime? reviewedAt;

  const AttendanceRecord({
    required this.id,
    required this.classId,
    required this.sessionId,
    required this.studentId,
    required this.status,
    required this.requestedAt,
    this.reviewedAt,
  });

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) =>
      AttendanceRecord(
        id: map['id'] as String,
        classId: map['class_id'] as String,
        sessionId: map['session_id'] as String,
        studentId: map['student_id'] as String,
        status: map['status'] as String,
        requestedAt: DateTime.parse(map['requested_at'] as String),
        reviewedAt: map['reviewed_at'] == null
            ? null
            : DateTime.parse(map['reviewed_at'] as String),
      );
}

class AttendanceOverview {
  final List<AttendanceSchedule> schedules;
  final AttendanceSession? todaySession;
  final List<AttendanceRecord> records;
  final List<DateTime> studentAttendanceDates;

  const AttendanceOverview({
    required this.schedules,
    required this.todaySession,
    required this.records,
    required this.studentAttendanceDates,
  });
}
