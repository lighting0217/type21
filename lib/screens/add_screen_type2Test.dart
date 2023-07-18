
// Firestore instance
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:type21/models/field_info.dart';
import 'package:type21/screens/field_list.dart';


final FirebaseFirestore _firestore = FirebaseFirestore.instance;
CollectionReference fields = _firestore.collection('fields');
class AddScreenType2Test extends StatefulWidget {
  const AddScreenType2Test({
    Key? key,
    required this.totalDistance,
    required this.polygons,
    required this.polygonArea,
    required this.lengths,
    required double polygonAreaMeters,
  }) : super(key: key);

  final List<double> lengths;
  final double polygonArea;
  final List<LatLng> polygons;
  final double totalDistance;
  @override
  State<AddScreenType2Test> createState() => _AddScreenType2State();
}

class _AddScreenType2State extends State<AddScreenType2Test> {
  String? selectedValue;
  final TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate;
  final TextEditingController _fieldNameController = TextEditingController();
  final Map<String, String> _riceTypeKeys = {
    'ข้าวหอมมะลิ': 'KDML105',
    'ข้าวกข.6': 'RD6',
  };
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd-MM-yyyy').format(_selectedDate!);
      });
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

  // Create polygons based on the provided coordinates
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

  // Create markers based on the provided coordinates
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

  // Submit the form data to Firestore
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

    // Print the field data to the debug console
    if (kDebugMode) {
      print('Field Name: $fieldName');
      print('Rice Type: $riceType');
      print('Polygon Area: $polygonArea');
      print('Total Distance: $totalDistance');
      print('Polygons: $polygons');
    }
    try {
      _addNewFieldToFirestore(
          fieldName,
          riceType,
          polygonArea,
          totalDistance,
        polygons,
        _selectedDate!, // Pass the selected date to _addNewFieldToFirestore

      );
    } catch (e) {
      if (kDebugMode) {
        print('Error saving field data: $e');
      }
      return;
    }

    final field = Field(
      fieldName: fieldName,
      riceType: riceType,
      polygonArea: polygonArea,
      totalDistance: totalDistance,
      polygons: polygons,
    );

    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FieldList(fields: [field]),
      ),
    );
  }
  Future<void> _addNewFieldToFirestore(
      String fieldName,
      String riceType,
      double polygonArea,
      double totalDistance,
      List<LatLng> polygons, DateTime selectedDate) async {
    if (kDebugMode) {
      print('field Name: $fieldName\nrice type: $riceType\npolygon area:$polygonArea\ntotal distance:$totalDistance\nlat,lan:$polygons');
    }
    await _firestore.collection('fields').add(
        {
        'fieldName': fieldName,
        'riceType': riceType,
        'polygonArea': polygonArea,
        'totalDistance': totalDistance,
        'polygons': polygons
            .map((latLng) => {
          'latitude': latLng.latitude,
          'longitude': latLng.longitude,
        }).toList(),
          'selectedDate': _selectedDate != null ? Timestamp.fromDate(_selectedDate!) : null,
      }).then((value) => print("Field Added"))
        .catchError((error) => print("Failed to add field: $error")

    );
  }
  @override
  Widget build(BuildContext context) {
    // Calculate the center of the polygons
    final List<LatLng> polygonLatLngs = widget.polygons;
    final double centerLat =
        polygonLatLngs.map((latLng) => latLng.latitude).reduce((a, b) => a + b) /
            polygonLatLngs.length;
    final double centerLng =
        polygonLatLngs.map((latLng) => latLng.longitude).reduce((a, b) => a + b) /
            polygonLatLngs.length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Field'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(9.0),
        child: ListView(
          children: [
            const Text(
              'Field Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _fieldNameController,
              decoration: const InputDecoration(
                labelText: 'Field Name',
              ),
              validator: RequiredValidator(errorText: 'Please enter a field name'),
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
              ).toList(),
              onChanged: (value) => setState(() => selectedValue = value),
              decoration: const InputDecoration(
                labelText: 'Rice Type',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Select Date',
                suffixIcon: Icon(Icons.calendar_month),
              ),
              onTap: _selectDate, // Use _selectDate function to pick a date
              readOnly: true, // Prevents manual editing
              validator: RequiredValidator(errorText: 'Please select a date'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Polygon Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Polygon Area:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              convertAreaToRaiNganWah(widget.polygonArea),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Total Distance:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${widget.totalDistance.toStringAsFixed(2)} meters',
              style: const TextStyle(fontSize: 16),
            ),/*
            const SizedBox(height: 16),
            const Text(
              'Polygon Center:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Latitude: ${centerLat.toStringAsFixed(6)}, Longitude: ${centerLng.toStringAsFixed(6)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),*/
            const Divider(),
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                height: 250,
                width: 250,
                  child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(centerLat, centerLng),
                    zoom: 17,
                  ),
                  markers: Set<Marker>.from(_createMarkers()),
                  polygons: _createPolygons(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}