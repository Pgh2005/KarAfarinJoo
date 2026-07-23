import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:karafarini/core/theme/app_theme.dart';
import 'package:karafarini/core/providers/session_providers.dart';
import 'package:karafarini/features/profile/providers/current_session_profile_provider.dart';

class StudentClassDetailSection extends ConsumerWidget {
  final String classModelId;

  const StudentClassDetailSection({super.key, required this.classModelId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentId = ref.watch(currentUserIdProvider) ?? '';
    final profileAsync = ref.watch(currentSessionProfileProvider);
    final studentName = profileAsync.maybeWhen(
      data: (profile) => profile?.fullName ?? 'دانشجو',
      orElse: () => 'دانشجو',
    );

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          context.pushNamed(
            'form-list',
            queryParameters: {
              'classId': classModelId,
              'studentId': studentId,
              'studentName': studentName,
            },
          );
        },
        icon: const Icon(Icons.assignment_outlined),
        label: const Text('مشاهده و تکمیل فرم‌ها'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary.withValues(alpha: 0.9),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
