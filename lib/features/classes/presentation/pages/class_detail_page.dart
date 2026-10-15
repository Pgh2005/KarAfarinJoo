import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:karafarini/core/providers/session_providers.dart';
import 'package:karafarini/core/theme/app_theme.dart';
import 'package:karafarini/core/widgets/app_bar_builder.dart';
import 'package:karafarini/features/classes/models/class_model.dart';
import 'package:karafarini/features/classes/presentation/widgets/class_detail/class_detail_header.dart';
import 'package:karafarini/features/classes/presentation/widgets/class_detail/class_members_section.dart';
import 'package:karafarini/features/classes/presentation/widgets/class_detail/student_class_detail_section.dart';
import 'package:karafarini/features/classes/providers/classes_provider.dart';
import 'package:karafarini/features/classes/providers/invite_provider.dart';
import 'package:karafarini/features/profile/providers/current_session_profile_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClassDetailPage extends ConsumerStatefulWidget {
  final ClassModel classModel;

  const ClassDetailPage({super.key, required this.classModel});

  @override
  ConsumerState<ClassDetailPage> createState() => _ClassDetailPageState();
}

class _ClassDetailPageState extends ConsumerState<ClassDetailPage> {
  bool _isDeleting = false;

  Future<void> _deleteClass() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف دائمی کلاس'),
        content: Text(
          'کلاس «${widget.classModel.title}» و تمام اطلاعات وابسته به آن، '
          'از جمله عضویت دانشجویان و پاسخ‌های فرم‌های این کلاس، برای همیشه '
          'حذف می‌شوند. حساب‌ها و پروفایل‌های دانشجویان حذف نخواهند شد. '
          'این عملیات قابل بازگشت نیست.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف دائمی'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !mounted) return;

    final teacherId = ref.read(currentUserIdProvider);
    if (teacherId == null || teacherId != widget.classModel.teacherId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('فقط ایجادکنندهٔ کلاس می‌تواند آن را حذف کند.'),
        ),
      );
      return;
    }

    setState(() => _isDeleting = true);
    try {
      await ref
          .read(classActionsProvider)
          .deleteClass(classId: widget.classModel.id);

      ref.invalidate(teacherClassesProvider);
      ref.invalidate(studentClassesProvider);
      ref.invalidate(classMembersProvider(widget.classModel.id));
      ref.invalidate(pendingInviteRequestsProvider);

      if (mounted) context.pop(true);
    } on PostgrestException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حذف کلاس ناموفق بود: ${error.message}')),
        );
      }
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('حذف کلاس ناموفق بود: $error')));
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isProfessor = ref.watch(isProfessorProvider);
    final isClassOwner =
        ref.watch(currentUserIdProvider) == widget.classModel.teacherId;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBarBuilder(
        title: 'جزئیات کلاس',
        actions: [
          if (isProfessor && isClassOwner)
            IconButton(
              tooltip: 'حذف کلاس',
              onPressed: _isDeleting ? null : _deleteClass,
              icon: _isDeleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primary,
          onRefresh: () async {
            ref.invalidate(teacherClassesProvider);
            ref.invalidate(studentClassesProvider);
            ref.invalidate(classMembersProvider(widget.classModel.id));
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ClassDetailHeader(classModel: widget.classModel),
              const SizedBox(height: 24),
              isProfessor
                  ? ClassMembersSection(classId: widget.classModel.id)
                  : StudentClassDetailSection(
                      classModelId: widget.classModel.id,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
