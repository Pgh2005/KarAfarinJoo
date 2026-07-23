import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authUserProvider = StreamProvider<User?>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase.auth.onAuthStateChange.map((event) => event.session?.user);
});

final currentUserIdProvider = Provider<String?>((ref) {
  final asyncUser = ref.watch(authUserProvider);
  return switch (asyncUser) {
    AsyncData(:final value) => value?.id,
    _ => Supabase.instance.client.auth.currentUser?.id,
  };
});

final currentUserRoleProvider = FutureProvider<String>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return 'student';

  final supabase = ref.read(supabaseProvider);

  final response = await supabase
      .from('profiles')
      .select('role')
      .eq('id', userId)
      .single();

  return response['role'] as String? ?? 'student';
});

final isReadOnlyProvider = Provider<bool>((ref) {
  final roleAsync = ref.watch(currentUserRoleProvider);
  return roleAsync.maybeWhen(
    data: (role) => role == 'teacher' || role == 'admin',
    orElse: () => true,
  );
});
