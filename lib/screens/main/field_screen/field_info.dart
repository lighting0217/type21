import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:type21/screens/main/field_screen/temp_screen.dart';

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
  });
}

class MonthlyTemperatureData {
  final String monthYear;
  final double gddSum;
  final String documentID;
  final double maxGdd;

  MonthlyTemperatureData({
    required this.monthYear,
    required this.gddSum,
    required this.documentID,
    required this.maxGdd,
  });
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

class FieldInfo extends StatefulWidget {
  const FieldInfo({
    Key? key,
    required this.field,
    required this.documentID,
    required String fieldName,
    required String riceType,
    required double polygonArea,
    required List<LatLng> polygons,
    required DateTime? selectedDate,
  }) : super(key: key);
  final Field field;
  final String documentID;

  @override
  State<FieldInfo> createState() => _FieldInfoState();
}

class _FieldInfoState extends State<FieldInfo> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  GoogleMapController? mapController;

  LatLng getPolygonCenter(List<LatLng> points) {
    double latSum = points.fold(0.0, (sum, point) => sum + point.latitude);
    double lngSum = points.fold(0.0, (sum, point) => sum + point.longitude);

    double latCenter = latSum / points.length;
    double lngCenter = lngSum / points.length;

    return LatLng(latCenter, lngCenter);
  }

  String convertAreaToRaiNganWah(double polygonArea) {
    final double rai = (polygonArea / 1600).floorToDouble();
    final double ngan = ((polygonArea - (rai * 1600)) / 400).floorToDouble();
    final double squareWah = (polygonArea / 4) - (rai * 400) - (ngan * 100);
    final formattedArea = NumberFormat('#,##0.00').format(polygonArea);

    String result = 'พื้นที่เพาะปลูก \n';
    result += '$formattedArea ตารางเมตร\n';
    result += '${rai.toInt()} ไร่ ';
    result += '${ngan.toInt()} งาน ';
    result += '${squareWah.toStringAsFixed(2)} ตารางวา';

    return result;
  }

  String getThaiRiceType(String? riceType) {
    switch (riceType) {
      case 'KDML105':
        return 'ข้าวหอมมะลิ';
      case 'RD6':
        return 'ข้าวกข.6';
      default:
        return riceType ?? 'N/A';
    }
  }

  String formatDateThai(DateTime? date) {
    if (date == null) return 'Not selected';
    initializeDateFormatting('th_TH');
    final formatter = DateFormat.yMMMMEEEEd('th_TH');
    return formatter.format(date);
  }

  Future<void> loadTemperatureData() async {
    try {
      final temperatureQuerySnapshot = await FirebaseFirestore.instance
          .collection('fields')
          .doc(widget.documentID)
          .collection('temperatures')
          .orderBy('date', descending: true)
          .get();

      final temperatureData = temperatureQuerySnapshot.docs.map((doc) {
        final data = doc.data();
        final date = (data['date'] as Timestamp).toDate();
        final maxTemp = (data['maxTemp'] as num).toDouble();
        final minTemp = (data['minTemp'] as num).toDouble();
        final gdd = (data['gdd'] as num).toDouble();

        final documentID = doc.id;
        return TemperatureData(
          date: date,
          maxTemp: maxTemp,
          minTemp: minTemp,
          documentID: documentID,
          gdd: gdd,
        );
      }).toList();
      if (temperatureData.isNotEmpty) {
        setState(() {
          widget.field.temperatureData = temperatureData;
        });
      }
    } catch (error) {
      if (kDebugMode) {
        print("Error loading temperature data: $error");
      }
    }
  }

  Future<void> loadMonthlyTemperatureData() async {
    try {
      final fieldDocumentSnapshot = await FirebaseFirestore.instance
          .collection('fields')
          .doc(widget.documentID)
          .get();

      final fieldData = fieldDocumentSnapshot.data();
      final maxGdd = fieldData?['riceMaxGdd'];
      if (kDebugMode) {
        print("maxGdd from fieldData: $maxGdd");
      }

      final monthlyTemperatureQuerySnapshot = await FirebaseFirestore.instance
          .collection('fields')
          .doc(widget.documentID)
          .collection('temperatures_monthly')
          .orderBy('date', descending: true)
          .get();

      final monthlyTemperatureData =
          monthlyTemperatureQuerySnapshot.docs.map((doc) {
        final data = doc.data();
        final monthYear = doc.id;
        final gddSum = (data['gddSum']).toDouble();

        return MonthlyTemperatureData(
          monthYear: monthYear,
          gddSum: gddSum,
          documentID: doc.id,
          maxGdd: maxGdd,
        );
      }).toList();

      if (monthlyTemperatureData.isNotEmpty) {
        setState(() {
          widget.field.monthlyTemperatureData = monthlyTemperatureData;
        });
      }
    } catch (error) {
      if (kDebugMode) {
        print("Error loading monthly temperature data: $error");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadTemperatureData();
    loadMonthlyTemperatureData();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.field.polygons.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('ไม่พบข้อมูลแปลง'),
        ),
      );
    } else {
      return Scaffold(
          appBar: AppBar(
            title: Text(
              'ข้อมูลแปลงเพาะปลูก',
              style: GoogleFonts.openSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.blue, // Change app bar color
          ),
          body: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ชื่อแปลง: ${widget.field.fieldName}',
                    style: GoogleFonts.openSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'พันธุ์ข้าว: ${getThaiRiceType(widget.field.riceType)}',
                    style: GoogleFonts.openSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    convertAreaToRaiNganWah(widget.field.polygonArea),
                    style: GoogleFonts.openSans(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'วันที่เลือก: ${formatDateThai(widget.field.selectedDate ?? DateTime.now())}',
                    style: GoogleFonts.openSans(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: SizedBox(
                        height: 350,
                        width: 350,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: GoogleMap(
                                onMapCreated: (controller) {
                                  setState(() {
                                    mapController = controller;
                                  });
                                },
                                mapType: MapType.hybrid,
                                initialCameraPosition: CameraPosition(
                                  target:
                                      getPolygonCenter(widget.field.polygons),
                                  zoom: 20,
                                ),
                                polygons: {
                                  Polygon(
                                    polygonId: const PolygonId('field_polygon'),
                                    points: widget.field.polygons,
                                    strokeWidth: 2,
                                    strokeColor: Colors.black,
                                    fillColor: Colors.green.withOpacity(0.3),
                                  ),
                                },
                              ),
                            ),
                            Positioned(
                              bottom: 20,
                              left: 20,
                              child: FloatingActionButton(
                                onPressed: () {
                                  if (mapController != null) {
                                    final center =
                                        getPolygonCenter(widget.field.polygons);
                                    final cameraUpdate =
                                        CameraUpdate.newLatLng(center);
                                    mapController!.animateCamera(cameraUpdate);
                                  }
                                },
                                tooltip: 'กลับไปยังศูนย์กลางแปลง',
                                child: const Icon(Icons.center_focus_strong),
                              ),
                            ),
                          ],
                        )),
                  ),
                  const SizedBox(height: 16),
                  if (widget.field.temperatureData.isEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ไม่พบข้อมูลอุณหภูมิ',
                          style: GoogleFonts.openSans(fontSize: 18),
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ข้อมูลอุณภูมิ',
                          style: GoogleFonts.openSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TemperatureScreen(
                                  temperatureData: widget.field.temperatureData,
                                  monthlyTemperatureData:
                                      widget.field.monthlyTemperatureData,
                                ),
                              ),
                            );
                          },
                          child: const Text("ดูข้อมูลอุณหภูมิ"),
                        ),
                      ],
                    )
                ],
              )));
    }
  }
}
