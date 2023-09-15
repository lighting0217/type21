// temp_chart_utils.dart
// This function returns the Thai month name based on the given month index.

import '../models/temp_data_models.dart';

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

// This function calculates the percentage of accumulated GDD.
double calculatePercent(AccumulatedGddData accumulatedGddData, double maxGdd) {
  return (accumulatedGddData.accumulatedGdd / maxGdd) * 100;
}

// This function computes the cumulative GDD sum.
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
