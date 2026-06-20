import 'package:flutter/material.dart';
import 'package:karafarini/core/theme/app_theme.dart';
import 'package:karafarini/widgets/app_bar_builder.dart';
import 'package:karafarini/widgets/save_button.dart';
import 'package:karafarini/widgets/section_card.dart';
import '../core/state/app_state.dart';
import '../widgets/form_field_builder.dart';

class TalentPage extends StatefulWidget {
  final AppState appState;
  const TalentPage({super.key, required this.appState});

  @override
  State<TalentPage> createState() => _TalentPageState();
}

class _TalentPageState extends State<TalentPage> {
  final bool isLoading = false;
  final bool isEnable = true;

  @override
  Widget build(BuildContext context) {
    final model = widget.appState.talent;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: const AppBarBuilder(title: 'استعدادیابی'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── اطلاعات کلی استعداد ──
              SectionCard(
                icon: Icons.psychology_outlined,
                title: 'اطلاعات کلی استعداد',
                children: [
                  FormBuilder.buildTextField(
                    'بالاترین دسته استعدادی',
                    model.highestCategory,
                    (v) => setState(() => model.highestCategory = v),
                  ),
                  const SizedBox(height: 12),
                  FormBuilder.buildTextField(
                    'پایین‌ترین استعداد',
                    model.lowestTalent,
                    (v) => setState(() => model.lowestTalent = v),
                  ),
                  const SizedBox(height: 12),
                  FormBuilder.buildTextField(
                    'تیپ استعدادی دو بعدی',
                    model.twoDimType,
                    (v) => setState(() => model.twoDimType = v),
                  ),
                  const SizedBox(height: 12),
                  FormBuilder.buildTextField(
                    'تیپ استعدادی چهار بعدی',
                    model.fourDimType,
                    (v) => setState(() => model.fourDimType = v),
                  ),
                  const SizedBox(height: 12),
                  FormBuilder.buildTextField(
                    'بهترین تیم مناسب',
                    model.bestTeam,
                    (v) => setState(() => model.bestTeam = v),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── هدر جدول رتبه استعداد ──
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
                      letterSpacing: -0.2,
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
                      '${model.rows.length} مورد',
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

              // ── ردیف‌های جدول ──
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: model.rows.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final row = model.rows[index];
                  return _TalentRowCard(
                    index: index,
                    row: row,
                    onChanged: () => setState(() {}),
                  );
                },
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

// ─── Talent Row Card ──────────────────────────────────────────────────────────
class _TalentRowCard extends StatelessWidget {
  final int index;
  final dynamic row;
  final VoidCallback onChanged;

  const _TalentRowCard({
    required this.index,
    required this.row,
    required this.onChanged,
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
          // Row header با شماره ردیف
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              // color: AppTheme.divider,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(13),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: Text(
                    'استعداد ${index + 1}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: AppTheme.border),
          // فیلدها
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                const SizedBox(height: 10),
                FormBuilder.buildTextField('عنوان', row.title, (v) {
                  row.title = v;
                  onChanged();
                }),
                const SizedBox(height: 10),
                FormBuilder.buildTextField('شرح', row.description, (v) {
                  row.description = v;
                  onChanged();
                }, maxLines: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
