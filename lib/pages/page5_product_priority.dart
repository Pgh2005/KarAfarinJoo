import 'package:flutter/material.dart';
import 'package:karafarini/core/theme/app_theme.dart';
import 'package:karafarini/widgets/app_bar_builder.dart';
import 'package:karafarini/widgets/info_hint_box.dart';
import 'package:karafarini/widgets/save_button.dart';
import 'package:karafarini/widgets/score_card.dart';
import 'package:karafarini/widgets/section_card.dart';
import '../core/state/app_state.dart';

class ProductPriorityPage extends StatefulWidget {
  final AppState appState;
  const ProductPriorityPage({super.key, required this.appState});

  @override
  State<ProductPriorityPage> createState() => _ProductPriorityPageState();
}

class _ProductPriorityPageState extends State<ProductPriorityPage> {
  final bool isLoading = false;
  final bool isEnable = true;

  // نام ۴ محصول که دانشجو وارد می‌کند
  final List<TextEditingController> _productNameControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  @override
  void dispose() {
    for (final c in _productNameControllers) {
      c.dispose();
    }
    super.dispose();
  }

  /// جمع امتیاز هر محصول
  List<double> _calcTotals(ProductPriorityState model) {
    return List.generate(4, (productIndex) {
      return model.criteria.fold<double>(0.0, (
        double sum,
        ProductCriterion item,
      ) {
        final raw = item.scores[productIndex].replaceAll(',', '');
        final score = double.tryParse(raw) ?? 0.0;
        final weight = item.weight.toDouble();
        return sum + score.clamp(0.0, weight);
      });
    });
  }

  /// حداکثر امتیاز ممکن (جمع وزن‌ها)
  double _maxScore(ProductPriorityState model) {
    return model.criteria.fold<double>(0.0, (
      double sum,
      ProductCriterion item,
    ) {
      return sum + item.weight.toDouble();
    });
  }

  /// بررسی خطای یک فیلد خاص برای یک محصول
  String? _fieldError(ProductCriterion item, int productIndex) {
    final raw = item.scores[productIndex].replaceAll(',', '');
    final score = double.tryParse(raw);
    if (score == null && raw.isNotEmpty) return 'عدد وارد کنید';
    final weight = item.weight.toDouble();
    if (score != null && score > weight) return 'بیشتر از وزن ($weight)';
    // بررسی یکسان نبودن بین محصولات همین معیار
    final others = List.generate(4, (i) => i)
        .where((i) => i != productIndex)
        .map((i) => item.scores[i].replaceAll(',', ''))
        .where((v) => v.isNotEmpty)
        .map((v) => double.tryParse(v))
        .whereType<double>();
    if (score != null && others.contains(score)) return 'تکراری';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final ProductPriorityState model = widget.appState.productPriority;
    final totals = _calcTotals(model);
    final maxScore = _maxScore(model);

    // پیدا کردن برنده (بیشترین امتیاز)
    int winnerIndex = 0;
    for (int i = 1; i < 4; i++) {
      if (totals[i] > totals[winnerIndex]) winnerIndex = i;
    }
    final bool anyScore = totals.any((t) => t > 0);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: const AppBarBuilder(title: 'اولویت محصولات'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── نام‌گذاری محصولات ──
              SectionCard(
                icon: Icons.inventory_2_outlined,
                title: 'نام محصولات',
                children: [
                  const Text(
                    'ابتدا نام ۴ محصول خود را وارد کنید',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...List.generate(
                    4,
                    (i) => Padding(
                      padding: EdgeInsets.only(bottom: i < 3 ? 10 : 0),
                      child: TextField(
                        controller: _productNameControllers[i],
                        decoration: InputDecoration(
                          labelText: 'محصول ${i + 1}',
                          prefixIcon: Icon(
                            Icons.shopping_bag_outlined,
                            color: AppTheme.primary,
                            size: 20,
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── راهنما ──
              const InfoHintBox(
                text:
                    'امتیاز هر محصول نباید از وزن آن معیار بیشتر باشد و نمی‌توانند با هم یکسان باشند.',
              ),

              const SizedBox(height: 16),

              // ── ردیف‌های معیار ──
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: model.criteria.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = model.criteria[index];
                  return _ProductCriteriaRow(
                    item: item,
                    index: index,
                    productNames: _productNameControllers
                        .map((c) => c.text)
                        .toList(),
                    getError: (productIndex) => _fieldError(item, productIndex),
                    onChanged: () => setState(() {}),
                  );
                },
              ),

              const SizedBox(height: 20),

              // ── جمع امتیازات ──
              SectionCard(
                icon: Icons.bar_chart_rounded,
                title: 'نتیجه امتیازات',
                children: [
                  ...List.generate(4, (i) {
                    final isWinner = anyScore && i == winnerIndex;
                    final percent = maxScore > 0
                        ? totals[i] / maxScore * 100
                        : 0.0;
                    final productName =
                        _productNameControllers[i].text.isNotEmpty
                        ? _productNameControllers[i].text
                        : 'محصول ${i + 1}';

                    return Padding(
                      padding: EdgeInsets.only(bottom: i < 3 ? 12 : 0),
                      child: ScoreCard(
                        name: productName,
                        score: totals[i],
                        percent: percent.toDouble(),
                        maxScore: maxScore,
                        isWinner: isWinner,
                        winnerLabel: 'این محصول بالاترین امتیاز را دارد',
                      ),
                    );
                  }),
                ],
              ),

              const SizedBox(height: 24),

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

// ─── Product Criteria Row ──────────────────────────────────────────────────────
class _ProductCriteriaRow extends StatefulWidget {
  final ProductCriterion item;
  final int index;
  final List<String> productNames;
  final String? Function(int productIndex) getError;
  final VoidCallback onChanged;

  const _ProductCriteriaRow({
    required this.item,
    required this.index,
    required this.productNames,
    required this.getError,
    required this.onChanged,
  });

  @override
  State<_ProductCriteriaRow> createState() => _ProductCriteriaRowState();
}

class _ProductCriteriaRowState extends State<_ProductCriteriaRow> {
  late final TextEditingController _weightCtrl;
  late final List<TextEditingController> _scoreCtrl;

  @override
  void initState() {
    super.initState();
    _weightCtrl = TextEditingController(
      text: widget.item.weight == 0 ? '' : widget.item.weight.toString(),
    );
    _scoreCtrl = List.generate(
      4,
      (i) => TextEditingController(text: widget.item.scores[i]),
    );
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    for (final c in _scoreCtrl) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final bool isEven = widget.index % 2 == 0;
    return Container(
      decoration: BoxDecoration(
        color: isEven ? AppTheme.cardBg : AppTheme.divider,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // عنوان + دسته + وزن در یک ردیف
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (item.category.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        item.category,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // وزن — badge قابل ویرایش کنار عنوان
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6.0,
                    vertical: 5,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'وزن :',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        width: 35,
                        child: TextFormField(
                          controller: _weightCtrl,
                          onChanged: (v) {
                            final parsed = int.tryParse(v);
                            item.weight = parsed ?? 0;
                            widget.onChanged();
                          },
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryDark,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            filled: false,
                            hintText: '0',
                            hintStyle: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textHint,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // ردیف دوم: ۴ فیلد امتیاز در دو ردیف ۲تایی
          Row(
            children: [_buildScoreField(0, false), _buildScoreField(1, true)],
          ),
          const SizedBox(height: 8),
          Row(
            children: [_buildScoreField(2, false), _buildScoreField(3, true)],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreField(int productIndex, bool hasRightPadding) {
    final error = widget.getError(productIndex);
    final hasError = error != null;
    final productName = widget.productNames[productIndex].isNotEmpty
        ? widget.productNames[productIndex]
        : 'محصول ${productIndex + 1}';
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(right: hasRightPadding ? 6 : 0),
        child: TextFormField(
          controller: _scoreCtrl[productIndex],
          onChanged: (v) {
            widget.item.scores[productIndex] = v;
            widget.onChanged();
          },
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: hasError ? Colors.red[700] : AppTheme.textPrimary,
          ),
          decoration: InputDecoration(
            labelText: productName,
            labelStyle: const TextStyle(fontSize: 10),
            errorText: error,
            errorStyle: const TextStyle(fontSize: 9),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 8,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: hasError
                    ? Colors.red.withValues(alpha: 0.5)
                    : AppTheme.border,
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.8),
            ),
            filled: true,
            fillColor: hasError
                ? Colors.red.withValues(alpha: 0.06)
                : AppTheme.cardBg,
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:karafarini/widgets/app_bar_builder.dart';
// import 'package:karafarini/widgets/save_button.dart';
// import '../app_state.dart';

// class ProductPriorityPage extends StatefulWidget {
//   final AppState appState;
//   const ProductPriorityPage({super.key, required this.appState});

//   @override
//   State<ProductPriorityPage> createState() => _ProductPriorityPageState();
// }

// class _ProductPriorityPageState extends State<ProductPriorityPage> {
//   final bool isLoading = false;
//   final bool isEnable = true;

//   @override
//   Widget build(BuildContext context) {
//     final model = widget.appState.productPriority;
//     final totals = List.generate(
//       4,
//       (index) => model.criteria.fold<double>(0, (sum, item) {
//         final value =
//             double.tryParse(item.scores[index].replaceAll(',', '')) ?? 0;
//         return sum + value;
//       }),
//     );
//     final maxScore = 17 * 10;
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         appBar: const AppBarBuilder(title: 'اولویت محصولات'),
//         body: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               ListView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: model.criteria.length,
//                 itemBuilder: (context, index) {
//                   final item = model.criteria[index];
//                   return Padding(
//                     padding: const EdgeInsets.only(bottom: 14),
//                     child: Card(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(12),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               item.title,
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 6),
//                             Text(
//                               item.category,
//                               style: const TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.black54,
//                               ),
//                             ),
//                             const SizedBox(height: 10),
//                             Row(
//                               children: List.generate(4, (productIndex) {
//                                 return Expanded(
//                                   child: Padding(
//                                     padding: EdgeInsets.only(
//                                       left: productIndex < 3 ? 8 : 0,
//                                     ),
//                                     child: TextFormField(
//                                       initialValue: item.scores[productIndex],
//                                       onChanged: (value) => setState(
//                                         () => item.scores[productIndex] = value,
//                                       ),
//                                       keyboardType: TextInputType.number,
//                                       decoration: InputDecoration(
//                                         labelText: 'محصول ${productIndex + 1}',
//                                         border: const OutlineInputBorder(),
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               }),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//               const SizedBox(height: 16),
//               Card(
//                 color: Colors.grey[100],
//                 child: Padding(
//                   padding: const EdgeInsets.all(14),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'جمع امتیازات',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       ...List.generate(4, (index) {
//                         final percent = maxScore > 0
//                             ? totals[index] / maxScore * 100
//                             : 0;
//                         return Padding(
//                           padding: const EdgeInsets.only(bottom: 10),
//                           child: Text(
//                             'محصول ${index + 1}: ${totals[index].toStringAsFixed(1)}  |  درصد: ${percent.toStringAsFixed(1)}%',
//                           ),
//                         );
//                       }),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               SaveButton(
//                 onSave: () {},
//                 isLoading: isLoading,
//                 isEnabled: isEnable,
//               ),
//               const SizedBox(height: 32),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
