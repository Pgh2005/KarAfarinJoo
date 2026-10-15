import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karafarini/core/providers/session_providers.dart';
import 'package:karafarini/features/profile/data/profile_photo_service.dart';

final profilePhotoServiceProvider = Provider<ProfilePhotoService>((ref) {
  return ProfilePhotoService(ref.watch(supabaseProvider));
});

final profilePhotoUrlProvider = FutureProvider.autoDispose
    .family<String?, String?>((ref, avatarUrl) {
      if (avatarUrl?.trim().isNotEmpty != true) return null;

      return ref.watch(profilePhotoServiceProvider).getDisplayUrl(avatarUrl);
    });
