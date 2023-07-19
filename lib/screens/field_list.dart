import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:type21/screens/select_screen.dart';

import 'field_info.dart';

class FieldList extends StatelessWidget {
  const FieldList({Key? key, required this.fields}) : super(key: key);

  final List<Field> fields;

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Field List'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const SelectScreen(locationList: []),
              ),
            );
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('fields').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final List<Field> fieldList = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Field(
              fieldName: data['fieldName'],
              riceType: data['riceType'],
              polygonArea: data['polygonArea'].toDouble(),
              totalDistance: data['totalDistance'].toDouble(),
              polygons: (data['polygons'] as List<dynamic>).map((point) {
                return LatLng(point['latitude'].toDouble(), point['longitude'].toDouble());
              }).toList(),
              selectedDate: data['selectedDate'] != null
                  ? (data['selectedDate'] as Timestamp).toDate()
                  : null,
            );
          }).toList();

          return ListView.builder(
            itemCount: fieldList.length,
            itemBuilder: (context, index) {
              final field = fieldList[index];
              return ListTile(
                title: Text(
                  field.fieldName,
                  style: const TextStyle(
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
                        riceType: field.riceType,
                        polygonArea: field.polygonArea,
                        polygons: field.polygons,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}