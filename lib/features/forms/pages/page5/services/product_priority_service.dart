import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product_priority_model.dart';

class ProductPriorityService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<ProductPriorityModel> fetchPriority(
    String studentId,
    String classId,
  ) async {
    final response = await _supabase
        .from('product_priorities')
        .select(
          'id, prod_name_1, prod_name_2, prod_name_3, prod_name_4, '
          'product_priority_criteria(*)',
        )
        .eq('student_id', studentId)
        .eq('class_id', classId)
        .maybeSingle();

    if (response == null) {
      return ProductPriorityModel.empty();
    }

    return ProductPriorityModel.fromJson(response);
  }

  Future<void> savePriority(
    ProductPriorityModel model,
    String studentId,
    String classId,
  ) async {
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
  }
}
