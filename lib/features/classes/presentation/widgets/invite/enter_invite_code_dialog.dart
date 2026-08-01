import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karafarini/core/providers/session_providers.dart';
import 'package:karafarini/core/theme/app_theme.dart';
import 'package:karafarini/core/widgets/loading_indicator.dart';
import 'package:karafarini/features/classes/providers/classes_provider.dart';

class EnterInviteCodeDialog extends ConsumerStatefulWidget {
  const EnterInviteCodeDialog({super.key});

  @override
  ConsumerState<EnterInviteCodeDialog> createState() =>
      _EnterInviteCodeDialogState();
}

class _EnterInviteCodeDialogState extends ConsumerState<EnterInviteCodeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) throw Exception('کاربر یافت نشد');

      final service = ref.read(classServiceProvider);
      await service.sendJoinRequest(
        joinCode: _codeController.text.trim(),
        studentId: userId,
        message: _messageController.text.trim().isEmpty
            ? null
            : _messageController.text.trim(),
      );

      ref.invalidate(studentClassesProvider);

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('درخواست عضویت ارسال شد'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.group_add,
                      color: AppTheme.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'درخواست عضویت',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'کد دعوت را وارد کرده و در صورت نیاز پیامی بنویسید',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Invite Code Field
              TextFormField(
                enabled: !_isLoading,
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: 'کد دعوت *',
                  hintText: 'مثال: ABC123',
                  prefixIcon: const Icon(Icons.vpn_key),
                  filled: true,
                  fillColor: AppTheme.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'کد دعوت الزامی است';
                  }
                  if (value.trim().length != 6) {
                    return 'کد دعوت باید ۶ کاراکتر باشد';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 12),

              // Message Field
              TextFormField(
                enabled: !_isLoading,
                controller: _messageController,
                decoration: InputDecoration(
                  labelText: 'پیام (اختیاری)',
                  hintText: 'پیام خود را برای استاد بنویسید',
                  prefixIcon: const Icon(Icons.message_outlined),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),

              const SizedBox(height: 14),

              // Info Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.primary, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'کد دعوت را از استاد کلاس دریافت کنید. پس از ارسال، میتوانید وضعیت درخواست خود را در بخش اعلان‌ها مشاهده کنید.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('انصراف'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitRequest,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? const AppLoadingIndicator(size: 18, strokeWidth: 2, color: Colors.white)
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send, size: 18),
                                SizedBox(width: 8),
                                Text('ارسال'),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
