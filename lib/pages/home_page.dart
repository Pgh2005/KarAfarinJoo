import 'package:flutter/material.dart';
import '../app_state.dart';
import 'page1_personal_info.dart';
import 'page2_talent.dart';
import 'page3_values.dart';
import 'page4_business_selection.dart';
import 'page5_product_priority.dart';
import 'page6_growth_table.dart';

class HomePage extends StatelessWidget {
  final AppState appState;
  final VoidCallback toggleTheme;
  const HomePage({Key? key, required this.appState, required this.toggleTheme})
    : super(key: key);

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
        appBar: AppBar(
          title: const Text(
            'کارآفرین جو',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.brightness_4),
              onPressed: toggleTheme,
              tooltip: 'تغییر تم',
            ),
          ],
        ),
        body: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: pages.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
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
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                item['icon'] as IconData,
                                color: Theme.of(context).colorScheme.primary,
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
                        Icons.arrow_back_ios,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
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
