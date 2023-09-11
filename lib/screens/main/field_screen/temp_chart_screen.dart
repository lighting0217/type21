import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:type21/library/th_format_date.dart';
import 'package:type21/models/temp_data_models.dart';

class TempChartScreen extends StatefulWidget {
  final List<TemperatureData> temperatureData;
  final List<MonthlyTemperatureData> monthlyTemperatureData;
  final List<AccumulatedGddData> accumulatedGddData;
  final double maxGdd;

  const TempChartScreen({
    Key? key,
    required this.temperatureData,
    required this.monthlyTemperatureData,
    required this.accumulatedGddData,
    required this.maxGdd,
    required List<Field> field,
  }) : super(key: key);

  @override
  State<TempChartScreen> createState() => _TempChartScreenState();
}

class _TempChartScreenState extends State<TempChartScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Temperature Charts',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.blue,
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildChartSection(
              TempRangedChart(temperatureData: widget.temperatureData)),
          _buildChartSection(
              DayGddChart(temperatureData: widget.temperatureData)),
          _buildChartSection(MonthlyAgddPieChart(
              monthlyTemperatureData: widget.monthlyTemperatureData)),
          _buildChartSection(MonthGddChart(
              monthlyTemperatureData: widget.monthlyTemperatureData)),
          _buildChartSection(HalfCircularChart(
            accumulatedGddData: widget.accumulatedGddData,
            maxGdd: widget.maxGdd,
          )),
        ],
      ),
    );
  }

  Widget _buildChartSection(Widget chart) {
    return Column(
      children: [
        const SizedBox(height: 20),
        SizedBox(height: 400, child: chart),
        const SizedBox(height: 20),
      ],
    );
  }
}

double calculatePercent(AccumulatedGddData accumulatedGddData, double maxGdd) {
  return (accumulatedGddData.accumulatedGdd / maxGdd) * 100;
}

List<MonthlyTemperatureData> computeCumulativeGddSum(
    List<MonthlyTemperatureData> newData,
    [List<MonthlyTemperatureData>? existingData]) {
  double cumulativeSum = 0;
  existingData ??= [];

  if (existingData.isNotEmpty) {
    cumulativeSum = existingData.last.gddSum;
  }

  List<MonthlyTemperatureData> updatedData = [];
  for (var monthData in newData) {
    cumulativeSum += monthData.gddSum;
    updatedData.add(monthData.copyWith(gddSum: cumulativeSum));
  }

  return List.from(existingData)..addAll(updatedData);
}

class MonthlyAgddPieChart extends StatelessWidget {
  final List<MonthlyTemperatureData> monthlyTemperatureData;

  const MonthlyAgddPieChart({
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
          title: ChartTitle(text: 'Pie chart'),
          series: <CircularSeries>[
            PieSeries<MonthlyTemperatureData, String>(
              dataSource: monthlyTemperatureData,
              xValueMapper: (MonthlyTemperatureData data, _) => data.monthYear,
              yValueMapper: (MonthlyTemperatureData data, _) => data.gddSum,
              radius: '105%',
              dataLabelMapper: (MonthlyTemperatureData data, _) =>
                  '${thFormatDateMonth(data.monthYear)}\n${data.gddSum.toStringAsFixed(2)}',
              dataLabelSettings: const DataLabelSettings(
                labelIntersectAction: LabelIntersectAction.none,
                labelAlignment: ChartDataLabelAlignment.auto,
                isVisible: true,
                labelPosition: ChartDataLabelPosition.inside,
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Jasmine',
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TempRangedChart extends StatefulWidget {
  final List<TemperatureData> temperatureData;

  const TempRangedChart({Key? key, required this.temperatureData})
      : super(key: key);

  @override
  State<TempRangedChart> createState() => _TempRangedChartState();
}

class _TempRangedChartState extends State<TempRangedChart> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: SfCartesianChart(
        title: ChartTitle(text: 'ช่วงอุณหภูมิของวัน'),
        primaryXAxis: CategoryAxis(
          labelRotation: 25,
        ),
        primaryYAxis: NumericAxis(),
        zoomPanBehavior: ZoomPanBehavior(
          enableDoubleTapZooming: true,
          enablePanning: true,
          enablePinching: true,
          enableMouseWheelZooming: true,
          enableSelectionZooming: false,
        ),
        series: <ChartSeries>[
          RangeColumnSeries<TemperatureData, String>(
            dataSource: widget.temperatureData,
            xValueMapper: (TemperatureData data, _) =>
                thFormatDateShort(data.documentID),
            lowValueMapper: (TemperatureData data, _) => data.minTemp,
            highValueMapper: (TemperatureData data, _) => data.maxTemp,
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelAlignment: ChartDataLabelAlignment.bottom,
              labelPosition: ChartDataLabelPosition.outside,
              labelIntersectAction: LabelIntersectAction.none,
              textStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'Jasmine',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DayGddChart extends StatefulWidget {
  final List<TemperatureData> temperatureData;

  const DayGddChart({Key? key, required this.temperatureData})
      : super(key: key);

  @override
  State<DayGddChart> createState() => _DayGddChartState();
}

class _DayGddChartState extends State<DayGddChart> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 300,
        child: SfCartesianChart(
          title: ChartTitle(text: 'Growing Degree Days (GDD)/วัน'),
          primaryXAxis: CategoryAxis(
            labelRotation: 30,
          ),
          primaryYAxis: NumericAxis(),
          zoomPanBehavior: ZoomPanBehavior(
            enableDoubleTapZooming: true,
            enablePanning: true,
            enablePinching: true,
          ),
          series: <ChartSeries>[
            ColumnSeries<TemperatureData, String>(
              dataSource: widget.temperatureData,
              xValueMapper: (TemperatureData data, _) =>
                  thFormatDateShort(data.documentID),
              yValueMapper: (TemperatureData data, _) => data.gdd,
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                labelAlignment: ChartDataLabelAlignment.outer,
                textStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Jasmine',
                ),
              ),
            ),
          ],
        ));
  }
}

class MonthGddChart extends StatefulWidget {
  final List<MonthlyTemperatureData> monthlyTemperatureData;

  const MonthGddChart({Key? key, required this.monthlyTemperatureData})
      : super(key: key);

  @override
  State<MonthGddChart> createState() => _MonthGddChartState();
}

class _MonthGddChartState extends State<MonthGddChart> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 300,
        child: SfCartesianChart(
          title: ChartTitle(text: 'Growing Degree Days (GDD)/เดือน'),
          primaryXAxis: CategoryAxis(
            labelRotation: 30,
          ),
          primaryYAxis: NumericAxis(),
          zoomPanBehavior: ZoomPanBehavior(
            enableDoubleTapZooming: true,
            enablePanning: true,
            enablePinching: true,
          ),
          series: <ChartSeries>[
            ColumnSeries<MonthlyTemperatureData, String>(
              dataSource: widget.monthlyTemperatureData,
              xValueMapper: (MonthlyTemperatureData data, _) =>
                  thFormatDateMonth(data.documentID),
              yValueMapper: (MonthlyTemperatureData data, _) => data.gddSum,
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                labelAlignment: ChartDataLabelAlignment.outer,
                textStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ));
  }
}

class HalfCircularChart extends StatelessWidget {
  final List<AccumulatedGddData> accumulatedGddData;
  final double? maxGdd;

  const HalfCircularChart({
    Key? key,
    required this.accumulatedGddData,
    required this.maxGdd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("maxGdd: $maxGdd");
      print("accumulatedGddData: $accumulatedGddData");
    }

    double accumulatedValue = accumulatedGddData.isNotEmpty
        ? accumulatedGddData.last.accumulatedGdd
        : 0;
    double remainingGdd = (maxGdd ?? 0) - accumulatedValue;
    bool shouldHarvest = accumulatedValue >= (maxGdd ?? 0);
    double accumulatedPercentage = (accumulatedValue / (maxGdd ?? 1)) * 100;
    double remainingPercentage = (remainingGdd / (maxGdd ?? 1)) * 100;

    return AspectRatio(
      aspectRatio: 1.5,
      child: Stack(
        children: [
          // Pie chart
          PieChart(
            PieChartData(
              sections: [
                if (!shouldHarvest)
                  PieChartSectionData(
                    value: remainingGdd,
                    title: '${remainingPercentage.toStringAsFixed(2)}% Max GDD',
                    color: Colors.blue,
                    radius: 155,
                  ),
                PieChartSectionData(
                  value: accumulatedValue,
                  title:
                      '${accumulatedPercentage.toStringAsFixed(2)}% Accumulated GDD',
                  color: Colors.green,
                  radius: 155,
                ),
              ],
              sectionsSpace: 0,
              centerSpaceRadius: 0,
            ),
          ),
          // Message
          if (shouldHarvest)
            const Center(
              child: Text(
                'ควรเก็บเกี่ยวได้แล้ว',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
