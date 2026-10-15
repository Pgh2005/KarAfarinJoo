import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:karafarini/features/profile/models/profile.dart';

class StudentProfileService {
  final SupabaseClient _supabase;

  StudentProfileService(this._supabase);

  Future<Profile> getStudentProfile({
    required String classId,
    required String studentId,
  }) async {
    final professorId = _supabase.auth.currentUser?.id;
    if (professorId == null) {
      throw StateError('برای مشاهدهٔ پروفایل وارد حساب کاربری شوید.');
    }

    final professor = await _supabase
        .from('profiles')
        .select('role')
        .eq('id', professorId)
        .maybeSingle();

    if (professor?['role'] != 'professor') {
      throw StateError('فقط استاد می‌تواند پروفایل دانشجوی کلاس را ببیند.');
    }

    final member = await _supabase
        .from('class_members')
        .select('''
          classes!inner (
            id,
            teacher_id
          ),
          profiles:student_id (
            id,
            role,
            email,
            full_name,
            student_number,
            teacher_number,
            phone,
            major,
            department,
            bio,
            avatar_url,
            is_active,
            created_at,
            updated_at
          )
        ''')
        .eq('class_id', classId)
        .eq('student_id', studentId)
        .eq('classes.teacher_id', professorId)
        .maybeSingle();

    if (member == null) {
      throw StateError(
        'این دانشجو عضو کلاس نیست یا اجازهٔ مشاهدهٔ پروفایل را ندارید.',
      );
    }

    final profileData = member['profiles'];
    final profileMap = switch (profileData) {
      Map<String, dynamic> value => value,
      List<dynamic> values when values.isNotEmpty =>
        values.first as Map<String, dynamic>?,
      _ => null,
    };

    if (profileMap == null) {
      throw StateError('اطلاعات پروفایل دانشجو پیدا نشد.');
    }

    if (profileMap['id'] != studentId || profileMap['role'] != 'student') {
      throw StateError('اطلاعات پروفایل دانشجو معتبر نیست.');
    }

    final profile = Profile.fromJson(profileMap);
    if (profile.id != studentId || profile.role != UserRole.student) {
      throw StateError('اطلاعات پروفایل دانشجو معتبر نیست.');
    }

    return profile;
  }
}
