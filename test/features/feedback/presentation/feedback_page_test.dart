import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karafarini/features/feedback/data/feedback_service.dart';
import 'package:karafarini/features/feedback/presentation/feedback_page.dart';

void main() {
  testWidgets('validates and submits feedback through the service', (
    tester,
  ) async {
    final service = _FakeFeedbackSubmissionService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          feedbackSubmissionServiceProvider.overrideWith((ref) => service),
        ],
        child: const MaterialApp(home: FeedbackPage()),
      ),
    );

    await tester.tap(find.text('ارسال بازخورد'));
    await tester.pumpAndSettle();
    expect(find.text('عنوان را وارد کنید.'), findsOneWidget);
    expect(find.text('توضیحات را وارد کنید.'), findsOneWidget);
    expect(service.submissionCount, 0);

    await tester.enterText(find.byType(TextFormField).at(0), 'مشکل ورود');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'هنگام ورود، پیام خطای نامشخص نمایش داده می‌شود.',
    );
    await tester.tap(find.text('ارسال بازخورد'));
    await tester.pumpAndSettle();

    expect(service.submissionCount, 1);
    expect(service.category, 'issue');
    expect(service.title, 'مشکل ورود');
    expect(service.message, 'هنگام ورود، پیام خطای نامشخص نمایش داده می‌شود.');
    expect(
      find.text('گزارش شما ثبت شد. از اینکه اطلاع دادید سپاسگزاریم.'),
      findsOneWidget,
    );
  });
}

class _FakeFeedbackSubmissionService implements FeedbackSubmissionService {
  int submissionCount = 0;
  String? category;
  String? title;
  String? message;

  @override
  Future<void> submit({
    required String category,
    required String title,
    required String message,
  }) async {
    submissionCount++;
    this.category = category;
    this.title = title;
    this.message = message;
  }
}
