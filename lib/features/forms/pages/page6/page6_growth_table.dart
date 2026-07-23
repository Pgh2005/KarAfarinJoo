import 'package:flutter/material.dart';
import 'package:karafarini/core/theme/app_theme.dart';
import 'package:karafarini/core/widgets/app_bar_builder.dart';
import 'package:karafarini/features/forms/state/app_state.dart';
import 'package:karafarini/features/forms/widgets/info_hint_box.dart';
import 'package:karafarini/features/forms/widgets/save_button.dart';

class GrowthTablePage extends StatefulWidget {
  const GrowthTablePage({super.key});

  @override
  State<GrowthTablePage> createState() => _GrowthTablePageState();
}

class _GrowthTablePageState extends State<GrowthTablePage> {
  final bool isLoading = false;
  final bool isEnable = true;

  @override
  Widget build(BuildContext context) {
    final periods = AppState().growthTable.periods;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: const AppBarBuilder(title: 'جدول رشد کارآفرینی'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── راهنما ──
              const InfoHintBox(
                text:
                    'برای هر دوره، تاریخ شروع و هدف را مشخص کنید و برای هر شاخص مقدار هدف و نتیجه واقعی را وارد نمایید.',
              ),

              const SizedBox(height: 16),

              // ── دکمه افزودن دوره ──
              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      AppState().addGrowthPeriod();
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(color: AppTheme.primary, width: 1.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  label: const Text(
                    'افزودن دوره جدید',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── کارت هر دوره ──
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: periods.length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final period = periods[index];
                  return _PeriodCard(
                    period: period,
                    index: index,
                    onChanged: () => setState(() {}),
                  );
                },
              ),

              const SizedBox(height: 24),

              SaveButton(
                onSave: () {},
                isEnabled: isEnable,
                isLoading: isLoading,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Period Card ──────────────────────────────────────────────────────────────
class _PeriodCard extends StatelessWidget {
  final GrowthPeriod period;
  final int index;
  final VoidCallback onChanged;

  const _PeriodCard({
    required this.period,
    required this.index,
    required this.onChanged,
  });

  // گروه‌بندی شاخص‌ها بر اساس دسته‌بندی، با حفظ ترتیب اصلی
  Map<String, List<GrowthMetricRow>> _groupedMetrics() {
    final Map<String, List<GrowthMetricRow>> grouped = {};
    for (final m in period.metrics) {
      grouped.putIfAbsent(m.category, () => []).add(m);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedMetrics();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // هدر دوره
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'دوره ${index + 1}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryDark,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: AppTheme.border),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // تاریخ شروع و هدف
                Row(
                  children: [
                    Expanded(
                      child: _DateField(
                        label: 'تاریخ شروع',
                        value: period.startDate,
                        hintText: '1405/04/01',
                        onChanged: (v) {
                          period.startDate = v;
                          onChanged();
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DateField(
                        label: 'تاریخ هدف',
                        value: period.targetDate,
                        hintText: '1405/10/01',
                        onChanged: (v) {
                          period.targetDate = v;
                          onChanged();
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // دسته‌بندی‌ها و شاخص‌ها
                ...grouped.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _CategorySection(
                      categoryTitle: entry.key,
                      metrics: entry.value,
                      onChanged: onChanged,
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Date Field ───────────────────────────────────────────────────────────────
class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final String? hintText;
  final ValueChanged<String> onChanged;

  const _DateField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      onChanged: onChanged,
      keyboardType: TextInputType.number,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: const Icon(
          Icons.calendar_today_outlined,
          color: AppTheme.primary,
          size: 18,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }
}

// ─── Category Section ─────────────────────────────────────────────────────────
class _CategorySection extends StatelessWidget {
  final String categoryTitle;
  final List<GrowthMetricRow> metrics;
  final VoidCallback onChanged;

  const _CategorySection({
    required this.categoryTitle,
    required this.metrics,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.divider,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // هدر دسته
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  categoryTitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          // شاخص‌های این دسته
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              children: metrics
                  .map(
                    (m) => Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _MetricRow(metric: m, onChanged: onChanged),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Metric Row ───────────────────────────────────────────────────────────────
class _MetricRow extends StatelessWidget {
  final GrowthMetricRow metric;
  final VoidCallback onChanged;

  const _MetricRow({required this.metric, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // عنوان شاخص + واحد
          Row(
            children: [
              Expanded(
                child: Text(
                  metric.title,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  metric.unit,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // مقدار فعلی، هدف، نتیجه
          Row(
            children: [
              Expanded(
                child: _SmallField(
                  label: 'مقدار فعلی',
                  value: metric.currentValue,
                  onChanged: (v) {
                    metric.currentValue = v;
                    onChanged();
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _SmallField(
                  label: 'هدف',
                  value: metric.target,
                  onChanged: (v) {
                    metric.target = v;
                    onChanged();
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _SmallField(
                  label: 'نتیجه',
                  value: metric.result,
                  onChanged: (v) {
                    metric.result = v;
                    onChanged();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Small Field ──────────────────────────────────────────────────────────────
class _SmallField extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  const _SmallField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      onChanged: onChanged,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 9.5),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.border, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.8),
        ),
        filled: true,
        fillColor: AppTheme.divider,
      ),
    );
  }
}
