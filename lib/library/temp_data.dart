import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class TemperatureData {
  DateTime date;
  double maxTemp;
  double minTemp;
  String documentID;
  String formattedDate;
  double gdd;

  TemperatureData({
    required this.gdd,
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.documentID,
  }) : formattedDate = DateFormat('EEEE d MMMM y', 'th_TH').format(date) {
    if (kDebugMode) {
      print("TemperatureData instance created:");
      print("gdd: $gdd");
      print("date: $date");
      print("maxTemp: $maxTemp");
      print("minTemp: $minTemp");
      print("documentID: $documentID");
      print("formattedDate: $formattedDate");
    }
  }
}
