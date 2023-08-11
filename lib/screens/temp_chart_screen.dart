import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:type21/screens/temp_fl_chart.dart';

import 'field_info.dart';

class TempChartScreen extends StatelessWidget {
  final List<TemperatureData> temperatureData;

  const TempChartScreen({Key? key, required this.temperatureData})
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
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          TempFlChartScreen(temperatureData: temperatureData)),
                );
              },
              child: const Text('แสดงกราฟ'),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: temperatureData.length * 60.0,
                  child: SfCartesianChart(
                    primaryXAxis: CategoryAxis(),
                    primaryYAxis: NumericAxis(minimum: 20, maximum: 40),
                    tooltipBehavior: TooltipBehavior(
                      enable: true,
                      format: 'point.x : point.y °C',
                    ),
                    series: <ChartSeries>[
                      LineSeries<TemperatureData, String>(
                        dataSource: temperatureData,
                        xValueMapper: (TemperatureData data, _) =>
                            data.formattedDate,
                        // ใช้ formattedDate เป็น x-value
                        yValueMapper: (TemperatureData data, _) => data.minTemp,
                        name: 'อุณหภูมิต่ำสุด',
                        yAxisName: 'Min-Max Temp',
                      ),
                      LineSeries<TemperatureData, String>(
                        dataSource: temperatureData,
                        xValueMapper: (TemperatureData data, _) =>
                            data.formattedDate,
                        yValueMapper: (TemperatureData data, _) => data.maxTemp,
                        name: 'อุณหภูมิสูงสุด',
                        yAxisName: 'Min-Max Temp',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
