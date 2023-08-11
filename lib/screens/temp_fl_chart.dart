import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:type21/screens/new_temp_fl_screen.dart';

import 'field_info.dart';

class TempFlChartScreen extends StatelessWidget {
  final List<TemperatureData> temperatureData;

  const TempFlChartScreen({Key? key, required this.temperatureData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Temperature Charts'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Temperature Chart',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: LineChart(
                LineChartData(
                  titlesData: const FlTitlesData(),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: temperatureData
                          .map(
                            (data) => FlSpot(
                              data.date.microsecondsSinceEpoch.toDouble(),
                              // Convert DateTime to double
                              data.minTemp,
                            ),
                          )
                          .toList(),
                      isCurved: true,
                      color: Colors.red,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                    LineChartBarData(
                      spots: temperatureData
                          .map(
                            (data) => FlSpot(
                              data.date.microsecondsSinceEpoch.toDouble(),
                              // Convert DateTime to double
                              data.maxTemp,
                            ),
                          )
                          .toList(),
                      isCurved: true,
                      color: Colors.blue,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    NewTempChart(temperatureData: temperatureData)),
          );
        },
        child: const Text('แสดงกราฟ'),
      ),
    );
  }
}
