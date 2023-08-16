import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:type21/library/th_format_date.dart';

import 'field_info.dart';
import 'temp_chart_screen.dart';

class TemperatureScreen extends StatelessWidget {
  final List<TemperatureData> temperatureData;
  final List<MonthlyTemperatureData> monthlyTemperatureData;

  const TemperatureScreen({
    Key? key,
    required this.temperatureData,
    required this.monthlyTemperatureData,
  }) : super(key: key);

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
                        final formattedDate =
                            thFormatDate(temperature.documentID);
                        final maxTemp = temperature.maxTemp.toStringAsFixed(2);
                        final minTemp = temperature.minTemp.toStringAsFixed(2);
                        final gdd = temperature.gdd.toStringAsFixed(2);
                        return ListTile(
                          title: Text(
                            formattedDate,
                            style: GoogleFonts.openSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text('อุณหภูมิสูงสุด: $maxTemp °C\n'
                              'อุณหภูมิต่ำสุด: $minTemp °C\n'
                              'GDD: $gdd °C\n'),
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
                const SizedBox(height: 10),
                const Center(child: Text('GDD รายเดือน')),
                Expanded(
                    child: ListView.builder(
                        itemCount: monthlyTemperatureData.length,
                        itemBuilder: (context, index) {
                          final monthlyTemperature =
                              monthlyTemperatureData[index];
                          try {
                            final formattedDate = thFormatDateMonth(
                                monthlyTemperature.documentID);
                            final gdd =
                                monthlyTemperature.gddSum.toStringAsFixed(2);
                            return ListTile(
                              title: Text(
                                formattedDate,
                                style: GoogleFonts.openSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text('GDD รายเดือน: $gdd °C\n'),
                            );
                          } catch (e) {
                            return ListTile(
                              title: Text(
                                  'Error parsing date: ${monthlyTemperature.documentID}'),
                            );
                          }
                        }))
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TempChartScreen(
                      temperatureData: temperatureData,
                      monthlyTemperatureData: monthlyTemperatureData,
                    )),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.navigate_next),
      ),
    );
  }
}
