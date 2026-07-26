import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/growth_table_model.dart';

class GrowthTableService {
  final _supabase = Supabase.instance.client;

  Future<List<GrowthPeriod>> fetchData(String studentId, String classId) async {
    final response = await _supabase
        .from('growth_tables')
        .select('periods')
        .eq('student_id', studentId)
        .eq('class_id', classId)
        .maybeSingle();

    if (response == null) return [GrowthPeriod.newEmpty()];
    return (response['periods'] as List)
        .map((p) => GrowthPeriod.fromJson(p))
        .toList();
  }

  Future<void> saveData(
    String studentId,
    String classId,
    List<GrowthPeriod> periods,
  ) async {
    await _supabase.from('growth_tables').upsert({
      'student_id': studentId,
      'class_id': classId,
      'periods': periods.map((p) => p.toJson()).toList(),
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'student_id,class_id');
  }
}
