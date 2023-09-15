import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../models/temp_data_models.dart';
import '../select_screen.dart';
import 'field_info.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;

class FieldUtils {
  static String convertAreaToRaiNganWah(double polygonArea) {
    final double rai = (polygonArea / 1600).floorToDouble();
    final double ngan = ((polygonArea - (rai * 1600)) / 400).floorToDouble();
    final double squareWah = (polygonArea / 4) - (rai * 400) - (ngan * 100);

    String result = 'พื้นที่เพาะปลูก \n';
    result += '${rai.toInt()} ไร่ ';
    result += '${ngan.toInt()} งาน ';
    result += '${squareWah.toStringAsFixed(2)} ตารางวา';
    return result;
  }

  static String getThaiRiceType(String? riceType) {
    switch (riceType) {
      case 'KDML105':
        return 'ข้าวหอมมะลิ';
      case 'RD6':
        return 'ข้าวกข.6';
      default:
        return riceType ?? 'N/A';
    }
  }
}

class FieldList extends StatefulWidget {
  const FieldList({
    Key? key,
    required this.fields,
    required this.monthlyTemperatureData,
  }) : super(key: key);

  final List<Field> fields;
  final List<MonthlyTemperatureData> monthlyTemperatureData;

  @override
  State<FieldList> createState() => _FieldListState();
}

class _FieldListState extends State<FieldList> {
  late final String currentUserUid = _auth.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'รายชื่อแปลง',
          style:
              TextStyle(fontFamily: 'GoogleSans', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_auth.currentUser != null) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const SelectScreen(locationList: []),
                ),
              );
            }
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('fields').snapshots(),
        builder: _buildFieldStream,
      ),
    );
  }

  Widget _buildFieldStream(
      BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    if (!snapshot.hasData) {
      if (kDebugMode) {
        print('Snapshot has no data.');
        print('Snapshot data: ${snapshot.data}');
        print('Snapshot error: ${snapshot.error}');
      }
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (snapshot.hasError) {
      if (kDebugMode) {
        print('Snapshot has an error: ${snapshot.error}');
      }
      return Center(
        child: Text('Snapshot error: ${snapshot.error}'),
      );
    }

    final fieldList = snapshot.data!.docs
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['createdBy'] == currentUserUid) {
            return Field(
              id: doc.id,
              fieldName: data['fieldName'],
              riceType: data['riceType'],
              polygonArea: data['polygonArea'].toDouble(),
              totalDistance: data['totalDistance'].toDouble(),
              polygons: (data['polygons'] as List<dynamic>).map((point) {
                return LatLng(
                  point['latitude'].toDouble(),
                  point['longitude'].toDouble(),
                );
              }).toList(),
              selectedDate: data['selectedDate'] != null
                  ? (data['selectedDate'] as Timestamp).toDate()
                  : null,
              createdBy: data['createdBy'] ?? '',
              temperatureData: [],
              monthlyTemperatureData: [],
              accumulatedGddData: [],
              riceMaxGdd: data['riceMaxGdd'] ?? 0.0,
            );
          } else {
            return null;
          }
        })
        .whereType<Field>()
        .toList();
    if (kDebugMode) {
      print('Fetched ${fieldList.length} fields.');
      for (var field in fieldList) {
        print(
            'Field Name: ${field.fieldName}, Rice Type: ${field.riceType}, Area: ${field.polygonArea}');
      }
    }
    if (_auth.currentUser != null) {
      if (kDebugMode) {
        print("User Authenticated: true");
      }
      return _buildFieldList(fieldList);
    } else {
      return Container();
    }
  }

  Widget _buildFieldList(List<Field> fieldList) {
    final userFieldList =
        fieldList.where((field) => field.createdBy == currentUserUid).toList();

    if (userFieldList.isEmpty) {
      return const Center(
        child: Text('ยังไม่ได้สร้างแปลงเพาะปลูก.'),
      );
    }
    return ListView.builder(
      itemCount: userFieldList.length,
      itemBuilder: (context, index) {
        final field = userFieldList[index];
        final doc = fieldList[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8.0),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FieldInfo(
                    field: field,
                    documentID: doc.id,
                    fieldName: field.fieldName,
                    polygonArea: field.polygonArea,
                    riceType: field.riceType,
                    polygons: field.polygons,
                    selectedDate: field.selectedDate,
                  ),
                ),
              );
            },
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              title: Text(
                field.fieldName,
                style: GoogleFonts.openSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'พันธุ์ข้าว: ${FieldUtils.getThaiRiceType(field.riceType)}',
                    style: GoogleFonts.openSans(
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    FieldUtils.convertAreaToRaiNganWah(field.polygonArea),
                    style: GoogleFonts.openSans(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
