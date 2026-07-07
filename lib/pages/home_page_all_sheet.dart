import 'package:flutter/material.dart';
import 'package:karafarini/core/theme/app_theme.dart';
import 'package:karafarini/core/widgets/app_bar_builder.dart';
import '../core/state/app_state.dart';
import 'page1_personal_info.dart';
import 'page2_talent.dart';
import 'page3_values.dart';
import 'page4_business_selection.dart';
import 'page5_product_priority.dart';
import 'page6_growth_table.dart';

class HomePageAllSheet extends StatelessWidget {
  final AppState appState;
  // final VoidCallback toggleTheme;
  const HomePageAllSheet({
    super.key,
    required this.appState,
    // required this.toggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final pages = [
      {
        'title': 'اطلاعات فردی و کسب و کار',
        'icon': Icons.person,
        'widget': PersonalInfoPage(appState: appState),
      },
      {
        'title': 'استعدادیابی',
        'icon': Icons.lightbulb,
        'widget': TalentPage(appState: appState),
      },
      {
        'title': 'ارزش‌ها',
        'icon': Icons.favorite,
        'widget': ValuesPage(appState: appState),
      },
      {
        'title': 'انتخاب کسب و کار',
        'icon': Icons.business,
        'widget': BusinessSelectionPage(appState: appState),
      },
      {
        'title': 'اولویت محصولات',
        'icon': Icons.shopping_bag,
        'widget': ProductPriorityPage(appState: appState),
      },
      {
        'title': 'جدول رشد',
        'icon': Icons.trending_up,
        'widget': GrowthTablePage(appState: appState),
      },
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBarBuilder(title: 'کارآفرین جو'),
        body: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: pages.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = pages[index];
            return Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => item['widget'] as Widget),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                item['icon'] as IconData,
                                color: AppTheme.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                item['title'] as String,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 18,
                        color: AppTheme.primary,
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
