import 'package:flutter/material.dart';
import 'package:karafarini/widgets/app_bar_builder.dart';
import 'package:karafarini/widgets/save_button.dart';
import '../app_state.dart';

class GrowthTablePage extends StatefulWidget {
  final AppState appState;
  const GrowthTablePage({super.key, required this.appState});

  @override
  State<GrowthTablePage> createState() => _GrowthTablePageState();
}

class _GrowthTablePageState extends State<GrowthTablePage> {
  final bool isLoading = false;
  final bool isEnable = true;

  @override
  Widget build(BuildContext context) {
    final periods = widget.appState.growthTable.periods;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const AppBarBuilder(title: 'جدول رشد'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    widget.appState.addGrowthPeriod();
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('افزودن دوره جدید'),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: periods.length,
                itemBuilder: (context, index) {
                  final period = periods[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'دوره ${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 14),
                            buildTextField(
                              'تاریخ شروع',
                              period.startDate,
                              (value) =>
                                  setState(() => period.startDate = value),
                              hintText: '1405/04/01',
                            ),
                            const SizedBox(height: 14),
                            buildTextField(
                              'تاریخ هدف',
                              period.targetDate,
                              (value) =>
                                  setState(() => period.targetDate = value),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'شاخص‌ها',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 10),
                            ...period.metrics.map((metric) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${metric.title} (${metric.unit})',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: buildTextField(
                                            'مقدار فعلی',
                                            metric.currentValue,
                                            (value) => setState(
                                              () => metric.currentValue = value,
                                            ),
                                            keyboardType: TextInputType.number,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: buildTextField(
                                            'هدف',
                                            metric.target,
                                            (value) => setState(
                                              () => metric.target = value,
                                            ),
                                            keyboardType: TextInputType.number,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: buildTextField(
                                            'نتیجه',
                                            metric.result,
                                            (value) => setState(
                                              () => metric.result = value,
                                            ),
                                            keyboardType: TextInputType.number,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),
                            SaveButton(
                              onSave: () {},
                              isEnabled: isEnable,
                              isLoading: isLoading,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    String label,
    String value,
    ValueChanged<String> onChanged, {
    TextInputType keyboardType = TextInputType.text,
    String? hintText,
  }) {
    return TextFormField(
      initialValue: value,
      onChanged: onChanged,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
