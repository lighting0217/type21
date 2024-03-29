import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../library/colors_schema.dart';
import '../../../library/th_format_date.dart';
import '../../../models/temp_data_models.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TempChartScreen extends StatefulWidget {
  final List<TemperatureData> temperatureData;
  final List<MonthlyTemperatureData> monthlyTemperatureData;
  final List<AccumulatedGddData> accumulatedGddData;
  final double riceMaxGdd;

  const TempChartScreen({
    super.key,
    required this.temperatureData,
    required this.monthlyTemperatureData,
    required this.accumulatedGddData,
    required List<Field> field,
    required this.riceMaxGdd,
  });

  @override
  State<TempChartScreen> createState() => _TempChartScreenState();
}

class _TempChartScreenState extends State<TempChartScreen> {
  DateTime selectedDate = DateTime.now();
  List<TemperatureData> filteredTemperatureData = [];

  @override
  void initState() {
    super.initState();
    _filterDataByMonth();
  }

  _filterDataByMonth() {
    setState(() {
      filteredTemperatureData = widget.temperatureData
          .where((data) =>
              data.date.month == selectedDate.month &&
              data.date.year == selectedDate.year)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'แผนภูมิอุณหภูมิ',
          style: GoogleFonts.openSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: myColorScheme.primary,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: myGradient,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildMonthPicker(),
              const SizedBox(height: 20),
              _buildChartSection(
                  TempRangedChart(temperatureData: filteredTemperatureData)),
              const SizedBox(height: 20),
              _buildChartSection(
                  DayGddChart(temperatureData: filteredTemperatureData)),
              const SizedBox(
                height: 20,
              ),
              _buildChartSection(MonthlyAgddPieChart(
                monthlyTemperatureData: widget.monthlyTemperatureData,
                accumulatedGddData: widget.accumulatedGddData,
              )),
              const SizedBox(
                height: 20,
              ),
              _buildChartSection(RemainingGDD(
                monthlyTemperatureData: widget.monthlyTemperatureData,
                accumulatedGddData: widget.accumulatedGddData,
                riceMaxGdd: widget.riceMaxGdd,
              )),
              const SizedBox(
                height: 20,
              ),
              _buildChartSection(MonthGddChart(
                  monthlyTemperatureData: widget.monthlyTemperatureData)),
            ],
          ),
        ),
      ),
    );
  }

  String getThaiMonth(int month) {
    List<String> thaiMonths = [
      'มกราคม',
      'กุมภาพันธ์',
      'มีนาคม',
      'เมษายน',
      'พฤษภาคม',
      'มิถุนายน',
      'กรกฎาคม',
      'สิงหาคม',
      'กันยายน',
      'ตุลาคม',
      'พฤศจิกายน',
      'ธันวาคม'
    ];
    return thaiMonths[month - 1];
  }

  Widget _buildChartSection(Widget chart) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: SizedBox(height: 400, child: chart),
    );
  }

  Widget _buildMonthPicker() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_left),
          onPressed: () {
            setState(() {
              selectedDate =
                  DateTime(selectedDate.year, selectedDate.month - 1);
              _filterDataByMonth();
            });
          },
        ),
        Expanded(
          child: Center(
            child: Text(
              "${getThaiMonth(selectedDate.month)} ${selectedDate.year}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_right),
          onPressed: () {
            setState(() {
              selectedDate =
                  DateTime(selectedDate.year, selectedDate.month + 1);
              _filterDataByMonth();
            });
          },
        ),
      ],
    );
  }
}

double calculatePercent(
    AccumulatedGddData accumulatedGddData, double riceMaxGdd) {
  return (accumulatedGddData.accumulatedGdd / riceMaxGdd) * 100;
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

// Pie chart ที่รวมGDD ทุกเดือน
class MonthlyAgddPieChart extends StatelessWidget {
  final List<MonthlyTemperatureData> monthlyTemperatureData;
  final List<AccumulatedGddData> accumulatedGddData;

  const MonthlyAgddPieChart({
    super.key,
    required this.monthlyTemperatureData,
    required this.accumulatedGddData,
  });

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print(
          'Month Year date:${monthlyTemperatureData.map((data) => data.monthYear).toList()}');
      print(
          'Accumulated Gdd is:${accumulatedGddData.map((data) => data.accumulatedGdd).toList()}');
    }
    double totalAccumulatedGdd =
        accumulatedGddData.fold(0, (sum, item) => sum + item.accumulatedGdd);
    return SizedBox(
      height: 350,
      child: SizedBox(
        height: 350,
        child: SfCircularChart(
          title: ChartTitle(
              text: 'ค่าGDDสะสม \n${totalAccumulatedGdd.toStringAsFixed(2)}'),
          series: <CircularSeries>[
            PieSeries<MonthlyTemperatureData, String>(
              dataSource: monthlyTemperatureData,
              xValueMapper: (MonthlyTemperatureData data, _) => data.monthYear,
              yValueMapper: (MonthlyTemperatureData data, _) => data.gddSum,
              radius: '65%',
              dataLabelMapper: (MonthlyTemperatureData data, _) =>
                  '${thFormatDateMonthShort(data.monthYear)}\n${data.gddSum.toStringAsFixed(2)}',
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                connectorLineSettings: ConnectorLineSettings(
                    type: ConnectorType.line, color: Colors.black, width: 1),
                labelIntersectAction: LabelIntersectAction.shift,
                labelAlignment: ChartDataLabelAlignment.auto,
                labelPosition: ChartDataLabelPosition.outside,
                textStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
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

//piechrt ที่แสดงค่าGDD ทั้งหมด เทียบกับ GDD ที่เหลือ
class RemainingGDD extends StatelessWidget {
  final List<MonthlyTemperatureData> monthlyTemperatureData;
  final List<AccumulatedGddData> accumulatedGddData;
  final double riceMaxGdd;

  const RemainingGDD({
    super.key,
    required this.monthlyTemperatureData,
    required this.accumulatedGddData,
    required this.riceMaxGdd,
  });

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print(
          'Month Year date:${monthlyTemperatureData.map((data) => data.monthYear).toList()}');
      print(
          'Accumulated Gdd is:${accumulatedGddData.map((data) => data.accumulatedGdd).toList()}');
    }
    double totalAccumulatedGdd =
        accumulatedGddData.fold(0, (sum, item) => sum + item.accumulatedGdd);
    double remainingGdd = riceMaxGdd - totalAccumulatedGdd;

    if (remainingGdd <= 0) {
      remainingGdd = 0;
      return SizedBox(
        height: 380,
        child: Column(
          children: [
            const SizedBox(
              height: 22,
              child: Center(
                child: Text(
                  'ถึงเวลาเก็บเกี่ยวแล้ว',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 350,
              child: SfCircularChart(
                title: ChartTitle(
                    text:
                        'ค่าGDD สะสม \n${totalAccumulatedGdd.toStringAsFixed(2)}\nค่าGDD ที่เหลือ\n${remainingGdd.toStringAsFixed(2)}'),
                series: <CircularSeries>[
                  PieSeries<ChartData, String>(
                    dataSource: [
                      ChartData('GDD สะสม', totalAccumulatedGdd),
                      ChartData('GDD ที่เหลือ', remainingGdd),
                    ],
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y,
                    radius: '95%',
                    dataLabelMapper: (ChartData data, _) =>
                        '${data.x}\n${data.y.toStringAsFixed(2)}',
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      connectorLineSettings: ConnectorLineSettings(
                          type: ConnectorType.line,
                          color: Colors.black,
                          width: 1),
                      labelIntersectAction: LabelIntersectAction.shift,
                      labelAlignment: ChartDataLabelAlignment.auto,
                      labelPosition: ChartDataLabelPosition.outside,
                      textStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Jasmine',
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return SizedBox(
        height: 355,
        child: SizedBox(
          height: 350,
          child: SfCircularChart(
            title: ChartTitle(
                text:
                    'ค่าGDD สะสม \n${totalAccumulatedGdd.toStringAsFixed(2)}\nค่าGDD ที่เหลือ\n${remainingGdd.toStringAsFixed(2)}'),
            series: <CircularSeries>[
              PieSeries<ChartData, String>(
                dataSource: [
                  ChartData('GDD สะสม', totalAccumulatedGdd),
                  ChartData('GDD ที่เหลือ', remainingGdd),
                ],
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y,
                radius: '100%',
                dataLabelMapper: (ChartData data, _) =>
                    '${data.x}\n${data.y.toStringAsFixed(2)}',
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  connectorLineSettings: ConnectorLineSettings(
                      type: ConnectorType.line, color: Colors.black, width: 1),
                  labelIntersectAction: LabelIntersectAction.shift,
                  labelAlignment: ChartDataLabelAlignment.auto,
                  labelPosition: ChartDataLabelPosition.outside,
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
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
}

class ChartData {
  final String x;
  final double y;

  const ChartData(this.x, this.y);
}

// Ranged chart ของอุณหภูมิรายวัน
class TempRangedChart extends StatefulWidget {
  final List<TemperatureData> temperatureData;

  const TempRangedChart({super.key, required this.temperatureData});

  @override
  State<TempRangedChart> createState() => _TempRangedChartState();
}

class _TempRangedChartState extends State<TempRangedChart> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: SfCartesianChart(
        title: const ChartTitle(text: 'ช่วงอุณหภูมิของวัน'),
        primaryXAxis: const CategoryAxis(
          labelRotation: 25,
        ),
        primaryYAxis: const NumericAxis(),
        zoomPanBehavior: ZoomPanBehavior(
          enableDoubleTapZooming: true,
          enablePanning: true,
          enablePinching: true,
          enableMouseWheelZooming: true,
          enableSelectionZooming: false,
        ),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          builder: (dynamic data, dynamic point, dynamic series, int pointIndex,
              int seriesIndex) {
            TemperatureData tempData = data;
            return Card(
              color: Colors.blue,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      thFormatDateShort(tempData.documentID),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${tempData.minTemp.toStringAsFixed(2)} - ${tempData.maxTemp.toStringAsFixed(3)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        // Change the list type to `List<CartesianSeries>`
        series: <CartesianSeries>[
          RangeColumnSeries<TemperatureData, String>(
            dataSource: widget.temperatureData,
            xValueMapper: (TemperatureData data, _) =>
                thFormatDateShort(data.documentID),
            lowValueMapper: (TemperatureData data, _) => data.minTemp,
            highValueMapper: (TemperatureData data, _) => data.maxTemp,
            enableTooltip: true,
            dataLabelSettings: const DataLabelSettings(
              isVisible: false,
              labelAlignment: ChartDataLabelAlignment.middle,
              labelPosition: ChartDataLabelPosition.outside,
              labelIntersectAction: LabelIntersectAction.hide,
              overflowMode: OverflowMode.hide,
              angle: 90,
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                fontFamily: 'Jasmine',
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// Gdd ต่อ วัน แบบ Column Chart
class DayGddChart extends StatefulWidget {
  final List<TemperatureData> temperatureData;

  const DayGddChart({super.key, required this.temperatureData});

  @override
  State<DayGddChart> createState() => _DayGddChartState();
}

class _DayGddChartState extends State<DayGddChart> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 300,
        child: SfCartesianChart(
          title: const ChartTitle(text: 'Growing Degree Days (GDD)/วัน'),
          primaryXAxis: const CategoryAxis(
            labelRotation: 25,
          ),
          primaryYAxis: const NumericAxis(
            labelFormat: '{value}°C', // Adjust label format as needed
          ),
          zoomPanBehavior: ZoomPanBehavior(
            enableDoubleTapZooming: true,
            enablePanning: true,
            enablePinching: true,
          ),
          tooltipBehavior: TooltipBehavior(
            enable: true,
            builder: (dynamic data, dynamic point, dynamic series, int pointIndex,
                int seriesIndex) {
              TemperatureData tempData = data;
              return Card(
                color: Colors.blue,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        thFormatDateShort(tempData.documentID),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'GDD: ${tempData.gdd.toStringAsFixed(2)}°C',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          series: <ColumnSeries<TemperatureData, String>>[
            ColumnSeries<TemperatureData, String>(
              dataSource: widget.temperatureData,
              xValueMapper: (TemperatureData data, _) =>
                  thFormatDateShort(data.documentID),
              yValueMapper: (TemperatureData data, _) => data.gdd,
              dataLabelSettings: const DataLabelSettings( // Adjust visibility as needed
                isVisible: false,
                labelAlignment: ChartDataLabelAlignment.outer,
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Jasmine',
                ),
              ),
            ),
          ],
        ));
  }
}


// Gdd ต่อ เดือนแบบ Column Chart
class MonthGddChart extends StatefulWidget {
  final List<MonthlyTemperatureData> monthlyTemperatureData;

  const MonthGddChart({super.key, required this.monthlyTemperatureData});

  @override
  State<MonthGddChart> createState() => _MonthGddChartState();
}

class _MonthGddChartState extends State<MonthGddChart> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 300,
        child: SfCartesianChart(
          title: const ChartTitle(text: 'Growing Degree Days (GDD)/เดือน'),
          primaryXAxis: const CategoryAxis(
            labelRotation: 30,
          ),
          primaryYAxis: const NumericAxis(),
          zoomPanBehavior: ZoomPanBehavior(
            enableDoubleTapZooming: true,
            enablePanning: true,
            enablePinching: true,
          ),
          series: <CartesianSeries<MonthlyTemperatureData, String>>[
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
