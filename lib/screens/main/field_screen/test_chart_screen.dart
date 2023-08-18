import 'dart:math';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DailyTempData {
  final DateTime dateTime;
  final double minTemp;
  final double maxTemp;
  final double gdd;

  DailyTempData({
    required this.dateTime,
    required this.minTemp,
    required this.maxTemp,
    required this.gdd,
  });
}

class MonthlyTempData {
  final String monthYear;
  final double gddSum;

  MonthlyTempData({
    required this.monthYear,
    required this.gddSum,
  });
}

List<DailyTempData> aggregateWeekly(List<DailyTempData> dailyData) {
  List<DailyTempData> weeklyData = [];

  for (int i = 0; i < dailyData.length; i += 7) {
    final weekData = dailyData.sublist(i, min(i + 7, dailyData.length));

    DateTime weekStart = weekData.first.dateTime;
    double avgMaxTemp = weekData.map((e) => e.maxTemp).reduce((a, b) => a + b) /
        weekData.length;
    double avgMinTemp = weekData.map((e) => e.minTemp).reduce((a, b) => a + b) /
        weekData.length;

    weeklyData.add(DailyTempData(
      dateTime: weekStart,
      maxTemp: avgMaxTemp,
      minTemp: avgMinTemp,
      gdd: (avgMaxTemp + avgMinTemp) / 2 - 9,
    ));
  }

  return weeklyData;
}

List<MonthlyTempData> aggregateMonthly(List<DailyTempData> dailyData) {
  Map<String, List<DailyTempData>> groupedData = {};

  for (var entry in dailyData) {
    String monthYear = "${entry.dateTime.month}-${entry.dateTime.year}";
    if (!groupedData.containsKey(monthYear)) {
      groupedData[monthYear] = [];
    }
    groupedData[monthYear]!.add(entry);
  }

  List<MonthlyTempData> monthlyData = [];
  double accumulateGdd = 0;
  groupedData.forEach((monthYear, data) {
    double monthGdd = data.fold(0.0, (sum, item) => sum + item.gdd);
    accumulateGdd += monthGdd;
    monthlyData.add(MonthlyTempData(
      monthYear: monthYear,
      gddSum: accumulateGdd,
    ));
  });

  return monthlyData;
}

List<DailyTempData> generateDailyTestData() {
  final Random random = Random();
  final int numberOfDays = 100 + random.nextInt(11);

  List<DailyTempData> data = [];
  DateTime startDate = DateTime.now();

  for (int i = 0; i < numberOfDays; i++) {
    double minTemp, maxTemp;
    final double prob = random.nextDouble();

    if (prob <= 0.10) {
      minTemp = 30 + random.nextDouble() * 12;
    } else if (prob <= 0.30) {
      minTemp = 26 + random.nextDouble() * 8;
    } else if (prob <= 0.45) {
      minTemp = 20 + random.nextDouble() * 10;
    } else {
      minTemp = 23 + random.nextDouble() * 9;
    }

    maxTemp = minTemp + random.nextDouble() * 5;
    DateTime currentDay = startDate.add(Duration(days: i));
    data.add(DailyTempData(
      dateTime: currentDay,
      minTemp: minTemp,
      maxTemp: maxTemp,
      gdd: (maxTemp + minTemp) / 2 - 9,
    ));
  }
  return data;
}

class TestChartScreen extends StatefulWidget {
  const TestChartScreen({Key? key}) : super(key: key);

  @override
  State<TestChartScreen> createState() => _TestChartScreenState();
}

class _TestChartScreenState extends State<TestChartScreen> {
  late final List<DailyTempData> dailyTestData;
  late final List<MonthlyTempData> monthlyTestData;
  final aggregateMonthlyData = aggregateMonthly(generateDailyTestData());

  @override
  void initState() {
    super.initState();
    dailyTestData = generateDailyTestData();
    monthlyTestData = aggregateMonthly(dailyTestData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test Chart"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 350,
              child: SfCartesianChart(
                  primaryXAxis: DateTimeAxis(),
                  zoomPanBehavior: ZoomPanBehavior(
                    enableDoubleTapZooming: true,
                    enablePanning: true,
                    enablePinching: true,
                  ),
                  series: <ChartSeries>[
                    RangeColumnSeries<DailyTempData, DateTime>(
                      dataSource: generateDailyTestData(),
                      xValueMapper: (DailyTempData data, _) => data.dateTime,
                      lowValueMapper: (DailyTempData data, _) => data.minTemp,
                      highValueMapper: (DailyTempData data, _) => data.maxTemp,
                    ),
                    LineSeries<DailyTempData, DateTime>(
                        dataSource: generateDailyTestData(),
                        xValueMapper: (DailyTempData data, _) => data.dateTime,
                        yValueMapper: (DailyTempData data, _) => data.gdd,
                        name: 'GDD')
                  ]),
            ),
            const SizedBox(
              height: 10,
            ),
            const SizedBox(
              height: 350,
              child: MonthlyGDDChartScreen(),
            ),
            const SizedBox(
              height: 10,
            ),
            const SizedBox(
              height: 350,
              child: GddComparisonChart(),
            ),
            const SizedBox(height: 10),
            Text('Acumulated GDD: ${aggregateMonthlyData.last.gddSum} '),
            const SizedBox(
              height: 10,
            ),
            Text(getHarvestNotification(aggregateMonthlyData.last.gddSum)),
          ],
        ),
      ),
    );
  }
}

class MonthlyGDDChartScreen extends StatefulWidget {
  const MonthlyGDDChartScreen({Key? key}) : super(key: key);

  @override
  State<MonthlyGDDChartScreen> createState() => _MonthlyGDDChartScreenState();
}

class _MonthlyGDDChartScreenState extends State<MonthlyGDDChartScreen> {
  @override
  Widget build(BuildContext context) {
    final data = aggregateMonthly(generateDailyTestData());

    return Container(
      padding: const EdgeInsets.all(8.0),
      child: SfCartesianChart(
        plotAreaBorderWidth: 0,
        primaryXAxis: CategoryAxis(
          majorGridLines: const MajorGridLines(width: 0),
        ),
        primaryYAxis: NumericAxis(
          axisLine: const AxisLine(width: 0),
          labelFormat: '{value}°C',
          majorTickLines: const MajorTickLines(size: 0),
        ),
        series: <ChartSeries>[
          ColumnSeries<MonthlyTempData, String>(
            dataSource: data,
            xValueMapper: (MonthlyTempData data, _) => data.monthYear,
            yValueMapper: (MonthlyTempData data, _) => data.gddSum,
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.outside,
            ),
          ),
        ],
        tooltipBehavior: TooltipBehavior(enable: true),
        zoomPanBehavior: ZoomPanBehavior(
          enablePanning: true,
          enablePinching: true,
          enableDoubleTapZooming: true,
        ),
      ),
    );
  }
}

double calculateGDDPercentage(double accumulatedGDD) {
  const double maxGDD = 2777.2;
  return accumulatedGDD / maxGDD * 100;
}

String getHarvestNotification(double accumulatedGDD) {
  double percentage = calculateGDDPercentage(accumulatedGDD);
  if (percentage >= 100) {
    return "ถึงเวลาเก็บเกี่ยวแล้ว!";
  } else if (percentage >= 80) {
    const double maxGDD = 2777.2;
    int daysToHarvest = ((maxGDD - accumulatedGDD) /
            (accumulatedGDD /
                DateTime.now()
                    .difference(
                        DateTime.now().subtract(const Duration(days: 120)))
                    .inDays))
        .ceil();
    DateTime harvestDate = DateTime.now().add(Duration(days: daysToHarvest));
    return "ใกล้ถึงวันที่จะต้องเก็บเกี่ยวแล้ว: ${harvestDate.day}/${harvestDate.month}/${harvestDate.year}";
  } else {
    return "ยังไม่ใกล้ถึงวันเก็บเกี่ยว";
  }
}

class GddComparisonChart extends StatefulWidget {
  const GddComparisonChart({Key? key}) : super(key: key);

  @override
  State<GddComparisonChart> createState() => _GddComparisonChartState();
}

class _GddComparisonChartState extends State<GddComparisonChart> {
  @override
  Widget build(BuildContext context) {
    final data = aggregateMonthly(generateDailyTestData());
    const maxGdd = 2777.2;
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: SfCartesianChart(
        plotAreaBorderWidth: 0.5,
        primaryXAxis: CategoryAxis(
          majorGridLines: const MajorGridLines(width: 0),
        ),
        primaryYAxis: NumericAxis(
          axisLine: const AxisLine(width: 0),
          labelFormat: '{value}°C',
          majorTickLines: const MajorTickLines(size: 0),
        ),
        series: <ChartSeries>[
          ColumnSeries<MonthlyTempData, String>(
            dataSource: data,
            xValueMapper: (MonthlyTempData data, _) => data.monthYear,
            yValueMapper: (MonthlyTempData data, _) => data.gddSum,
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.outside,
            ),
          ),
          LineSeries<MonthlyTempData, String>(
            dataSource: data,
            xValueMapper: (MonthlyTempData data, _) => data.monthYear,
            yValueMapper: (MonthlyTempData data, _) => maxGdd,
            name: 'Max GDD',
            color: Colors.red,
          ),
          LineSeries<MonthlyTempData, String>(
            dataSource: data,
            xValueMapper: (MonthlyTempData data, _) => data.monthYear,
            yValueMapper: (MonthlyTempData data, _) =>
                calculateGDDPercent(data.gddSum),
            name: 'Percent of Max GDD',
            color: Colors.blue,
          ),
        ],
        tooltipBehavior:
            TooltipBehavior(enable: true, format: 'point.x : point.y'),
        zoomPanBehavior: ZoomPanBehavior(
          enablePanning: true,
          enablePinching: true,
          enableDoubleTapZooming: true,
        ),
      ),
    );
  }
}

double calculateGDDPercent(double accumulatedGDD) {
  const double maxGDD = 2777.2;
  return accumulatedGDD / maxGDD * 100;
}
