import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  final _client = Supabase.instance.client;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? studentNumber,
    String? teacherNumber,
    String? phone,
    String? major,
    String? department,
    String? bio,
    String? avatarUrl,
  }) {
    return _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': role,
        'student_number': studentNumber ?? '',
        'teacher_number': teacherNumber ?? '',
        'phone': phone ?? '',
        'major': major ?? '',
        'department': department ?? '',
        'bio': bio ?? '',
        'avatar_url': avatarUrl ?? '',
      },
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => _client.auth.signOut();
}
