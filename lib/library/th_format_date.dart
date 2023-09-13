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

String thFormatDateYMD(String inputDate) {
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
    final dateParts = inputDate.split('T')[0].split('-');
    final day = int.parse(dateParts[2]);
    final month = dateParts[1];
    final monthInThai = convertMonthToThai(month);
    final monthIndex = monthNames.indexOf(monthInThai);
    final year = int.parse(dateParts[0]) + 543;

    if (kDebugMode) {
      print('Month Day: $month');
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

String thFormatDateMonthShortNumber(String inputDate) {
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
    final dateParts = inputDate.split('-');
    final month = dateParts[0];
    final monthInThai = convertMonthToThai(month);
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
  if (['January', 'Jan', '1', '01'].contains(month)) {
    return 'มกราคม';
  } else if (['February', 'Feb', '2', '02'].contains(month)) {
    return 'กุมภาพันธ์';
  } else if (['March', 'Mar', '3', '03'].contains(month)) {
    return 'มีนาคม';
  } else if (['April', 'Apr', '4', '04'].contains(month)) {
    return 'เมษายน';
  } else if (['May', '5', '05'].contains(month)) {
    return 'พฤษภาคม';
  } else if (['June', 'Jun', '6', '06'].contains(month)) {
    return 'มิถุนายน';
  } else if (['July', 'Jul', '7', '07'].contains(month)) {
    return 'กรกฎาคม';
  } else if (['August', 'Aug', '8', '08'].contains(month)) {
    return 'สิงหาคม';
  } else if (['September', 'Sep', '9', '09'].contains(month)) {
    return 'กันยายน';
  } else if (['October', 'Oct', '10'].contains(month)) {
    return 'ตุลาคม';
  } else if (['November', 'Nov', '11'].contains(month)) {
    return 'พฤศจิกายน';
  } else if (['December', 'Dec', '12'].contains(month)) {
    return 'ธันวาคม';
  } else {
    return month;
  }
}
