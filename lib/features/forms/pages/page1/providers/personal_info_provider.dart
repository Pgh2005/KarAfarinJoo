import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:karafarini/features/forms/pages/page1/service/personal_info_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/personal_info_model.dart';

// ─── Service Provider ────────────────────────────────────────────────────────
final personalInfoServiceProvider = Provider<PersonalInfoService>((ref) {
  return PersonalInfoService(Supabase.instance.client);
});

// ─── Family Parameter Class ──────────────────────────────────────────────────
class FormParams {
  final String classId;
  final String studentId;

  const FormParams({required this.classId, required this.studentId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FormParams &&
          runtimeType == other.runtimeType &&
          classId == other.classId &&
          studentId == other.studentId;

  @override
  int get hashCode => classId.hashCode ^ studentId.hashCode;
}

// ─── Provider Definition ─────────────────────────────────────────────────────
final personalInfoNotifierProvider =
    StateNotifierProvider.family<
      PersonalInfoNotifier,
      AsyncValue<PersonalInfoModel>,
      FormParams
    >((ref, params) {
      return PersonalInfoNotifier(
        service: ref.watch(personalInfoServiceProvider),
        params: params,
      );
    });

// ─── StateNotifier Class ─────────────────────────────────────────────────────
class PersonalInfoNotifier
    extends StateNotifier<AsyncValue<PersonalInfoModel>> {
  final PersonalInfoService _service;
  final FormParams _params;

  PersonalInfoNotifier({
    required PersonalInfoService service,
    required FormParams params,
  }) : _service = service,
       _params = params,
       super(const AsyncValue.loading()) {
    loadData();
  }

  /// لود اولیه داده‌ها از Supabase
  Future<void> loadData() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final existingData = await _service.fetchPersonalInfo(
        classId: _params.classId,
        studentId: _params.studentId,
      );
      return existingData ??
          PersonalInfoModel(
            classId: _params.classId,
            studentId: _params.studentId,
          );
    });
  }

  /// آپدیت وضعیت محلی در حافظه
  void updateState(
    PersonalInfoModel Function(PersonalInfoModel current) update,
  ) {
    state.whenData((currentData) {
      state = AsyncData(update(currentData));
    });
  }

  /// ذخیره‌سازی نهایی در Supabase
  Future<bool> saveData() async {
    final currentData = state.value;
    if (currentData == null) return false;

    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      return await _service.savePersonalInfo(currentData);
    });

    state = result;
    return !result.hasError;
  }
}
