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

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: Colors.red.shade400,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'خطا در دریافت درخواست‌ها',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$error',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          data: (requests) {
            if (requests.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.65,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primary.withValues(alpha: 0.1),
                                AppTheme.primaryLight,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.primary.withValues(alpha: 0.15),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.inbox_outlined,
                            size: 40,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'درخواستی وجود ندارد',
                          style: TextStyle(
                            fontSize: 17,
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            'هنوز هیچ درخواست عضویتی ثبت نشده است',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textHint,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
                      isStudentView: false,
                      onApprove: () async {
                        await _handleApprove(context, ref, item);
                      },
                      onReject: () async {
                        await _handleReject(context, ref, item);
                      },
                    );
                  }

                  // Students only see requests while they are pending review.
                  return _RequestCard(
                    studentName: item.studentName ?? 'بدون نام',
                    studentEmail: item.studentEmail ?? '',
                    className: item.className,
                    message: item.request.message,
                    createdAt: item.request.createdAt,
                    status: item.request.status,
                    isStudentView: true,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleApprove(BuildContext context, WidgetRef ref, item) async {
    final studentName = item.studentName ?? 'این دانشجو';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.green, size: 24),
            SizedBox(width: 8),
            Text('تایید درخواست'),
          ],
        ),
        content: Text(
          'آیا می‌خواهید $studentName را به کلاس "${item.className}" اضافه کنید؟',
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'انصراف',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'تایید',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) throw Exception('کاربر یافت نشد');

      final service = ref.read(inviteServiceProvider);
      await service.approveRequest(requestId: item.request.id);

      ref.invalidate(pendingInviteRequestsProvider);
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

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.cancel_rounded, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Text('رد درخواست'),
          ],
        ),
        content: Text(
          'آیا می‌خواهید درخواست $studentName را رد کنید؟ پس از رد، درخواست از فهرست حذف می‌شود.',
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'انصراف',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'رد کردن',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) throw Exception('کاربر یافت نشد');

      final service = ref.read(inviteServiceProvider);
      await service.rejectRequest(requestId: item.request.id);

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
  final bool isStudentView;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const _RequestCard({
    required this.studentName,
    required this.studentEmail,
    required this.className,
    this.message,
    required this.createdAt,
    required this.status,
    this.isStudentView = false,
    this.onApprove,
    this.onReject,
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
            color: AppTheme.cardShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primary.withValues(alpha: 0.1),
                        AppTheme.primaryLight,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: AppTheme.primary,
                    size: 22,
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
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (studentEmail.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          studentEmail,
                          style: const TextStyle(
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
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textHint,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Notification description line
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.notifications_outlined,
                    size: 16,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isStudentView
                          ? 'درخواست عضویت شما در کلاس "$className" ثبت شد.'
                          : '$studentName درخواست عضویت در کلاس "$className" را ارسال کرده است.',
                      style: const TextStyle(
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
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.border, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.message_outlined,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        SizedBox(width: 6),
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
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),

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
                        side: BorderSide(
                          color: Colors.red.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
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
                        elevation: 0,
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
              // Student view
              if (status == JoinRequestStatus.pending) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.hourglass_top_rounded,
                          size: 20,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'در حال بررسی',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'درخواست شما برای کلاس "$className" ثبت شد و هم‌اکنون در دست بررسی است. به زودی نتیجه اعلام می‌شود.',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
