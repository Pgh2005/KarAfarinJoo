import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/business_selection_model.dart';

class BusinessSelectionService {
  final _supabase = Supabase.instance.client;

  Future<BusinessSelectionModel> fetchSelection(
    String studentId,
    String classId,
  ) async {
    try {
      final response = await _supabase
          .from('business_selections')
          .select(
            'id, biz_name_1, biz_name_2, biz_name_3, business_selection_criteria(criterion_title, category, weight, score_1, score_2, score_3)',
          )
          .eq('student_id', studentId)
          .eq('class_id', classId)
          .maybeSingle();

      if (response == null) return BusinessSelectionModel.empty();
      return BusinessSelectionModel.fromJson(response);
    } catch (e) {
      throw Exception('خطا در دریافت اطلاعات ارزیابی کسب‌و‌کار: $e');
    }
  }

  Future<void> saveSelection(
    BusinessSelectionModel model,
    String studentId,
    String classId,
  ) async {
    try {
      final parentResponse = await _supabase
          .from('business_selections')
          .upsert(
            model.toParentJson(studentId, classId),
            onConflict: 'student_id, class_id',
          )
          .select('id')
          .single();

      final selectionId = parentResponse['id'] as String;
      final criteriaJson = model.criteria
          .map((c) => c.toJson(selectionId))
          .toList();

      await _supabase
          .from('business_selection_criteria')
          .upsert(criteriaJson, onConflict: 'selection_id, criterion_title');
    } catch (e) {
      throw Exception('خطا در ذخیره‌سازی اطلاعات: $e');
    }
  }
}
