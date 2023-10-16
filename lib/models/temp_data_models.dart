import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Field {
  final String id;
  String fieldName;
  double polygonArea;
  List<LatLng> polygons;
  String riceType;
  double totalDistance;
  DateTime? selectedDate;
  String createdBy;
  List<TemperatureData> temperatureData;
  List<MonthlyTemperatureData> monthlyTemperatureData;
  List<AccumulatedGddData> accumulatedGddData;
  DateTime? forecastedHarvestDate;
  double riceMaxGdd;

  Field({
    required this.id,
    required this.fieldName,
    required this.riceType,
    required this.polygonArea,
    required this.totalDistance,
    required this.polygons,
    required this.selectedDate,
    required this.createdBy,
    required this.temperatureData,
    required this.monthlyTemperatureData,
    required this.accumulatedGddData,
    required this.riceMaxGdd,
    DateTime? forecastedHarvestDate,
    required String documentID,
  });
}

class AccumulatedGddData {
  final Timestamp date;
  final double accumulatedGdd;
  final String documentID;
  final double riceMaxGdd;

  AccumulatedGddData({
    required this.date,
    required this.accumulatedGdd,
    required this.documentID,
    required this.riceMaxGdd,
  });
}

class MonthlyTemperatureData {
  final String monthYear;
  final double gddSum;
  final String documentID;
  final double riceMaxGdd;
  AccumulatedGddData? accumulatedGddData;

  MonthlyTemperatureData({
    required this.monthYear,
    required this.gddSum,
    required this.documentID,
    required this.riceMaxGdd,
    this.accumulatedGddData,
  });

  MonthlyTemperatureData copyWith({
    String? documentID,
    double? gddSum,
    double? riceMaxGdd,
    String? monthYear,
    DateTime? forecastedHarvestDate,
  }) {
    return MonthlyTemperatureData(
      documentID: documentID ?? this.documentID,
      gddSum: gddSum ?? this.gddSum,
      riceMaxGdd: riceMaxGdd ?? this.riceMaxGdd,
      monthYear: monthYear ?? this.monthYear,
    );
  }
}

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
