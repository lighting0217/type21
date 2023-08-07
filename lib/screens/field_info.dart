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

  // Add this factory constructor
  factory Field.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final List<Map<String, dynamic>> polygonData =
        List<Map<String, dynamic>>.from(data['polygons']);
    final polygonsList = polygonData.map((point) {
      return LatLng(point['latitude'], point['longitude']);
    }).toList();

    return Field(
      id: doc.id,
      fieldName: data['fieldName'],
      polygonArea: data['polygonArea'],
      polygons: polygonsList,
      riceType: data['riceType'],
      selectedDate: (data['selectedDate'] as Timestamp)?.toDate(),
      totalDistance: data['totalDistance'],
      createdBy: data['createdBy'],
    );
  }
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

  factory TemperatureData.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TemperatureData(
      date: doc.id,
      minTemp: data['minTemp'],
      maxTemp: data['maxTemp'],
    );
  }
}

class FieldInfo extends StatefulWidget {
  const FieldInfo({
    Key? key,
    required this.field,
    required String fieldName,
    required String riceType,
    required List<LatLng> polygons,
    required double polygonArea,
  }) : super(key: key);

  final Field field;

  @override
  State<FieldInfo> createState() => _FieldInfoState();
}

class _FieldInfoState extends State<FieldInfo> {
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
                    final temperatureData = temperatureDocs
                        .map((doc) => TemperatureData.fromSnapshot(doc))
                        .toList();

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
