import 'package:flutter_test/flutter_test.dart';
import 'package:karafarini/features/profile/data/student_profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('rejects unauthenticated profile lookups', () async {
    final client = SupabaseClient(
      'https://example.com',
      'test-key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );
    addTearDown(client.dispose);

    final service = StudentProfileService(client);

    await expectLater(
      service.getStudentProfile(classId: 'class-1', studentId: 'student-1'),
      throwsA(isA<StateError>()),
    );
  });
}
