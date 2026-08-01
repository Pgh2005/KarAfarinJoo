import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karafarini/core/providers/session_providers.dart';
import 'package:karafarini/core/theme/app_theme.dart';
import 'package:karafarini/core/widgets/app_bar_builder.dart';
import 'package:karafarini/features/classes/providers/classes_provider.dart';
import 'package:karafarini/features/classes/providers/invite_provider.dart';
import 'package:karafarini/features/classes/models/join_request_model.dart';

class InviteRequestsPage extends ConsumerWidget {
  const InviteRequestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(pendingInviteRequestsProvider);
    final roleAsync = ref.watch(currentUserRoleProvider);
    final isProfessor = roleAsync.maybeWhen(
      data: (r) => r == 'professor' || r == 'teacher',
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: const AppBarBuilder(
        title: 'درخواست‌های عضویت',
        automaticallyImplyLeading: true,
      ),
      body: requestsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'خطا در دریافت درخواست‌ها:\n$error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
        data: (requests) {
          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 80,
                    color: AppTheme.textSecondary.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'درخواستی وجود ندارد',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(pendingInviteRequestsProvider);
              await ref.read(pendingInviteRequestsProvider.future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = requests[index];

                if (isProfessor) {
                  return _RequestCard(
                    studentName: item.studentName ?? 'بدون نام',
                    studentEmail: item.studentEmail ?? '',
                    className: item.className,
                    message: item.request.message,
                    createdAt: item.request.createdAt,
                    status: item.request.status,
                    onApprove: () async {
                      await _handleApprove(context, ref, item);
                    },
                    onReject: () async {
                      await _handleReject(context, ref, item);
                    },
                  );
                }

                // Student view: no approve/reject buttons. Show delete for rejected requests.
                return _RequestCard(
                  studentName: item.studentName ?? 'بدون نام',
                  studentEmail: item.studentEmail ?? '',
                  className: item.className,
                  message: item.request.message,
                  createdAt: item.request.createdAt,
                  status: item.request.status,
                  onDelete: () async {
                    try {
                      final userId = ref.read(currentUserIdProvider);
                      if (userId == null) throw Exception('کاربر یافت نشد');

                      final service = ref.read(inviteServiceProvider);
                      await service.deleteRequest(
                        requestId: item.request.id,
                        studentId: userId,
                      );

                      ref.invalidate(pendingInviteRequestsProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('اعلان حذف شد'),
                            backgroundColor: Colors.grey,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('خطا: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleApprove(BuildContext context, WidgetRef ref, item) async {
    final studentName = item.studentName ?? 'این دانشجو';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تایید درخواست'),
        content: Text(
          'آیا می‌خواهید $studentName را به کلاس "${item.className}" اضافه کنید؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('تایید'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) throw Exception('کاربر یافت نشد');

      final service = ref.read(inviteServiceProvider);
      await service.approveRequest(
        requestId: item.request.id,
        classId: item.request.classId,
        studentId: item.request.studentId,
        teacherId: userId,
      );

      ref.invalidate(pendingInviteRequestsProvider);
      // Invalidate student classes so the student sees the new class
      // on their next home screen visit
      ref.invalidate(studentClassesProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$studentName با موفقیت به کلاس "${item.className}" اضافه شد',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleReject(BuildContext context, WidgetRef ref, item) async {
    final studentName = item.studentName ?? 'این دانشجو';
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('رد درخواست'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('آیا می‌خواهید درخواست $studentName را رد کنید؟'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'دلیل رد (اختیاری)',
                hintText: 'دلیل رد کردن را وارد کنید',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('رد کردن'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      reasonController.dispose();
      return;
    }

    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) throw Exception('کاربر یافت نشد');

      final service = ref.read(inviteServiceProvider);
      await service.rejectRequest(
        requestId: item.request.id,
        teacherId: userId,
        rejectionReason: reasonController.text.trim().isEmpty
            ? null
            : reasonController.text.trim(),
      );

      reasonController.dispose();
      ref.invalidate(pendingInviteRequestsProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('درخواست $studentName رد شد'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      reasonController.dispose();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطا: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

class _RequestCard extends StatelessWidget {
  final String studentName;
  final String studentEmail;
  final String className;
  final String? message;
  final DateTime createdAt;
  final JoinRequestStatus status;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onDelete;

  const _RequestCard({
    required this.studentName,
    required this.studentEmail,
    required this.className,
    this.message,
    required this.createdAt,
    required this.status,
    this.onApprove,
    this.onReject,
    this.onDelete,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes} دقیقه پیش';
      }
      return '${diff.inHours} ساعت پیش';
    } else if (diff.inDays == 1) {
      return 'دیروز';
    }
    return '${diff.inDays} روز پیش';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: student name + time
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: AppTheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (studentEmail.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          studentEmail,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  _formatDate(createdAt),
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Notification description line
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    size: 16,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$studentName درخواست عضویت در کلاس "$className" را ارسال کرده است.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Message
            if (message != null && message!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.border, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.message_outlined,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'پیام دانشجو:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      message!,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Action Buttons
            if (onApprove != null || onReject != null) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('رد'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onApprove,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('تایید'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Student view: show a status or delete button when appropriate
              if (status == JoinRequestStatus.pending) ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: Chip(
                    label: const Text('در حال بررسی'),
                    backgroundColor: AppTheme.primaryLight,
                  ),
                ),
              ] else if (status == JoinRequestStatus.rejected &&
                  onDelete != null) ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('حذف اعلان'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
