import '../models/temp_data_models.dart';
// This file contains utility functions for temperature chart data manipulation.

/// Returns the Thai month name based on the given month index.
///
/// The function takes an integer [month] as input and returns the corresponding
/// Thai month name as a string. The month index should be between 1 and 12.
String getThaiMonth(int month) {
  List<String> thaiMonths = [
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
    'ธันวาคม'
  ];
  return thaiMonths[month - 1];
}

/// Calculates the percentage of accumulated GDD.
///
/// The function takes an [accumulatedGddData] object and a double [riceMaxGdd] as
/// input and returns the percentage of accumulated GDD as a double.
double calculatePercent(
    AccumulatedGddData accumulatedGddData, double riceMaxGdd) {
  return (accumulatedGddData.accumulatedGdd / riceMaxGdd) * 100;
}

/// Computes the cumulative GDD sum.
///
/// The function takes a list of [newData] and an optional list of [existingData]
/// as input and returns a new list of [MonthlyTemperatureData] objects with the
/// cumulative GDD sum computed for each month. If [existingData] is provided,
/// the cumulative sum is computed starting from the last element of the list.
List<MonthlyTemperatureData> computeCumulativeGddSum(
    List<MonthlyTemperatureData> newData,
    [List<MonthlyTemperatureData>? existingData]) {
  double cumulativeSum = 0;
  existingData ??= [];

  if (existingData.isNotEmpty) {
    cumulativeSum = existingData.last.gddSum;
  }

  List<MonthlyTemperatureData> updatedData = [];
  for (var monthData in newData) {
    cumulativeSum += monthData.gddSum;
    updatedData.add(monthData.copyWith(gddSum: cumulativeSum));
  }

  return List.from(existingData)..addAll(updatedData);
}
