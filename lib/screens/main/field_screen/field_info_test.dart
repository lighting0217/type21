// import 'dart:core';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:type21/models/temp_data_models.dart';
//
// import '../../../library/field_utils.dart';
//
// final FirebaseFirestore firestore = FirebaseFirestore.instance;
//
// class FieldInfo extends StatefulWidget {
//   const FieldInfo({
//     Key? key,
//     required this.field,
//     required this.documentID,
//   }) : super(key: key);
//
//   final Field field;
//   final String documentID;
//
//   @override
//   State<FieldInfo> createState() => _FieldInfoState();
// }
//
// class _FieldInfoState extends State<FieldInfo> {
//   GoogleMapController? mapController;
//
//   @override
//   void initState() {
//     super.initState();
//     FieldUtils.loadTemperatureData(widget.documentID, widget.field);
//     FieldUtils.loadMonthlyTemperatureData(widget.documentID, widget.field);
//     FieldUtils.loadAccumulatedGddData(widget.documentID, widget.field);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final polygons = widget.field.polygons;
//
//     if (polygons.isEmpty) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'ข้อมูลแปลงเพาะปลูก',
//           style: GoogleFonts.openSans(fontSize: 24, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Colors.blue,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(10.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('ชื่อแปลง: ${widget.field.fieldName}', style: GoogleFonts.openSans(fontSize: 20, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 8),
//               Text('พันธุ์ข้าว: ${FieldUtils.getThaiRiceType(widget.field.riceType)}', style: GoogleFonts.openSans(fontSize: 18, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 8),
//               Text(FieldUtils.convertAreaToRaiNganWah(widget.field.polygonArea), style: GoogleFonts.openSans(fontSize: 18)),
//               const SizedBox(height: 8),
//               Text('วันที่เลือก: ${FieldUtils.formatDateThai(widget.field.selectedDate ?? DateTime.now())}', style: GoogleFonts.openSans(fontSize: 18)),
//               const SizedBox(height: 16),
//               Center(
//                 child: SizedBox(
//                   height: 350,
//                   width: 350,
//                   child: FieldUtils.buildGoogleMap(polygons, mapController),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               FieldUtils.buildTemperatureDataButton(context, widget.field),
//               const SizedBox(height: 10),
//               FieldUtils.buildForecastedHarvestDate(widget.field),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
