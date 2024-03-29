import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../controller/global_controller.dart';
import '../../th_format_date.dart';

class HeaderSc extends StatefulWidget {
  const HeaderSc({super.key});

  @override
  State<HeaderSc> createState() => _HeaderScState();
}

class _HeaderScState extends State<HeaderSc> {
  String city = "";
  final GlobalController globalController =
      Get.put(GlobalController(), permanent: true);
  String date =
      thFormatDateShort(DateFormat('MMMM, d yyyy').format(DateTime.now()));

  @override
  void initState() {
    getCity(globalController.getlat().value, globalController.getlng().value);
    super.initState();
  }

  Future<void> getCity(double lat, double lng) async {
    final url = Uri.parse(
        'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=$lat&longitude=$lng&localityLanguage=th');
    final response = await http.get(url);
    final data = jsonDecode(response.body);

    setState(() {
      city = '${data["locality"]}, ${data["city"]}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 20, right: 20),
          alignment: Alignment.topLeft,
          child: Text(
            city.isNotEmpty ? city : 'Getting the name...',
            style: const TextStyle(height: 2, fontSize: 30),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          alignment: Alignment.topLeft,
          child: Text(
            date,
            style:
                const TextStyle(height: 1.5, fontSize: 14, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
