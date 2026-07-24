class ProductCriterionModel {
  final String title;
  final String category;
  final String description;
  int weight;
  final List<String> scores;

  ProductCriterionModel({
    required this.title,
    required this.category,
    required this.description,
    required this.weight,
    required this.scores,
  });

  factory ProductCriterionModel.fromJson(Map<String, dynamic> json) {
    return ProductCriterionModel(
      title: json['criterion_title'] as String? ?? '',
      category: json['category'] as String? ?? '',
      description: json['description'] as String? ?? '',
      weight: json['weight'] as int? ?? 0,
      scores: [
        json['score_1'] as String? ?? '',
        json['score_2'] as String? ?? '',
        json['score_3'] as String? ?? '',
        json['score_4'] as String? ?? '',
      ],
    );
  }

  Map<String, dynamic> toJson(String priorityId) {
    return {
      'priority_id': priorityId,
      'criterion_title': title,
      'category': category,
      'description': description,
      'weight': weight,
      'score_1': scores[0],
      'score_2': scores[1],
      'score_3': scores[2],
      'score_4': scores[3],
    };
  }

  ProductCriterionModel copyWith({
    String? title,
    String? category,
    String? description,
    int? weight,
    List<String>? scores,
  }) {
    return ProductCriterionModel(
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      weight: weight ?? this.weight,
      scores: scores ?? List<String>.from(this.scores),
    );
  }
}

class ProductPriorityModel {
  final String? id;
  final List<String> productNames;
  final List<ProductCriterionModel> criteria;

  ProductPriorityModel({
    this.id,
    required this.productNames,
    required this.criteria,
  });

  ProductPriorityModel copyWith({
    String? id,
    List<String>? productNames,
    List<ProductCriterionModel>? criteria,
  }) {
    return ProductPriorityModel(
      id: id ?? this.id,
      productNames: productNames ?? List<String>.from(this.productNames),
      criteria: criteria ?? List<ProductCriterionModel>.from(this.criteria),
    );
  }

  factory ProductPriorityModel.empty() {
    const defaultCriteria = [
      (
        'کیفیت محصول',
        'ویژگی‌های ذاتی و رقابتی',
        'میزان استحکام، کارایی و دوام محصول در عمل',
      ),
      (
        'طراحی کارآمدتر',
        'ویژگی‌های ذاتی و رقابتی',
        'مصرف کمتر منابع مانند زمان، انرژی یا مواد برای رسیدن به همان نتیجه',
      ),
      (
        'متمایز بودن',
        'ویژگی‌های ذاتی و رقابتی',
        'داشتن ویژگی‌ای که در محصولات دیگر کمتر دیده می‌شود',
      ),
      (
        'نوآوری',
        'ویژگی‌های ذاتی و رقابتی',
        'تازگی در ایده، کاربرد، روش ساخت یا ارائه محصول',
      ),
      (
        'قدرت کپی پایین',
        'ویژگی‌های ذاتی و رقابتی',
        'سختی تقلید شدن محصول توسط رقبا',
      ),
      (
        'شناخت مشتری',
        'مشتری و بازار',
        'میزان آگاهی مشتری از نیاز یا مسئله‌ای که محصول قرار است حل کند',
      ),
      (
        'سهولت دسترسی به مشتری',
        'مشتری و بازار',
        'اینکه چقدر سریع و ساده می‌توان به مشتری هدف دسترسی پیدا کرد',
      ),
      (
        'طول چرخه فروش',
        'مشتری و بازار',
        'مدت زمان لازم از اولین ارتباط تا نهایی شدن خرید',
      ),
      (
        'وفاداری مشتری',
        'مشتری و بازار',
        'احتمال خرید مجدد و معرفی محصول به دیگران توسط مشتری',
      ),
      (
        'هزینه تولید کم',
        'تولید و عملیات',
        'امکان تولید با هزینه مناسب نسبت به ارزش فروش',
      ),
      (
        'زمان کوتاه تولید',
        'تولید و عملیات',
        'زمان کم بین سفارش تا تحویل محصول',
      ),
      (
        'پیچیدگی فرآیند تولید',
        'تولید و عملیات',
        'هرچه فرآیند ساده‌تر باشد، خطا و هزینه کمتر خواهد بود',
      ),
      (
        'تامین مواد اولیه ساده',
        'تولید و عملیات',
        'دسترسی ساده و پایدار به مواد اولیه مناسب',
      ),
      (
        'بازگشت سرمایه کوتاه',
        'مالی و درآمدزایی',
        'مدت زمان لازم برای بازگشت هزینه اولیه از محل سود',
      ),
      ('سود بالا', 'مالی و درآمدزایی', 'حاشیه سود مناسب نسبت به هزینه‌ها'),
      (
        'قابلیت پیش‌فروش',
        'مالی و درآمدزایی',
        'امکان دریافت وجه قبل از تحویل نهایی محصول',
      ),
      (
        'پتانسیل فروش جانبی',
        'مالی و درآمدزایی',
        'امکان فروش محصولات مکمل یا نسخه‌های گران‌تر به مشتری فعلی',
      ),
    ];

    return ProductPriorityModel(
      productNames: const ['', '', '', ''],
      criteria: defaultCriteria
          .map(
            (item) => ProductCriterionModel(
              title: item.$1,
              category: item.$2,
              description: item.$3,
              weight: 0,
              scores: ['', '', '', ''],
            ),
          )
          .toList(),
    );
  }

  factory ProductPriorityModel.fromJson(Map<String, dynamic> json) {
    final rawCriteria = json['product_priority_criteria'] as List? ?? [];
    final loadedCriteria = rawCriteria
        .map((e) => ProductCriterionModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final emptyModel = ProductPriorityModel.empty();

    final sortedCriteria = emptyModel.criteria.map((defaultItem) {
      final match = loadedCriteria.where((c) => c.title == defaultItem.title);
      if (match.isEmpty) {
        return defaultItem;
      }
      return match.first.copyWith(
        category: defaultItem.category,
        description: defaultItem.description,
      );
    }).toList();

    return ProductPriorityModel(
      id: json['id'] as String?,
      productNames: [
        json['prod_name_1'] as String? ?? '',
        json['prod_name_2'] as String? ?? '',
        json['prod_name_3'] as String? ?? '',
        json['prod_name_4'] as String? ?? '',
      ],
      criteria: sortedCriteria,
    );
  }

  Map<String, dynamic> toParentJson(String studentId, String classId) {
    return {
      'student_id': studentId,
      'class_id': classId,
      'prod_name_1': productNames[0],
      'prod_name_2': productNames[1],
      'prod_name_3': productNames[2],
      'prod_name_4': productNames[3],
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
