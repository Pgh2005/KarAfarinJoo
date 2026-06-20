class AppState {
  final personalInfo = PersonalBusinessInfoState();
  final talent = TalentState();
  final values = ValuesState();
  final businessSelection = BusinessSelectionState();
  final productPriority = ProductPriorityState();
  final growthTable = GrowthTableState();

  void addGrowthPeriod() {
    growthTable.periods.add(GrowthPeriod.newEmpty());
  }
}

class PersonalBusinessInfoState {
  String lastName = '';
  String firstName = '';
  String contact = '';
  String neighborhood = '';
  String major = '';
  String degree = 'کارشناسی';
  String satisfiedMajor = 'بله';
  String majorReason = '';
  String ifReturn = '';
  String businessTitle = '';
  String businessSatisfied = 'تا حدی';
  String valueOrientation = 'علم';
  String rank = '';
  String score = '';
}

class TalentRow {
  String rank = '';
  String title = '';
  String description = '';
}

class TalentState {
  String highestCategory = '';
  String lowestTalent = '';
  String twoDimType = '';
  String fourDimType = '';
  String bestTeam = '';
  final List<TalentRow> rows = List.generate(5, (_) => TalentRow());
}

class ValuesState {
  final List<String> list = List.generate(10, (_) => '');
}

class BusinessCriterion {
  final String title;
  final String category;
  int weight; // final حذف شد — دانشجو می‌تونه وزن رو ویرایش کنه
  final List<String> scores = List.generate(3, (_) => '');

  BusinessCriterion({
    required this.title,
    required this.category,
    required this.weight,
  });
}

class BusinessSelectionState {
  final List<BusinessCriterion> criteria = [
    BusinessCriterion(
      title: 'علاقه و انگیزه پایدار',
      category: 'ویژگی‌های فردی',
      weight: 0,
    ),
    BusinessCriterion(
      title: 'انعطاف‌ پذیری در شرایط بحرانی',
      category: 'ویژگی‌های فردی',
      weight: 0,
    ),
    BusinessCriterion(
      title: 'کنترل حرص و طمع',
      category: 'ویژگی‌های فردی',
      weight: 0,
    ),
    BusinessCriterion(
      title: 'سلامت جامع (جسم و روان)',
      category: 'ویژگی‌های فردی',
      weight: 0,
    ),
    BusinessCriterion(
      title: 'تعادل بهینه زندگی و کار',
      category: 'ویژگی‌های فردی',
      weight: 0,
    ),
    BusinessCriterion(
      title: 'استعداد و خودکفایی فنی',
      category: 'شایستگی‌های فنی',
      weight: 0,
    ),
    BusinessCriterion(
      title: 'اعتبار و وجه حرفه‌ای',
      category: 'شایستگی‌های فنی',
      weight: 0,
    ),
    BusinessCriterion(
      title: 'ظرفیت توسعه علمی و آموزشی',
      category: 'شایستگی‌های فنی',
      weight: 0,
    ),
    BusinessCriterion(
      title: 'تعهد به پیشرفت مستمر',
      category: 'شایستگی‌های فنی',
      weight: 0,
    ),
    BusinessCriterion(
      title: 'دسترسی به دانش خبرگان',
      category: 'شایستگی‌های فنی',
      weight: 0,
    ),
    BusinessCriterion(
      title: 'اصول انصاف در تعامل با مشتری',
      category: 'اخلاق کسب و کار',
      weight: 0,
    ),
    BusinessCriterion(
      title: 'صداقت در ارتباطات',
      category: 'اخلاق کسب و کار',
      weight: 0,
    ),
    BusinessCriterion(
      title: 'مسئولیت‌پذیری زیست محیطی',
      category: 'اخلاق کسب و کار',
      weight: 0,
    ),
    BusinessCriterion(
      title: 'حمایت اجتماعی و دولتی',
      category: 'اخلاق کسب و کار',
      weight: 0,
    ),
    BusinessCriterion(
      title: 'پاسخگویی به نیازهای بومی',
      category: 'اخلاق کسب و کار',
      weight: 0,
    ),
    BusinessCriterion(
      title: 'ثبات مالی در شرایط عدم قطعیت درآمد',
      category: 'عملکرد مالی',
      weight: 0,
    ),
    BusinessCriterion(
      title: 'پتانسیل درآمد زایی بالا',
      category: 'عملکرد مالی',
      weight: 0,
    ),
    BusinessCriterion(
      title: 'ظرفیت کارآفرینی',
      category: 'عملکرد مالی',
      weight: 0,
    ),
    BusinessCriterion(
      title: 'حداکثر بازدهی اقتصادی',
      category: 'عملکرد مالی',
      weight: 0,
    ),
    BusinessCriterion(
      title: 'برتری رقابتی',
      category: 'عملکرد مالی',
      weight: 0,
    ),
    BusinessCriterion(
      title: 'درآمدزایی ارزی در فروش',
      category: 'عملکرد مالی',
      weight: 0,
    ),
    BusinessCriterion(
      title: 'طول عمر پایدار کسب و کار',
      category: 'چشم‌انداز',
      weight: 0,
    ),
    BusinessCriterion(title: 'کیفیت محصول', category: 'چشم‌انداز', weight: 0),
    BusinessCriterion(
      title: 'جامعیت زنجیره ارزش',
      category: 'چشم‌انداز',
      weight: 0,
    ),
    BusinessCriterion(
      title: 'استقلال ارزی در تولید',
      category: 'چشم‌انداز',
      weight: 0,
    ),
  ];
}

class ProductCriterion {
  final String title;
  final String category;
  int weight; // قابل ویرایش — دانشجو وزن هر معیار را وارد می‌کند
  final List<String> scores = List.generate(4, (_) => '');

  ProductCriterion({
    required this.title,
    required this.category,
    this.weight = 0,
  });
}

class ProductPriorityState {
  final List<ProductCriterion> criteria = [
    ProductCriterion(title: 'کیفیت محصول', category: 'ویژگی‌های ذاتی و رقابتی'),
    ProductCriterion(
      title: 'طراحی کارآمدتر',
      category: 'ویژگی‌های ذاتی و رقابتی',
    ),
    ProductCriterion(title: 'متمایز بودن', category: 'ویژگی‌های ذاتی و رقابتی'),
    ProductCriterion(title: 'نوآوری', category: 'ویژگی‌های ذاتی و رقابتی'),
    ProductCriterion(
      title: 'قدرت کپی پایین',
      category: 'ویژگی‌های ذاتی و رقابتی',
    ),
    ProductCriterion(title: 'شناخت مشتری', category: 'مشتری و بازار'),
    ProductCriterion(title: 'سهولت دسترسی به مشتری', category: 'مشتری و بازار'),
    ProductCriterion(title: 'طول چرخه فروش', category: 'مشتری و بازار'),
    ProductCriterion(title: 'وفاداری مشتری', category: 'مشتری و بازار'),
    ProductCriterion(title: 'هزینه تولید کم', category: 'تولید و عملیات'),
    ProductCriterion(title: 'زمان کوتاه تولید', category: 'تولید و عملیات'),
    ProductCriterion(title: 'پیچیدگی فرآیند تولید', category: 'تولید و عملیات'),
    ProductCriterion(
      title: 'تامین مواد اولیه ساده',
      category: 'تولید و عملیات',
    ),
    ProductCriterion(
      title: 'بازگشت سرمایه کوتاه',
      category: 'مالی و درآمدزایی',
    ),
    ProductCriterion(title: 'سود بالا', category: 'مالی و درآمدزایی'),
    ProductCriterion(title: 'قابلیت پیش فروش', category: 'مالی و درآمدزایی'),
    ProductCriterion(title: 'پتانسیل فروش جانبی', category: 'مالی و درآمدزایی'),
  ];
}

class GrowthMetricRow {
  final String title;
  final String unit;
  final String category;
  String currentValue;
  String target;
  String result;

  GrowthMetricRow({
    required this.title,
    required this.unit,
    required this.category,
    required this.currentValue,
    required this.target,
    required this.result,
  });
}

class GrowthPeriod {
  String startDate;
  String targetDate;
  final List<GrowthMetricRow> metrics;

  GrowthPeriod({
    required this.startDate,
    required this.targetDate,
    required this.metrics,
  });

  factory GrowthPeriod.newEmpty() {
    return GrowthPeriod(
      startDate: '',
      targetDate: '',
      metrics: [
        GrowthMetricRow(
          title: 'مختصات حاضر',
          unit: 'امتیاز',
          category: 'دارایی‌ها و منابع',
          currentValue: '',
          target: '',
          result: '',
        ),
        GrowthMetricRow(
          title: 'تامین‌کننده اعتباری',
          unit: 'تومان',
          category: 'دارایی‌ها و منابع',
          currentValue: '',
          target: '',
          result: '',
        ),
        GrowthMetricRow(
          title: 'موجودی انبار',
          unit: 'تومان',
          category: 'دارایی‌ها و منابع',
          currentValue: '',
          target: '',
          result: '',
        ),
        GrowthMetricRow(
          title: 'ماشین آلات',
          unit: 'تومان',
          category: 'دارایی‌ها و منابع',
          currentValue: '',
          target: '',
          result: '',
        ),
        GrowthMetricRow(
          title: 'سرمایه در گردش',
          unit: 'تومان',
          category: 'دارایی‌ها و منابع',
          currentValue: '',
          target: '',
          result: '',
        ),
        GrowthMetricRow(
          title: 'کارکنان',
          unit: 'تعداد',
          category: 'نیروی انسانی',
          currentValue: '',
          target: '',
          result: '',
        ),
        GrowthMetricRow(
          title: 'رضایت کارکنان',
          unit: 'امتیاز',
          category: 'نیروی انسانی',
          currentValue: '',
          target: '',
          result: '',
        ),
        GrowthMetricRow(
          title: 'عضو کانال',
          unit: 'تعداد',
          category: 'بازاریابی',
          currentValue: '',
          target: '',
          result: '',
        ),
        GrowthMetricRow(
          title: 'عضو صفحه',
          unit: 'تعداد',
          category: 'بازاریابی',
          currentValue: '',
          target: '',
          result: '',
        ),
        GrowthMetricRow(
          title: 'ترافیک وب‌سایت',
          unit: 'تعداد',
          category: 'بازاریابی',
          currentValue: '',
          target: '',
          result: '',
        ),
        GrowthMetricRow(
          title: 'شناسایی روش رقیب',
          unit: 'امتیاز',
          category: 'بازاریابی',
          currentValue: '',
          target: '',
          result: '',
        ),
        GrowthMetricRow(
          title: 'محلی',
          unit: 'تعداد',
          category: 'گستره جغرافیایی',
          currentValue: '',
          target: '',
          result: '',
        ),
        GrowthMetricRow(
          title: 'شهری',
          unit: 'تعداد',
          category: 'گستره جغرافیایی',
          currentValue: '',
          target: '',
          result: '',
        ),
        GrowthMetricRow(
          title: 'ملی',
          unit: 'تعداد',
          category: 'گستره جغرافیایی',
          currentValue: '',
          target: '',
          result: '',
        ),
        GrowthMetricRow(
          title: 'بین‌المللی',
          unit: 'تعداد',
          category: 'گستره جغرافیایی',
          currentValue: '',
          target: '',
          result: '',
        ),
        GrowthMetricRow(
          title: 'طول عمر مشتری',
          unit: 'ماه',
          category: 'مشتری',
          currentValue: '',
          target: '',
          result: '',
        ),
        GrowthMetricRow(
          title: 'شکایات مشتری',
          unit: 'درصد',
          category: 'مشتری',
          currentValue: '',
          target: '',
          result: '',
        ),
        GrowthMetricRow(
          title: 'سود خالص',
          unit: 'تومان',
          category: 'مالی و سودآوری',
          currentValue: '',
          target: '',
          result: '',
        ),
        GrowthMetricRow(
          title: 'دوره نقدشوندگی',
          unit: 'روز',
          category: 'مالی و سودآوری',
          currentValue: '',
          target: '',
          result: '',
        ),
      ],
    );
  }
}

class GrowthTableState {
  final List<GrowthPeriod> periods = [GrowthPeriod.newEmpty()];
}

// class AppState {
//   final personalInfo = PersonalBusinessInfoState();
//   final talent = TalentState();
//   final values = ValuesState();
//   final businessSelection = BusinessSelectionState();
//   final productPriority = ProductPriorityState();
//   final growthTable = GrowthTableState();

//   void addGrowthPeriod() {
//     growthTable.periods.add(GrowthPeriod.newEmpty());
//   }
// }

// class PersonalBusinessInfoState {
//   String lastName = '';
//   String firstName = '';
//   String contact = '';
//   String neighborhood = '';
//   String major = '';
//   String degree = 'کارشناسی';
//   String satisfiedMajor = 'بله';
//   String majorReason = '';
//   String ifReturn = '';
//   String businessTitle = '';
//   String businessSatisfied = 'تا حدی';
//   String valueOrientation = 'علم';
//   String rank = '';
//   String score = '';
// }

// class TalentRow {
//   String rank = '';
//   String title = '';
//   String description = '';
// }

// class TalentState {
//   String highestCategory = '';
//   String lowestTalent = '';
//   String twoDimType = '';
//   String fourDimType = '';
//   String bestTeam = '';
//   final List<TalentRow> rows = List.generate(5, (_) => TalentRow());
// }

// class ValuesState {
//   final List<String> list = List.generate(10, (_) => '');
// }

// class BusinessCriterion {
//   final String title;
//   final String category;
//   int weight; // final حذف شد — دانشجو می‌تونه وزن رو ویرایش کنه
//   final List<String> scores = List.generate(3, (_) => '');

//   BusinessCriterion({
//     required this.title,
//     required this.category,
//     required this.weight,
//   });
// }

// class BusinessSelectionState {
//   final List<BusinessCriterion> criteria = [
//     BusinessCriterion(
//       title: 'علاقه و انگیزه پایدار',
//       category: 'ویژگی‌های فردی',
//       weight: 0,
//     ),
//     BusinessCriterion(
//       title: 'انعطاف‌ پذیری در شرایط بحرانی',
//       category: 'ویژگی‌های فردی',
//       weight: 0,
//     ),
//     BusinessCriterion(
//       title: 'کنترل حرص و طمع',
//       category: 'ویژگی‌های فردی',
//       weight: 0,
//     ),
//     BusinessCriterion(
//       title: 'سلامت جامع (جسم و روان)',
//       category: 'ویژگی‌های فردی',
//       weight: 0,
//     ),
//     BusinessCriterion(
//       title: 'تعادل بهینه زندگی و کار',
//       category: 'ویژگی‌های فردی',
//       weight: 0,
//     ),
//     BusinessCriterion(
//       title: 'استعداد و خودکفایی فنی',
//       category: 'شایستگی‌های فنی',
//       weight: 0,
//     ),
//     BusinessCriterion(
//       title: 'اعتبار و وجه حرفه‌ای',
//       category: 'شایستگی‌های فنی',
//       weight: 0,
//     ),
//     BusinessCriterion(
//       title: 'ظرفیت توسعه علمی و آموزشی',
//       category: 'شایستگی‌های فنی',
//       weight: 0,
//     ),
//     BusinessCriterion(
//       title: 'تعهد به پیشرفت مستمر',
//       category: 'شایستگی‌های فنی',
//       weight: 0,
//     ),
//     BusinessCriterion(
//       title: 'دسترسی به دانش خبرگان',
//       category: 'شایستگی‌های فنی',
//       weight: 0,
//     ),
//     BusinessCriterion(
//       title: 'اصول انصاف در تعامل با مشتری',
//       category: 'اخلاق کسب و کار',
//       weight: 0,
//     ),
//     BusinessCriterion(
//       title: 'صداقت در ارتباطات',
//       category: 'اخلاق کسب و کار',
//       weight: 0,
//     ),
//     BusinessCriterion(
//       title: 'مسئولیت‌پذیری زیست محیطی',
//       category: 'اخلاق کسب و کار',
//       weight: 0,
//     ),
//     BusinessCriterion(
//       title: 'حمایت اجتماعی و دولتی',
//       category: 'اخلاق کسب و کار',
//       weight: 0,
//     ),
//     BusinessCriterion(
//       title: 'پاسخگویی به نیازهای بومی',
//       category: 'اخلاق کسب و کار',
//       weight: 0,
//     ),
//     BusinessCriterion(
//       title: 'ثبات مالی در شرایط عدم قطعیت درآمد',
//       category: 'عملکرد مالی',
//       weight: 0,
//     ),
//     BusinessCriterion(
//       title: 'پتانسیل درآمد زایی بالا',
//       category: 'عملکرد مالی',
//       weight: 0,
//     ),
//     BusinessCriterion(
//       title: 'ظرفیت کارآفرینی',
//       category: 'عملکرد مالی',
//       weight: 0,
//     ),
//     BusinessCriterion(
//       title: 'حداکثر بازدهی اقتصادی',
//       category: 'عملکرد مالی',
//       weight: 0,
//     ),
//     BusinessCriterion(
//       title: 'برتری رقابتی',
//       category: 'عملکرد مالی',
//       weight: 0,
//     ),
//     BusinessCriterion(
//       title: 'درآمدزایی ارزی در فروش',
//       category: 'عملکرد مالی',
//       weight: 0,
//     ),
//     BusinessCriterion(
//       title: 'طول عمر پایدار کسب و کار',
//       category: 'چشم‌انداز',
//       weight: 0,
//     ),
//     BusinessCriterion(title: 'کیفیت محصول', category: 'چشم‌انداز', weight: 0),
//     BusinessCriterion(
//       title: 'جامعیت زنجیره ارزش',
//       category: 'چشم‌انداز',
//       weight: 0,
//     ),
//     BusinessCriterion(
//       title: 'استقلال ارزی در تولید',
//       category: 'چشم‌انداز',
//       weight: 0,
//     ),
//   ];
// }

// class ProductCriterion {
//   final String title;
//   final String category;
//   int weight; // قابل ویرایش — دانشجو وزن هر معیار را وارد می‌کند
//   final List<String> scores = List.generate(4, (_) => '');

//   ProductCriterion({
//     required this.title,
//     required this.category,
//     this.weight = 0,
//   });
// }

// class ProductPriorityState {
//   final List<ProductCriterion> criteria = [
//     ProductCriterion(title: 'کیفیت محصول', category: 'ویژگی‌های ذاتی و رقابتی'),
//     ProductCriterion(
//       title: 'طراحی کارآمدتر',
//       category: 'ویژگی‌های ذاتی و رقابتی',
//     ),
//     ProductCriterion(title: 'متمایز بودن', category: 'ویژگی‌های ذاتی و رقابتی'),
//     ProductCriterion(title: 'نوآوری', category: 'ویژگی‌های ذاتی و رقابتی'),
//     ProductCriterion(
//       title: 'قدرت کپی پایین',
//       category: 'ویژگی‌های ذاتی و رقابتی',
//     ),
//     ProductCriterion(title: 'شناخت مشتری', category: 'مشتری و بازار'),
//     ProductCriterion(title: 'سهولت دسترسی به مشتری', category: 'مشتری و بازار'),
//     ProductCriterion(title: 'طول چرخه فروش', category: 'مشتری و بازار'),
//     ProductCriterion(title: 'وفاداری مشتری', category: 'مشتری و بازار'),
//     ProductCriterion(title: 'هزینه تولید کم', category: 'تولید و عملیات'),
//     ProductCriterion(title: 'زمان کوتاه تولید', category: 'تولید و عملیات'),
//     ProductCriterion(title: 'پیچیدگی فرآیند تولید', category: 'تولید و عملیات'),
//     ProductCriterion(
//       title: 'تامین مواد اولیه ساده',
//       category: 'تولید و عملیات',
//     ),
//     ProductCriterion(
//       title: 'بازگشت سرمایه کوتاه',
//       category: 'مالی و درآمدزایی',
//     ),
//     ProductCriterion(title: 'سود بالا', category: 'مالی و درآمدزایی'),
//     ProductCriterion(title: 'قابلیت پیش فروش', category: 'مالی و درآمدزایی'),
//     ProductCriterion(title: 'پتانسیل فروش جانبی', category: 'مالی و درآمدزایی'),
//   ];
// }

// class GrowthMetricRow {
//   final String title;
//   final String unit;
//   String currentValue;
//   String target;
//   String result;

//   GrowthMetricRow({
//     required this.title,
//     required this.unit,
//     required this.currentValue,
//     required this.target,
//     required this.result,
//   });
// }

// class GrowthPeriod {
//   String startDate;
//   String targetDate;
//   final List<GrowthMetricRow> metrics;

//   GrowthPeriod({
//     required this.startDate,
//     required this.targetDate,
//     required this.metrics,
//   });

//   factory GrowthPeriod.newEmpty() {
//     return GrowthPeriod(
//       startDate: '',
//       targetDate: '',
//       metrics: [
//         GrowthMetricRow(
//           title: 'موقعیت مکانی',
//           unit: 'امتیاز',
//           currentValue: '4',
//           target: '',
//           result: '',
//         ),
//         GrowthMetricRow(
//           title: 'تامین‌کننده اعتباری',
//           unit: 'تومان',
//           currentValue: '1000000000',
//           target: '',
//           result: '',
//         ),
//         GrowthMetricRow(
//           title: 'موجودی انبار',
//           unit: 'تومان',
//           currentValue: '10000000',
//           target: '',
//           result: '',
//         ),
//       ],
//     );
//   }
// }

// class GrowthTableState {
//   final List<GrowthPeriod> periods = [GrowthPeriod.newEmpty()];
// }
