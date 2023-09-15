import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:type21/models/temp_data_models.dart';
import 'package:type21/screens/main/field_screen/field_list.dart';
import 'package:type21/screens/main/field_screen/temp_screen.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

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

  String formatDateThai(DateTime? date) {
    if (date == null) return 'ไม่ได้เลือก';
    initializeDateFormatting('th_TH');
    final formatter = DateFormat.yMMMMEEEEd('th_TH');
    return formatter.format(date);
  }

  Future<void> loadTemperatureData() async {
    try {
      final dailyTempData = await FirebaseFirestore.instance
          .collection('fields')
          .doc(widget.documentID)
          .collection('temperatures')
          .orderBy('date', descending: true)
          .get();
      if (kDebugMode) {
        print('fetch data $dailyTempData');
      }

      final temperatureData = dailyTempData.docs.map((doc) {
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
        widget.field.temperatureData = temperatureData;
      }
    } catch (error) {
      if (kDebugMode) {
        print("Error loading temperature data: $error");
      }
    }
  }

  Future<void> loadMonthlyTemperatureData() async {
    try {
      final monthlyTempData = await FirebaseFirestore.instance
          .collection('fields')
          .doc(widget.documentID)
          .get();
      if (kDebugMode) {
        print('Monthly Temperature Data: $monthlyTempData');
      }

      final fieldData = monthlyTempData.data();
      final maxGdd = fieldData?['riceMaxGdd'];
      final forecastedHarvestDateTimestamp =
          fieldData?['forecastedHarvestDate'] as Timestamp?;
      if (forecastedHarvestDateTimestamp != null) {
        final forecastedHarvestDate = forecastedHarvestDateTimestamp.toDate();
        widget.field.forecastedHarvestDate = forecastedHarvestDate;
      }

      final monthlyTemperatureCollectionGroup = await FirebaseFirestore.instance
          .collection('fields')
          .doc(widget.documentID)
          .collection('temperatures_monthly')
          .where('gddSum', isGreaterThan: 0)
          .get();
      if (kDebugMode) {
        print('Fetched Data: $monthlyTemperatureCollectionGroup');
      }

      final monthlyTemperatureData =
          monthlyTemperatureCollectionGroup.docs.map((doc) {
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
        widget.field.monthlyTemperatureData = monthlyTemperatureData;
      }
    } catch (error) {
      if (kDebugMode) {
        print("Error loading monthly temperature data: $error");
      }
    }
  }

  Future<void> loadAccumulatedGddData() async {
    try {
      final fieldDoc = await FirebaseFirestore.instance
          .collection('fields')
          .doc(widget.documentID)
          .get();

      final fieldData = fieldDoc.data();
      final maxGdd = fieldData?['riceMaxGdd'];

      final accumulatedGddCollection = await fieldDoc.reference
          .collection('accumulated_gdd')
          .orderBy('date', descending: true)
          .get();
      if (kDebugMode) {
        print('Accumulated GDD Collection: $accumulatedGddCollection');
      }

      final accumulatedGddData = accumulatedGddCollection.docs.map((doc) {
        final data = doc.data();
        final accumulatedGdd = (data['accumulatedGdd']).toDouble();
        final date = (data['date']);
        final maxGddSub = (data['maxGdd']);
        return AccumulatedGddData(
          accumulatedGdd: accumulatedGdd,
          documentID: doc.id,
          date: date,
          maxGdd: maxGddSub ?? maxGdd,
        );
      }).toList();

      if (kDebugMode) {
        print('Accumulated Gdd is $accumulatedGddData');
      }

      if (accumulatedGddData.isNotEmpty) {
        widget.field.accumulatedGddData = accumulatedGddData;
        widget.field.maxGddSubcollection = maxGdd;
      } else if (accumulatedGddData.isEmpty) {
        if (kDebugMode) {
          print('Acccumulate Gdd data is empty');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print("Error loading accumulated GDD data: $error");
      }
    }
  }

  Widget _buildForecastedHarvestDate() {
    final forecastedHarvestDate = widget.field.forecastedHarvestDate;
    if (forecastedHarvestDate != null) {
      final formattedDate =
          DateFormat('dd MMMM yyyy', 'th_TH').format(forecastedHarvestDate);
      return Text(
        'วันคาดการ์ณวันเก็บเกี่ยวที่เหมาะสม: \n$formattedDate',
        style: GoogleFonts.openSans(fontSize: 18),
      );
    } else {
      return Text(
        'วันคาดการ์ณวันเก็บเกี่ยวที่เหมาะสม:\n ยังมีข้อมูลไม่เพียงพอ',
        style: GoogleFonts.openSans(fontSize: 18),
      );
    }
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      loadTemperatureData(),
      loadMonthlyTemperatureData(),
      loadAccumulatedGddData(),
    ]);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.field.polygons.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
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
            backgroundColor: Colors.blue,
          ),
          body: SingleChildScrollView(
              child: Padding(
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
                          'พันธุ์ข้าว: ${FieldUtils.getThaiRiceType(widget.field.riceType)}',
                          style: GoogleFonts.openSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          FieldUtils.convertAreaToRaiNganWah(
                              widget.field.polygonArea),
                          style: GoogleFonts.openSans(fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'วันที่เริ่มปลูก: ${formatDateThai(widget.field.selectedDate ?? DateTime.now())}',
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
                                        target: getPolygonCenter(
                                            widget.field.polygons),
                                        zoom: 20,
                                      ),
                                      polygons: {
                                        Polygon(
                                          polygonId:
                                              const PolygonId('field_polygon'),
                                          points: widget.field.polygons,
                                          strokeWidth: 2,
                                          strokeColor: Colors.black,
                                          fillColor:
                                              Colors.green.withOpacity(0.3),
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
                                          final center = getPolygonCenter(
                                              widget.field.polygons);
                                          final cameraUpdate =
                                              CameraUpdate.newLatLng(center);
                                          mapController!
                                              .animateCamera(cameraUpdate);
                                        }
                                      },
                                      tooltip: 'กลับไปยังศูนย์กลางแปลง',
                                      child:
                                          const Icon(Icons.center_focus_strong),
                                    ),
                                  ),
                                ],
                              )),
                        ),
                        const SizedBox(height: 8),
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
                                        temperatureData:
                                            widget.field.temperatureData,
                                        monthlyTemperatureData:
                                            widget.field.monthlyTemperatureData,
                                        accumulatedGddData:
                                            widget.field.accumulatedGddData,
                                        field: const [],
                                      ),
                                    ),
                                  );
                                },
                                child: const Text("ดูข้อมูลอุณหภูมิ"),
                              ),
                            ],
                          ),
                        const SizedBox(height: 10),
                        _buildForecastedHarvestDate(),
                      ]))));
    }
  }
}
