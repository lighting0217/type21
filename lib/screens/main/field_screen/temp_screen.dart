import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:type21/library/th_format_date.dart';

import 'field_info.dart';
import 'temp_chart_screen.dart';

class TemperatureScreen extends StatelessWidget {
  final List<TemperatureData> temperatureData;

  const TemperatureScreen({Key? key, required this.temperatureData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ข้อมูลอุณหภูมิ (รูปแบบภาษาไทย)',
          style: GoogleFonts.openSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: temperatureData.isEmpty
          ? Center(
              child: Text(
                'ไม่พบข้อมูลอุณหภูมิ',
                style: GoogleFonts.openSans(fontSize: 18),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: temperatureData.length,
                    itemBuilder: (context, index) {
                      final temperature = temperatureData[index];
                      try {
                        final temperature = temperatureData[index];
                        return ListTile(
                          title: Text(
                            thFormatDate(temperature.documentID),
                            style: GoogleFonts.openSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                    ),
                          subtitle: Text(
                            'อุณหภูมิสูงสุด: ${temperature.maxTemp.toStringAsFixed(2)} °C\n'
                            'อุณหภูมิต่ำสุด: ${temperature.minTemp.toStringAsFixed(2)} °C',
                          ),
                        );
                      } catch (e) {
                        return ListTile(
                          title: Text(
                              'Error parsing date: ${temperature.documentID}'),
                        );
                      }
                    },
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TempChartScreen(
                      temperatureData: temperatureData,
                    )),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.navigate_next),
      ),
    );
  }
}
