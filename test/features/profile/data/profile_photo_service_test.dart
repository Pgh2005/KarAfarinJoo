import 'package:flutter_test/flutter_test.dart';
import 'package:karafarini/features/profile/data/profile_photo_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('keeps legacy photo URLs and handles empty profile photos', () async {
    final client = SupabaseClient(
      'https://example.com',
      'test-key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );
    addTearDown(client.dispose);

    final service = ProfilePhotoService(client);

    expect(await service.getDisplayUrl(null), isNull);
    expect(await service.getDisplayUrl('  '), isNull);
    expect(
      await service.getDisplayUrl('https://example.com/legacy-photo.jpg'),
      'https://example.com/legacy-photo.jpg',
    );
  });
}
