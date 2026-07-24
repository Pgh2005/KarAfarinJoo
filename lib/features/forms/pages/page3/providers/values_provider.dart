import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:karafarini/features/forms/pages/page1/providers/personal_info_provider.dart'; 
import '../models/values_model.dart';
import '../services/values_service.dart';

final valuesServiceProvider = Provider((ref) => ValuesService());

final valuesNotifierProvider =
    StateNotifierProvider.family<
      ValuesNotifier,
      AsyncValue<ValuesModel>,
      FormParams
    >((ref, params) {
      return ValuesNotifier(ref.watch(valuesServiceProvider), params);
    });

class ValuesNotifier extends StateNotifier<AsyncValue<ValuesModel>> {
  final ValuesService _service;
  final FormParams _params;

  ValuesNotifier(this._service, this._params) : super(const AsyncLoading()) {
    loadData();
  }

  Future<void> loadData() async {
    state = const AsyncLoading();
    try {
      final data = await _service.fetchValues(
        _params.studentId,
        _params.classId,
      );
      state = AsyncData(data);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  void updateState(ValuesModel Function(ValuesModel) update) {
    if (state is AsyncData<ValuesModel>) {
      state = AsyncData(update(state.asData!.value));
    }
  }

  Future<bool> saveData() async {
    if (state is! AsyncData<ValuesModel>) return false;
    try {
      await _service.upsertValues(
        state.asData!.value,
        _params.studentId,
        _params.classId,
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
