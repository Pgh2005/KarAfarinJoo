import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/values_model.dart';

class ValuesService {
  final _supabase = Supabase.instance.client;

  Future<ValuesModel> fetchValues(String studentId, String classId) async {
    try {
      final response = await _supabase
          .from('values_responses')
          .select()
          .eq('student_id', studentId)
          .eq('class_id', classId)
          .maybeSingle();

      if (response == null) return ValuesModel.empty();
      return ValuesModel.fromJson(response);
    } catch (e) {
      throw Exception('خطا در دریافت ارزش‌ها: $e');
    }
  }

  Future<void> upsertValues(
    ValuesModel model,
    String studentId,
    String classId,
  ) async {
    await _supabase
        .from('values_responses')
        .upsert(
          model.toJson(studentId, classId),
          onConflict: 'student_id, class_id',
        );
  }
}
