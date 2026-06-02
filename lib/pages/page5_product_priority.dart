import 'package:flutter/material.dart';
import '../app_state.dart';
// import '../widgets/form_field_builder.dart';

class ProductPriorityPage extends StatefulWidget {
  final AppState appState;
  const ProductPriorityPage({super.key, required this.appState});

  @override
  State<ProductPriorityPage> createState() => _ProductPriorityPageState();
}

// class _ProductPriorityPageState extends State<ProductPriorityPage> {
//   @override
//   Widget build(BuildContext context) {
//     final model = widget.appState.productPriority;
//     final totals = List.generate(
//       4,
//       (index) => model.criteria.fold<double>(0, (sum, item) {
//         final value = double.tryParse(item.scores[index].replaceAll(',', '')) ?? 0;
//         return sum + value;
//       }),
//     );
//     final maxScore = 17 * 10;
    
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         appBar: AppBar(title: const Text('اولویت محصولات')),
//         body: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             children: [
//               ListView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: model.criteria.length,
//                 itemBuilder: (context, index) {
//                   final item = model.criteria[index];
//                   return Card(
//                     margin: const EdgeInsets.only(bottom: 12),
//                     child: Padding(
//                       padding: const EdgeInsets.all(12),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       item.title,
//                                       style: const TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 14,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       item.category,
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color: Theme.of(context).colorScheme.secondary,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 12),
//                           Row(
//                             children: List.generate(4, (productIndex) {
//                               return Expanded(
//                                 child: Padding(
//                                   padding: EdgeInsets.only(left: productIndex < 3 ? 8 : 0),
//                                   child: TextFormField(
//                                     initialValue: item.scores[productIndex],
//                                     onChanged: (value) => setState(() => item.scores[productIndex] = value),
//                                     keyboardType: TextInputType.number,
//                                     decoration: InputDecoration(
//                                       labelText: 'محصول ${productIndex + 1}',
//                                       border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(8),
//                                       ),
//                                       contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             }),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//               const SizedBox(height: 16),
//               Card(
//                 child: Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                     gradient: LinearGradient(
//                       colors: [
//                         Theme.of(context).colorScheme.primary.withOpacity(0.1),
//                         Theme.of(context).colorScheme.primary.withOpacity(0.05),
//                       ],
//                     ),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(14),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'جمع امتیازات',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                             color: Theme.of(context).colorScheme.primary,
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         ...List.generate(4, (index) {
//                           final percent = maxScore > 0 ? totals[index] / maxScore * 100 : 0;
//                           return Padding(
//                             padding: const EdgeInsets.only(bottom: 8),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text('محصول ${index + 1}'),
//                                 Row(
//                                   children: [
//                                     Text(totals[index].toStringAsFixed(1)),
//                                     const SizedBox(width: 8),
//                                     Container(
//                                       width: 60,
//                                       height: 6,
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(3),
//                                         color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
//                                       ),
//                                       child: FractionallySizedBox(
//                                         widthFactor: percent / 100,
//                                         child: Container(
//                                           decoration: BoxDecoration(
//                                             borderRadius: BorderRadius.circular(3),
//                                             color: Theme.of(context).colorScheme.primary,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     const SizedBox(width: 8),
//                                     Text('${percent.toStringAsFixed(1)}%'),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           );
//                         }),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               FormBuilder.buildSaveButton(
//                 () {
//                   setState(() {});
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('✓ مقادیر ذخیره شد')),
//                   );
//                 },
//                 context,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class _ProductPriorityPageState extends State<ProductPriorityPage> {
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
        appBar: AppBar(title: const Text('اولویت محصولات')),
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
