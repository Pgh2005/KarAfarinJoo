import 'package:flutter/material.dart';
import 'package:karafarini/widgets/app_bar_builder.dart';
import 'package:karafarini/widgets/save_button.dart';
import '../app_state.dart';

class ProductPriorityPage extends StatefulWidget {
  final AppState appState;
  const ProductPriorityPage({super.key, required this.appState});

  @override
  State<ProductPriorityPage> createState() => _ProductPriorityPageState();
}

class _ProductPriorityPageState extends State<ProductPriorityPage> {
  final bool isLoading = false;
  final bool isEnable = true;

  @override
  Widget build(BuildContext context) {
    final model = widget.appState.productPriority;
    final totals = List.generate(
      4,
      (index) => model.criteria.fold<double>(0, (sum, item) {
        final value =
            double.tryParse(item.scores[index].replaceAll(',', '')) ?? 0;
        return sum + value;
      }),
    );
    final maxScore = 17 * 10;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const AppBarBuilder(title: 'اولویت محصولات'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: model.criteria.length,
                itemBuilder: (context, index) {
                  final item = model.criteria[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.category,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: List.generate(4, (productIndex) {
                                return Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      left: productIndex < 3 ? 8 : 0,
                                    ),
                                    child: TextFormField(
                                      initialValue: item.scores[productIndex],
                                      onChanged: (value) => setState(
                                        () => item.scores[productIndex] = value,
                                      ),
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: 'محصول ${productIndex + 1}',
                                        border: const OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Card(
                color: Colors.grey[100],
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'جمع امتیازات',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...List.generate(4, (index) {
                        final percent = maxScore > 0
                            ? totals[index] / maxScore * 100
                            : 0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            'محصول ${index + 1}: ${totals[index].toStringAsFixed(1)}  |  درصد: ${percent.toStringAsFixed(1)}%',
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
