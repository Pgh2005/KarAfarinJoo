import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karafarini/core/theme/app_theme.dart';
import 'package:karafarini/core/widgets/app_bar_builder.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:karafarini/features/forms/pages/page2/models/talent_model.dart';
import 'package:karafarini/features/forms/pages/page2/providers/talent_provider.dart';
import 'package:karafarini/features/forms/widgets/form_field_builder.dart';
import 'package:karafarini/features/forms/widgets/form_progress.dart';
import 'package:karafarini/features/forms/widgets/progress_bar_widget.dart';
import 'package:karafarini/features/forms/widgets/save_button.dart';
import 'package:karafarini/features/forms/widgets/section_card.dart';

class _RowControllers {
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();

  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
  }
}

class TalentPage extends ConsumerStatefulWidget {
  final String classId;
  final String studentId;
  final bool isProfessor;

  const TalentPage({
    super.key,
    required this.classId,
    required this.studentId,
    this.isProfessor = false,
  });

  @override
  ConsumerState<TalentPage> createState() => _TalentPageState();
}

class _TalentPageState extends ConsumerState<TalentPage> {
  late final TextEditingController _highestCategoryCtrl;
  late final TextEditingController _lowestTalentCtrl;
  late final TextEditingController _twoDimTypeCtrl;
  late final TextEditingController _fourDimTypeCtrl;
  late final TextEditingController _bestTeamCtrl;

  late final List<_RowControllers> _rowCtrls;

  bool _isInitialized = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _highestCategoryCtrl = TextEditingController();
    _lowestTalentCtrl = TextEditingController();
    _twoDimTypeCtrl = TextEditingController();
    _fourDimTypeCtrl = TextEditingController();
    _bestTeamCtrl = TextEditingController();

    _rowCtrls = List.generate(5, (_) => _RowControllers());
  }

  @override
  void didUpdateWidget(covariant TalentPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.classId != widget.classId ||
        oldWidget.studentId != widget.studentId) {
      _isInitialized = false;
      _clearControllers();
    }
  }

  @override
  void dispose() {
    _highestCategoryCtrl.dispose();
    _lowestTalentCtrl.dispose();
    _twoDimTypeCtrl.dispose();
    _fourDimTypeCtrl.dispose();
    _bestTeamCtrl.dispose();
    for (final rc in _rowCtrls) {
      rc.dispose();
    }
    super.dispose();
  }

  void _clearControllers() {
    _highestCategoryCtrl.clear();
    _lowestTalentCtrl.clear();
    _twoDimTypeCtrl.clear();
    _fourDimTypeCtrl.clear();
    _bestTeamCtrl.clear();
    for (final rc in _rowCtrls) {
      rc.titleCtrl.clear();
      rc.descCtrl.clear();
    }
  }

  void _syncControllers(TalentModel model) {
    if (_isInitialized) return;

    _highestCategoryCtrl.text = model.highestCategory;
    _lowestTalentCtrl.text = model.lowestTalent;
    _twoDimTypeCtrl.text = model.twoDimType;
    _fourDimTypeCtrl.text = model.fourDimType;
    _bestTeamCtrl.text = model.bestTeam;

    for (int i = 0; i < model.rows.length && i < _rowCtrls.length; i++) {
      _rowCtrls[i].titleCtrl.text = model.rows[i].title;
      _rowCtrls[i].descCtrl.text = model.rows[i].description;
    }

    _isInitialized = true;
  }

  Future<void> _handleSave(TalentModel currentModel) async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedRows = List.generate(5, (index) {
        return TalentRowModel(
          rank: '${index + 1}',
          title: _rowCtrls[index].titleCtrl.text.trim(),
          description: _rowCtrls[index].descCtrl.text.trim(),
        );
      });

      final updatedModel = currentModel.copyWith(
        highestCategory: _highestCategoryCtrl.text.trim(),
        lowestTalent: _lowestTalentCtrl.text.trim(),
        twoDimType: _twoDimTypeCtrl.text.trim(),
        fourDimType: _fourDimTypeCtrl.text.trim(),
        bestTeam: _bestTeamCtrl.text.trim(),
        rows: updatedRows,
      );

      final params = TalentParams(
        classId: widget.classId,
        studentId: widget.studentId,
      );

      await ref.read(talentProvider(params).notifier).save(updatedModel);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اطلاعات استعدادیابی با موفقیت ثبت شد'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('خطا در ثبت اطلاعات'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final params = TalentParams(
      classId: widget.classId,
      studentId: widget.studentId,
    );

    final talentAsync = ref.watch(talentProvider(params));
    final isEditable = !widget.isProfessor;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: const AppBarBuilder(title: 'استعدادیابی'),
        body: talentAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('خطا در دریافت اطلاعات: $err')),
          data: (model) {
            _syncControllers(model);

            final progress = model.progress;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Progress Bar ──
                  FormProgressBar(percent: progress.percent, showLabel: true),
                  const SizedBox(height: 16),

                  // ── Clifton Strengths Test Link ──
                  _CliftonTestBanner(isEditable: isEditable),
                  const SizedBox(height: 16),

                  SectionCard(
                    icon: Icons.psychology_outlined,
                    title: 'اطلاعات کلی استعداد',
                    children: [
                      FormBuilder.buildTextField(
                        'بالاترین دسته استعدادی',
                        _highestCategoryCtrl.text,
                        null,
                        controller: _highestCategoryCtrl,
                        enabled: isEditable,
                      ),
                      const SizedBox(height: 12),
                      FormBuilder.buildTextField(
                        'پایین‌ترین استعداد',
                        _lowestTalentCtrl.text,
                        null,
                        controller: _lowestTalentCtrl,
                        enabled: isEditable,
                      ),
                      const SizedBox(height: 12),
                      FormBuilder.buildTextField(
                        'تیپ استعدادی دو بعدی',
                        _twoDimTypeCtrl.text,
                        null,
                        controller: _twoDimTypeCtrl,
                        enabled: isEditable,
                      ),
                      const SizedBox(height: 12),
                      FormBuilder.buildTextField(
                        'تیپ استعدادی چهار بعدی',
                        _fourDimTypeCtrl.text,
                        null,
                        controller: _fourDimTypeCtrl,
                        enabled: isEditable,
                      ),
                      const SizedBox(height: 12),
                      FormBuilder.buildTextField(
                        'بهترین تیم مناسب',
                        _bestTeamCtrl.text,
                        null,
                        controller: _bestTeamCtrl,
                        enabled: isEditable,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'جدول رتبه استعداد',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_rowCtrls.length} مورد',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _rowCtrls.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return _TalentRowCard(
                        index: index,
                        rowCtrl: _rowCtrls[index],
                        enabled: isEditable,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  if (isEditable)
                    SaveButton(
                      onSave: () => _handleSave(model),
                      isLoading: _isSaving,
                      isEnabled: true,
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CliftonTestBanner extends StatelessWidget {
  final bool isEditable;

  const _CliftonTestBanner({required this.isEditable});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6C63FF).withValues(alpha: 0.08),
            AppTheme.cardBg,
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isEditable
              ? () async {
                  final uri = Uri.parse(
                    'https://esanj.ir/clifton-strengths-test',
                  );
                  try {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('امکان باز کردن لینک وجود ندارد'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon container
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.psychology_rounded,
                    color: Color(0xFF6C63FF),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'تست استعداد یابی کلیفتون',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isEditable
                            ? 'برای شرکت در آزمون کلیک کنید و نتیجه را در فرم وارد نمایید'
                            : 'نتیجه آزمون استعدادیابی کلیفتون',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Arrow or link icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isEditable ? Icons.open_in_new_rounded : Icons.link,
                    color: const Color(0xFF6C63FF),
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TalentRowCard extends StatelessWidget {
  final int index;
  final _RowControllers rowCtrl;
  final bool enabled;

  const _TalentRowCard({
    required this.index,
    required this.rowCtrl,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
            ),
            child: Text(
              'استعداد ${index + 1}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryDark,
              ),
            ),
          ),
          Container(height: 1, color: AppTheme.border),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                FormBuilder.buildTextField(
                  'عنوان',
                  rowCtrl.titleCtrl.text,
                  null,
                  controller: rowCtrl.titleCtrl,
                  enabled: enabled,
                ),
                const SizedBox(height: 10),
                FormBuilder.buildTextField(
                  'شرح',
                  rowCtrl.descCtrl.text,
                  null,
                  controller: rowCtrl.descCtrl,
                  maxLines: 2,
                  enabled: enabled,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
