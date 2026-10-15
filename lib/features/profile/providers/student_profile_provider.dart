import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karafarini/core/providers/session_providers.dart';
import 'package:karafarini/features/profile/data/student_profile_service.dart';
import 'package:karafarini/features/profile/models/profile.dart';

final studentProfileServiceProvider = Provider<StudentProfileService>((ref) {
  return StudentProfileService(ref.watch(supabaseProvider));
});

final studentProfileProvider = FutureProvider.autoDispose
    .family<Profile, ({String classId, String studentId})>((ref, args) {
      return ref
          .watch(studentProfileServiceProvider)
          .getStudentProfile(classId: args.classId, studentId: args.studentId);
    });
