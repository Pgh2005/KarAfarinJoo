import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karafarini/core/theme/app_theme.dart';
import 'package:karafarini/core/widgets/app_bar_builder.dart';
import 'package:karafarini/features/feedback/data/feedback_service.dart';
import 'package:karafarini/features/forms/widgets/form_field_builder.dart';

class FeedbackPage extends ConsumerStatefulWidget {
  const FeedbackPage({super.key});

  @override
  ConsumerState<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends ConsumerState<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _category = 'issue';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting || !(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(feedbackSubmissionServiceProvider)
          .submit(
            category: _category,
            title: _titleController.text,
            message: _messageController.text,
          );
      if (!mounted) return;
      _titleController.clear();
      _messageController.clear();
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('گزارش شما ثبت شد. از اینکه اطلاع دادید سپاسگزاریم.'),
          ),
        );
    } on StateError catch (error) {
      _showError(error.message);
    } on ArgumentError catch (error) {
      _showError(error.message?.toString() ?? 'اطلاعات واردشده معتبر نیست.');
    } on Exception catch (error) {
      _showError('ارسال بازخورد انجام نشد: $error');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String? _validateTitle(String? value) {
    final title = value?.trim() ?? '';
    if (title.isEmpty) return 'عنوان را وارد کنید.';
    if (title.length > 120) return 'عنوان حداکثر ۱۲۰ نویسه باشد.';
    return null;
  }

  String? _validateMessage(String? value) {
    final message = value?.trim() ?? '';
    if (message.isEmpty) return 'توضیحات را وارد کنید.';
    if (message.length > 3000) return 'توضیحات حداکثر ۳۰۰۰ نویسه باشد.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: const AppBarBuilder(
          title: 'ارائهٔ ایراد یا پیشنهاد',
          automaticallyImplyLeading: true,
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.12),
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.chat_bubble_outline, color: AppTheme.primary),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'نظر شما به بهتر شدن برنامه کمک می‌کند. لطفاً مورد را با جزئیات بنویسید.',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: FormBuilder.inputDecoration(
                    label: 'نوع بازخورد',
                    prefixIcon: const Icon(Icons.category_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'issue',
                      child: Text('گزارش ایراد'),
                    ),
                    DropdownMenuItem(
                      value: 'suggestion',
                      child: Text('پیشنهاد'),
                    ),
                    DropdownMenuItem(value: 'other', child: Text('سایر موارد')),
                  ],
                  onChanged: _isSubmitting
                      ? null
                      : (value) {
                          if (value != null) setState(() => _category = value);
                        },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _titleController,
                  enabled: !_isSubmitting,
                  maxLength: 120,
                  textInputAction: TextInputAction.next,
                  validator: _validateTitle,
                  decoration: FormBuilder.inputDecoration(
                    label: 'عنوان',
                    hintText: 'خلاصهٔ ایراد یا پیشنهاد',
                    prefixIcon: const Icon(Icons.short_text),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _messageController,
                  enabled: !_isSubmitting,
                  maxLength: 3000,
                  minLines: 5,
                  maxLines: 9,
                  textInputAction: TextInputAction.newline,
                  validator: _validateMessage,
                  decoration: FormBuilder.inputDecoration(
                    label: 'توضیحات',
                    hintText: 'چه اتفاقی افتاد یا چه چیزی را پیشنهاد می‌کنید؟',
                    prefixIcon: const Icon(Icons.notes_outlined),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_outlined),
                    label: Text(
                      _isSubmitting ? 'در حال ارسال...' : 'ارسال بازخورد',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
