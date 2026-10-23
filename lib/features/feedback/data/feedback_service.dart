import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karafarini/core/providers/session_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class FeedbackSubmissionService {
  Future<void> submit({
    required String category,
    required String title,
    required String message,
  });
}

final feedbackSubmissionServiceProvider = Provider<FeedbackSubmissionService>((
  ref,
) {
  return SupabaseFeedbackSubmissionService(ref.watch(supabaseProvider));
});

class SupabaseFeedbackSubmissionService implements FeedbackSubmissionService {
  final SupabaseClient _supabase;

  const SupabaseFeedbackSubmissionService(this._supabase);

  @override
  Future<void> submit({
    required String category,
    required String title,
    required String message,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('برای ارسال بازخورد باید وارد حساب کاربری شوید.');
    }

    final normalizedTitle = title.trim();
    final normalizedMessage = message.trim();
    if (!{'issue', 'suggestion', 'other'}.contains(category)) {
      throw ArgumentError.value(category, 'category', 'دسته‌بندی معتبر نیست.');
    }
    if (normalizedTitle.isEmpty || normalizedTitle.length > 120) {
      throw ArgumentError('عنوان باید بین ۱ تا ۱۲۰ نویسه باشد.');
    }
    if (normalizedMessage.isEmpty || normalizedMessage.length > 3000) {
      throw ArgumentError('توضیحات باید بین ۱ تا ۳۰۰۰ نویسه باشد.');
    }

    await _supabase.from('user_feedback').insert({
      'user_id': userId,
      'category': category,
      'title': normalizedTitle,
      'message': normalizedMessage,
    });
  }
}
