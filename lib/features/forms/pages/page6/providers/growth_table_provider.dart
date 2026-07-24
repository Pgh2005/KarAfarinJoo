import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/growth_table_model.dart';
import '../services/growth_table_service.dart';

class GrowthTableParams {
  final String studentId;
  final String classId;

  GrowthTableParams({required this.studentId, required this.classId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GrowthTableParams &&
          studentId == other.studentId &&
          classId == other.classId;

  @override
  int get hashCode => studentId.hashCode ^ classId.hashCode;
}

final growthTableProvider =
    StateNotifierProvider.family<
      GrowthTableNotifier,
      AsyncValue<List<GrowthPeriod>>,
      GrowthTableParams
    >((ref, params) {
      return GrowthTableNotifier(GrowthTableService(), params);
    });

class GrowthTableNotifier
    extends StateNotifier<AsyncValue<List<GrowthPeriod>>> {
  final GrowthTableService _service;
  final GrowthTableParams _params;

  GrowthTableNotifier(this._service, this._params)
    : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _service.fetchData(_params.studentId, _params.classId);
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void addPeriod() {
    state.whenData((periods) {
      state = AsyncValue.data([...periods, GrowthPeriod.newEmpty()]);
    });
  }

  void removePeriod(int index) {
    state.whenData((periods) {
      if (periods.length > 1 && index < periods.length) {
        final updated = List<GrowthPeriod>.from(periods)..removeAt(index);
        state = AsyncValue.data(updated);
      }
    });
  }

  void updateMetric(int periodIdx, int metricIdx, String field, String value) {
    state.whenData((periods) {
      final period = periods[periodIdx];
      final metric = period.metrics[metricIdx];

      if (field == 'current') {
        metric.currentValue = value;
      } else if (field == 'target') {
        metric.target = value;
      } else if (field == 'result') {
        metric.result = value;
      }

      state = AsyncValue.data([...periods]);
    });
  }

  void updateDates(int periodIdx, String start, String target) {
    state.whenData((periods) {
      periods[periodIdx].startDate = start;
      periods[periodIdx].targetDate = target;
      state = AsyncValue.data([...periods]);
    });
  }

  Future<bool> save() async {
    try {
      await _service.saveData(_params.studentId, _params.classId, state.value!);
      return true;
    } catch (e) {
      return false;
    }
  }
}
