import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  final _client = Supabase.instance.client;

  Future<void> signUp({
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
  }) async {
    await _client.auth.signUp(
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

  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => _client.auth.signOut();

  static String formatAuthError(Object error) {
    if (error is AuthException) {
      final code = error.code?.toLowerCase();
      final normalized = error.message.toLowerCase();

      if (code == 'email_exists' ||
          code == 'user_already_exists' ||
          code == 'conflict' ||
          normalized.contains('user already registered') ||
          normalized.contains('already registered') ||
          normalized.contains('already exists') ||
          normalized.contains('duplicate key value')) {
        return 'این ایمیل یا کاربر قبلاً ثبت شده است. لطفاً از صفحه ورود استفاده کنید.';
      }

      if (code == 'phone_exists' ||
          normalized.contains('phone number is already registered')) {
        return 'این شماره تلفن قبلاً ثبت شده است.';
      }

      if (normalized.contains('invalid login credentials') ||
          normalized.contains('invalid email or password') ||
          normalized.contains('invalid password') ||
          normalized.contains('incorrect email') ||
          normalized.contains('incorrect password')) {
        return 'ایمیل یا رمز عبور اشتباه است.';
      }

      if (normalized.contains('password should be at least') ||
          normalized.contains('weak password')) {
        return 'رمز عبور باید حداقل ۶ کاراکتر باشد.';
      }

      if (normalized.contains('invalid email address') ||
          normalized.contains('invalid email')) {
        return 'ایمیل وارد شده معتبر نیست.';
      }

      if (normalized.contains('signup disabled')) {
        return 'ثبت‌نام در حال حاضر غیرفعال است.';
      }

      return error.message.isNotEmpty
          ? error.message
          : 'خطای احراز هویت رخ داد. لطفاً دوباره تلاش کنید.';
    }

    final message = error.toString();
    final normalized = message.toLowerCase();

    if (normalized.contains('user already registered') ||
        normalized.contains('already registered') ||
        normalized.contains('already exists') ||
        normalized.contains('duplicate key value')) {
      return 'این ایمیل یا کاربر قبلاً ثبت شده است. لطفاً از صفحه ورود استفاده کنید.';
    }

    if (normalized.contains('invalid email address') ||
        normalized.contains('invalid email')) {
      return 'ایمیل وارد شده معتبر نیست.';
    }

    return message.isNotEmpty
        ? message
        : 'خطای احراز هویت رخ داد. لطفاً دوباره تلاش کنید.';
  }
}
