import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class FieldInfo extends StatefulWidget {
  const FieldInfo({
    Key? key,
    required this.field,
    required this.fieldName,
    required this.riceType,
    required this.polygonArea,
    required this.polygons,
    this.selectedDate,
  }) : super(key: key);

  final Field field;
  final String? fieldName;
  final String? riceType;
  final double polygonArea;
  final List<LatLng> polygons;
  final DateTime? selectedDate;

  @override
  State<FieldInfo> createState() => _FieldInfoState();
}

class _FieldInfoState extends State<FieldInfo> {
  GoogleMapController? mapController; // Declare the GoogleMapController
  LatLng getPolygonCenter(List<LatLng> points) {
    double latSum = 0.0;
    double lngSum = 0.0;

    for (final point in points) {
      latSum += point.latitude;
      lngSum += point.longitude;
    }

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
    // Map rice types to their Thai labels
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

    initializeDateFormatting('th_TH'); // Initialize Thai date format
    final formatter = DateFormat.yMMMMEEEEd('th_TH');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.field.polygons.isEmpty) {} else if (widget.field.polygons.isNotEmpty) {
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
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                  'ชื่อแปลง: ${widget.fieldName ?? "N/A"}',
                  style: GoogleFonts.openSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'พันธุ์ข้าว: ${getThaiRiceType(widget.riceType)}',
                  style: GoogleFonts.openSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  convertAreaToRaiNganWah(widget.polygonArea),
                  style: GoogleFonts.openSans(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'วันที่เลือก: ${formatDateThai(widget.field.selectedDate)}',
                  style: GoogleFonts.openSans(fontSize: 18),
                ),
                const SizedBox(height: 16),
                Center(
                  child: SizedBox(
                    height: 400,
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
                              target: getPolygonCenter(widget.polygons),
                              zoom: 20,
                            ),
                            polygons: {
                              Polygon(
                                polygonId: const PolygonId('field_polygon'),
                                points: widget.polygons,
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
                                final center = getPolygonCenter(widget.polygons);
                                final cameraUpdate = CameraUpdate.newLatLng(center);
                                mapController!.animateCamera(cameraUpdate);
                              }
                            },
                            tooltip: 'กลับไปยังศูนย์กลางแปลง',
                            child: const Icon(Icons.center_focus_strong),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                  SizedBox(
                    width: 350,
                    height: 400,
                    child: FutureBuilder<List<List<FlSpot>>>(
                      future: fetchTemperatureData(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          // Handle the error here, e.g., display an error message
                          if (kDebugMode) {
                            print('Error fetching temperature data: ${snapshot.error}');
                          }
                          return const Center(child: Text('Temperature data not available. Please check your internet connection and try again.'));
                        } else {
                          final List<List<FlSpot>> temperatureData = snapshot.data!;
                          final List<FlSpot> minTemperatureData = temperatureData[0];
                          final List<FlSpot> maxTemperatureData = temperatureData[1];

                          if (minTemperatureData.isEmpty || maxTemperatureData.isEmpty) {
                            // Handle the case when the data is empty
                            return const Center(child: Text('Temperature data not available.'));
                          }

                          // Build the LineChart here using minTemperatureData and maxTemperatureData
                          return LineChart(
                            LineChartData(
                              lineBarsData: [
                                LineChartBarData(
                                  spots: minTemperatureData,
                                  isCurved: true,
                                  color: Colors.green,
                                  dotData: const FlDotData(show: false),
                                  belowBarData: BarAreaData(show: false),
                                ),
                                LineChartBarData(
                                  spots: maxTemperatureData,
                                  isCurved: true,
                                  color: Colors.red,
                                  dotData: const FlDotData(show: false),
                                  belowBarData: BarAreaData(show: false),
                                ),
                              ],
                              minX: minTemperatureData.first.x, // Set the min x-axis value
                              maxX: minTemperatureData.last.x, // Set the max x-axis value
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
      );
    }
    return const SizedBox();
  }
  Future<List<List<FlSpot>>> fetchTemperatureData() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final temperaturesSnapshot = await firestore
          .collection('fields')
          .doc(widget.field.fieldName)
          .collection('temperatures')
          .doc('daily')
          .get();

      if (temperaturesSnapshot.exists) {
        final data = temperaturesSnapshot.data() as Map<String, dynamic>;
        final List<FlSpot> minTemperatureData = [];
        final List<FlSpot> maxTemperatureData = [];

        // Convert each temperature entry to FlSpot and add to the respective lists
        data.forEach((key, value) {
          final date = DateFormat('d/M/yyyy').parse(key);
          final minTemp = value['minTemp'] as double?;
          final maxTemp = value['maxTemp'] as double?;

          if (minTemp != null && maxTemp != null) {
            minTemperatureData.add(FlSpot(date.day.toDouble(), minTemp));
            maxTemperatureData.add(FlSpot(date.day.toDouble(), maxTemp));
          }
        });

        // Sort the temperature data by date (in case it's not already sorted)
        minTemperatureData.sort((a, b) => a.x.compareTo(b.x));
        maxTemperatureData.sort((a, b) => a.x.compareTo(b.x));

        return [minTemperatureData, maxTemperatureData];
      } else {
        return [[], []]; // Return empty lists if temperature data not found
      }
    } catch (e) {
      // Handle any potential exceptions or errors during data retrieval
      if (kDebugMode) {
        print('Error fetching temperature data: $e');
      }
      return [[], []]; // Return empty lists in case of an error
    }
  }

}

  class Field {
  Field({
  required this.fieldName,
  required this.riceType,
  required this.polygonArea,
  required this.totalDistance,
  required this.polygons,
  this.selectedDate,
  });

  final String fieldName;
  final double polygonArea;
  final List<LatLng> polygons;
  final String riceType;
  final double totalDistance;
  final DateTime? selectedDate;
  }
