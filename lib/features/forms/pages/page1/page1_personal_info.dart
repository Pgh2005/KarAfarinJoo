import 'package:flutter/material.dart';
import 'package:karafarini/features/forms/state/app_state.dart';
import 'package:karafarini/core/theme/app_theme.dart';
import 'package:karafarini/core/widgets/app_bar_builder.dart';
import 'package:karafarini/features/forms/widgets/form_field_builder.dart';
import 'package:karafarini/features/forms/widgets/save_button.dart';
import 'package:karafarini/features/forms/widgets/section_card.dart';

// ─── Page ─────────────────────────────────────────────────────────────────────
class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final bool isLoading = false;
  final bool isEnable = true;

  @override
  Widget build(BuildContext context) {
    final model = AppState().personalInfo;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: const AppBarBuilder(title: 'اطلاعات فردی و کسب‌و‌کار'),
        body: SingleChildScrollView(
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
                    'نام خانوادگی',
                    model.lastName,
                    (v) => setState(() => model.lastName = v),
                  ),
                  const SizedBox(height: 12),
                  FormBuilder.buildTextField(
                    'نام',
                    model.firstName,
                    (v) => setState(() => model.firstName = v),
                  ),
                  const SizedBox(height: 12),
                  FormBuilder.buildTextField(
                    'شماره تماس',
                    model.contact,
                    (v) => setState(() => model.contact = v),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  FormBuilder.buildTextField(
                    'محله (اختیاری)',
                    model.neighborhood,
                    (v) => setState(() => model.neighborhood = v),
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
                    model.major,
                    (v) => setState(() => model.major = v),
                  ),
                  const SizedBox(height: 12),
                  FormBuilder.buildDropdown<String>(
                    'مقطع تحصیلی',
                    model.degree,
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
                      DropdownMenuItem(value: 'دکتری', child: Text('دکتری')),
                    ],
                    (v) {
                      if (v != null) setState(() => model.degree = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  FormBuilder.buildDropdown<String>(
                    'رضایت از رشته؟',
                    model.satisfiedMajor,
                    const [
                      DropdownMenuItem(value: 'بله', child: Text('بله')),
                      DropdownMenuItem(value: 'خیر', child: Text('خیر')),
                    ],
                    (v) {
                      if (v != null) setState(() => model.satisfiedMajor = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  FormBuilder.buildTextField(
                    'علت انتخاب رشته',
                    model.majorReason,
                    (v) => setState(() => model.majorReason = v),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  FormBuilder.buildTextField(
                    'اگر به گذشته برگردی، چه می‌کنی؟',
                    model.ifReturn,
                    (v) => setState(() => model.ifReturn = v),
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
                    model.businessTitle,
                    (v) => setState(() => model.businessTitle = v),
                  ),
                  const SizedBox(height: 12),
                  FormBuilder.buildDropdown<String>(
                    'رضایت از کسب‌و‌کار؟',
                    model.businessSatisfied,
                    const [
                      DropdownMenuItem(value: 'بله', child: Text('بله')),
                      DropdownMenuItem(value: 'خیر', child: Text('خیر')),
                      DropdownMenuItem(value: 'تا حدی', child: Text('تا حدی')),
                    ],
                    (v) {
                      if (v != null) {
                        setState(() => model.businessSatisfied = v);
                      }
                    },
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
                    const [
                      DropdownMenuItem(value: 'علم', child: Text('علم')),
                      DropdownMenuItem(value: 'قدرت', child: Text('قدرت')),
                      DropdownMenuItem(value: 'ثروت', child: Text('ثروت')),
                      DropdownMenuItem(value: 'شهرت', child: Text('شهرت')),
                      DropdownMenuItem(value: 'وظیفه', child: Text('وظیفه')),
                    ],
                    (v) {
                      if (v != null) setState(() => model.valueOrientation = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  // رتبه و نمره — فقط نمایش، قابل ویرایش نیست
                  Row(
                    children: [
                      Expanded(
                        child: _ReadOnlyField(
                          label: 'رتبه',
                          value: model.rank,
                          icon: Icons.leaderboard_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ReadOnlyField(
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
              // ── دکمه ذخیره ──
              SaveButton(
                onSave: () {},
                isLoading: isLoading,
                isEnabled: isEnable,
              ),
              const SizedBox(height: 32),
            ],
          ),
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
