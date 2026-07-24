import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/talent_model.dart';

class TalentService {
  TalentService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<TalentModel> fetchTalent({
    required String classId,
    required String studentId,
  }) async {
    final response = await _client
        .from('talent_responses')
        .select()
        .eq('class_id', classId)
        .eq('student_id', studentId)
        .maybeSingle();

    if (response == null) {
      return TalentModel.empty(classId: classId, studentId: studentId);
    }

    return TalentModel.fromJson(response);
  }

  Future<void> saveTalent(TalentModel model) async {
    await _client
        .from('talent_responses')
        .upsert(model.toJson(), onConflict: 'class_id,student_id');
  }
}
