import 'package:intl/intl.dart';

String thFormatDate(String inputDate) {
  const monthNames = [
    'มกราคม',
    'กุมภาพันธ์',
    'มีนาคม',
    'เมษายน',
    'พฤษภาคม',
    'มิถุนายน',
    'กรกฎาคม',
    'สิงหาคม',
    'กันยายน',
    'ตุลาคม',
    'พฤศจิกายน',
    'ธันวาคม',
  ];

  try {
    final documentIdDateParts = inputDate.split(' ');
    final monthIndex = monthNames.indexOf(documentIdDateParts[0]);
    final day = int.parse(documentIdDateParts[1].replaceAll(',', ''));
    final year = int.parse(documentIdDateParts[2]);
    final documentIdDateTime = DateTime(year, monthIndex + 1, day);
    final formattedDate =
        DateFormat('EEEE, d MMMM y', 'th_TH').format(documentIdDateTime);
    return formattedDate;
  } catch (e) {
    return 'Error parsing date: $inputDate';
  }
}
