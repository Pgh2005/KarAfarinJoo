import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product_priority_model.dart';

class ProductPriorityService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<ProductPriorityModel> fetchPriority(
    String studentId,
    String classId,
  ) async {
    try {
      // Use explicit column listing (like page4) to avoid relying on
      // auto-detected foreign key relationships in Supabase.
      final response = await _supabase
          .from('product_priorities')
          .select(
            'id, student_id, class_id, prod_name_1, prod_name_2, prod_name_3, prod_name_4, '
            'product_priority_criteria(criterion_title, category, description, weight, score_1, score_2, score_3, score_4)',
          )
          .eq('student_id', studentId)
          .eq('class_id', classId)
          .maybeSingle();

      if (response == null) {
        return ProductPriorityModel.empty();
      }

      return ProductPriorityModel.fromJson(
        Map<String, dynamic>.from(response as Map),
      );
    } catch (e) {
      throw Exception('خطا در دریافت اطلاعات اولویت محصولات: $e');
    }
  }

  Future<void> savePriority(
    ProductPriorityModel model,
    String studentId,
    String classId,
  ) async {
    try {
      final parentResponse = await _supabase
          .from('product_priorities')
          .upsert(
            model.toParentJson(studentId, classId),
            onConflict: 'student_id,class_id',
          )
          .select('id')
          .single();

      final priorityId = parentResponse['id'] as String;

      final criteriaJson = model.criteria
          .map((criterion) => criterion.toJson(priorityId))
          .toList();

      await _supabase
          .from('product_priority_criteria')
          .upsert(criteriaJson, onConflict: 'priority_id,criterion_title');
    } catch (e) {
      throw Exception('خطا در ذخیره‌سازی اطلاعات اولویت محصولات: $e');
    }
  }
}
