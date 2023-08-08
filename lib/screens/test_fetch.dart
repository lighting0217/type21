import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

// Define Field class
class Field {
  Field({
    required this.fieldName,
    required this.polygonArea,
    required this.polygons,
    required this.riceType,
    required this.selectedDate,
    required this.totalDistance,
    required this.createdBy,
  });

  final String fieldName;
  final double polygonArea;
  final List<LatLng> polygons;
  final String riceType;
  final DateTime? selectedDate;
  final double totalDistance;
  final String createdBy;
}

class TestFetch extends StatefulWidget {
  const TestFetch({Key? key}) : super(key: key);

  @override
  State<TestFetch> createState() => _TestFetchState();
}

class _TestFetchState extends State<TestFetch> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Temperature Data')),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collectionGroup('temperatures').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final temperatureDocs = snapshot.data!.docs;
          final temperatureData = temperatureDocs
              .map((doc) => TemperatureData.fromSnapshot(doc))
              .toList();

          return ListView.builder(
            itemCount: temperatureData.length,
            itemBuilder: (context, index) {
              final data = temperatureData[index];
              return ListTile(
                title: Text('Date: ${data.date}'),
                subtitle: Text('Min Temp: ${data.minTemp},'
                    ' Max Temp: ${data.maxTemp}'),
              );
            },
          );
        },
      ),
    );
  }
}
