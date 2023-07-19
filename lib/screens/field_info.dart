import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

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
    if (widget.field.polygons.isEmpty) {
      // Existing code...
    } else if (widget.field.polygons.isNotEmpty) {
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox();
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
