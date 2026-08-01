import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:karafarini/core/providers/session_providers.dart';
import '../data/invite_service.dart';
import '../models/join_request_with_profile_model.dart';

final inviteServiceProvider = Provider<InviteService>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return InviteService(supabase);
});

/// Global set of request ids the student has dismissed locally. This is used
/// to immediately hide dismissed notifications from the UI (badge and list)
/// without waiting for a DB round-trip or when the backend doesn't allow
/// deletion.
final dismissedRequestIdsProvider = StateProvider<Set<String>>((_) => {});

final pendingInviteRequestsProvider =
    FutureProvider.autoDispose<List<JoinRequestWithProfile>>((ref) async {
      final service = ref.watch(inviteServiceProvider);
      final userId = ref.watch(currentUserIdProvider);
      final roleAsync = ref.watch(currentUserRoleProvider);

      if (userId == null) return [];

      final isProfessor = roleAsync.maybeWhen(
        data: (r) => r == 'professor' || r == 'teacher',
        orElse: () => false,
      );

      List<JoinRequestWithProfile> list;
      if (isProfessor) {
        list = await service.getPendingRequestsForTeacher(userId);
      } else {
        // For students return their own requests so they can view the status
        list = await service.getRequestsForStudent(userId);
      }

      final dismissed = ref.watch(dismissedRequestIdsProvider);
      if (dismissed.isEmpty) return list;

      return list.where((r) => !dismissed.contains(r.request.id)).toList();
    });
