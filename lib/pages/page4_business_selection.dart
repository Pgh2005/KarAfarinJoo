import 'package:flutter/material.dart';
import '../app_state.dart';

class BusinessSelectionPage extends StatefulWidget {
  final AppState appState;
  const BusinessSelectionPage({Key? key, required this.appState})
    : super(key: key);

  @override
  State<BusinessSelectionPage> createState() => _BusinessSelectionPageState();
}

class _BusinessSelectionPageState extends State<BusinessSelectionPage> {
  @override
  Widget build(BuildContext context) {
    final model = widget.appState.businessSelection;
    final totals = List.generate(
      3,
      (index) => model.criteria.fold<double>(0, (sum, item) {
        final value =
            double.tryParse(item.scores[index].replaceAll(',', '')) ?? 0;
        return sum + value;
      }),
    );
    final maxScore = 25 * 10;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('انتخاب کسب و کار')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
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
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 4,
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
                                  const SizedBox(height: 6),
                                  Text(
                                    'وزن: ${item.weight}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 5,
                              child: Row(
                                children: List.generate(3, (bizIndex) {
                                  return Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        left: bizIndex < 2 ? 8 : 0,
                                      ),
                                      child: TextFormField(
                                        initialValue: item.scores[bizIndex],
                                        onChanged: (value) => setState(
                                          () => item.scores[bizIndex] = value,
                                        ),
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          labelText: 'کسب‌وکار ${bizIndex + 1}',
                                          border: const OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
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
                      ...List.generate(3, (index) {
                        final percent = maxScore > 0
                            ? totals[index] / maxScore * 100
                            : 0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            'کسب‌وکار ${index + 1}: ${totals[index].toStringAsFixed(1)}  |  درصد: ${percent.toStringAsFixed(1)}%',
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('مقادیر ذخیره شد')),
                  );
                },
                child: const Text('ذخیره'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
