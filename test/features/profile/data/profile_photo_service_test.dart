import 'dart:convert';
import 'dart:io';

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

  test(
    'creates signed URLs in one request and reuses them from cache',
    () async {
      final requests = <String>[];
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((request) async {
        requests.add(request.uri.path);
        final body = await utf8.decoder.bind(request).join();
        final paths =
            (jsonDecode(body) as Map<String, dynamic>)['paths'] as List;
        request.response.headers.contentType = ContentType.json;
        request.response.write(
          jsonEncode(
            paths
                .map(
                  (path) => {
                    'path': path,
                    'signedURL': '/object/sign/$path?token=test',
                  },
                )
                .toList(),
          ),
        );
        await request.response.close();
      });

      final client = SupabaseClient(
        'http://127.0.0.1:${server.port}',
        'test-key',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
      );
      addTearDown(client.dispose);
      addTearDown(() => server.close(force: true));

      final service = ProfilePhotoService(client);
      final urls = await service.getDisplayUrls([
        'student-1/profile',
        'student-2/profile',
      ]);
      final cachedUrl = await service.getDisplayUrl('student-1/profile');

      expect(requests, hasLength(1));
      expect(requests.single, '/storage/v1/object/sign/student-profile-photos');
      expect(
        urls['student-1/profile'],
        endsWith('/student-1/profile?token=test'),
      );
      expect(
        urls['student-2/profile'],
        endsWith('/student-2/profile?token=test'),
      );
      expect(cachedUrl, urls['student-1/profile']);
    },
  );
}
