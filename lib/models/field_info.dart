import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class FieldInfo extends StatelessWidget {
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
  @override
  Widget build(BuildContext context) {
    if (field.polygons.isEmpty) {
      // Existing code...
    } else if (field.polygons.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          // Existing code...
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'แปลงเพาะปลูก: $fieldName',
                    style: GoogleFonts.openSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'พันธุ์ข้าว: $riceType',
                    style: GoogleFonts.openSans(fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    convertAreaToRaiNganWah(polygonArea),
                    style: GoogleFonts.openSans(fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'วันที่เลือก: ${field.selectedDate != null ? DateFormat('dd-MM-yyyy').format(field.selectedDate!) : "Not selected"}',
                    style: GoogleFonts.openSans(fontSize: 18),

                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  GoogleMap(
                    mapType: MapType.hybrid,
                    initialCameraPosition: CameraPosition(
                      target: polygons.first,
                      zoom: 19.5,
                    ),
                    polygons: {
                      Polygon(
                        polygonId: const PolygonId('field_polygon'),
                        points: polygons,
                        strokeWidth: 2,
                        strokeColor: Colors.black,
                        fillColor: Colors.green.withOpacity(0.3),
                      ),
                    },
                  ),
                ],
              ),
            ),
          ],
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
