import 'package:flutter/foundation.dart';
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
    final monthInThai = convertMonthToThai(monthDay[0]);
    final monthIndex = monthNames.indexOf(monthInThai);
    final day = int.parse(monthDay[1]);
    final year = int.parse(dateParts[1]) + 543;

    if (kDebugMode) {
      print('Month Day: $monthDay');
      print('Month Index: $monthIndex');
      print('Day: $day');
      print('Year: $year');
    }
    final documentIdDateTime = DateTime(year, monthIndex + 1, day, 12, 0);

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
    final monthInThai = convertMonthToThai(monthDay[0]);
    final monthIndex = monthNames.indexOf(monthInThai);
    final day = int.parse(monthDay[1]);
    final year = int.parse(dateParts[1]) + 543;

    if (kDebugMode) {
      print('Month Day: $monthDay');
      print('Month Index: $monthIndex');
      print('Day: $day');
      print('Year: $year');
    }
    final documentIdDateTime = DateTime(year, monthIndex + 1, day, 12, 0);

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
    final monthInThai = convertMonthToThai(month); // Corrected this line
    final monthIndex = monthNames.indexOf(monthInThai);
    final year = int.parse(dateParts[1]) + 543;

    final documentIdDateTime = DateTime(year, monthIndex + 1, 12, 0);

    if (kDebugMode) {
      print('Month Index: $monthIndex');
      print('Year: $year');
    }

    final formattedDate =
        DateFormat('MMMM y', 'th_TH').format(documentIdDateTime);
    return formattedDate;
  } catch (e) {
    return 'Error parsing date: $inputDate';
  }
}

String convertMonthToThai(String month) {
  switch (month) {
    case 'January':
      return 'มกราคม';
    case 'February':
      return 'กุมภาพันธ์';
    case 'March':
      return 'มีนาคม';
    case 'April':
      return 'เมษายน';
    case 'May':
      return 'พฤษภาคม';
    case 'June':
      return 'มิถุนายน';
    case 'July':
      return 'กรกฎาคม';
    case 'August':
      return 'สิงหาคม';
    case 'September':
      return 'กันยายน';
    case 'October':
      return 'ตุลาคม';
    case 'November':
      return 'พฤศจิกายน';
    case 'December':
      return 'ธันวาคม';
    default:
      return month;
  }
}
