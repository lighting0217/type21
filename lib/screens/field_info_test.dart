import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class FieldInfoTest extends StatefulWidget {
  const FieldInfoTest({
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
  State<FieldInfoTest> createState() => _FieldInfoTestState();
}

class _FieldInfoTestState extends State<FieldInfoTest> {
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
    final formattedArea = NumberFormat('#,##0.00', 'th_TH').format(polygonArea);

    String result = 'พื้นที่เพาะปลูก \n';
    result += '$formattedArea ตารางเมตร\n';
    result += '${rai.toInt()} ไร่ ';
    result += '${ngan.toInt()} งาน ';
    result += '${NumberFormat('#,##0.00', 'th_TH').format(squareWah)} ตารางวา';

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
    if (date == null) return 'ไม่ได้เลือก';

    initializeDateFormatting('th_TH'); // Initialize Thai date format
    final formatter = DateFormat.yMMMMEEEEd('th_TH');
    return formatter.format(date);
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
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              ..._buildTemperatureList(), // Display temperature data
            ],
          ),
        ),
      );
    }
  }

  List<Widget> _buildTemperatureList() {
    return [
      const SizedBox(height: 16),
      const Text(
        'Temperature Data:',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      FutureBuilder<Map<DateTime, Map<String, double>>>(
        future: fetchTemperatureData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return Column(
              children: [
                ...snapshot.data!.entries.map((entry) {
                  final date = entry.key;
                  final temperatureData = entry.value;
                  final minTemp = temperatureData['minTemp'];
                  final maxTemp = temperatureData['maxTemp'];

                  return Column(
                    children: [
                      ListTile(
                        title: Text(
                          DateFormat('DD ,MMMM, YYYY', 'th_TH').format(date),
                          style: GoogleFonts.openSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Min Temp: ${minTemp!.toStringAsFixed(2)}°C, Max Temp: ${maxTemp!.toStringAsFixed(2)}°C',
                          style: GoogleFonts.openSans(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: const FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              // Line representing the minTemp
                              LineChartBarData(
                                spots: [
                                  FlSpot(0, minTemp),
                                  FlSpot(1, minTemp), // To create a straight horizontal line
                                ],
                                isCurved: false,
                                color: Colors.blue.withOpacity(0.4),
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(show: false),
                              ),
                              // Line representing the maxTemp
                              LineChartBarData(
                                spots: [
                                  FlSpot(0, maxTemp),
                                  FlSpot(1, maxTemp), // To create a straight horizontal line
                                ],
                                isCurved: false,
                                color: Colors.orange.withOpacity(0.4),
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(show: false),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ],
            );
          } else {
            return const Text('Temperature data not available.');
          }
        },
      ),
    ];
  }

  // Helper function to fetch temperature data from Firestore
  Future<Map<DateTime, Map<String, double>>> fetchTemperatureData() async {
    final firestore = FirebaseFirestore.instance;
    final temperaturesSnapshot = await firestore
        .collection('fields')
        .doc(widget.field.fieldName)
        .collection('temperatures')
        .doc('daily')
        .get();

    if (temperaturesSnapshot.exists) {
      final data = temperaturesSnapshot.data();
      final temperatureData = <DateTime, Map<String, double>>{};

      data?.forEach((key, value) {
        // 'key' represents the date in String format, and 'value' contains minTemp and maxTemp
        final date = DateTime.parse(key);
        final minTemp = value['minTemp'] as double?;
        final maxTemp = value['maxTemp'] as double?;

        if (minTemp != null && maxTemp != null) {
          temperatureData[date] = {'minTemp': minTemp, 'maxTemp': maxTemp};
        }
      });

      return temperatureData;
    } else {
      return {}; // Return an empty map if temperature data not found
    }
  }

  Future<List<Forecast>> fetchTemperatureForecastData() async {
    final firestore = FirebaseFirestore.instance;
    final forecastSnapshot = await firestore
        .collection('fields')
        .doc(widget.field.fieldName)
        .collection('temperatures')
        .doc('forecast') // Assuming forecast data is stored under 'forecast' collection
        .get();

    if (forecastSnapshot.exists) {
      final data = forecastSnapshot.data();
      final forecastData = <Forecast>[];

      data?.forEach((key, value) {
        final date = DateTime.parse(key);
        final minTemp = value['minTemp'] as double?;
        final maxTemp = value['maxTemp'] as double?;

        if (minTemp != null && maxTemp != null) {
          forecastData.add(Forecast(date: date, minTemp: minTemp, maxTemp: maxTemp));
        }
      });

      return forecastData;
    } else {
      return []; // Return an empty list if forecast data not found
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

class Forecast {
  final DateTime date;
  final double minTemp;
  final double maxTemp;

  Forecast({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
  });
}
