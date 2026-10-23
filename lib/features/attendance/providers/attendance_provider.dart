import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karafarini/core/providers/session_providers.dart';
import 'package:karafarini/features/attendance/data/attendance_service.dart';
import 'package:karafarini/features/attendance/models/attendance_models.dart';
import 'package:karafarini/features/classes/models/class_member_model.dart';
import 'package:karafarini/features/classes/providers/classes_provider.dart';

final attendanceServiceProvider = Provider<AttendanceService>((ref) {
  return AttendanceService(ref.watch(supabaseProvider));
});

final attendanceOverviewProvider = FutureProvider.autoDispose
    .family<AttendanceOverview, String>((ref, classId) {
      return ref.watch(attendanceServiceProvider).getOverview(classId);
    });

final attendanceMembersProvider = FutureProvider.autoDispose
    .family<List<ClassMemberModel>, String>((ref, classId) {
      return ref.watch(classServiceProvider).getClassMembers(classId);
    });
