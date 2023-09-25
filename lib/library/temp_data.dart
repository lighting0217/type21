import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// A class representing temperature data.
class TemperatureData {
  /// The date of the temperature data.
  DateTime date;

  /// The maximum temperature of the day.
  double maxTemp;

  /// The minimum temperature of the day.
  double minTemp;

  /// The ID of the document.
  String documentID;

  /// The formatted date of the temperature data.
  String formattedDate;

  /// The growing degree days of the temperature data.
  double gdd;

  /// Creates a new instance of [TemperatureData].
  ///
  /// [gdd] is the growing degree days of the temperature data.
  /// [date] is the date of the temperature data.
  /// [maxTemp] is the maximum temperature of the day.
  /// [minTemp] is the minimum temperature of the day.
  /// [documentID] is the ID of the document.
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
