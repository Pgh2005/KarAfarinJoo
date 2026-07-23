import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:karafarini/core/theme/app_theme.dart';
import 'package:karafarini/core/widgets/app_bar_builder.dart';
import 'package:karafarini/features/forms/pages/page1/presentation/personal_info_page.dart';
import 'package:karafarini/features/forms/pages/page2/page2_talent.dart';
import 'package:karafarini/features/forms/pages/page3/page3_values.dart';
import 'package:karafarini/features/forms/pages/page4/page4_business_selection.dart';
import 'package:karafarini/features/forms/pages/page5/page5_product_priority.dart';
import 'package:karafarini/features/forms/pages/page6/page6_growth_table.dart';
import 'package:karafarini/features/profile/providers/current_session_profile_provider.dart';

class FormList extends ConsumerWidget {
  final String classId;
  final String studentId;
  final String studentName;

  const FormList({
    super.key,
    required this.classId,
    required this.studentId,
    required this.studentName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isProfessor = ref.watch(isProfessorProvider);
    // لیست ساختاریافته فرم‌ها
    final List<Map<String, dynamic>> forms = [
      {
        'title': 'اطلاعات فردی و کسب و کار',
        'icon': Icons.person,
        'page': (String cid, String sid) => PersonalInfoPage(
          classId: cid,
          studentId: sid,
          isProfessor: isProfessor,
        ),
      },
      {
        'title': 'استعدادیابی',
        'icon': Icons.lightbulb,
        'page': (String cid, String sid) => TalentPage(),
      },
      {
        'title': 'ارزش‌ها',
        'icon': Icons.favorite,
        'page': (String cid, String sid) => ValuesPage(),
      },
      {
        'title': 'انتخاب کسب و کار',
        'icon': Icons.business,
        'page': (String cid, String sid) => BusinessSelectionPage(),
      },
      {
        'title': 'اولویت محصولات',
        'icon': Icons.shopping_bag,
        'page': (String cid, String sid) => ProductPriorityPage(),
      },
      {
        'title': 'جدول رشد',
        'icon': Icons.trending_up,
        'page': (String cid, String sid) => GrowthTablePage(),
      },
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: AppBarBuilder(title: studentName),
        body: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: forms.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final form = forms[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          (form['page'] as Function(String, String))(
                                classId,
                                studentId,
                              )
                              as Widget,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 16,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          form['icon'] as IconData,
                          color: AppTheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          form['title'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: AppTheme.primary.withValues(alpha: 0.7),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
