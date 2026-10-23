import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karafarini/core/theme/app_theme.dart';
import 'package:karafarini/core/widgets/app_bar_builder.dart';
import 'package:karafarini/core/providers/session_providers.dart';
import 'package:karafarini/features/classes/models/class_member_model.dart';
import 'package:karafarini/features/classes/models/class_model.dart';
import 'package:karafarini/features/forms/widgets/save_button.dart';
import 'package:karafarini/features/profile/providers/current_session_profile_provider.dart';

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
  late final Map<String, TextEditingController> _controllers;
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
    _initialized = true;
  }

  String _formatScore(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toString();
  }

  double? _parseInput(String value) {
    final normalized = value
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
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  StudentGrade _gradeFromInput() {
    var grade = StudentGrade.empty(
      classId: widget.classModel.id,
      studentId: widget.member.studentId,
    );
    for (final component in StudentGrade.components) {
      grade = grade.copyWithScore(
        component.key,
        _parseInput(_controllers[component.key]!.text),
      );
    }
    return grade;
  }

  Future<void> _save() async {
    if (_saving) return;
    final grade = _gradeFromInput();
    final validationError = grade.validate();
    if (validationError != null ||
        StudentGrade.components.any(
          (component) =>
              _controllers[component.key]!.text.trim().isNotEmpty &&
              grade.scores[component.key] == null,
        )) {
      setState(() {
        _validationError = validationError ?? 'یکی از نمره‌ها عدد معتبر نیست.';
      });
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
    } catch (error) {
      if (mounted) {
        setState(() {
          _validationError = 'ذخیرهٔ نمره‌ها ناموفق بود: $error';
        });
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
            final currentGrade = _gradeFromInput();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _StudentHeader(
                  name: widget.member.studentName ?? 'دانشجوی بدون نام',
                  studentNumber: widget.member.studentNumber,
                  total: currentGrade.total,
                ),
                const SizedBox(height: 16),
                const Text(
                  'نمرهٔ هر بخش را تا سقف مشخص‌شده وارد کنید. ثبت نمرهٔ ناقص مجاز است.',
                  style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 12),
                ...StudentGrade.components.map((component) {
                  final controller = _controllers[component.key]!;
                  return _GradeComponentField(
                    component: component,
                    controller: controller,
                    onChanged: () => setState(() => _validationError = null),
                  );
                }),
                if (_validationError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _validationError!,
                    style: const TextStyle(color: AppTheme.error),
                  ),
                ],
                const SizedBox(height: 16),
                _TotalCard(grade: currentGrade),
                const SizedBox(height: 20),
                SaveButton(
                  onSave: _save,
                  isLoading: _saving,
                  isEnabled: !_saving,
                ),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StudentHeader extends StatelessWidget {
  final String name;
  final String? studentNumber;
  final double total;

  const _StudentHeader({
    required this.name,
    required this.studentNumber,
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
          const CircleAvatar(
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.primary,
            child: Icon(Icons.person_outline),
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
          Text(
            '${total.toStringAsFixed(1)} / ۱۱۰',
            style: const TextStyle(
              color: AppTheme.primaryDark,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _GradeComponentField extends StatelessWidget {
  final GradeComponent component;
  final TextEditingController controller;
  final VoidCallback onChanged;

  const _GradeComponentField({
    required this.component,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final maxScore = _formatMaxScore(component.maxScore);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9۰-۹٠-٩.,٫]')),
        ],
        onChanged: (_) => onChanged(),
        decoration: InputDecoration(
          labelText: component.label,
          helperText: 'حداکثر $maxScore',
          suffixText: 'از $maxScore',
        ),
      ),
    );
  }

  String _formatMaxScore(double value) =>
      value == value.roundToDouble() ? value.toInt().toString() : '$value';
}

class _TotalCard extends StatelessWidget {
  final StudentGrade grade;

  const _TotalCard({required this.grade});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'جمع فعلی: ${grade.total.toStringAsFixed(1)} از ۱۱۰',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'معادل از ۲۲: ${grade.scoreOutOf22.toStringAsFixed(2)}'
            '${grade.isComplete ? '' : ' • ${grade.enteredComponents} از ${StudentGrade.components.length} بخش ثبت شده'}',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
