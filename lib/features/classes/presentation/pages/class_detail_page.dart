import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karafarini/core/theme/app_theme.dart';
import 'package:karafarini/core/widgets/app_bar_builder.dart';
import 'package:karafarini/features/classes/models/class_model.dart';

class ClassDetailPage extends ConsumerWidget {
  final ClassModel classModel;

  const ClassDetailPage({super.key, required this.classModel});

  void _copyInviteCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: classModel.joinCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('کد دعوت کپی شد: ${classModel.joinCode}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBarBuilder(
        title: classModel.title,
        automaticallyImplyLeading: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Card with gradient
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primary.withValues(alpha: 0.1),
                  AppTheme.primaryLight,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.class_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        classModel.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (classModel.description != null && classModel.description!.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    classModel.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Class Info Card
          Container(
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'اطلاعات کلاس',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.code,
                    'کد درس',
                    classModel.courseCode,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.calendar_month,
                    'ترم',
                    classModel.semester,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.group,
                    'حداکثر دانشجو',
                    '${classModel.maxStudents} نفر',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.circle,
                    'وضعیت',
                    classModel.isActive ? 'فعال' : 'غیرفعال',
                    valueColor: classModel.isActive ? Colors.green : Colors.red,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Invite Code Card - Highlighted
          Container(
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.vpn_key, color: AppTheme.primary, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'کد دعوت کلاس',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          classModel.joinCode,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                            letterSpacing: 6,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _copyInviteCode(context),
                            icon: const Icon(Icons.copy, size: 18),
                            label: const Text('کپی کد دعوت'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'این کد را با دانشجویان خود به اشتراک بگذارید تا بتوانند درخواست عضویت بدهند',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Members Section (placeholder)
          Container(
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.people, color: AppTheme.primary, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'اعضای کلاس',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'لیست اعضا به زودی اضافه می‌شود',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textSecondary),
        const SizedBox(width: 10),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: valueColor ?? AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
