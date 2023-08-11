import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:type21/screens/temp_chart_screen.dart';

import 'field_info.dart';

class TemperatureScreen extends StatelessWidget {
  final List<TemperatureData> temperatureData;

  const TemperatureScreen({Key? key, required this.temperatureData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ข้อมูลแุณภูมิ',
          style: GoogleFonts.openSans(
            fontSize: 24,
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
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TempChartScreen(temperatureData: temperatureData),
                      ),
                    );
                  },
                  child: const Text('แสดงกราฟ'),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: temperatureData.length,
                    itemBuilder: (context, index) {
                      final temperature = temperatureData[index];
                      try {
                        const monthNames = [
                          'January',
                          'February',
                          'March',
                          'April',
                          'May',
                          'June',
                          'July',
                          'August',
                          'September',
                          'October',
                          'November',
                          'December',
                        ];
                        final temperature = temperatureData[index];
                        final documentIdDateParts =
                            temperature.documentID.split(' ');
                        final monthIndex =
                            monthNames.indexOf(documentIdDateParts[0]);
                        final day = int.parse(
                            documentIdDateParts[1].replaceAll(',', ''));
                        final year = int.parse(documentIdDateParts[2]);
                        final documentIdDateTime =
                            DateTime(year, monthIndex + 1, day);
                        final formattedDate =
                            DateFormat('EEEE ที่ d MMMM ปี y', 'th_TH')
                                .format(documentIdDateTime);
                        return ListTile(
                          title: Text(
                            formattedDate,
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
    );
  }
}
