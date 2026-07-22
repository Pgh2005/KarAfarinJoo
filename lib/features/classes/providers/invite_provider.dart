import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karafarini/core/providers/session_providers.dart';
import '../data/invite_service.dart';
import '../models/join_request_with_profile_model.dart';

final inviteServiceProvider = Provider<InviteService>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return InviteService(supabase);
});

final pendingInviteRequestsProvider = FutureProvider.autoDispose<List<JoinRequestWithProfile>>((ref) async {
  final service = ref.watch(inviteServiceProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) return [];

  return service.getPendingRequestsForTeacher(userId);
});
