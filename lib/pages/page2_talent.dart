import 'package:flutter/material.dart';
import '../app_state.dart';
import '../widgets/form_field_builder.dart';

class TalentPage extends StatefulWidget {
  final AppState appState;
  const TalentPage({super.key, required this.appState});

  @override
  State<TalentPage> createState() => _TalentPageState();
}

class _TalentPageState extends State<TalentPage> {
  @override
  Widget build(BuildContext context) {
    final model = widget.appState.talent;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('استعدادیابی')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FormBuilder.buildTextField(
                'بالاترین دسته استعدادی',
                model.highestCategory,
                (value) => setState(() => model.highestCategory = value),
              ),
              FormBuilder.buildTextField(
                'پایین‌ترین استعداد',
                model.lowestTalent,
                (value) => setState(() => model.lowestTalent = value),
              ),
              FormBuilder.buildTextField(
                'تیپ استعدادی دو بعدی',
                model.twoDimType,
                (value) => setState(() => model.twoDimType = value),
              ),
              FormBuilder.buildTextField(
                'تیپ استعدادی چهار بعدی',
                model.fourDimType,
                (value) => setState(() => model.fourDimType = value),
              ),
              FormBuilder.buildTextField(
                'بهترین تیم مناسب',
                model.bestTeam,
                (value) => setState(() => model.bestTeam = value),
              ),
              FormBuilder.buildSectionHeader('جدول رتبه استعداد'),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: model.rows.length,
                itemBuilder: (context, index) {
                  final row = model.rows[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ردیف ${index + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          FormBuilder.buildTextField(
                            'رتبه استعداد',
                            row.rank,
                            (value) => setState(() => row.rank = value),
                            keyboardType: TextInputType.number,
                          ),
                          FormBuilder.buildTextField(
                            'عنوان',
                            row.title,
                            (value) => setState(() => row.title = value),
                          ),
                          FormBuilder.buildTextField(
                            'شرح',
                            row.description,
                            (value) => setState(() => row.description = value),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              FormBuilder.buildSaveButton(
                () {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✓ مقادیر ذخیره شد')),
                  );
                },
                context,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
