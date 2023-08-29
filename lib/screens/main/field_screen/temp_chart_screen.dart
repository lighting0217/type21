import 'package:flutter/material.dart';
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
    List<MonthlyTemperatureData> modifiedData =
        computeCumulativeGddSum(widget.monthlyTemperatureData);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Temperature Charts',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        children: [
          SizedBox(
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
          ),
          const SizedBox(height: 20),
          SizedBox(
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
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
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
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
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
                  dataSource: modifiedData,
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
                  dataSource: modifiedData,
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
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            child: Column(children: [
              Expanded(
                child: MinMaxTempChart(temperatureData: widget.temperatureData),
              ),
              const SizedBox(height: 20),
              MonthlyAgddChart(
                  monthlyTemperatureData: widget.monthlyTemperatureData),
            ]),
          )
        ],
      ),
    );
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

class MinMaxTempChart extends StatefulWidget {
  final List<TemperatureData> temperatureData;

  const MinMaxTempChart({
    Key? key,
    required this.temperatureData,
  }) : super(key: key);

  @override
  State<MinMaxTempChart> createState() => _MinMaxTempChartState();
}

class _MinMaxTempChartState extends State<MinMaxTempChart>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _months.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: _months.map((month) => Tab(text: month)).toList(),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _months.map((month) {
              // Filter temperature data based on the selected month
              final filteredData = widget.temperatureData.where((data) {
                final formattedDate = thFormatDate(data.documentID);
                return formattedDate.contains(month);
              }).toList();

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
                      dataSource: filteredData,
                      xValueMapper: (TemperatureData data, _) =>
                          thFormatDate(data.documentID),
                      highValueMapper: (TemperatureData data, _) =>
                          data.maxTemp,
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
            }).toList(),
          ),
        ),
      ],
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