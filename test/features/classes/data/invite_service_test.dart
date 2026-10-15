import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:karafarini/features/classes/data/invite_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  late HttpServer server;
  late SupabaseClient client;
  late InviteService service;
  final requests = <({String method, String path, String body})>[];

  setUp(() async {
    requests.clear();
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      final body = await utf8.decoder.bind(request).join();
      requests.add((
        method: request.method,
        path: request.uri.path,
        body: body,
      ));
      request.response.statusCode = HttpStatus.noContent;
      await request.response.close();
    });

    client = SupabaseClient(
      'http://127.0.0.1:${server.port}',
      'test-key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );
    service = InviteService(client);
  });

  tearDown(() async {
    await client.dispose();
    await server.close(force: true);
  });

  test(
    'approval reviews request through the atomic database function',
    () async {
      await service.approveRequest(requestId: 'request-1');

      expect(requests, hasLength(1));
      expect(requests.single.method, 'POST');
      expect(requests.single.path, '/rest/v1/rpc/review_class_join_request');
      expect(jsonDecode(requests.single.body), {
        'p_request_id': 'request-1',
        'p_decision': 'approved',
      });
    },
  );

  test(
    'rejection reviews request through the atomic database function',
    () async {
      await service.rejectRequest(requestId: 'request-2');

      expect(requests, hasLength(1));
      expect(requests.single.method, 'POST');
      expect(requests.single.path, '/rest/v1/rpc/review_class_join_request');
      expect(jsonDecode(requests.single.body), {
        'p_request_id': 'request-2',
        'p_decision': 'rejected',
      });
    },
  );
}
