import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:type21/screens/select_screen.dart';

import 'field_info.dart';

class FieldList extends StatefulWidget {
  const FieldList({Key? key, required this.fields}) : super(key: key);

  final List<Field> fields;

  @override
  State<FieldList> createState() => _FieldListState();
}

class _FieldListState extends State<FieldList> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late final String currentUserUid = _auth.currentUser?.uid ?? '';

  Widget _buildFieldList(List<Field> fieldList) {
    final userFieldList =
        fieldList.where((field) => field.createdBy == currentUserUid).toList();

    if (userFieldList.isEmpty) {
      return const Center(
        child: Text('You haven\'t created any fields yet.'),
      );
    }

    return ListView.builder(
      itemCount: userFieldList.length,
      itemBuilder: (context, index) {
        final field = userFieldList[index];
        return ListTile(
          title: Text(
            field.fieldName,
            style: GoogleFonts.openSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text('Rice Type: ${field.riceType}'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FieldInfo(
                  field: field,
                  fieldName: field.fieldName,
                  polygonArea: field.polygonArea,
                  riceType: field.riceType,
                  polygons: field.polygons, // Pass the Field object
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Field List',
          style:
              TextStyle(fontFamily: 'GoogleSans', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue, // Change app bar color
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
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (kDebugMode) {
              print('\n${snapshot.data}\n ${snapshot.error}');
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Snapshot error: ${snapshot.error}'),
            );
          }

          final fieldList = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Field(
              fieldName: data['fieldName'],
              riceType: data['riceType'],
              polygonArea: data['polygonArea'].toDouble(),
              totalDistance: data['totalDistance'].toDouble(),
              polygons: (data['polygons'] as List<dynamic>).map((point) {
                return LatLng(point['latitude'].toDouble(),
                    point['longitude'].toDouble());
              }).toList(),
              selectedDate: data['selectedDate'] != null
                  ? (data['selectedDate'] as Timestamp).toDate()
                  : null,
              createdBy: data['createdBy'] ?? '',
            );
          }).toList();

          if (_auth.currentUser != null) {
            if (kDebugMode) {
              print("User Authenticated: true");
            }
            return _buildFieldList(fieldList);
          } else {
            return Container(); // This case is already handled in the AppBar's onPressed logic
          }
        },
      ),
    );
  }
}
