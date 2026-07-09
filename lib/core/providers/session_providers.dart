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
