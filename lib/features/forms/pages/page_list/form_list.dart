import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karafarini/core/theme/app_theme.dart';
import 'package:karafarini/core/widgets/app_bar_builder.dart';
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

class FormList extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
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
        'page': (String cid, String sid) => PersonalInfoPage(
          classId: cid,
          studentId: sid,
          isProfessor: isProfessor,
        ),
      },
      {
        'title': 'استعدادیابی',
        'icon': Icons.lightbulb,
        'page': (String cid, String sid) =>
            TalentPage(classId: cid, studentId: sid, isProfessor: isProfessor),
      },
      {
        'title': 'ارزش‌ها',
        'icon': Icons.favorite,
        'page': (String cid, String sid) =>
            ValuesPage(classId: cid, studentId: sid, isProfessor: isProfessor),
      },
      {
        'title': 'انتخاب کسب و کار',
        'icon': Icons.business,
        'page': (String cid, String sid) => BusinessSelectionPage(
          classId: cid,
          studentId: sid,
          isProfessor: isProfessor,
        ),
      },
      {
        'title': 'اولویت محصولات',
        'icon': Icons.shopping_bag,
        'page': (String cid, String sid) => ProductPriorityPage(
          classId: cid,
          studentId: sid,
          isProfessor: isProfessor,
        ),
      },
      {
        'title': 'جدول رشد',
        'icon': Icons.trending_up,
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
        appBar: AppBarBuilder(title: studentName),
        body: Column(
          children: [
            // ── Overall Progress Header ──
            _OverallProgressHeader(progress: progressAsync.overall),
            // ── Form List ──
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                itemCount: forms.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final form = forms[index];
                  final formProgress = allProgress[index];
                  return _FormProgressCard(
                    title: form['title'] as String,
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
    final color = percent >= 100
        ? AppTheme.success
        : percent >= 60
            ? AppTheme.primary
            : percent >= 30
                ? AppTheme.warning
                : const Color(0xFFEF4444);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.08),
            AppTheme.cardBg,
          ],
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
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${percent.round()}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FormProgressBar(
            percent: percent,
            height: 8,
            showLabel: false,
          ),
        ],
      ),
    );
  }
}

// ─── Form Progress Card ─────────────────────────────────────────────────────

class _FormProgressCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final FormProgress progress;
  final VoidCallback onTap;

  const _FormProgressCard({
    required this.title,
    required this.icon,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percent = progress.percent;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border, width: 1),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon,
                        color: AppTheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    // Check mark or arrow
                    if (progress.isComplete)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: AppTheme.success,
                          size: 16,
                        ),
                      )
                    else
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: AppTheme.primary.withValues(alpha: 0.7),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Progress bar row
                FormProgressBar(
                  percent: percent,
                  height: 6,
                  showLabel: false,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${progress.filled} از ${progress.total} فیلد',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textHint,
                      ),
                    ),
                    Text(
                      '${percent.round()}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: percent >= 100
                            ? AppTheme.success
                            : percent >= 60
                                ? AppTheme.primary
                                : percent >= 30
                                    ? AppTheme.warning
                                    : const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
