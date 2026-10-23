import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:karafarini/core/providers/session_providers.dart';
import 'package:karafarini/core/theme/app_theme.dart';
import 'package:karafarini/core/widgets/app_bar_builder.dart';
import 'package:karafarini/features/classes/models/class_member_model.dart';
import 'package:karafarini/features/classes/models/class_model.dart';
import 'package:karafarini/features/classes/providers/classes_provider.dart';
import 'package:karafarini/features/profile/providers/current_session_profile_provider.dart';
import 'package:karafarini/features/profile/presentation/widgets/profile_avatar.dart';

import '../models/student_grade.dart';
import '../providers/gradebook_provider.dart';

class GradeStudentRouteArgs {
  final ClassModel classModel;
  final ClassMemberModel member;

  const GradeStudentRouteArgs({required this.classModel, required this.member});
}

class GradebookPage extends ConsumerStatefulWidget {
  final ClassModel classModel;

  const GradebookPage({super.key, required this.classModel});

  @override
  ConsumerState<GradebookPage> createState() => _GradebookPageState();
}

class _GradebookPageState extends ConsumerState<GradebookPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isProfessor = ref.watch(isProfessorProvider);
    final isOwner =
        ref.watch(currentUserIdProvider) == widget.classModel.teacherId;

    if (!isProfessor || !isOwner) {
      return const Scaffold(
        appBar: AppBarBuilder(title: 'دفتر نمرات'),
        body: Center(
          child: Text('فقط استاد این کلاس می‌تواند نمرات را ببیند.'),
        ),
      );
    }

    final membersAsync = ref.watch(classMembersProvider(widget.classModel.id));
    final gradesAsync = ref.watch(classGradesProvider(widget.classModel.id));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: const AppBarBuilder(title: 'دفتر نمرات'),
        body: membersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _LoadError(
            message: 'خطا در دریافت دانشجویان کلاس: $error',
            onRetry: () =>
                ref.invalidate(classMembersProvider(widget.classModel.id)),
          ),
          data: (members) => gradesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _LoadError(
              message: 'خطا در دریافت نمرات: $error',
              onRetry: () =>
                  ref.invalidate(classGradesProvider(widget.classModel.id)),
            ),
            data: (grades) => _buildGradeList(context, members, grades),
          ),
        ),
      ),
    );
  }

  Widget _buildGradeList(
    BuildContext context,
    List<ClassMemberModel> members,
    Map<String, StudentGrade> grades,
  ) {
    final query = _searchQuery.trim().toLowerCase();
    final filtered = members.where((member) {
      final name = (member.studentName ?? '').toLowerCase();
      final number = (member.studentNumber ?? '').toLowerCase();
      return name.contains(query) || number.contains(query);
    }).toList();

    final completeGrades = grades.values.where((grade) => grade.isComplete);
    final orderedScores = completeGrades.map((grade) => grade.total).toList()
      ..sort((a, b) => b.compareTo(a));
    final rankByStudent = <String, int>{};
    for (final grade in completeGrades) {
      rankByStudent[grade.studentId] = orderedScores.indexOf(grade.total) + 1;
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(classMembersProvider(widget.classModel.id));
        ref.invalidate(classGradesProvider(widget.classModel.id));
        await Future.wait([
          ref.read(classMembersProvider(widget.classModel.id).future),
          ref.read(classGradesProvider(widget.classModel.id).future),
        ]);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _GradebookSummary(
            className: widget.classModel.title,
            totalStudents: members.length,
            gradedStudents: grades.values
                .where((grade) => !grade.isEmpty)
                .length,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: const InputDecoration(
              labelText: 'جستجوی نام یا شماره دانشجویی',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 12),
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  members.isEmpty
                      ? 'هنوز دانشجویی عضو این کلاس نیست.'
                      : 'دانشجویی با این مشخصات پیدا نشد.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            )
          else
            ...filtered.map((member) {
              final grade = grades[member.studentId];
              final rank = rankByStudent[member.studentId];
              return _StudentGradeCard(
                member: member,
                grade: grade,
                rank: rank,
                onTap: () => context.pushNamed(
                  'student-grade',
                  extra: GradeStudentRouteArgs(
                    classModel: widget.classModel,
                    member: member,
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _GradebookSummary extends StatelessWidget {
  final String className;
  final int totalStudents;
  final int gradedStudents;

  const _GradebookSummary({
    required this.className,
    required this.totalStudents,
    required this.gradedStudents,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.primary,
            child: Icon(Icons.grade_outlined),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  className,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$gradedStudents از $totalStudents دانشجو نمره دارند',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentGradeCard extends StatelessWidget {
  final ClassMemberModel member;
  final StudentGrade? grade;
  final int? rank;
  final VoidCallback onTap;

  const _StudentGradeCard({
    required this.member,
    required this.grade,
    required this.rank,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isComplete = grade?.isComplete ?? false;
    final hasScores = grade != null && !grade!.isEmpty;
    final status = hasScores ? (isComplete ? 'تکمیل‌شده' : 'ناقص') : null;

    return Card(
      color: AppTheme.primaryLight,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        minVerticalPadding: 12,
        onTap: onTap,
        leading: Container(
          width: 52,
          height: 52,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.primary.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ProfileAvatar(
            fullName: member.studentName ?? 'کاربر بدون نام',
            avatarUrl: member.avatarUrl,
            resolvedImageUrl: member.avatarUrl,
            radius: 24,
            backgroundColor: AppTheme.avatarBg,
            foregroundColor: AppTheme.primary,
          ),
        ),
        title: Text(
          member.studentName ?? 'دانشجوی بدون نام',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            [
              member.studentNumber?.isNotEmpty == true
                  ? member.studentNumber!
                  : 'بدون کد دانشجویی',
              if (hasScores)
                '${grade!.total.toStringAsFixed(1)} از ۱۱۰ • '
                    '${grade!.scoreOutOf22.toStringAsFixed(2)} از ۲۲',
              if (isComplete) 'رتبه $rank',
              ?status,
            ].join('\n'),
            style: const TextStyle(color: AppTheme.textSecondary, height: 1.5),
          ),
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _LoadError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('تلاش دوباره'),
            ),
          ],
        ),
      ),
    );
  }
}
