import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/talent_model.dart';
import '../services/talent_service.dart';

@immutable
class TalentParams {
  final String classId;
  final String studentId;

  const TalentParams({required this.classId, required this.studentId});

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TalentParams &&
            other.classId == classId &&
            other.studentId == studentId;
  }

  @override
  int get hashCode => Object.hash(classId, studentId);
}

final talentServiceProvider = Provider<TalentService>((ref) {
  return TalentService();
});

final talentProvider =
    StateNotifierProvider.family<
      TalentNotifier,
      AsyncValue<TalentModel>,
      TalentParams
    >((ref, params) {
      final service = ref.read(talentServiceProvider);
      return TalentNotifier(service: service, params: params);
    });

class TalentNotifier extends StateNotifier<AsyncValue<TalentModel>> {
  TalentNotifier({required TalentService service, required TalentParams params})
    : _service = service,
      _params = params,
      super(const AsyncValue.loading()) {
    _load();
  }

  final TalentService _service;
  final TalentParams _params;

  Future<void> _load() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      return _service.fetchTalent(
        classId: _params.classId,
        studentId: _params.studentId,
      );
    });
  }

  Future<void> reload() async {
    await _load();
  }

  Future<void> save(TalentModel model) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      await _service.saveTalent(model);
      return model;
    });
  }
}
