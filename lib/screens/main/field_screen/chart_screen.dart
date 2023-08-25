import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'field_info.dart';

class ChartScreen extends StatefulWidget {
  final List<TemperatureData> temperatureData;
  final List<MonthlyTemperatureData> monthlyTemperatureData;
  final List<AccumulatedGddData> accumulatedGddData;

  const ChartScreen({
    Key? key,
    required this.monthlyTemperatureData,
    required this.accumulatedGddData,
    required this.temperatureData,
  }) : super(key: key);

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  @override
  Widget build(BuildContext context) {
    final agddValue = widget.accumulatedGddData.isNotEmpty
        ? widget.accumulatedGddData[0].AGDD
        : 0.0;
    final maxGddValue = widget.monthlyTemperatureData.isNotEmpty
        ? widget.monthlyTemperatureData[0].maxGdd
        : 0.0;
    if (kDebugMode) {
      print('AGDD = $agddValue');
      print('Max GDD = $maxGddValue');
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chart Screen'),
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.only(top: 10, left: 5, right: 5),
        child: Column(
          children: [
            MinMaxTempChart(temperatureData: widget.temperatureData),
            MonthlyAgddChart(
                monthlyTemperatureData: widget.monthlyTemperatureData),
            PercentageGdd(
                accumulatedGddData: widget.accumulatedGddData,
                monthlyTemperatureData: widget.monthlyTemperatureData)
            //TempChart(temperatureData: temperatureData),
            //GddComparisonChart(agddValue: agddValue, maxGddValue: maxGddValue),
          ],
        ),
      )),
    );
  }
}

class MinMaxTempChart extends StatelessWidget {
  final List<TemperatureData> temperatureData;

  const MinMaxTempChart({
    Key? key,
    required this.temperatureData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        zoomPanBehavior: ZoomPanBehavior(
          enablePanning: true,
          enablePinching: true,
          enableDoubleTapZooming: true,
          zoomMode: ZoomMode.xy,
        ),
        series: <ChartSeries>[
          ColumnSeries<TemperatureData, String>(
            dataSource: temperatureData,
            xValueMapper: (TemperatureData data, _) => data.formattedDate,
            yValueMapper: (TemperatureData data, _) => data.maxTemp + 10,
            name: 'Max Temp',
          ),
          ColumnSeries<TemperatureData, String>(
            dataSource: temperatureData,
            xValueMapper: (TemperatureData data, _) => data.formattedDate,
            yValueMapper: (TemperatureData data, _) => data.minTemp - 10,
            name: 'Min Temp',
          ),
        ],
        legend: const Legend(isVisible: false),
      ),
    );
  }
}

class MonthlyAgddChart extends StatelessWidget {
  final List<MonthlyTemperatureData> monthlyTemperatureData;

  const MonthlyAgddChart({
    Key? key,
    required this.monthlyTemperatureData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      child: SizedBox(
        height: 325,
        child: SfCircularChart(
          series: <CircularSeries>[
            DoughnutSeries<MonthlyTemperatureData, String>(
                dataSource: monthlyTemperatureData,
                xValueMapper: (MonthlyTemperatureData data, _) =>
                    data.monthYear,
                yValueMapper: (MonthlyTemperatureData data, _) => data.gddSum,
                innerRadius: '50%',
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ))
          ],
        ),
      ),
    );
  }
}

class PercentageGdd extends StatelessWidget {
  final List<AccumulatedGddData> accumulatedGddData;
  final List<MonthlyTemperatureData> monthlyTemperatureData;

  const PercentageGdd(
      {Key? key,
      required this.accumulatedGddData,
      required this.monthlyTemperatureData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double agddValue =
        accumulatedGddData.isNotEmpty ? accumulatedGddData[0].AGDD : 0.0;
    double maxGddValue = monthlyTemperatureData.isNotEmpty
        ? monthlyTemperatureData[0].maxGdd
        : 0.0;

    double percentage =
        maxGddValue != 0.0 ? (agddValue / maxGddValue) * 100 : 0.0;
    print('AGDD value = $agddValue');
    print('Max GDD value = $maxGddValue');
    return SizedBox(
      height: 400,
      child: SfCircularChart(
        series: [
          DoughnutSeries<double, double>(
            dataSource: [percentage, 100 - percentage],
            xValueMapper: (data, _) => data,
            yValueMapper: (data, _) => data,
            startAngle: 270,
            endAngle: 90,
            innerRadius: '50%',
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// class GddComparisonChart extends StatelessWidget {
//   final double agddValue;
//   final double maxGddValue;
//
//   const GddComparisonChart({
//     Key? key,
//     required this.agddValue,
//     required this.maxGddValue,
//   }) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 350,
//       child: SizedBox(
//         height: 350,
//         child: PieChart(
//           PieChartData(
//             sections: [
//               PieChartSectionData(
//                 value: agddValue,
//                 title: 'AGDD',
//                 color: Colors.green,
//               ),
//               PieChartSectionData(
//                 value: maxGddValue,
//                 title: 'Max GDD',
//                 color: Colors.grey,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class TempChart extends StatelessWidget {
//   final List<TemperatureData> temperatureData;
//
//   const TempChart({
//     Key? key,
//     required this.temperatureData,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return  Column(
//         children: [
//           SizedBox(
//             height: 350,
//             child: LineChart(
//               LineChartData(
//                 gridData: const FlGridData(show: true),
//                 titlesData: const FlTitlesData(show: false),
//                 minX: 0,
//                 maxX: temperatureData.length.toDouble() - 1,
//                 minY: 0,
//                 maxY: temperatureData
//                     .map((data) => data.maxTemp)
//                     .reduce((a, b) => a > b ? a : b),
//                 lineBarsData: [
//                   LineChartBarData(
//                     spots: temperatureData.asMap().entries.map((entry) {
//                       final index = entry.key.toDouble();
//                       final maxTemp = entry.value.maxTemp;
//                       return FlSpot(index, maxTemp);
//                     }).toList(),
//                     isCurved: true,
//                     dotData: const FlDotData(show: false),
//                     belowBarData: BarAreaData(show: true),
//                     aboveBarData: BarAreaData(show: false),
//                     color: Colors.green,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 10),
//         ],
//       );
//
//   }
// }
