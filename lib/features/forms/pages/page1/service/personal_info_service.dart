import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/personal_info_model.dart';

class PersonalInfoService {
  final SupabaseClient _client;

  PersonalInfoService(this._client);

  Future<PersonalInfoModel?> fetchPersonalInfo({
    required String classId,
    required String studentId,
  }) async {
    final response = await _client
        .from('personal_info_responses')
        .select()
        .eq('class_id', classId)
        .eq('student_id', studentId)
        .maybeSingle();

    if (response == null) return null;
    return PersonalInfoModel.fromJson(response);
  }

  Future<PersonalInfoModel> savePersonalInfo(PersonalInfoModel model) async {
    final response = await _client
        .from('personal_info_responses')
        .upsert(model.toJson(), onConflict: 'class_id,student_id')
        .select()
        .single();

    return PersonalInfoModel.fromJson(response);
  }
}
