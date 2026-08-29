import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:karafarini/features/forms/pages/page1/providers/personal_info_provider.dart';

import '../models/product_priority_model.dart';
import '../services/product_priority_service.dart';

final productPriorityServiceProvider = Provider<ProductPriorityService>((ref) {
  return ProductPriorityService();
});

final productPriorityNotifierProvider =
    StateNotifierProvider.family<
      ProductPriorityNotifier,
      AsyncValue<ProductPriorityModel>,
      FormParams
    >((ref, params) {
      final service = ref.watch(productPriorityServiceProvider);
      return ProductPriorityNotifier(service, params);
    });

class ProductPriorityNotifier
    extends StateNotifier<AsyncValue<ProductPriorityModel>> {
  final ProductPriorityService _service;
  final FormParams _params;

  ProductPriorityNotifier(this._service, this._params)
    : super(const AsyncLoading()) {
    loadData();
  }

  Future<void> loadData() async {
    state = const AsyncLoading();
    try {
      final data = await _service.fetchPriority(
        _params.studentId,
        _params.classId,
      );
      debugPrint('[ProductPriority] Loaded: id=${data.id}, names=${data.productNames}, criteriaCount=${data.criteria.length}');
      debugPrint('[ProductPriority] First criterion weight=${data.criteria.first.weight}, scores=${data.criteria.first.scores}');
      state = AsyncData(data);
    } catch (e, st) {
      debugPrint('[ProductPriority] Error loading: $e');
      state = AsyncError(e, st);
    }
  }

  void updateState(ProductPriorityModel Function(ProductPriorityModel) update) {
    final current = state.asData?.value;
    if (current == null) {
      return;
    }
    state = AsyncData(update(current));
  }

  Future<bool> saveData() async {
    final current = state.asData?.value;
    if (current == null) {
      return false;
    }

    try {
      await _service.savePriority(current, _params.studentId, _params.classId);
      return true;
    } catch (_) {
      return false;
    }
  }
}
