import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karafarini/core/providers/session_providers.dart';
import 'package:karafarini/core/theme/app_theme.dart';
import 'package:karafarini/core/utils/app_date_formatter.dart';
import 'package:karafarini/core/utils/date_picker/persian_date_picker_sheet.dart';
import 'package:karafarini/core/widgets/app_bar_builder.dart';
import 'package:karafarini/features/classes/models/class_member_model.dart';
import 'package:karafarini/features/classes/models/class_model.dart';
import 'package:karafarini/features/forms/widgets/form_field_builder.dart';
import 'package:karafarini/features/forms/widgets/save_button.dart';
import 'package:karafarini/features/profile/providers/current_session_profile_provider.dart';
import 'package:karafarini/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/student_grade.dart';
import '../providers/gradebook_provider.dart';

class StudentGradePage extends ConsumerStatefulWidget {
  final ClassModel classModel;
  final ClassMemberModel member;

  const StudentGradePage({
    super.key,
    required this.classModel,
    required this.member,
  });

  @override
  ConsumerState<StudentGradePage> createState() => _StudentGradePageState();
}

class _StudentGradePageState extends ConsumerState<StudentGradePage> {
  final _formKey = GlobalKey<FormState>();
  final _extracurricularController = TextEditingController();
  late final Map<String, TextEditingController> _controllers;
  final List<_ParticipationDraft> _participationDrafts = [];
  bool _initialized = false;
  bool _saving = false;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final component in StudentGrade.components)
        component.key: TextEditingController(),
    };
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _extracurricularController.dispose();
    for (final draft in _participationDrafts) {
      draft.scoreController.dispose();
    }
    super.dispose();
  }

  void _syncControllers(StudentGrade? grade) {
    if (_initialized) return;
    for (final component in StudentGrade.components) {
      final score = grade?.scores[component.key];
      _controllers[component.key]!.text = score == null
          ? ''
          : _formatScore(score);
    }
    _extracurricularController.text = grade?.extracurricularScore == null
        ? ''
        : _formatScore(grade!.extracurricularScore!);
    for (final entry
        in grade?.participationEntries ?? const <ParticipationEntry>[]) {
      _participationDrafts.add(
        _ParticipationDraft(
          date: entry.date,
          scoreController: TextEditingController(
            text: _formatScore(entry.score),
          ),
        ),
      );
    }
    _initialized = true;
  }

  String _formatScore(double value) =>
      value == value.roundToDouble() ? value.toInt().toString() : '$value';

  double? _parseInput(String value) {
    final normalized = _normalizeScoreInput(value);
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  StudentGrade _gradeFromInput({StudentGrade? savedGrade}) {
    final participationEntries = [
      for (final draft in _participationDrafts)
        if (draft.date != null &&
            _parseInput(draft.scoreController.text) != null)
          ParticipationEntry(
            date: draft.date!,
            score: _parseInput(draft.scoreController.text)!,
          ),
    ];

    return StudentGrade(
      classId: widget.classModel.id,
      studentId: widget.member.studentId,
      scores: {
        for (final component in StudentGrade.components)
          component.key: _parseInput(_controllers[component.key]!.text),
      },
      legacyScores: savedGrade?.legacyScores ?? const {},
      participationEntries: participationEntries,
      attendanceDates: savedGrade?.attendanceDates ?? const [],
      hasNewParticipationData:
          savedGrade?.hasNewParticipationData == true ||
          participationEntries.isNotEmpty,
      extracurricularScore: _parseInput(_extracurricularController.text),
    );
  }

  Future<void> _addParticipationSession() async {
    final pickedDate = await PersianDatePickerSheet.show(
      context,
      initialDate: DateTime.now(),
      title: 'تاریخ جلسه',
      description: 'تاریخ برگزاری کلاس را انتخاب کنید',
    );
    if (pickedDate == null || !mounted) return;

    final dateKey = _dateKey(pickedDate);
    if (_participationDrafts.any((draft) => _dateKey(draft.date!) == dateKey)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('برای این تاریخ قبلاً نمره ثبت شده است.')),
      );
      return;
    }

    setState(() {
      _participationDrafts.add(
        _ParticipationDraft(
          date: pickedDate,
          scoreController: TextEditingController(),
        ),
      );
      _validationError = null;
    });
  }

  Future<void> _editParticipationDate(int index) async {
    final draft = _participationDrafts[index];
    final pickedDate = await PersianDatePickerSheet.show(
      context,
      initialDate: draft.date,
      title: 'تاریخ جلسه',
      description: 'تاریخ برگزاری کلاس را انتخاب کنید',
    );
    if (pickedDate == null || !mounted) return;

    final dateKey = _dateKey(pickedDate);
    if (_participationDrafts.asMap().entries.any(
      (entry) => entry.key != index && _dateKey(entry.value.date!) == dateKey,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('برای این تاریخ قبلاً نمره ثبت شده است.')),
      );
      return;
    }

    setState(() {
      draft.date = pickedDate;
      _participationDrafts.sort((a, b) => a.date!.compareTo(b.date!));
      _validationError = null;
    });
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  void _removeParticipationSession(_ParticipationDraft draft) {
    setState(() {
      _participationDrafts.remove(draft);
      draft.scoreController.dispose();
      _validationError = null;
    });
  }

  Future<void> _save(StudentGrade? savedGrade) async {
    if (_saving) return;
    final rawInputError = _rawInputError();
    if (rawInputError != null) {
      setState(() => _validationError = rawInputError);
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() => _validationError = 'نمره‌های واردشده را بررسی کنید.');
      return;
    }

    final grade = _gradeFromInput(savedGrade: savedGrade);
    final validationError = grade.validate();
    if (validationError != null) {
      setState(() => _validationError = validationError);
      return;
    }

    setState(() {
      _saving = true;
      _validationError = null;
    });

    try {
      await ref.read(gradebookServiceProvider).saveGrade(grade);
      ref.invalidate(classGradesProvider(widget.classModel.id));
      ref.invalidate(
        studentGradeProvider((
          classId: widget.classModel.id,
          studentId: widget.member.studentId,
        )),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('نمره‌ها با موفقیت ذخیره شدند.')),
        );
      }
    } on PostgrestException catch (error) {
      if (mounted) {
        setState(() => _validationError = 'ذخیره ناموفق بود: ${error.message}');
      }
    } on StateError catch (error) {
      if (mounted) setState(() => _validationError = error.message);
    } on ArgumentError catch (error) {
      if (mounted) setState(() => _validationError = '$error');
    } on Exception catch (error) {
      if (mounted) {
        setState(() => _validationError = 'ذخیره ناموفق بود: $error');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _rawInputError() {
    for (final component in StudentGrade.components) {
      final input = _controllers[component.key]!.text.trim();
      if (input.isEmpty) continue;
      final score = _parseInput(input);
      if (score == null || !score.isFinite) {
        return 'برای ${component.label} یک عدد معتبر وارد کنید.';
      }
      if (score < 0 || score > component.maxScore) {
        return 'نمرهٔ ${component.label} باید بین 0 و ${_formatScore(component.maxScore)} باشد.';
      }
    }

    for (final draft in _participationDrafts) {
      final input = draft.scoreController.text.trim();
      if (input.isEmpty) {
        return 'نمرهٔ جلسهٔ ${AppDateFormatter.toJalali(draft.date!)} را وارد کنید.';
      }
      final score = _parseInput(input);
      if (score == null || !score.isFinite) {
        return 'نمرهٔ جلسه باید یک عدد معتبر باشد.';
      }
      if (score < 0) return 'نمرهٔ جلسه نمی‌تواند منفی باشد.';
    }

    final extracurricularInput = _extracurricularController.text.trim();
    if (extracurricularInput.isNotEmpty) {
      final score = _parseInput(extracurricularInput);
      if (score == null || !score.isFinite) {
        return 'نمرهٔ فوق‌برنامه باید یک عدد معتبر باشد.';
      }
      if (score < 0) return 'نمرهٔ فوق‌برنامه نمی‌تواند منفی باشد.';
    }
    return null;
  }

  String? _scoreValidator(
    String? value, {
    double? maxScore,
    bool required = false,
  }) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return required ? 'این نمره را وارد کنید.' : null;
    final score = _parseInput(input);
    if (score == null || !score.isFinite) return 'یک عدد معتبر وارد کنید.';
    if (score < 0) return 'نمره نمی‌تواند منفی باشد.';
    if (maxScore != null && score > maxScore) {
      return 'حداکثر نمره ${_formatScore(maxScore)} است.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isProfessor = ref.watch(isProfessorProvider);
    final isOwner =
        ref.watch(currentUserIdProvider) == widget.classModel.teacherId;
    if (!isProfessor || !isOwner) {
      return const Scaffold(
        appBar: AppBarBuilder(title: 'ثبت نمره'),
        body: Center(child: Text('فقط استاد این کلاس می‌تواند نمره ثبت کند.')),
      );
    }

    final params = (
      classId: widget.classModel.id,
      studentId: widget.member.studentId,
    );
    final gradeAsync = ref.watch(studentGradeProvider(params));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: AppBarBuilder(
          title: widget.member.studentName ?? 'نمرهٔ دانشجو',
        ),
        body: gradeAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'خطا در دریافت نمره‌ها: $error',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () =>
                        ref.invalidate(studentGradeProvider(params)),
                    child: const Text('تلاش دوباره'),
                  ),
                ],
              ),
            ),
          ),
          data: (savedGrade) {
            _syncControllers(savedGrade);
            final currentGrade = _gradeFromInput(savedGrade: savedGrade);

            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _StudentHeader(
                    name: widget.member.studentName ?? 'دانشجوی بدون نام',
                    studentNumber: widget.member.studentNumber,
                    avatarUrl: widget.member.avatarUrl,
                    total: currentGrade.total,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'نمرهٔ هر زیر‌بخش را وارد کنید. ثبت نمرهٔ ناقص مجاز است.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...StudentGrade.sections.map(
                    (section) => _GradeSectionCard(
                      section: section,
                      controllers: _controllers,
                      currentGrade: currentGrade,
                      validator: (value, maxScore) =>
                          _scoreValidator(value, maxScore: maxScore),
                      onChanged: () => setState(() => _validationError = null),
                    ),
                  ),
                  _ParticipationCard(
                    drafts: _participationDrafts,
                    total: currentGrade.manualParticipationTotal,
                    attendanceScore: currentGrade.attendanceScore,
                    activities: currentGrade.datedParticipationEntries,
                    legacyScore: savedGrade?.hasNewParticipationData == true
                        ? null
                        : savedGrade?.legacyScores['class_participation'],
                    onAdd: _addParticipationSession,
                    onEditDate: _editParticipationDate,
                    onRemove: _removeParticipationSession,
                    onChanged: () => setState(() => _validationError = null),
                    validator: (value) =>
                        _scoreValidator(value, required: true),
                  ),
                  _ExtracurricularCard(
                    controller: _extracurricularController,
                    validator: (value) => _scoreValidator(value),
                    onChanged: () => setState(() => _validationError = null),
                  ),
                  if (_validationError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _validationError!,
                      style: const TextStyle(color: AppTheme.error),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SaveButton(
                    onSave: () => _save(savedGrade),
                    isLoading: _saving,
                    isEnabled: !_saving,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ParticipationDraft {
  DateTime? date;
  final TextEditingController scoreController;

  _ParticipationDraft({required this.date, required this.scoreController});
}

class _StudentHeader extends StatelessWidget {
  final String name;
  final String? studentNumber;
  final String? avatarUrl;
  final double total;

  const _StudentHeader({
    required this.name,
    required this.studentNumber,
    required this.avatarUrl,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
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
              fullName: name,
              avatarUrl: avatarUrl,
              resolvedImageUrl: avatarUrl,
              radius: 24,
              backgroundColor: AppTheme.avatarBg,
              foregroundColor: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                if (studentNumber?.isNotEmpty == true)
                  Text(
                    studentNumber!,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${total.toStringAsFixed(1)} / 110',
                style: const TextStyle(
                  color: AppTheme.primaryDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${(total / 5).toStringAsFixed(1)} / 22',
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GradeSectionCard extends StatelessWidget {
  final GradeSection section;
  final Map<String, TextEditingController> controllers;
  final StudentGrade currentGrade;
  final String? Function(String? value, double maxScore) validator;
  final VoidCallback onChanged;

  const _GradeSectionCard({
    required this.section,
    required this.controllers,
    required this.currentGrade,
    required this.validator,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final legacyScore = currentGrade.legacyScores[section.legacyKey];
    final hasLegacyScore = legacyScore != null;
    final hasDetailedScore = section.components.any(
      (component) => currentGrade.scores[component.key] != null,
    );
    final sectionScore = currentGrade.scoreForSection(section);

    return Card(
      color: AppTheme.cardBg,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        collapsedBackgroundColor: AppTheme.cardBg,
        backgroundColor: AppTheme.cardBg,
        iconColor: AppTheme.primary,
        collapsedIconColor: AppTheme.primary,
        title: Text(
          '${section.title} (${_formatScore(section.maxScore)} نمره)',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          hasLegacyScore && hasDetailedScore
              ? 'نمرهٔ قبلی ${_formatScore(legacyScore)} با ذخیرهٔ جزئیات جایگزین می‌شود • فعلی: ${_formatScore(sectionScore)}'
              : hasLegacyScore
              ? 'نمرهٔ قبلی: ${_formatScore(sectionScore)}؛ با ثبت جزئیات جایگزین می‌شود'
              : 'ثبت‌شده: ${_formatScore(sectionScore)} از ${_formatScore(section.maxScore)}',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        children: [
          for (final component in section.components)
            _GradeScoreField(
              title: component.label,
              controller: controllers[component.key]!,
              validator: (value) => validator(value, component.maxScore),
              maxScore: component.maxScore,
              helperText: 'حداکثر ${_formatScore(component.maxScore)} نمره',
              suffixText: 'از ${_formatScore(component.maxScore)}',
              icon: Icons.grade_outlined,
              onChanged: onChanged,
            ),
        ],
      ),
    );
  }
}

class _ParticipationCard extends StatelessWidget {
  final List<_ParticipationDraft> drafts;
  final double total;
  final double attendanceScore;
  final List<ParticipationEntry> activities;
  final double? legacyScore;
  final Future<void> Function() onAdd;
  final Future<void> Function(int index) onEditDate;
  final void Function(_ParticipationDraft draft) onRemove;
  final VoidCallback onChanged;
  final String? Function(String? value) validator;

  const _ParticipationCard({
    required this.drafts,
    required this.total,
    required this.attendanceScore,
    required this.activities,
    required this.legacyScore,
    required this.onAdd,
    required this.onEditDate,
    required this.onRemove,
    required this.onChanged,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final combinedTotal = total + attendanceScore;
    final remaining = (StudentGrade.participationMaxScore - combinedTotal)
        .clamp(0, StudentGrade.participationMaxScore)
        .toDouble();
    final savedLegacyScore = legacyScore;

    return Card(
      color: AppTheme.cardBg,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'مشارکت کلاسی (${_formatScore(StudentGrade.participationMaxScore)} نمره)',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'مجموع فعالیت‌های تاریخ‌دار: '
              '${_formatScore(combinedTotal)} از 20 • مانده: '
              '${_formatScore(remaining)}',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
            if (attendanceScore > 0)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  'حضور تأییدشده به‌عنوان ۱ نمره در فعالیت همان تاریخ ثبت می‌شود.',
                  style: TextStyle(color: AppTheme.textSecondary, height: 1.4),
                ),
              ),
            if (combinedTotal > StudentGrade.participationMaxScore)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  'جمع مشارکت دستی و امتیاز حضور از سقف 20 بیشتر شده است.',
                  style: TextStyle(color: AppTheme.error),
                ),
              ),
            if (savedLegacyScore != null) ...[
              const SizedBox(height: 8),
              Text(
                drafts.isEmpty
                    ? 'نمرهٔ مشارکت قبلی ${_formatScore(savedLegacyScore)} حفظ شده؛ '
                          'با افزودن اولین جلسه، جمع نمره‌های تاریخ‌دار جایگزین آن می‌شود.'
                    : 'نمرهٔ مشارکت قبلی ${_formatScore(savedLegacyScore)} با ذخیرهٔ '
                          'جلسه‌های تاریخ‌دار جایگزین می‌شود.',
                style: const TextStyle(color: AppTheme.warning, height: 1.4),
              ),
            ],
            const SizedBox(height: 12),
            ...activities.map((activity) {
              final date = activity.date;
              final index = drafts.indexWhere(
                (draft) => _dateKey(draft.date!) == _dateKey(date),
              );
              if (index < 0) {
                return _AttendanceParticipationRow(
                  date: date,
                  score: activity.score,
                );
              }
              return _ParticipationSessionRow(
                key: ValueKey(date.toIso8601String()),
                index: index,
                draft: drafts[index],
                hasAttendance:
                    activity.score >
                    (_parseScoreText(drafts[index].scoreController.text) ?? 0),
                activityScore: activity.score,
                validator: validator,
                onEditDate: onEditDate,
                onRemove: onRemove,
                onChanged: onChanged,
              );
            }),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('افزودن تاریخ جلسه'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParticipationSessionRow extends StatelessWidget {
  final int index;
  final _ParticipationDraft draft;
  final bool hasAttendance;
  final double activityScore;
  final Future<void> Function(int index) onEditDate;
  final void Function(_ParticipationDraft draft) onRemove;
  final VoidCallback onChanged;
  final String? Function(String? value) validator;

  const _ParticipationSessionRow({
    super.key,
    required this.index,
    required this.draft,
    required this.hasAttendance,
    required this.activityScore,
    required this.onEditDate,
    required this.onRemove,
    required this.onChanged,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => onEditDate(index),
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Text(
                    AppDateFormatter.toJalali(draft.date!),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'حذف این جلسه',
                onPressed: () => onRemove(draft),
                icon: const Icon(Icons.delete_outline, color: AppTheme.error),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _GradeScoreField(
            title: 'نمرهٔ این جلسه',
            controller: draft.scoreController,
            validator: validator,
            helperText: 'جمع مشارکت دستی و حضور حداکثر 20 نمره است',
            icon: Icons.grade_outlined,
            onChanged: onChanged,
          ),
          if (hasAttendance)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'حضور تأییدشده در همین تاریخ: +۱ نمره',
                    style: TextStyle(
                      color: AppTheme.success,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'نمرهٔ مجموع این فعالیت: ${_formatScore(activityScore)}',
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

class _AttendanceParticipationRow extends StatelessWidget {
  final DateTime date;
  final double score;

  const _AttendanceParticipationRow({required this.date, required this.score});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.event_available_outlined,
            color: AppTheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${AppDateFormatter.toJalali(date)} • حضور تأییدشده',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '+${_formatScore(score)}',
            style: const TextStyle(
              color: AppTheme.primaryDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ),
  );
}

String _dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

double? _parseScoreText(String value) {
  final normalized = _normalizeScoreInput(value);
  if (normalized.isEmpty) return null;
  return double.tryParse(normalized);
}

class _ExtracurricularCard extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String? value) validator;
  final VoidCallback onChanged;

  const _ExtracurricularCard({
    required this.controller,
    required this.validator,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.cardBg,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _GradeScoreField(
          title: 'فوق‌برنامه',
          controller: controller,
          validator: validator,
          helperText: 'بدون سقف؛ به جمع کل اضافه می‌شود.',
          icon: Icons.stars_outlined,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

final _scoreInputFormatter = FilteringTextInputFormatter.allow(
  RegExp(r'[0-9۰-۹٠-٩.,٫]'),
);

class _GradeScoreField extends StatefulWidget {
  final String title;
  final TextEditingController controller;
  final String? Function(String? value) validator;
  final double? maxScore;
  final String? helperText;
  final String? suffixText;
  final IconData icon;
  final VoidCallback onChanged;

  const _GradeScoreField({
    required this.title,
    required this.controller,
    required this.validator,
    required this.icon,
    required this.onChanged,
    this.maxScore,
    this.helperText,
    this.suffixText,
  });

  @override
  State<_GradeScoreField> createState() => _GradeScoreFieldState();
}

class _GradeScoreFieldState extends State<_GradeScoreField> {
  bool _limitExceeded = false;

  void _showLimitWarning() {
    if (_limitExceeded) return;
    setState(() => _limitExceeded = true);
  }

  @override
  Widget build(BuildContext context) {
    final maxScore = widget.maxScore;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: widget.controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          _scoreInputFormatter,
          if (maxScore != null)
            _MaxScoreInputFormatter(maxScore, onRejected: _showLimitWarning),
        ],
        validator: widget.validator,
        forceErrorText: _limitExceeded && maxScore != null
            ? 'حداکثر نمره ${_formatScore(maxScore)} است؛ مقدار بیشتر پذیرفته نمی‌شود.'
            : null,
        onChanged: (_) {
          if (_limitExceeded) setState(() => _limitExceeded = false);
          widget.onChanged();
        },
        decoration:
            FormBuilder.inputDecoration(
              label: widget.title,
              prefixIcon: Icon(widget.icon, size: 20),
              borderRadius: 16,
            ).copyWith(
              helperText: widget.helperText,
              suffixText: widget.suffixText,
            ),
      ),
    );
  }
}

class _MaxScoreInputFormatter extends TextInputFormatter {
  final double maxScore;
  final VoidCallback onRejected;

  const _MaxScoreInputFormatter(this.maxScore, {required this.onRejected});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final score = double.tryParse(_normalizeScoreInput(newValue.text));
    if (score != null && score > maxScore) {
      onRejected();
      return oldValue;
    }
    return newValue;
  }
}

String _normalizeScoreInput(String value) => value
    .replaceAll(',', '')
    .replaceAll('٫', '.')
    .replaceAll('۰', '0')
    .replaceAll('۱', '1')
    .replaceAll('۲', '2')
    .replaceAll('۳', '3')
    .replaceAll('۴', '4')
    .replaceAll('۵', '5')
    .replaceAll('۶', '6')
    .replaceAll('۷', '7')
    .replaceAll('۸', '8')
    .replaceAll('۹', '9')
    .replaceAll('٠', '0')
    .replaceAll('١', '1')
    .replaceAll('٢', '2')
    .replaceAll('٣', '3')
    .replaceAll('٤', '4')
    .replaceAll('٥', '5')
    .replaceAll('٦', '6')
    .replaceAll('٧', '7')
    .replaceAll('٨', '8')
    .replaceAll('٩', '9')
    .trim();

String _formatScore(double value) =>
    value == value.roundToDouble() ? value.toInt().toString() : '$value';
