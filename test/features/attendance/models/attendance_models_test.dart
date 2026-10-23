import 'package:flutter_test/flutter_test.dart';
import 'package:karafarini/features/attendance/models/attendance_models.dart';

void main() {
  test('parses a Tehran-local attendance session and request window', () {
    final session = AttendanceSession.fromMap({
      'id': 'session-1',
      'class_id': 'class-1',
      'session_date': '2026-10-23',
      'starts_at': '2026-10-23T09:00:00',
      'ends_at': '2026-10-23T10:30:00',
      'request_open': true,
    });

    expect(session.id, 'session-1');
    expect(session.startsAt, DateTime(2026, 10, 23, 9));
    expect(session.endsAt, DateTime(2026, 10, 23, 10, 30));
    expect(session.isRequestOpen, isTrue);
  });

  test('parses an attendance decision and review timestamp', () {
    final record = AttendanceRecord.fromMap({
      'id': 'record-1',
      'class_id': 'class-1',
      'session_id': 'session-1',
      'student_id': 'student-1',
      'status': 'approved',
      'requested_at': '2026-10-23T08:50:00Z',
      'reviewed_at': '2026-10-23T09:02:00Z',
    });

    expect(record.status, 'approved');
    expect(record.reviewedAt, DateTime.parse('2026-10-23T09:02:00Z'));
  });

  test('parses inactive weekly schedule values', () {
    final schedule = AttendanceSchedule.fromMap({
      'id': 7,
      'class_id': 'class-1',
      'weekday': 5,
      'starts_at': '08:30:00',
      'ends_at': '10:00:00',
      'is_active': false,
    });

    expect(schedule.weekday, 5);
    expect(schedule.startsAt, '08:30:00');
    expect(schedule.isActive, isFalse);
  });
}
