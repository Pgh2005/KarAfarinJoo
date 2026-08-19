import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karafarini/core/theme/app_theme.dart';
import 'package:karafarini/core/widgets/app_bar_builder.dart';
import 'package:karafarini/features/forms/pages/page1/models/personal_info_model.dart';
import 'package:karafarini/features/forms/widgets/form_field_builder.dart';
import 'package:karafarini/features/forms/widgets/form_progress.dart';
import 'package:karafarini/features/forms/widgets/progress_bar_widget.dart';
import 'package:karafarini/features/forms/widgets/save_button.dart';
import 'package:karafarini/features/forms/widgets/section_card.dart';
import '../providers/personal_info_provider.dart';

class PersonalInfoPage extends ConsumerStatefulWidget {
  final String classId;
  final String studentId;
  final bool isProfessor;

  const PersonalInfoPage({
    super.key,
    required this.classId,
    required this.studentId,
    this.isProfessor = false,
  });

  @override
  ConsumerState<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends ConsumerState<PersonalInfoPage> {
  // Controllers
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _contactCtrl;
  late final TextEditingController _neighborhoodCtrl;
  late final TextEditingController _majorCtrl;
  late final TextEditingController _majorReasonCtrl;
  late final TextEditingController _ifReturnCtrl;
  late final TextEditingController _businessTitleCtrl;
  late final TextEditingController _businessSloganCtrl;
  late final TextEditingController _lifeSloganCtrl;
  late final TextEditingController _rankCtrl;
  late final TextEditingController _scoreCtrl;

  bool _isInitialized = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _lastNameCtrl = TextEditingController();
    _firstNameCtrl = TextEditingController();
    _contactCtrl = TextEditingController();
    _neighborhoodCtrl = TextEditingController();
    _majorCtrl = TextEditingController();
    _majorReasonCtrl = TextEditingController();
    _ifReturnCtrl = TextEditingController();
    _businessTitleCtrl = TextEditingController();
    _businessSloganCtrl = TextEditingController();
    _lifeSloganCtrl = TextEditingController();
    _rankCtrl = TextEditingController();
    _scoreCtrl = TextEditingController();
  }

  @override
  void didUpdateWidget(covariant PersonalInfoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.classId != widget.classId ||
        oldWidget.studentId != widget.studentId) {
      _isInitialized = false;
      _clearControllers();
    }
  }

  @override
  void dispose() {
    _lastNameCtrl.dispose();
    _firstNameCtrl.dispose();
    _contactCtrl.dispose();
    _neighborhoodCtrl.dispose();
    _majorCtrl.dispose();
    _majorReasonCtrl.dispose();
    _ifReturnCtrl.dispose();
    _businessTitleCtrl.dispose();
    _businessSloganCtrl.dispose();
    _lifeSloganCtrl.dispose();
    _rankCtrl.dispose();
    _scoreCtrl.dispose();
    super.dispose();
  }

  void _clearControllers() {
    _lastNameCtrl.clear();
    _firstNameCtrl.clear();
    _contactCtrl.clear();
    _neighborhoodCtrl.clear();
    _majorCtrl.clear();
    _majorReasonCtrl.clear();
    _ifReturnCtrl.clear();
    _businessTitleCtrl.clear();
    _businessSloganCtrl.clear();
    _lifeSloganCtrl.clear();
    _rankCtrl.clear();
    _scoreCtrl.clear();
  }

  void _syncControllers(PersonalInfoModel model) {
    if (_isInitialized) return;

    _lastNameCtrl.text = model.lastName;
    _firstNameCtrl.text = model.firstName;
    _contactCtrl.text = model.contact;
    _neighborhoodCtrl.text = model.neighborhood;
    _majorCtrl.text = model.major;
    _majorReasonCtrl.text = model.majorReason;
    _ifReturnCtrl.text = model.ifReturn;
    _businessTitleCtrl.text = model.businessTitle;
    _businessSloganCtrl.text = model.businessSlogan;
    _lifeSloganCtrl.text = model.lifeSlogan;
    _rankCtrl.text = model.rank;
    _scoreCtrl.text = model.score;

    _isInitialized = true;
  }

  Future<void> _handleSave(PersonalInfoNotifier notifier) async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    // ۱. مقادیر کنترلرها را در State بروزرسانی می‌کنیم
    notifier.updateState(
      (m) => m.copyWith(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        contact: _contactCtrl.text.trim(),
        neighborhood: _neighborhoodCtrl.text.trim(),
        major: _majorCtrl.text.trim(),
        majorReason: _majorReasonCtrl.text.trim(),
        ifReturn: _ifReturnCtrl.text.trim(),
        businessTitle: _businessTitleCtrl.text.trim(),
        businessSlogan: _businessSloganCtrl.text.trim(),
        lifeSlogan: _lifeSloganCtrl.text.trim(),
        rank: _rankCtrl.text.trim(),
        score: _scoreCtrl.text.trim(),
      ),
    );

    // ۲. متد save را فراخوانی می‌کنیم
    final success = await notifier.saveData();

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'اطلاعات با موفقیت ذخیره شد' : 'خطا در ثبت اطلاعات',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final params = FormParams(
      classId: widget.classId,
      studentId: widget.studentId,
    );
    final asyncState = ref.watch(personalInfoNotifierProvider(params));
    final notifier = ref.read(personalInfoNotifierProvider(params).notifier);
    final isEditable = !widget.isProfessor;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: const AppBarBuilder(title: 'اطلاعات فردی و کسب‌و‌کار'),
        body: asyncState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Text(
              'خطا در دریافت اطلاعات: $err',
              style: const TextStyle(color: Colors.red),
            ),
          ),
          data: (model) {
            _syncControllers(model);

            final progress = model.progress;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Progress Bar ──
                  FormProgressBar(
                    percent: progress.percent,
                    showLabel: true,
                  ),
                  const SizedBox(height: 16),
                  // ── بخش اطلاعات شخصی ──
                  SectionCard(
                    icon: Icons.person_outline_rounded,
                    title: 'اطلاعات شخصی',
                    children: [
                      FormBuilder.buildTextField(
                        'نام',
                        _firstNameCtrl.text,
                        null,
                        controller: _firstNameCtrl,
                        enabled: isEditable,
                      ),
                      const SizedBox(height: 12),
                      FormBuilder.buildTextField(
                        'نام خانوادگی',
                        _lastNameCtrl.text,
                        null,
                        controller: _lastNameCtrl,
                        enabled: isEditable,
                      ),
                      const SizedBox(height: 12),
                      FormBuilder.buildTextField(
                        'شماره تماس',
                        _contactCtrl.text,
                        null,
                        controller: _contactCtrl,
                        enabled: isEditable,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      FormBuilder.buildTextField(
                        'محله (اختیاری)',
                        _neighborhoodCtrl.text,
                        null,
                        controller: _neighborhoodCtrl,
                        enabled: isEditable,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── بخش تحصیلات ──
                  SectionCard(
                    icon: Icons.school_outlined,
                    title: 'تحصیلات',
                    children: [
                      FormBuilder.buildTextField(
                        'رشته تحصیلی',
                        _majorCtrl.text,
                        null,
                        controller: _majorCtrl,
                        enabled: isEditable,
                      ),
                      const SizedBox(height: 12),
                      FormBuilder.buildDropdown<String>(
                        'مقطع تحصیلی',
                        model.degree,
                        enabled: isEditable,
                        const [
                          DropdownMenuItem(
                            value: 'کاردانی',
                            child: Text('کاردانی'),
                          ),
                          DropdownMenuItem(
                            value: 'کارشناسی',
                            child: Text('کارشناسی'),
                          ),
                          DropdownMenuItem(value: 'ارشد', child: Text('ارشد')),
                          DropdownMenuItem(
                            value: 'دکتری',
                            child: Text('دکتری'),
                          ),
                        ],
                        isEditable
                            ? (v) {
                                if (v != null) {
                                  notifier.updateState(
                                    (m) => m.copyWith(degree: v),
                                  );
                                }
                              }
                            : null,
                      ),
                      const SizedBox(height: 12),
                      FormBuilder.buildDropdown<String>(
                        'رضایت از رشته؟',
                        model.satisfiedMajor,
                        enabled: isEditable,
                        const [
                          DropdownMenuItem(value: 'بله', child: Text('بله')),
                          DropdownMenuItem(value: 'خیر', child: Text('خیر')),
                        ],
                        isEditable
                            ? (v) {
                                if (v != null) {
                                  notifier.updateState(
                                    (m) => m.copyWith(satisfiedMajor: v),
                                  );
                                }
                              }
                            : null,
                      ),
                      const SizedBox(height: 12),
                      FormBuilder.buildTextField(
                        'علت انتخاب رشته',
                        _majorReasonCtrl.text,
                        null,
                        controller: _majorReasonCtrl,
                        enabled: isEditable,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      FormBuilder.buildTextField(
                        'اگر به گذشته برگردی، چه می‌کنی؟',
                        _ifReturnCtrl.text,
                        null,
                        controller: _ifReturnCtrl,
                        enabled: isEditable,
                        maxLines: 2,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── بخش کسب‌وکار ──
                  SectionCard(
                    icon: Icons.business_center_outlined,
                    title: 'کسب‌و‌کار',
                    children: [
                      FormBuilder.buildTextField(
                        'عنوان کسب‌و‌کار',
                        _businessTitleCtrl.text,
                        null,
                        controller: _businessTitleCtrl,
                        enabled: isEditable,
                      ),
                      const SizedBox(height: 12),
                      FormBuilder.buildDropdown<String>(
                        'رضایت از کسب‌و‌کار؟',
                        model.businessSatisfied,
                        enabled: isEditable,
                        const [
                          DropdownMenuItem(value: 'بله', child: Text('بله')),
                          DropdownMenuItem(value: 'خیر', child: Text('خیر')),
                          DropdownMenuItem(
                            value: 'تا حدی',
                            child: Text('تا حدی'),
                          ),
                        ],
                        isEditable
                            ? (v) {
                                if (v != null) {
                                  notifier.updateState(
                                    (m) => m.copyWith(businessSatisfied: v),
                                  );
                                }
                              }
                            : null,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  SectionCard(
                    icon: Icons.auto_awesome_rounded,
                    title: 'شعار',
                    children: [
                      FormBuilder.buildTextField(
                        'شعار کسب‌و‌کار',
                        _businessSloganCtrl.text,
                        null,
                        controller: _businessSloganCtrl,
                        enabled: isEditable,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      FormBuilder.buildTextField(
                        'شعار زندگی',
                        _lifeSloganCtrl.text,
                        null,
                        controller: _lifeSloganCtrl,
                        enabled: isEditable,
                        maxLines: 2,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── بخش ارزش‌ها ──
                  SectionCard(
                    icon: Icons.star_border_rounded,
                    title: 'ارزش‌ها',
                    children: [
                      FormBuilder.buildDropdown<String>(
                        'جهت‌گیری ارزشی',
                        model.valueOrientation,
                        enabled: isEditable,
                        const [
                          DropdownMenuItem(value: 'علم', child: Text('علم')),
                          DropdownMenuItem(value: 'قدرت', child: Text('قدرت')),
                          DropdownMenuItem(value: 'ثروت', child: Text('ثروت')),
                          DropdownMenuItem(value: 'شهرت', child: Text('شهرت')),
                          DropdownMenuItem(
                            value: 'وظیفه',
                            child: Text('وظیفه'),
                          ),
                        ],
                        isEditable
                            ? (v) {
                                if (v != null) {
                                  notifier.updateState(
                                    (m) => m.copyWith(valueOrientation: v),
                                  );
                                }
                              }
                            : null,
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: widget.isProfessor
                                ? FormBuilder.buildTextField(
                                    'رتبه',
                                    _rankCtrl.text,
                                    null,
                                    controller: _rankCtrl,
                                    enabled: true,
                                    keyboardType: TextInputType.number,
                                  )
                                : _ReadOnlyField(
                                    label: 'رتبه',
                                    value: model.rank,
                                    icon: Icons.leaderboard_outlined,
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: widget.isProfessor
                                ? FormBuilder.buildTextField(
                                    'نمره',
                                    _scoreCtrl.text,
                                    null,
                                    controller: _scoreCtrl,
                                    enabled: true,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                  )
                                : _ReadOnlyField(
                                    label: 'نمره',
                                    value: model.score,
                                    icon: Icons.grade_outlined,
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // دکمه ذخیره بر اساس وضعیت دسترسی استاد/دانشجو نمایش داده یا فعال می‌شود
                  SaveButton(
                    onSave: () => _handleSave(notifier),
                    isLoading: _isSaving,
                    isEnabled: !_isSaving && (isEditable || widget.isProfessor),
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

// ─── Read-Only Field Widget ───────────────────────────────────────────────────
class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ReadOnlyField({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.divider,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border, width: 1.2),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textHint, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textHint,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isEmpty ? '—' : value,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppTheme.textSecondary,
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
