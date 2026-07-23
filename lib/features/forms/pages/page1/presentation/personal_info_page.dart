import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karafarini/core/theme/app_theme.dart';
import 'package:karafarini/core/widgets/app_bar_builder.dart';
import 'package:karafarini/features/forms/pages/page1/models/personal_info_model.dart';
import 'package:karafarini/features/forms/widgets/form_field_builder.dart';
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

  @override
  Widget build(BuildContext context) {
    final params = FormParams(
      classId: widget.classId,
      studentId: widget.studentId,
    );
    final asyncState = ref.watch(personalInfoNotifierProvider(params));
    final notifier = ref.read(personalInfoNotifierProvider(params).notifier);

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

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── بخش اطلاعات شخصی ──
                  SectionCard(
                    icon: Icons.person_outline_rounded,
                    title: 'اطلاعات شخصی',
                    children: [
                      FormBuilder.buildTextField(
                        'نام',
                        _firstNameCtrl.text,
                        enabled: !widget.isProfessor,
                        widget.isProfessor
                            ? (_) {}
                            : (v) => notifier.updateState(
                                (m) => m.copyWith(firstName: v),
                              ),
                      ),
                      const SizedBox(height: 12),
                      FormBuilder.buildTextField(
                        'نام خانوادگی',
                        _lastNameCtrl.text,
                        enabled: !widget.isProfessor,
                        widget.isProfessor
                            ? (_) {}
                            : (v) => notifier.updateState(
                                (m) => m.copyWith(lastName: v),
                              ),
                      ),
                      const SizedBox(height: 12),
                      FormBuilder.buildTextField(
                        'شماره تماس',
                        _contactCtrl.text,
                        enabled: !widget.isProfessor,
                        widget.isProfessor
                            ? (_) {}
                            : (v) => notifier.updateState(
                                (m) => m.copyWith(contact: v),
                              ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      FormBuilder.buildTextField(
                        'محله (اختیاری)',
                        _neighborhoodCtrl.text,
                        enabled: !widget.isProfessor,
                        widget.isProfessor
                            ? (_) {}
                            : (v) => notifier.updateState(
                                (m) => m.copyWith(neighborhood: v),
                              ),
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
                        enabled: !widget.isProfessor,
                        widget.isProfessor
                            ? (_) {}
                            : (v) => notifier.updateState(
                                (m) => m.copyWith(major: v),
                              ),
                      ),
                      const SizedBox(height: 12),
                      FormBuilder.buildDropdown<String>(
                        'مقطع تحصیلی',
                        model.degree,
                        enabled: !widget.isProfessor,
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
                        widget.isProfessor
                            ? (_) {}
                            : (v) {
                                if (v != null) {
                                  notifier.updateState(
                                    (m) => m.copyWith(degree: v),
                                  );
                                }
                              },
                      ),
                      const SizedBox(height: 12),
                      FormBuilder.buildDropdown<String>(
                        'رضایت از رشته؟',
                        model.satisfiedMajor,
                        enabled: !widget.isProfessor,
                        const [
                          DropdownMenuItem(value: 'بله', child: Text('بله')),
                          DropdownMenuItem(value: 'خیر', child: Text('خیر')),
                        ],
                        widget.isProfessor
                            ? (_) {}
                            : (v) {
                                if (v != null) {
                                  notifier.updateState(
                                    (m) => m.copyWith(satisfiedMajor: v),
                                  );
                                }
                              },
                      ),
                      const SizedBox(height: 12),
                      FormBuilder.buildTextField(
                        'علت انتخاب رشته',
                        _majorReasonCtrl.text,
                        enabled: !widget.isProfessor,
                        widget.isProfessor
                            ? (_) {}
                            : (v) => notifier.updateState(
                                (m) => m.copyWith(majorReason: v),
                              ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      FormBuilder.buildTextField(
                        'اگر به گذشته برگردی، چه می‌کنی؟',
                        _ifReturnCtrl.text,
                        enabled: !widget.isProfessor,
                        widget.isProfessor
                            ? (_) {}
                            : (v) => notifier.updateState(
                                (m) => m.copyWith(ifReturn: v),
                              ),
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
                        enabled: !widget.isProfessor,
                        widget.isProfessor
                            ? (_) {}
                            : (v) => notifier.updateState(
                                (m) => m.copyWith(businessTitle: v),
                              ),
                      ),
                      const SizedBox(height: 12),
                      FormBuilder.buildDropdown<String>(
                        'رضایت از کسب‌و‌کار؟',
                        model.businessSatisfied,
                        enabled: !widget.isProfessor,
                        const [
                          DropdownMenuItem(value: 'بله', child: Text('بله')),
                          DropdownMenuItem(value: 'خیر', child: Text('خیر')),
                          DropdownMenuItem(
                            value: 'تا حدی',
                            child: Text('تا حدی'),
                          ),
                        ],
                        widget.isProfessor
                            ? (_) {}
                            : (v) {
                                if (v != null) {
                                  notifier.updateState(
                                    (m) => m.copyWith(businessSatisfied: v),
                                  );
                                }
                              },
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
                        enabled: !widget.isProfessor,
                        widget.isProfessor
                            ? (_) {}
                            : (v) => notifier.updateState(
                                (m) => m.copyWith(businessSlogan: v),
                              ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      FormBuilder.buildTextField(
                        'شعار زندگی',
                        _lifeSloganCtrl.text,
                        enabled: !widget.isProfessor,
                        widget.isProfessor
                            ? (_) {}
                            : (v) => notifier.updateState(
                                (m) => m.copyWith(lifeSlogan: v),
                              ),
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
                        enabled: !widget.isProfessor,
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
                        widget.isProfessor
                            ? (_) {}
                            : (v) {
                                if (v != null) {
                                  notifier.updateState(
                                    (m) => m.copyWith(valueOrientation: v),
                                  );
                                }
                              },
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: widget.isProfessor
                                ? FormBuilder.buildTextField(
                                    'رتبه',
                                    _rankCtrl.text,
                                    (v) => notifier.updateState(
                                      (m) => m.copyWith(rank: v),
                                    ),
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
                                    (v) => notifier.updateState(
                                      (m) => m.copyWith(score: v),
                                    ),
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

                  SaveButton(
                    onSave: () async {
                      final success = await notifier.saveData();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? 'اطلاعات با موفقیت ذخیره شد'
                                  : 'خطا در ثبت اطلاعات',
                            ),
                            backgroundColor: success
                                ? Colors.green
                                : Colors.red,
                          ),
                        );
                      }
                    },
                    isLoading: asyncState.isLoading,
                    isEnabled: !asyncState.isLoading,
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
