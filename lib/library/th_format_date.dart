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
    final dateParts = inputDate.split(', ');
    final monthDay = dateParts[0].split(' ');
    final monthIndex = monthNames.indexOf(monthDay[0]);
    final day = int.parse(monthDay[1]);
    final year = int.parse(dateParts[1]) + 543;

    final documentIdDateTime = DateTime(year, monthIndex + 9, day, 12, 0);

    final formattedDate =
        DateFormat('EEEE, d MMMM y', 'th_TH').format(documentIdDateTime);
    return formattedDate;
  } catch (e) {
    return 'Error parsing date: $inputDate';
  }
}

String thFormatDateShort(String inputDate) {
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
    final dateParts = inputDate.split(', ');
    final monthDay = dateParts[0].split(' ');
    final monthIndex = monthNames.indexOf(monthDay[0]);
    final day = int.parse(monthDay[1]);
    final year = int.parse(dateParts[1]) + 543;

    final documentIdDateTime = DateTime(year, monthIndex + 9, day, 12, 0);

    final formattedDate =
        DateFormat('d/MM/y', 'th_TH').format(documentIdDateTime);
    return formattedDate;
  } catch (e) {
    return 'Error parsing date: $inputDate';
  }
}

String thFormatDateMonth(String inputDate) {
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
    final dateParts = inputDate.split(' ');
    final month = dateParts[0];
    final monthIndex = monthNames.indexOf(month[0]);
    final year = int.parse(dateParts[1]) + 543;
    final documentIdDateTime = DateTime(year, monthIndex + 9, 12, 0);

    final formattedDate = DateFormat(
      'MMMM y',
      'th_TH',
    ).format(documentIdDateTime);
    return formattedDate;
  } catch (e) {
    return 'Error parsing date: $inputDate';
  }
}
