import 'package:intl/intl.dart';

class Helpers {
  static String formatDate(DateTime date) {
    return DateFormat.yMMMd('ar').format(date);
  }

  static DateTime getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - DateTime.saturday));
  }

  static bool isHalaqaDay(DateTime date) {
    return [DateTime.saturday, DateTime.sunday, DateTime.monday, DateTime.tuesday, DateTime.wednesday].contains(date.weekday);
  }
}