import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/class_model.dart';

class ClassService {
  final SupabaseClient _client = Supabase.instance.client;

  // ۱. ساخت کلاس جدید (مخصوص استاد)
  Future<ClassModel> createClass({
    required String title,
    required String courseCode,
    required String semester,
    String? description,
    required String joinCode,
    required int maxStudents,
  }) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) throw Exception('کاربر وارد نشده است.');

    final response = await _client
        .from('classes')
        .insert({
          'teacher_id': currentUser.id,
          'title': title,
          'course_code': courseCode,
          'semester': semester,
          'description': description,
          'join_code': joinCode,
          'max_students': maxStudents,
        })
        .select()
        .single();

    return ClassModel.fromJson(response);
  }

  // ۲. دریافت کلاس‌های ساخته شده توسط استاد
  Future<List<ClassModel>> getProfessorClasses() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) return [];

    final response = await _client
        .from('classes')
        .select()
        .eq('teacher_id', currentUser.id)
        .order('created_at', ascending: false);

    return (response as List).map((json) => ClassModel.fromJson(json)).toList();
  }

  // ۳. دریافت کلاس‌هایی که دانشجو عضو آن‌هاست (تایید شده)
  Future<List<ClassModel>> getStudentClasses() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) return [];

    // ابتدا آیدی کلاس‌هایی که دانشجو عضو است را دریافت می‌کنیم
    final membersResponse = await _client
        .from('class_members')
        .select('*, classes(*, profiles(full_name))')
        .eq('student_id', currentUser.id);

    final List<ClassModel> classes = [];
    for (var member in membersResponse as List) {
      if (member['classes'] != null) {
        classes.add(ClassModel.fromJson(member['classes']));
      }
    }
    return classes;
  }

  // ۴. ارسال درخواست عضویت در کلاس با کد کلاس (مخصوص دانشجو)
  Future<void> requestToJoinClass(String joinCode) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) throw Exception('ابتدا وارد شوید.');

    // پیدا کردن کلاس با استفاده از joinCode
    final classResponse = await _client
        .from('classes')
        .select()
        .eq('join_code', joinCode)
        .maybeSingle();

    if (classResponse == null) {
      throw Exception('کلاسی با این کد یافت نشد.');
    }

    final classId = classResponse['id'] as String;

    // ثبت درخواست عضویت در جدول class_join_requests
    await _client.from('class_join_requests').insert({
      'class_id': classId,
      'student_id': currentUser.id,
      'status': 'pending',
    });
  }
}
