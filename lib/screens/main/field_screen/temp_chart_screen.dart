import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:type21/library/th_format_date.dart';
import 'package:type21/models/temp_data_models.dart';

class TempChartScreen extends StatefulWidget {
  final List<TemperatureData> temperatureData;
  final List<MonthlyTemperatureData> monthlyTemperatureData;
  final List<AccumulatedGddData> accumulatedGddData;

  const TempChartScreen({
    Key? key,
    required this.temperatureData,
    required this.monthlyTemperatureData,
    required this.accumulatedGddData,
  }) : super(key: key);

  @override
  State<TempChartScreen> createState() => _TempChartScreenState();
}

String getThaiMonthFromDateTime(DateTime dateTime) {
  return DateFormat('MMMM yyyy', 'th_TH').format(dateTime);
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
      appBar: AppBar(
        title: const Text(
          'Temperature Charts',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            SizedBox(
              height: 400,
              child: TempRangedChart(temperatureData: widget.temperatureData),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 400,
              child: DayGddChart(temperatureData: widget.temperatureData),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 400,
              child: MonthlyAgddChart(
                monthlyTemperatureData: widget.monthlyTemperatureData,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 400,
              child: MonthGddChart(
                monthlyTemperatureData: widget.monthlyTemperatureData,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 400,
              child: MonthlyTempChart(
                monthlyTemperatureData: widget.monthlyTemperatureData,
              ),
            ),
            const SizedBox(height: 20),
            for (var monthlyData in widget.monthlyTemperatureData)
              Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'วันที่เหมาะสมเก็บเกี่ยว (${monthlyData.monthYear}):',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'arial',
                    ),
                  ),
                  if (monthlyData.forecastedHarvestDate != null)
                    Text(
                      DateFormat('DD MMMM YYYY', 'th_TH')
                          .format(monthlyData.forecastedHarvestDate!),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'arial',
                      ),
                    ),
                  if (monthlyData.forecastedHarvestDate == null)
                    Text(
                      'ยังไม่สามารถแนะนำได้ ข้อมูลยังไม่เพียงพอ ตอนนี้มีข้อมูล GDD อยู่: ${calculatePercent(
                        monthlyData.accumulatedGddData!,
                        monthlyData.maxGdd,
                      ).toStringAsFixed(2)}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'arial',
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  double calculatePercent(
      AccumulatedGddData accumulatedGddData, double maxGdd) {
    return (accumulatedGddData.accumulatedGdd / maxGdd) * 100;
  }
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
          title: ChartTitle(text: ('Pie chart')),
          series: <CircularSeries>[
            DoughnutSeries<MonthlyTemperatureData, String>(
                dataSource: monthlyTemperatureData,
                xValueMapper: (MonthlyTemperatureData data, _) =>
                    data.monthYear,
                yValueMapper: (MonthlyTemperatureData data, _) => data.gddSum,
                innerRadius: '0%',
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.normal,
                    fontFamily: ('arial'),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}

List<MonthlyTemperatureData> computeRemainingGdd(
    List<MonthlyTemperatureData> data) {
  List<MonthlyTemperatureData> remainingData = [];
  for (var monthData in data) {
    remainingData
        .add(monthData.copyWith(gddSum: monthData.maxGdd - monthData.gddSum));
  }
  return remainingData;
}

class MonthlyTempChart extends StatelessWidget {
  final List<MonthlyTemperatureData> monthlyTemperatureData;
  final List<MonthlyTemperatureData> cumulativeData;
  final List<MonthlyTemperatureData> remainingData;

  MonthlyTempChart({
    Key? key,
    required this.monthlyTemperatureData,
  })  : cumulativeData = computeCumulativeGddSum(monthlyTemperatureData),
        remainingData = computeRemainingGdd(monthlyTemperatureData),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 300,
        child: SfCartesianChart(
          title: ChartTitle(text: 'GDD vs Max GDD'),
          primaryXAxis: CategoryAxis(
            labelRotation: 30,
          ),
          primaryYAxis: NumericAxis(
            title: AxisTitle(text: 'GDD'),
          ),
          zoomPanBehavior: ZoomPanBehavior(
            enableDoubleTapZooming: true,
            enablePanning: true,
            enablePinching: true,
          ),
          series: <ChartSeries>[
            StackedColumn100Series<MonthlyTemperatureData, String>(
              dataSource: cumulativeData,
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
            // Second series for the remaining value (maxGdd - gddSum)
            StackedColumn100Series<MonthlyTemperatureData, String>(
              dataSource: remainingData,
              xValueMapper: (MonthlyTemperatureData data, _) =>
                  thFormatDateMonth(data.documentID),
              yValueMapper: (MonthlyTemperatureData data, _) =>
                  data.maxGdd - data.gddSum,
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
        title: ChartTitle(text: 'Temperature Range วัน'),
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
          RangeColumnSeries<TemperatureData, String>(
            dataSource: widget.temperatureData,
            xValueMapper: (TemperatureData data, _) =>
                thFormatDateShort(data.documentID),
            lowValueMapper: (TemperatureData data, _) => data.minTemp,
            highValueMapper: (TemperatureData data, _) => data.maxTemp,
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
          title: ChartTitle(text: 'Growing Degree Days (GDD) วัน'),
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
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
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
          title: ChartTitle(text: 'Growing Degree Days (GDD) เดือน'),
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
