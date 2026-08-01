import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product_priority_model.dart';

class ProductPriorityService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<ProductPriorityModel> fetchPriority(
    String studentId,
    String classId,
  ) async {
    // Use a broader select to be resilient to schema variations and ensure
    // the parent row and nested criteria are returned if present.
    final response = await _supabase
        .from('product_priorities')
        .select('*, product_priority_criteria(*)')
        .eq('student_id', studentId)
        .eq('class_id', classId)
        .maybeSingle();

    if (response == null) {
      return ProductPriorityModel.empty();
    }

    // Supabase sometimes returns nested results as maps with lists — ensure
    // we convert the response into a Map<String, dynamic> before parsing.
    return ProductPriorityModel.fromJson(
      Map<String, dynamic>.from(response as Map),
    );
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
