import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

// case สำหรับแปลง เดือนในภาษาอังกฤษ ในรูปแบบ MMMM MM number 0Number เป็นภาษาไทย
const monthToThaiMapping = {
  'January': 'มกราคม',
  'Jan': 'มกราคม',
  '1': 'มกราคม',
  '01': 'มกราคม',
  'February': 'กุมภาพันธ์',
  'Feb': 'กุมภาพันธ์',
  '2': 'กุมภาพันธ์',
  '02': 'กุมภาพันธ์',
  'March': 'มีนาคม',
  'Mar': 'มีนาคม',
  '3': 'มีนาคม',
  '03': 'มีนาคม',
  'April': 'เมษายน',
  'Apr': 'เมษายน',
  '4': 'เมษายน',
  '04': 'เมษายน',
  'May': 'พฤษภาคม',
  '5': 'พฤษภาคม',
  '05': 'พฤษภาคม',
  'June': 'มิถุนายน',
  'Jun': 'มิถุนายน',
  '6': 'มิถุนายน',
  '06': 'มิถุนายน',
  'July': 'กรกฎาคม',
  'Jul': 'กรกฎาคม',
  '7': 'กรกฎาคม',
  '07': 'กรกฎาคม',
  'August': 'สิงหาคม',
  'Aug': 'สิงหาคม',
  '8': 'สิงหาคม',
  '08': 'สิงหาคม',
  'September': 'กันยายน',
  'Sep': 'กันยายน',
  '9': 'กันยายน',
  '09': 'กันยายน',
  'October': 'ตุลาคม',
  'Oct': 'ตุลาคม',
  '10': 'ตุลาคม',
  'November': 'พฤศจิกายน',
  'Nov': 'พฤศจิกายน',
  '11': 'พฤศจิกายน',
  'December': 'ธันวาคม',
  'Dec': 'ธันวาคม',
  '12': 'ธันวาคม',
};

String convertMonthToThai(String month) {
  return monthToThaiMapping[month] ?? month;
}

const convertMonthThaiLongToShort = {
  'มกราคม': 'ม.ค.',
  'กุมภาพันธ์': 'ก.พ.',
  'มีนาคม': 'มี.ค.',
  'เมษายน': 'เม.ย.',
  'พฤษภาคม': 'พ.ค.',
  'มิถุนายน': 'มิ.ย.',
  'กรกฎาคม': 'ก.ค.',
  'สิงหาคม': 'ส.ค.',
  'กันยายน': 'ก.ย.',
  'ตุลาคม': 'ต.ค.',
  'พฤศจิกายน': 'พ.ย.',
  'ธันวาคม': 'ธ.ค.'
};

String convertMonthToThaiShort(String month) {
  return convertMonthThaiLongToShort[month] ?? month;
}

//th format date สำหรับแปลงวันที่ M D, Y เป็น EEEE, d MMMM y
String thFormatDate(String inputDate) {
  try {
    final dateParts = inputDate.split(', ');
    final monthDay = dateParts[0].split(' ');
    final monthInThai = convertMonthToThai(monthDay[0]);
    final monthIndex = thMonthNames.indexOf(monthInThai);
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

//th format date สำหรับแปลงวันที่ Y-M-DT เป็น EEEE, d MMMM y
String thFormatDateYMD(String inputDate) {
  try {
    final dateParts = inputDate.split('T')[0].split('-');
    final day = int.parse(dateParts[2]);
    final month = dateParts[1];
    final monthInThai = convertMonthToThai(month);
    final monthIndex = thMonthNames.indexOf(monthInThai);
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

//th format date สำหรับ D/M/Y to D:M:Y
String thFormatDateDMY(String inputDate) {
  try {
    final dateParts = inputDate.split('/');
    final day = int.parse(dateParts[0]);
    final month = dateParts[1];
    final year = int.parse(dateParts[2]) + 543;
    final monthInThai = convertMonthToThai(month);
    final monthIndex = thMonthNames.indexOf(monthInThai);

    if (kDebugMode) {
      print('Month Day: $month');
      print('Month Index: $monthIndex');
      print('Day: $day');
      print('Year: $year');
    }

    final formattedDate = "$day:${monthNamesShort[monthIndex]}:$year";
    return formattedDate;
  } catch (e) {
    return 'Error parsing date: $inputDate';
  }
}

// th format date สำหรับแปลงวันที่ M D, Y เป็น d/MM/y
String thFormatDateShort(String inputDate) {
  try {
    final dateParts = inputDate.split(', ');
    final monthDay = dateParts[0].split(' ');
    final monthInThai = convertMonthToThai(monthDay[0]);
    final monthIndex = thMonthNames.indexOf(monthInThai);
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

// th format date สำหรับแปลงวันที่ M Y เป็น MMMM y
String thFormatDateMonth(String inputDate) {
  try {
    final dateParts = inputDate.split(' ');
    final month = dateParts[0];
    final monthInThai = convertMonthToThai(month);
    final monthIndex = thMonthNames.indexOf(monthInThai);
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

//th format date สำหรับแปลง M Y เป็น MMM Y
String thFormatDateMonthShort(String inputDate) {
  try {
    final dateParts = inputDate.split(' ');
    final month = dateParts[0];
    final monthInThai = convertMonthToThai(month);
    final monthIndex = thMonthNames.indexOf(monthInThai);
    final year = int.parse(dateParts[1]) + 543;

    if (kDebugMode) {
      print('Month Index: $monthIndex');
      print('Year: $year');
    }

    final formattedDate = "${monthNamesShort[monthIndex]} $year";
    return formattedDate;
  } catch (e) {
    return 'Error parsing date: $inputDate';
  }
}

// th format date สำหรับแปลงวันที่ M-Y เป็น MMMM y
String thFormatDateMonthShortNumber(String inputDate) {
  try {
    final dateParts = inputDate.split('-');
    final month = dateParts[0];
    final monthInThai = convertMonthToThai(month);
    final monthIndex = thMonthNames.indexOf(monthInThai);
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

// Month name ภาษาไทย
const thMonthNames = [
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
const monthNamesShort = [
  'ม.ค.',
  'ก.พ.',
  'มี.ค.',
  'เม.ย.',
  'พ.ค.',
  'มิ.ย.',
  'ก.ค.',
  'ส.ค.',
  'ก.ย.',
  'ต.ค.',
  'พ.ย.',
  'ธ.ค.'
];
