import 'package:shamsi_date/shamsi_date.dart';

class AppDateFormatter {
  static const List<String> _months = [
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'مرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند',
  ];

  static String toJalali(DateTime date) {
    final jDate = Jalali.fromDateTime(date);
    return '${jDate.day} ${_months[jDate.month - 1]} ${jDate.year}';
  }

  static String toJalaliShort(DateTime date) {
    final jDate = Jalali.fromDateTime(date);
    return '${jDate.day} ${_months[jDate.month - 1]}';
  }

  static String toJalaliSlash(DateTime date) {
    final jDate = Jalali.fromDateTime(date);
    final y = jDate.year.toString();
    final m = jDate.month.toString().padLeft(2, '0');
    final d = jDate.day.toString().padLeft(2, '0');
    return '$y/$m/$d';
  }

  static DateTime? parseJalaliSlash(String value) {
    try {
      final parts = value.trim().split('/');
      if (parts.length != 3) return null;

      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);

      return Jalali(year, month, day).toDateTime();
    } catch (_) {
      return null;
    }
  }

  static bool isAfter(String jalaliDate1, String jalaliDate2) {
    final d1 = parseJalaliSlash(jalaliDate1);
    final d2 = parseJalaliSlash(jalaliDate2);
    if (d1 == null || d2 == null) return false;
    return d1.isAfter(d2);
  }
}
