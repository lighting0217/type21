import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'field_info.dart';

class ChartScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final agddValue =
        accumulatedGddData.isNotEmpty ? accumulatedGddData[0].AGDD : 0.0;
    final maxGddValue = monthlyTemperatureData.isNotEmpty
        ? monthlyTemperatureData[0].maxGdd
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GddComparisonChart(
                  agddValue: agddValue,
                  maxGddValue: maxGddValue,
                ),
              ),
              const SizedBox(height: 16),
              MinMaxTempChart(temperatureData: temperatureData),
              const SizedBox(height: 16),
              MonthlyAgddChart(
                monthlyTemperatureData: monthlyTemperatureData,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TempChart extends StatelessWidget {
  final List<TemperatureData> temperatureData;

  const TempChart({
    Key? key,
    required this.temperatureData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true),
          titlesData: const FlTitlesData(show: false),
          minX: 0,
          maxX: temperatureData.length.toDouble() - 1,
          minY: 0,
          maxY: temperatureData
              .map((data) => data.maxTemp)
              .reduce((a, b) => a > b ? a : b),
          lineBarsData: [
            LineChartBarData(
              spots: temperatureData.asMap().entries.map((entry) {
                final index = entry.key.toDouble();
                final maxTemp = entry.value.maxTemp;
                return FlSpot(index, maxTemp);
              }).toList(),
              isCurved: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(show: true),
              aboveBarData: BarAreaData(show: false),
              color: Colors.green,
            ),
          ],
        ),
      ),
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
    return AspectRatio(
      aspectRatio: 1.5,
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        series: <ChartSeries>[
          ColumnSeries<TemperatureData, String>(
            dataSource: temperatureData,
            xValueMapper: (TemperatureData data, _) => data.formattedDate,
            yValueMapper: (TemperatureData data, _) => data.maxTemp,
            name: 'Max Temp',
          ),
          ColumnSeries<TemperatureData, String>(
            dataSource: temperatureData,
            xValueMapper: (TemperatureData data, _) => data.formattedDate,
            yValueMapper: (TemperatureData data, _) => data.minTemp,
            name: 'Min Temp',
          ),
        ],
        legend: const Legend(isVisible: true),
      ),
    );
  }
}

class GddComparisonChart extends StatelessWidget {
  final double agddValue;
  final double maxGddValue;

  const GddComparisonChart({
    Key? key,
    required this.agddValue,
    required this.maxGddValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: agddValue,
              title: 'AGDD',
              color: Colors.blue,
            ),
            PieChartSectionData(
              value: maxGddValue,
              title: 'Max GDD',
              color: Colors.grey,
            ),
          ],
        ),
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
    return AspectRatio(
      aspectRatio: 1.5,
      child: SfCircularChart(
        series: <CircularSeries>[
          DoughnutSeries<MonthlyTemperatureData, String>(
            dataSource: monthlyTemperatureData,
            xValueMapper: (MonthlyTemperatureData data, _) => data.monthYear,
            yValueMapper: (MonthlyTemperatureData data, _) => data.gddSum,
            innerRadius: '50%',
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              textStyle: TextStyle(fontSize: 16),
            ),
          )
        ],
      ),
    );
  }
}
