import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authUserProvider = Provider<User?>((ref) {
  return Supabase.instance.client.auth.currentUser;
});

final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authUserProvider)?.id;
});
