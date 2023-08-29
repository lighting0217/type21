import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:type21/library/th_format_date.dart';
import 'package:type21/models/temp_data_models.dart';

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
        ? widget.accumulatedGddData[0].accumulatedGdd
        : 0.0;
    final maxGddValue = widget.monthlyTemperatureData.isNotEmpty
        ? widget.monthlyTemperatureData[0].maxGdd
        : 0.0;
    if (kDebugMode) {
      print('accumulatedGdd = $agddValue');
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
          RangeColumnSeries<TemperatureData, String>(
            dataSource: temperatureData,
            xValueMapper: (TemperatureData data, _) =>
                thFormatDate(data.documentID),
            highValueMapper: (TemperatureData data, _) => data.maxTemp,
            lowValueMapper: (TemperatureData data, _) => data.minTemp,
            color: Colors.blue,
            dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                labelAlignment: ChartDataLabelAlignment.top,
                textStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                ),
                color: Colors.greenAccent,
                borderColor: Colors.black,
                borderWidth: 0.5),
          )
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
