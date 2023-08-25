import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:type21/library/th_format_date.dart';
import 'package:type21/screens/main/field_screen/calendar_screen.dart';
import 'package:type21/screens/main/field_screen/chart_screen.dart';
import 'package:type21/screens/main/field_screen/test_chart_screen.dart';

import 'field_info.dart';
import 'temp_chart_screen.dart';

class TemperatureScreen extends StatelessWidget {
  final List<TemperatureData> temperatureData;
  final List<MonthlyTemperatureData> monthlyTemperatureData;
  final List<AccumulatedGddData> accumulatedGddData;
  final List<Field> field;

  const TemperatureScreen({
    Key? key,
    required this.temperatureData,
    required this.monthlyTemperatureData,
    required this.accumulatedGddData,
    required this.field,
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
                          final maxTemp =
                              temperature.maxTemp.toStringAsFixed(2);
                          final minTemp =
                              temperature.minTemp.toStringAsFixed(2);
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
                        if (kDebugMode) {
                          print("Monthly Temperature: $monthlyTemperature");
                        }
                        try {
                          final formattedDate =
                              thFormatDateMonth(monthlyTemperature.documentID);
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
                      },
                    ),
                  )
                ],
              ),
        floatingActionButton: Stack(
          alignment: Alignment.bottomRight,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 195),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TempChartScreen(
                              temperatureData: temperatureData,
                              monthlyTemperatureData: monthlyTemperatureData,
                              accumulatedGddData: accumulatedGddData,
                            )),
                  );
                },
                backgroundColor: Colors.blue,
                child: const Icon(Icons.navigate_next),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 130),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TestChartScreen()),
                  );
                },
                backgroundColor: Colors.blue,
                child: const Icon(Icons.graphic_eq),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 65),
              child: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChartScreen(
                                monthlyTemperatureData: monthlyTemperatureData,
                                accumulatedGddData: accumulatedGddData,
                                temperatureData: temperatureData,
                              )),
                    );
                  },
                  child: const Icon(Icons.show_chart)),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 0),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CalendarScreen(
                                temperatureData: temperatureData,
                                monthlyTemperatureData: monthlyTemperatureData,
                                accumulatedGddData: accumulatedGddData,
                                field: field,
                              )));
                },
                child: Icon(Icons.calendar_month_rounded),
              ),
            )
          ],
        ));
  }
}
