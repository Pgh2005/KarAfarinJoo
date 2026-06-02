import 'package:flutter/material.dart';
import '../app_state.dart';
import '../widgets/form_field_builder.dart';

class PersonalInfoPage extends StatefulWidget {
  final AppState appState;
  const PersonalInfoPage({super.key, required this.appState});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  @override
  Widget build(BuildContext context) {
    final model = widget.appState.personalInfo;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('اطلاعات فردی و کسب و کار')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FormBuilder.buildSectionHeader('اطلاعات شخصی'),
              FormBuilder.buildTextField(
                'نام خانوادگی',
                model.lastName,
                (value) => setState(() => model.lastName = value),
              ),
              FormBuilder.buildTextField(
                'نام',
                model.firstName,
                (value) => setState(() => model.firstName = value),
              ),
              FormBuilder.buildTextField(
                'تماس',
                model.contact,
                (value) => setState(() => model.contact = value),
                keyboardType: TextInputType.phone,
              ),
              FormBuilder.buildTextField(
                'محله (اختیاری)',
                model.neighborhood,
                (value) => setState(() => model.neighborhood = value),
              ),
              FormBuilder.buildSectionHeader('تحصیلات'),
              FormBuilder.buildTextField(
                'رشته تحصیلی',
                model.major,
                (value) => setState(() => model.major = value),
              ),
              FormBuilder.buildDropdown<String>(
                'مقطع تحصیلی',
                model.degree,
                const [
                  DropdownMenuItem(value: 'کارشناسی', child: Text('کارشناسی')),
                  DropdownMenuItem(value: 'ارشد', child: Text('ارشد')),
                  DropdownMenuItem(value: 'دکتری', child: Text('دکتری')),
                ],
                (value) {
                  if (value != null) setState(() => model.degree = value);
                },
              ),
              FormBuilder.buildDropdown<String>(
                'رضایت از رشته؟',
                model.satisfiedMajor,
                const [
                  DropdownMenuItem(value: 'بله', child: Text('بله')),
                  DropdownMenuItem(value: 'خیر', child: Text('خیر')),
                ],
                (value) {
                  if (value != null)
                    setState(() => model.satisfiedMajor = value);
                },
              ),
              FormBuilder.buildTextField(
                'علت انتخاب رشته',
                model.majorReason,
                (value) => setState(() => model.majorReason = value),
                maxLines: 3,
              ),
              FormBuilder.buildTextField(
                'اگر برگردی به گذشته، چه می‌کنی؟',
                model.ifReturn,
                (value) => setState(() => model.ifReturn = value),
                maxLines: 2,
              ),
              FormBuilder.buildSectionHeader('کسب و کار'),
              FormBuilder.buildTextField(
                'عنوان کسب و کار',
                model.businessTitle,
                (value) => setState(() => model.businessTitle = value),
              ),
              FormBuilder.buildDropdown<String>(
                'آیا از کسب و کار خود راضی هستی؟',
                model.businessSatisfied,
                const [
                  DropdownMenuItem(value: 'بله', child: Text('بله')),
                  DropdownMenuItem(value: 'خیر', child: Text('خیر')),
                  DropdownMenuItem(value: 'تا حدی', child: Text('تا حدی')),
                ],
                (value) {
                  if (value != null)
                    setState(() => model.businessSatisfied = value);
                },
              ),
              FormBuilder.buildSectionHeader('ارزش‌ها'),
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
                (value) {
                  if (value != null)
                    setState(() => model.valueOrientation = value);
                },
              ),
              FormBuilder.buildTextField(
                'رتبه',
                model.rank,
                (value) => setState(() => model.rank = value),
                keyboardType: TextInputType.number,
                enabled: false,
              ),
              FormBuilder.buildTextField(
                'نمره',
                model.score,
                (value) => setState(() => model.score = value),
                keyboardType: TextInputType.number,
                enabled: false,
              ),
              FormBuilder.buildSaveButton(() {
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✓ مقادیر ذخیره شد')),
                );
              }, context),
            ],
          ),
        ),
      ),
    );
  }
}
