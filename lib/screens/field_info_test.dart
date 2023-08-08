import 'package:cloud_firestore/cloud_firestore.dart';
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
  State<FieldInfoTest> createState() => _FieldInfoTestTestTestState();
}

class _FieldInfoTestTestTestState extends State<FieldInfoTest> {
  GoogleMapController? mapController; // Declare the GoogleMapController

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

  double getMinTemp(Map<DateTime, Map<String, double>> temperatureData) {
    double minTemp = double.infinity;

    for (var data in temperatureData.values) {
      final double currentMinTemp = data['minTemp'] ?? double.infinity;
      if (currentMinTemp < minTemp) {
        minTemp = currentMinTemp;
      }
    }

    return minTemp;
  }

  double getMaxTemp(Map<DateTime, Map<String, double>> temperatureData) {
    double maxTemp = double.negativeInfinity;

    for (var data in temperatureData.values) {
      final double currentMaxTemp = data['maxTemp'] ?? double.negativeInfinity;
      if (currentMaxTemp > maxTemp) {
        maxTemp = currentMaxTemp;
      }
    }

    return maxTemp;
  }

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
                              final cameraUpdate =
                                  CameraUpdate.newLatLng(center);
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
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('fields')
            .doc(widget.field.fieldName)
            .collection('temperatures')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            final temperatureDocs = snapshot.data!.docs;
            return ListView.builder(
              shrinkWrap: true,
              itemCount: temperatureDocs.length,
              itemBuilder: (context, index) {
                final temperatureData = temperatureDocs[index].data();
                final date = temperatureDocs[index].id;
                final maxTemp = temperatureData['maxTemp'] as double?;
                final minTemp = temperatureData['minTemp'] as double?;
                if (maxTemp != null && minTemp != null) {
                  return ListTile(
                    title: Text(
                      'Date: ${formatDateThai(DateTime.parse(date))}',
                      style: GoogleFonts.openSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Min: ${minTemp.toStringAsFixed(2)} °C, Max: ${maxTemp.toStringAsFixed(2)} °C',
                      style: GoogleFonts.openSans(fontSize: 16),
                    ),
                  );
                } else {
                  return Container();
                }
              },
            );
          } else {
            return const Text('Temperature data not available.');
          }
        },
      ),
    ];
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
/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class Field {
  String? id;
  String fieldName;
  double polygonArea;
  List<LatLng> polygons;
  String riceType;
  DateTime? selectedDate;
  double totalDistance;
  String createdBy;

  Field({
    required this.id,
    required this.fieldName,
    required this.polygonArea,
    required this.polygons,
    required this.riceType,
    required this.selectedDate,
    required this.totalDistance,
    required this.createdBy,
  });
}

class TemperatureData {
  final String date;
  final double minTemp;
  final double maxTemp;

  TemperatureData({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
  });
}

class FieldInfoTest extends StatefulWidget {
  const FieldInfoTest({
    Key? key,
    required this.field,
    required String fieldName,
    required String riceType,
    required List<LatLng> polygons,
    required double polygonArea,
  }) : super(key: key);

  final Field field;

  @override
  State<FieldInfoTest> createState() => _FieldInfoTestState();
}

class _FieldInfoTestState extends State<FieldInfoTest> {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
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
    initializeDateFormatting('th_TH'); // Initialize Thai date format
    final formatter = DateFormat.yMMMMEEEEd('th_TH');
    return formatter.format(date);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
              'วันที่เลือก: ${formatDateThai(widget.field.selectedDate)}',
              style: GoogleFonts.openSans(fontSize: 18),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 400,
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: GoogleMap(
                        onMapCreated: (controller) {
                          setState(() {
                            mapController = controller;
                          });
                        },
                        mapType: MapType.hybrid,
                        initialCameraPosition: CameraPosition(
                          target: getPolygonCenter(widget.field.polygons),
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
                  ),
                  const SizedBox(height: 10),
                  Positioned(
                    left: 20,
                    top: 20,
                    child: FloatingActionButton(
                      onPressed: () {
                        if (mapController != null) {
                          final center =
                              getPolygonCenter(widget.field.polygons);
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
            const SizedBox(height: 10),
            Column(
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: firestore
                      .collection('fields')
                      .doc(widget.field.id)
                      .collection('temperatures')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Something went wrong ${snapshot.error}');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text("Loading");
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final temperatureDocs = snapshot.data!.docs;
                    final temperatureData = temperatureDocs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return TemperatureData(
                        date: data['date'],
                        minTemp: data['minTemp'],
                        maxTemp: data['maxTemp'],
                      );
                    }).toList();

                    return Column(
                      children: temperatureData.map((data) {
                        return ListTile(
                          title: Text(
                            'Min Temp: ${data.minTemp} \nMax Temp: ${data.maxTemp}',
                          ),
                          subtitle: Text('Date: ${data.date}'),
                        );
                      }).toList(),
                    );
                  },
                )

              ],
            ),
          ]),
        )));
  }
}

* */
