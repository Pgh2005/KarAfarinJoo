import 'package:flutter/material.dart';
import 'package:karafarini/core/theme/app_theme.dart';
import 'package:karafarini/features/classes/models/class_model.dart';

class StudentClassDetailSection extends StatelessWidget {
  final ClassModel classModel;

  const StudentClassDetailSection({super.key, required this.classModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: AppTheme.primary),
              SizedBox(width: 8),
              Text(
                'اطلاعات کلاس',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'شما به عنوان دانشجو در این کلاس هستید. در این بخش می‌توانید اطلاعات مربوط به کلاس، فرم‌ها، تکالیف یا وضعیت خود را مشاهده کنید.',
            style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.7),
          ),
        ],
      ),
    );
  }
}
