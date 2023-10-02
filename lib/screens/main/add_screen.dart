/// FILEPATH: c:\my_project\type21\lib\screens\main\add_screen.dart
/// This file contains the implementation of the AddScreen widget, which is responsible for adding a new field to the Firestore database.
/// The widget takes in various parameters such as the lengths, polygons, polygonArea, totalDistance, monthlyTemperatureData, and selectedDate.
/// The widget also contains helper methods such as getRiceMaxGdd, convertAreaToRaiNganWah, _createPolygons, _createMarkers, fetchForecastedHarvestDate, and _submitForm.
/// The widget uses various packages such as cloud_firestore, firebase_auth, fluttertoast, form_field_validator, google_maps_flutter, and intl.
// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../../models/temp_data_models.dart';
import 'field_screen/field_list.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class AddScreen extends StatefulWidget {
  const AddScreen({
    Key? key,
    required this.totalDistance,
    required this.polygons,
    required this.polygonArea,
    required this.lengths,
    required double polygonAreaMeters,
    required this.monthlyTemperatureData,
    required this.selectedDate,
  }) : super(key: key);

  final List<double> lengths;
  final double polygonArea;
  final List<LatLng> polygons;
  final double totalDistance;
  final List<MonthlyTemperatureData> monthlyTemperatureData;
  final DateTime selectedDate;

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  String? selectedValue;
  DateTime? forecastedHarvestDate;
  DateTime? selectedDate;

  final TextEditingController _fieldNameController = TextEditingController();
  final Map<String, String> _riceTypeKeys = {
    'ข้าวหอมมะลิ': 'KDML105',
    'ข้าวกข.6': 'RD6',
  };

  double getRiceMaxGdd(String riceType) {
    switch (riceType) {
      case 'KDML105':
        return 2422.09;
      case 'RD6':
        return 2290.1;
      default:
        return 0;
    }
  }

  String convertAreaToRaiNganWah(double area) {
    final double rai = (area / 1600).floorToDouble();
    final double ngan = ((area - (rai * 1600)) / 400).floorToDouble();
    final double squareWah = (area / 4) - (rai * 400) - (ngan * 100);

    String result = 'พื้นที่แปลง: ${area.toStringAsFixed(2)} ตารางเมตร\n';
    result += '${rai.toInt()} ไร่ ';
    result += '${ngan.toInt()} งาน ';
    result += '${squareWah.toStringAsFixed(2)} ตารางวา';

    return result;
  }

  Set<Polygon> _createPolygons() {
    final List<LatLng> polygonLatLngs = widget.polygons;
    final Set<Polygon> polygonSet = {};
    if (polygonLatLngs.length > 2) {
      final Polygon polygon = Polygon(
        polygonId: const PolygonId('field_polygon'),
        points: polygonLatLngs,
        strokeWidth: 2,
        strokeColor: Colors.black,
        fillColor: Colors.greenAccent.withOpacity(0.3),
      );
      polygonSet.add(polygon);
    }
    return polygonSet;
  }

  List<Marker> _createMarkers() {
    final List<LatLng> polygonLatLngs = widget.polygons;
    final List<Marker> markerList = [];

    for (int i = 0; i < polygonLatLngs.length; i++) {
      final LatLng polygonPoint = polygonLatLngs[i];
      final Marker marker = Marker(
        markerId: MarkerId('point_$i'),
        position: polygonPoint,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
      markerList.add(marker);
    }

    return markerList;
  }

  Future<void> fetchForecastedHarvestDate() async {
    try {
      final currentUserUid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final querySnapshot = await FirebaseFirestore.instance
          .collection('fields')
          .where('createdBy', isEqualTo: currentUserUid)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        final fieldData = querySnapshot.docs.first.data();
        final date = fieldData['forecastedHarvestDate'] as Timestamp?;
        if (date != null) {
          setState(() {
            forecastedHarvestDate = date.toDate();
          });
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching forecasted harvest date: $error');
      }
      _showToast('Error fetching forecasted harvest date');
    }
  }

  void _submitForm() async {
    if (_fieldNameController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please enter a field name.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }
    final fieldName = _fieldNameController.text;
    final riceType = _riceTypeKeys[selectedValue ?? ''] ?? '';
    final polygonArea = widget.polygonArea;
    final totalDistance = widget.totalDistance;
    final polygons = widget.polygons;
    final riceMaxGdd = getRiceMaxGdd(riceType);
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final selectedDate = widget.selectedDate;
    await _addNewFieldToFirestore(
      fieldName,
      riceType,
      polygonArea,
      totalDistance,
      polygons,
      currentUserUid,
      riceMaxGdd,
      selectedDate,
    );

    final newField = Field(
      fieldName: fieldName,
      riceType: riceType,
      polygonArea: polygonArea,
      totalDistance: totalDistance,
      polygons: polygons,
      selectedDate: selectedDate,
      createdBy: currentUserUid,
      temperatureData: [],
      id: '',
      monthlyTemperatureData: [],
      accumulatedGddData: [],
      riceMaxGdd: riceMaxGdd,
    );
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => FieldList(
          fields: [newField],
          monthlyTemperatureData: const [],
        ),
      ),
    );
  }

  Future<DocumentReference> _addNewFieldToFirestore(
    String fieldName,
    String riceType,
    double polygonArea,
    double totalDistance,
    List<LatLng> polygons,
    String createdBy,
    double riceMaxGdd,
    DateTime selectedDate,
  ) async {
    try {
      if (kDebugMode) {
        print(
            'field Name: $fieldName\nrice type: $riceType\npolygon area:$polygonArea\ntotal distance:$totalDistance\nlat,lan:$polygons');
      }
      double riceMaxGdd = 0;
      if (riceType == 'KDML105') {
        riceMaxGdd = 2720.8;
      } else if (riceType == 'RD6') {
        riceMaxGdd = 2676.664;
      }

      return await _firestore.collection('fields').add({
        'fieldName': fieldName,
        'riceType': riceType,
        'riceMaxGdd': riceMaxGdd,
        'polygonArea': polygonArea,
        'totalDistance': totalDistance,
        'selectedDate': selectedDate,
        'polygons': polygons
            .map((latLng) => {
                  'latitude': latLng.latitude,
                  'longitude': latLng.longitude,
                })
            .toList(),
        'createdBy': createdBy,
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error adding field to Firestore: $error');
      }
      _showToast('Error adding field to Firestore');
      throw Exception('Failed to add field to Firestore');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchForecastedHarvestDate();
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  LatLng _calculatePolygonCenter(List<LatLng> polygonLatLngs) {
    final double centerLat = polygonLatLngs
            .map((latLng) => latLng.latitude)
            .reduce((a, b) => a + b) /
        polygonLatLngs.length;
    final double centerLng = polygonLatLngs
            .map((latLng) => latLng.longitude)
            .reduce((a, b) => a + b) /
        polygonLatLngs.length;

    return LatLng(centerLat, centerLng);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime(2023),
        lastDate: DateTime.now().add(const Duration(days: 365)));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final LatLng center = _calculatePolygonCenter(widget.polygons);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'เพิ่มแปลง',
          style:
              TextStyle(fontFamily: 'GoogleSans', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(9.0),
        child: ListView(
          children: [
            const Text(
              'ข้อมูลแปลง',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _fieldNameController,
              decoration: const InputDecoration(
                labelText: 'ชื่อแปลง',
              ),
              validator: RequiredValidator(errorText: 'กรุณาใส่ชื่อแปลง'),
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedValue,
              items: _riceTypeKeys.keys
                  .map(
                    (value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => selectedValue = value),
              decoration: const InputDecoration(
                labelText: 'ชนิดพันธุ์ข้าว',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    controller: TextEditingController(
                      text: selectedDate != null
                          ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                          : '',
                    ),
                    decoration: const InputDecoration(
                      labelText: 'วันที่เลือก',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () {
                    _selectDate(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'ข้อมูลตำแหน่งแปลง',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'ขนาดแปลง:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              convertAreaToRaiNganWah(widget.polygonArea),
              style: const TextStyle(fontSize: 16),
            ),
            /*const SizedBox(height: 16),
            const Text(
              'Total Distance:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${widget.totalDistance.toStringAsFixed(2)} meters',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Polygon Center:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Latitude: ${center.latitude}, Longitude: ${center.longitude}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),*/
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                  height: 300,
                  width: 300,
                  child: GoogleMap(
                    mapType: MapType.hybrid,
                    initialCameraPosition: CameraPosition(
                      target: center,
                      zoom: 24,
                    ),
                    markers: Set<Marker>.from(_createMarkers()),
                    polygons: _createPolygons(),
                  )),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('บันทึก'),
            ),
          ],
        ),
      ),
    );
  }
}
