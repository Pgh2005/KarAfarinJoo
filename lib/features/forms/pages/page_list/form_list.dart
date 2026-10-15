import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:karafarini/core/theme/app_theme.dart';
import 'package:karafarini/core/widgets/app_bar_builder.dart';
import 'package:karafarini/features/classes/providers/classes_provider.dart';
import 'package:karafarini/features/classes/providers/invite_provider.dart';
import 'package:karafarini/features/forms/pages/page1/presentation/personal_info_page.dart';
import 'package:karafarini/features/forms/pages/page2/presentation/talent_page.dart';
import 'package:karafarini/features/forms/pages/page3/presentation/values_page.dart';
import 'package:karafarini/features/forms/pages/page4/presentation/business_selection_page.dart';
import 'package:karafarini/features/forms/pages/page5/presentation/product_priority_page.dart';
import 'package:karafarini/features/forms/pages/page6/presentation/growth_table_page.dart';
import 'package:karafarini/features/forms/widgets/form_progress.dart';
import 'package:karafarini/features/forms/widgets/form_progress_provider.dart';
import 'package:karafarini/features/forms/widgets/progress_bar_widget.dart';
import 'package:karafarini/features/profile/providers/current_session_profile_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FormList extends ConsumerStatefulWidget {
  final String classId;
  final String studentId;
  final String studentName;

  const FormList({
    super.key,
    required this.classId,
    required this.studentId,
    required this.studentName,
  });

  @override
  ConsumerState<FormList> createState() => _FormListState();
}

class _FormListState extends ConsumerState<FormList> {
  bool _isRemovingStudent = false;

  Future<void> _removeStudentFromClass() async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف دانشجو از کلاس'),
        content: Text(
          '${widget.studentName} از این کلاس حذف می‌شود. پاسخ‌های فرم‌ها و '
          'حساب دانشجو حذف نخواهند شد.',
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
            child: const Text('حذف از کلاس'),
          ),
        ],
      ),
    );

    if (shouldRemove != true || !mounted) return;

    setState(() => _isRemovingStudent = true);
    try {
      await ref
          .read(classActionsProvider)
          .removeStudentFromClass(
            classId: widget.classId,
            studentId: widget.studentId,
          );
      ref.invalidate(classMembersProvider(widget.classId));
      ref.invalidate(studentClassesProvider);
      ref.invalidate(pendingInviteRequestsProvider);

      if (mounted) context.pop(true);
    } on PostgrestException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حذف دانشجو ناموفق بود: ${error.message}')),
        );
      }
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حذف دانشجو ناموفق بود: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isRemovingStudent = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final classId = widget.classId;
    final studentId = widget.studentId;
    final studentName = widget.studentName;
    final isProfessor = ref.watch(isProfessorProvider);

    // Watch overall progress
    final progressAsync = ref.watch(
      allFormsProgressProvider((classId, studentId)),
    );

    // لیست ساختاریافته فرم‌ها
    final List<Map<String, dynamic>> forms = [
      {
        'title': 'اطلاعات فردی و کسب و کار',
        'icon': Icons.person,
        'subtitle': 'مشخصات فردی، تحصیلات و کسب‌وکار',
        'page': (String cid, String sid) => PersonalInfoPage(
          classId: cid,
          studentId: sid,
          isProfessor: isProfessor,
        ),
      },
      {
        'title': 'استعدادیابی',
        'icon': Icons.lightbulb,
        'subtitle': 'تشخیص و رتبه‌بندی استعدادها',
        'page': (String cid, String sid) =>
            TalentPage(classId: cid, studentId: sid, isProfessor: isProfessor),
      },
      {
        'title': 'ارزش‌ها',
        'icon': Icons.favorite,
        'subtitle': 'ده ارزش مهم زندگی و کاری',
        'page': (String cid, String sid) =>
            ValuesPage(classId: cid, studentId: sid, isProfessor: isProfessor),
      },
      {
        'title': 'انتخاب کسب و کار',
        'icon': Icons.business,
        'subtitle': 'مقایسه و امتیازدهی کسب‌وکارها',
        'page': (String cid, String sid) => BusinessSelectionPage(
          classId: cid,
          studentId: sid,
          isProfessor: isProfessor,
        ),
      },
      {
        'title': 'اولویت محصولات',
        'icon': Icons.shopping_bag,
        'subtitle': 'اولویت‌بندی و امتیازدهی محصولات',
        'page': (String cid, String sid) => ProductPriorityPage(
          classId: cid,
          studentId: sid,
          isProfessor: isProfessor,
        ),
      },
      {
        'title': 'جدول رشد',
        'icon': Icons.trending_up,
        'subtitle': 'برنامه‌ریزی و پیگیری رشد کارآفرینی',
        'page': (String cid, String sid) => GrowthTablePage(
          classId: cid,
          studentId: sid,
          isProfessor: isProfessor,
        ),
      },
    ];

    // Extract per-form progress values
    final allProgress = progressAsync.all;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: AppBarBuilder(
          title: studentName,
          actions: [
            if (isProfessor && classId.isNotEmpty && studentId.isNotEmpty)
              IconButton(
                tooltip: 'حذف دانشجو از کلاس',
                onPressed: _isRemovingStudent ? null : _removeStudentFromClass,
                icon: _isRemovingStudent
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.person_remove_alt_1_outlined),
              ),
          ],
        ),
        body: Column(
          children: [
            // ── Overall Progress Header ──
            _OverallProgressHeader(progress: progressAsync.overall),
            // ── Form List ──
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                itemCount: forms.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final form = forms[index];
                  final formProgress = allProgress[index];
                  return _FormProgressCard(
                    stepNumber: index + 1,
                    title: form['title'] as String,
                    subtitle: form['subtitle'] as String,
                    icon: form['icon'] as IconData,
                    progress: formProgress,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              (form['page'] as Function(String, String))(
                                    classId,
                                    studentId,
                                  )
                                  as Widget,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Overall Progress Header ─────────────────────────────────────────────────

class _OverallProgressHeader extends StatelessWidget {
  final FormProgress progress;

  const _OverallProgressHeader({required this.progress});

  @override
  Widget build(BuildContext context) {
    final percent = progress.percent;
    final color = _progressColor(percent);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.08), AppTheme.cardBg],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  progress.isComplete
                      ? Icons.check_circle_rounded
                      : Icons.pie_chart_rounded,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'پیشرفت کل فرم‌ها',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${progress.filled} از ${progress.total} فیلد پر شده',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${percent.round()}%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FormProgressBar(percent: percent, height: 8, showLabel: false),
        ],
      ),
    );
  }

  Color _progressColor(double percent) {
    if (percent >= 100) return AppTheme.success;
    if (percent >= 60) return AppTheme.primary;
    if (percent >= 30) return AppTheme.warning;
    return const Color(0xFFEF4444);
  }
}

// ─── Form Progress Card ─────────────────────────────────────────────────────

class _FormProgressCard extends StatelessWidget {
  final int stepNumber;
  final String title;
  final String subtitle;
  final IconData icon;
  final FormProgress progress;
  final VoidCallback onTap;

  const _FormProgressCard({
    required this.stepNumber,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percent = progress.percent;
    final color = _progressColor(percent);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: progress.isComplete
              ? AppTheme.success.withValues(alpha: 0.3)
              : AppTheme.border,
          width: progress.isComplete ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.cardShadow,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Step number badge
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: progress.isComplete
                        ? AppTheme.success.withValues(alpha: 0.12)
                        : AppTheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: progress.isComplete
                      ? const Icon(
                          Icons.check_rounded,
                          color: AppTheme.success,
                          size: 20,
                        )
                      : Text(
                          '$stepNumber',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Percentage badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${percent.round()}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: color,
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

  Color _progressColor(double percent) {
    if (percent >= 100) return AppTheme.success;
    if (percent >= 60) return AppTheme.primary;
    if (percent >= 30) return AppTheme.warning;
    return const Color(0xFFEF4444);
  }
}
