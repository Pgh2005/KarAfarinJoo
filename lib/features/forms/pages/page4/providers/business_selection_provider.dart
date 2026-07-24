import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:karafarini/features/forms/pages/page1/providers/personal_info_provider.dart';
import '../models/business_selection_model.dart';
import '../services/business_selection_service.dart';

final businessSelectionServiceProvider = Provider(
  (ref) => BusinessSelectionService(),
);

final businessSelectionNotifierProvider =
    StateNotifierProvider.family<
      BusinessSelectionNotifier,
      AsyncValue<BusinessSelectionModel>,
      FormParams
    >((ref, params) {
      return BusinessSelectionNotifier(
        ref.watch(businessSelectionServiceProvider),
        params,
      );
    });

class BusinessSelectionNotifier
    extends StateNotifier<AsyncValue<BusinessSelectionModel>> {
  final BusinessSelectionService _service;
  final FormParams _params;

  BusinessSelectionNotifier(this._service, this._params)
    : super(const AsyncLoading()) {
    loadData();
  }

  Future<void> loadData() async {
    state = const AsyncLoading();
    try {
      final data = await _service.fetchSelection(
        _params.studentId,
        _params.classId,
      );
      state = AsyncData(data);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  void updateState(
    BusinessSelectionModel Function(BusinessSelectionModel) update,
  ) {
    if (state is AsyncData<BusinessSelectionModel>) {
      state = AsyncData(update(state.asData!.value));
    }
  }

  Future<bool> saveData() async {
    if (state is! AsyncData<BusinessSelectionModel>) return false;

    try {
      await _service.saveSelection(
        state.asData!.value,
        _params.studentId,
        _params.classId,
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
