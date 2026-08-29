class BusinessCriterionModel {
  final String title;
  final String category;
  final String description;
  int weight;
  final List<String> scores;

  BusinessCriterionModel({
    required this.title,
    required this.category,
    required this.description,
    required this.weight,
    required this.scores,
  });

  factory BusinessCriterionModel.fromJson(Map<String, dynamic> json) {
    return BusinessCriterionModel(
      title: json['criterion_title'] as String? ?? '',
      category: json['category'] as String? ?? '',
      description: json['description'] as String? ?? '',
      weight: (json['weight'] as num?)?.toInt() ?? 0,
      scores: [
        _toStringScore(json['score_1']),
        _toStringScore(json['score_2']),
        _toStringScore(json['score_3']),
      ],
    );
  }

  /// Safely convert score values that may come as int, double, or String from Supabase.
  static String _toStringScore(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is num) {
      if (value == value.roundToDouble()) return value.toInt().toString();
      return value.toString();
    }
    return value.toString();
  }

  Map<String, dynamic> toJson(String selectionId) => {
    'selection_id': selectionId,
    'criterion_title': title,
    'category': category,
    'weight': weight,
    'score_1': scores[0],
    'score_2': scores[1],
    'score_3': scores[2],
  };

  BusinessCriterionModel copyWith({
    String? title,
    String? category,
    String? description,
    int? weight,
    List<String>? scores,
  }) {
    return BusinessCriterionModel(
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      weight: weight ?? this.weight,
      scores: scores ?? List<String>.from(this.scores),
    );
  }
}

class BusinessSelectionModel {
  final String? id;
  final List<String> bizNames;
  final List<BusinessCriterionModel> criteria;

  BusinessSelectionModel({
    this.id,
    required this.bizNames,
    required this.criteria,
  });

  factory BusinessSelectionModel.empty() {
    final defaultCriteria = [
      (
        'علاقه و انگیزه پایدار',
        'ویژگی‌های فردی',
        'یعنی کاری که خیلی دوستش داری، حتی اگر اولش پول زیادی نداشته باشه.',
      ),
      (
        'انعطاف‌پذیری در شرایط بحرانی',
        'ویژگی‌های فردی',
        'یعنی کارت جوری باشه که اگه مریض شدی یا خانواده نیاز به توجهت داشت، بتونی مدیریتش کنی.',
      ),
      (
        'کنترل حرص و طمع',
        'ویژگی‌های فردی',
        'یعنی قانع باشی و دنبال سودهای بادآورده یا زیاد نباشی.',
      ),
      (
        'سلامت جامع (جسم و روان)',
        'ویژگی‌های فردی',
        'یعنی کاری که انجام میدی، هم به سلامتی جسمت خوب باشه و هم به روحت.',
      ),
      (
        'تعادل بهینه زندگی و کار',
        'ویژگی‌های فردی',
        'یعنی بتونی بین کار و زندگی شخصی‌ات تعادل برقرار کنی.',
      ),
      (
        'استعداد و خودکفایی فنی',
        'شایستگی‌های فنی',
        'یعنی در کار فنی خیلی ماهر باشی و بتونی مستقل کار کنی.',
      ),
      (
        'اعتبار و وجه حرفه‌ای',
        'شایستگی‌های فنی',
        'یعنی کاری باشه که به خاطرش احترام ببینی.',
      ),
      (
        'ظرفیت توسعه علمی و آموزشی',
        'شایستگی‌های فنی',
        'یعنی بتونی در کنار کارت، علم و دانش خودت رو هم بالا ببری و مدرک بگیری.',
      ),
      (
        'تعهد به پیشرفت مستمر',
        'شایستگی‌های فنی',
        'یعنی همیشه دوست داشته باشی برای هدفت تلاش کنی.',
      ),
      (
        'دسترسی به دانش خبرگان',
        'شایستگی‌های فنی',
        'یعنی بتونی از آدم‌های باتجربه کمک بگیری و راهنمایی بخوای.',
      ),
      (
        'اصول انصاف در تعامل با مشتری',
        'اخلاق کسب و کار',
        'یعنی با مشتری‌هات منصفانه رفتار کنی.',
      ),
      (
        'صداقت در ارتباطات',
        'اخلاق کسب و کار',
        'یعنی با کسانی که باهاشون در ارتباطی، صادق باشی.',
      ),
      (
        'مسئولیت‌پذیری زیست محیطی',
        'اخلاق کسب و کار',
        'یعنی کاری باشه که به طبیعت و محیط زیست آسیب نزنه و حتی بهش کمک کنه.',
      ),
      (
        'حمایت اجتماعی و دولتی',
        'اخلاق کسب و کار',
        'یعنی دولت و جامعه از کارت حمایت کنن.',
      ),
      (
        'پاسخگویی به نیازهای بومی',
        'اخلاق کسب و کار',
        'یعنی کاری باشه که مردم ایران واقعا بهش نیاز دارن.',
      ),
      (
        'ثبات مالی در شرایط عدم قطعیت درآمد',
        'عملکرد مالی',
        'یعنی بتونی با درآمدی که هر ماه ممکنه کم و زیاد بشه، کارت رو پایدار نگه داری.',
      ),
      (
        'پتانسیل درآمدزایی بالا',
        'عملکرد مالی',
        'یعنی پول خوبی از کارت به دست بیاری.',
      ),
      (
        'ظرفیت کارآفرینی',
        'عملکرد مالی',
        'یعنی بتونی برای آدم‌های دیگه هم شغل ایجاد کنی.',
      ),
      (
        'حداکثر بازدهی اقتصادی',
        'عملکرد مالی',
        'یعنی با کمترین هزینه، بیشترین درآمد رو داشته باشی.',
      ),
      (
        'برتری رقابتی',
        'عملکرد مالی',
        'یعنی کارت اونقدر خوب باشه که بتونه با بقیه رقابت کنه.',
      ),
      (
        'درآمدزایی ارزی در فروش',
        'عملکرد مالی',
        'یعنی بتونی محصولاتت رو بفروشی و ارز خارجی به دست بیاری.',
      ),
      (
        'طول عمر پایدار کسب و کار',
        'چشم‌انداز',
        'یعنی کسب و کارت اونقدر قوی باشه که برای مدت طولانی باقی بمونه.',
      ),
      (
        'کیفیت محصول',
        'چشم‌انداز',
        'یعنی محصولاتی که تولید می‌کنی یا ارائه میدی، کیفیت خوبی داشته باشن.',
      ),
      (
        'جامعیت زنجیره ارزش',
        'چشم‌انداز',
        'یعنی تمام مراحل تولید و رسوندن محصول به دست مشتری، به خوبی طی بشه.',
      ),
      (
        'استقلال ارزی در تولید',
        'چشم‌انداز',
        'یعنی بتونی محصولاتی تولید کنی که نیاز به ارز خارجی نداشته باشن.',
      ),
    ];

    return BusinessSelectionModel(
      bizNames: ['', '', ''],
      criteria: defaultCriteria
          .map(
            (item) => BusinessCriterionModel(
              title: item.$1,
              category: item.$2,
              description: item.$3,
              weight: 0,
              scores: ['', '', ''],
            ),
          )
          .toList(),
    );
  }

  factory BusinessSelectionModel.fromJson(Map<String, dynamic> json) {
    final rawCriteria = json['business_selection_criteria'] as List? ?? [];
    final loadedCriteria = rawCriteria
        .map((e) => BusinessCriterionModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final emptyModel = BusinessSelectionModel.empty();
    final sortedCriteria = emptyModel.criteria.map((defaultItem) {
      final match = loadedCriteria.firstWhere(
        (c) => c.title == defaultItem.title,
        orElse: () => defaultItem,
      );

      return match.copyWith(
        description: defaultItem.description,
        category: defaultItem.category,
        title: defaultItem.title,
      );
    }).toList();

    return BusinessSelectionModel(
      id: json['id'] as String?,
      bizNames: [
        json['biz_name_1'] as String? ?? '',
        json['biz_name_2'] as String? ?? '',
        json['biz_name_3'] as String? ?? '',
      ],
      criteria: sortedCriteria,
    );
  }

  Map<String, dynamic> toParentJson(String studentId, String classId) => {
    'student_id': studentId,
    'class_id': classId,
    'biz_name_1': bizNames[0],
    'biz_name_2': bizNames[1],
    'biz_name_3': bizNames[2],
    'updated_at': DateTime.now().toIso8601String(),
  };

  BusinessSelectionModel copyWith({
    String? id,
    List<String>? bizNames,
    List<BusinessCriterionModel>? criteria,
  }) {
    return BusinessSelectionModel(
      id: id ?? this.id,
      bizNames: bizNames ?? this.bizNames,
      criteria: criteria ?? this.criteria,
    );
  }
}
