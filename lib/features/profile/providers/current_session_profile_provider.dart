import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karafarini/core/providers/session_providers.dart';
import 'package:karafarini/features/profile/models/profile.dart';

final currentSessionProfileProvider = FutureProvider<Profile?>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    return null;
  }

  final data = await supabase
      .from('profiles')
      .select()
      .eq('id', userId)
      .single();

  return Profile.fromJson(data);
});

final currentUserRoleProvider = Provider<UserRole?>((ref) {
  final profileAsync = ref.watch(currentSessionProfileProvider);

  return profileAsync.maybeWhen(
    data: (profile) => profile?.role,
    orElse: () => null,
  );
});

final isProfessorProvider = Provider<bool>((ref) {
  final role = ref.watch(currentUserRoleProvider);
  return role == UserRole.professor;
});

final isStudentProvider = Provider<bool>((ref) {
  final role = ref.watch(currentUserRoleProvider);
  return role == UserRole.student;
});
