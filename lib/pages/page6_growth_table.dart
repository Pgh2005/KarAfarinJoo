import 'package:flutter/material.dart';
import '../app_state.dart';
// import '../widgets/form_field_builder.dart';

class GrowthTablePage extends StatefulWidget {
  final AppState appState;
  const GrowthTablePage({super.key, required this.appState});

  @override
  State<GrowthTablePage> createState() => _GrowthTablePageState();
}

// class _GrowthTablePageState extends State<GrowthTablePage> {
//   @override
//   Widget build(BuildContext context) {
//     final periods = widget.appState.growthTable.periods;
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         appBar: AppBar(title: const Text('جدول رشد')),
//         body: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             children: [
//               ElevatedButton.icon(
//                 onPressed: () {
//                   setState(() {
//                     widget.appState.addGrowthPeriod();
//                   });
//                 },
//                 icon: const Icon(Icons.add),
//                 label: const Text('افزودن دوره جدید'),
//               ),
//               const SizedBox(height: 16),
//               ListView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: periods.length,
//                 itemBuilder: (context, index) {
//                   final period = periods[index];
//                   return Card(
//                     margin: const EdgeInsets.only(bottom: 16),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                                 decoration: BoxDecoration(
//                                   color: Theme.of(context).colorScheme.primary,
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                                 child: Text(
//                                   'دوره ${index + 1}',
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 14,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 14),
//                           FormBuilder.buildTextField(
//                             'تاریخ شروع',
//                             period.startDate,
//                             (value) => setState(() => period.startDate = value),
//                           ),
//                           FormBuilder.buildTextField(
//                             'تاریخ هدف',
//                             period.targetDate,
//                             (value) => setState(() => period.targetDate = value),
//                           ),
//                           const SizedBox(height: 12),
//                           Text(
//                             'شاخص‌ها',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 14,
//                               color: Theme.of(context).colorScheme.primary,
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           ...period.metrics.map((metric) {
//                             return Padding(
//                               padding: const EdgeInsets.only(bottom: 14),
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   border: Border(
//                                     right: BorderSide(
//                                       color: Theme.of(context).colorScheme.primary,
//                                       width: 3,
//                                     ),
//                                   ),
//                                 ),
//                                 child: Padding(
//                                   padding: const EdgeInsets.only(right: 12),
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         '${metric.title} (${metric.unit})',
//                                         style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
//                                       ),
//                                       const SizedBox(height: 8),
//                                       Row(
//                                         children: [
//                                           Expanded(
//                                             child: FormBuilder.buildTextField(
//                                               'مقدار فعلی',
//                                               metric.currentValue,
//                                               (value) => setState(() => metric.currentValue = value),
//                                               keyboardType: TextInputType.number,
//                                             ),
//                                           ),
//                                           const SizedBox(width: 10),
//                                           Expanded(
//                                             child: FormBuilder.buildTextField(
//                                               'هدف',
//                                               metric.target,
//                                               (value) => setState(() => metric.target = value),
//                                               keyboardType: TextInputType.number,
//                                             ),
//                                           ),
//                                           const SizedBox(width: 10),
//                                           Expanded(
//                                             child: FormBuilder.buildTextField(
//                                               'نتیجه',
//                                               metric.result,
//                                               (value) => setState(() => metric.result = value),
//                                               keyboardType: TextInputType.number,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             );
//                           }).toList(),
//                           const SizedBox(height: 12),
//                           ElevatedButton(
//                             onPressed: () {
//                               setState(() {});
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(content: Text('✓ دوره ذخیره شد')),
//                               );
//                             },
//                             child: const Text('ذخیره دوره'),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

//   @override
//   State<GrowthTablePage> createState() => _GrowthTablePageState();
// }

class _GrowthTablePageState extends State<GrowthTablePage> {
  @override
  Widget build(BuildContext context) {
    final periods = widget.appState.growthTable.periods;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('جدول رشد')),
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
                            }).toList(),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {});
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('دوره ذخیره شد'),
                                  ),
                                );
                              },
                              child: const Text('ذخیره'),
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
