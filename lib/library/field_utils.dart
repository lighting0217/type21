/// A collection of utility functions for working with fields.
///
/// This class contains static methods for converting area to Rai-Ngan-Wah,
/// getting the Thai name of a rice type, and formatting a date in Thai format.
///
library;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class FieldUtilsWidget {
  /// Converts a polygon area in square meters to Rai-Ngan-Wah.
  ///
  /// The result is returned as a formatted string with the format:
  ///
  /// ```
  /// พื้นที่เพาะปลูก
  /// <rai> ไร่ <ngan> งาน <squareWah> ตารางวา
  /// ```
  ///
  /// where `<rai>` is the number of Rai, `<ngan>` is the number of Ngan,
  /// and `<squareWah>` is the number of square Wah.
  static String convertAreaToRaiNganWah(double polygonArea) {
    final double rai = (polygonArea / 1600).floorToDouble();
    final double ngan = ((polygonArea - (rai * 1600)) / 400).floorToDouble();
    final double squareWah = (polygonArea / 4) - (rai * 400) - (ngan * 100);

    String result = 'พื้นที่เพาะปลูก \n';
    result += '${rai.toInt()} ไร่ ';
    result += '${ngan.toInt()} งาน ';
    result += '${squareWah.toStringAsFixed(2)} ตารางวา';
    return result;
  }

  /// Gets the Thai name of a rice type.
  ///
  /// If the `riceType` parameter is `null`, the function returns `'N/A'`.
  ///
  /// If the `riceType` parameter is not `null`, the function returns the
  /// corresponding Thai name of the rice type, as follows:
  ///
  /// - `'KDML105'`: `'ข้าวหอมมะลิ'`
  /// - `'RD6'`: `'ข้าวกข.6'`
  ///
  /// For any other value of `riceType`, the function returns the value of
  /// `riceType` itself.
  static String getThaiRiceType(String? riceType) {
    switch (riceType) {
      case 'KDML105':
        return 'ข้าวหอมมะลิ';
      case 'RD6':
        return 'ข้าวกข.6';
      default:
        return riceType ?? 'N/A';
    }
  }

  /// Formats a date in Thai format.
  ///
  /// The `date` parameter is formatted using the Thai locale and returned as
  /// a string in the format:
  ///
  /// ```
  /// <weekday>ที่ <day> <month> <year>
  /// ```
  ///
  /// where `<weekday>` is the full name of the weekday in Thai,
  /// `<day>` is the day of the month, `<month>` is the full name of the month
  /// in Thai, and `<year>` is the year in the Buddhist Era (BE) format.
  ///
  /// If the `date` parameter is `null`, the function returns `'Not selected'`.
  static String formatDateThai(DateTime? date) {
    if (date == null) return 'Not selected';
    initializeDateFormatting('th_TH');
    final formatter = DateFormat.yMMMMEEEEd('th_TH');
    return formatter.format(date);
  }
}
