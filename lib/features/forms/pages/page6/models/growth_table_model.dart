class GrowthMetricRow {
  final String title;
  final String unit;
  final String category;
  final String description;
  String currentValue;
  String target;
  String result;

  GrowthMetricRow({
    required this.title,
    required this.unit,
    required this.category,
    required this.description,
    this.currentValue = '',
    this.target = '',
    this.result = '',
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'unit': unit,
    'category': category,
    'description': description,
    'current_value': currentValue,
    'target': target,
    'result': result,
  };

  factory GrowthMetricRow.fromJson(Map<String, dynamic> json) =>
      GrowthMetricRow(
        title: json['title'] ?? '',
        unit: json['unit'] ?? '',
        category: json['category'] ?? '',
        description: json['description'] ?? '',
        currentValue: json['current_value'] ?? '',
        target: json['target'] ?? '',
        result: json['result'] ?? '',
      );
}

class GrowthPeriod {
  String startDate;
  String targetDate;
  List<GrowthMetricRow> metrics;

  GrowthPeriod({
    this.startDate = '',
    this.targetDate = '',
    required this.metrics,
  });

  Map<String, dynamic> toJson() => {
    'start_date': startDate,
    'target_date': targetDate,
    'metrics': metrics.map((m) => m.toJson()).toList(),
  };

  factory GrowthPeriod.fromJson(Map<String, dynamic> json) {
    return GrowthPeriod(
      startDate: json['start_date'] ?? '',
      targetDate: json['target_date'] ?? '',
      metrics: (json['metrics'] as List? ?? [])
          .map((m) => GrowthMetricRow.fromJson(m))
          .toList(),
    );
  }

  factory GrowthPeriod.newEmpty() => GrowthPeriod(
    metrics: [
      GrowthMetricRow(
        title: 'موقعیت مکانی',
        unit: 'امتیاز',
        category: 'دارایی‌ها',
        description: 'دسترسی به بازار و حمل‌ونقل',
      ),
      GrowthMetricRow(
        title: 'تامین کننده اعتباری',
        unit: 'تومان',
        category: 'دارایی‌ها',
        description: 'خرید چکی یا مدت‌دار',
      ),
      GrowthMetricRow(
        title: 'موجودی انبار',
        unit: 'تومان',
        category: 'دارایی‌ها',
        description: 'ارزش کالای موجود',
      ),
      GrowthMetricRow(
        title: 'ابزارآلات',
        unit: 'تومان',
        category: 'دارایی‌ها',
        description: 'ارزش تجهیزات',
      ),
      GrowthMetricRow(
        title: 'سرمایه در گردش',
        unit: 'تومان',
        category: 'دارایی‌ها',
        description: 'نقدینگی جاری',
      ),
      GrowthMetricRow(
        title: 'کارکنان',
        unit: 'تعداد',
        category: 'نیروی انسانی',
        description: 'تعداد کل تیم',
      ),
      GrowthMetricRow(
        title: 'رضایت کارکنان',
        unit: 'امتیاز',
        category: 'نیروی انسانی',
        description: 'نرخ خوشحالی تیم',
      ),
      GrowthMetricRow(
        title: 'عضو کانال',
        unit: 'تعداد',
        category: 'بازاریابی',
        description: 'چند دنبال‌کننده در شبکه‌های اجتماعی داریم؟',
      ),
      GrowthMetricRow(
        title: 'عضو صفحه',
        unit: 'تعداد',
        category: 'بازاریابی',
        description: 'چند دنبال‌کننده در شبکه‌های اجتماعی داریم؟',
      ),
      GrowthMetricRow(
        title: 'ترافیک سایت',
        unit: 'تعداد',
        category: 'بازاریابی',
        description: 'بازدید ماهانه',
      ),
      GrowthMetricRow(
        title: 'شناسایی رقبا',
        unit: 'امتیاز',
        category: 'بازاریابی',
        description: 'تحلیل استراتژی رقبا',
      ),
      GrowthMetricRow(
        title: 'محلی',
        unit: 'تعداد',
        category: 'جغرافیایی',
        description: 'چند منطقه یا محله را پوشش می‌دهیم؟',
      ),
      GrowthMetricRow(
        title: 'شهری',
        unit: 'تعداد',
        category: 'جغرافیایی',
        description: 'چند شهر حضور داریم؟',
      ),
      GrowthMetricRow(
        title: 'ملی',
        unit: 'تعداد',
        category: 'جغرافیایی',
        description: 'چند استان را پوشش می‌دهیم؟',
      ),
      GrowthMetricRow(
        title: 'بین المللی',
        unit: 'تعداد',
        category: 'جغرافیایی',
        description: 'چند کشور حضور داریم؟',
      ),
      GrowthMetricRow(
        title: 'طول عمر مشتری',
        unit: 'ماه',
        category: 'مشتری',
        description: 'ماندگاری مشتری در سیستم',
      ),
      GrowthMetricRow(
        title: 'شکایات مشتری',
        unit: 'درصد',
        category: 'مشتری',
        description: 'تعداد نارضایتی ثبت شده',
      ),
      GrowthMetricRow(
        title: 'سود خالص',
        unit: 'تومان',
        category: 'مالی',
        description: 'درآمد پس از کسر مخارج',
      ),
      GrowthMetricRow(
        title: 'دوره نقدشوندگی',
        unit: 'روز',
        category: 'مالی',
        description: 'زمان تبدیل کالا به پول',
      ),
    ],
  );
}
