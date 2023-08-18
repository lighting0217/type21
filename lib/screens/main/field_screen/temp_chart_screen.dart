import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:type21/library/th_format_date.dart';

import 'field_info.dart';

class TempChartScreen extends StatefulWidget {
  final List<TemperatureData> temperatureData;
  final List<MonthlyTemperatureData> monthlyTemperatureData;

  const TempChartScreen({
    Key? key,
    required this.temperatureData,
    required this.monthlyTemperatureData,
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
                RangeColumnSeries<MonthlyTemperatureData, String>(
                  dataSource: widget.monthlyTemperatureData,
                  xValueMapper: (MonthlyTemperatureData data, _) =>
                      thFormatDateMonth(data.documentID),
                  lowValueMapper: (MonthlyTemperatureData data, _) =>
                      data.gddSum,
                  highValueMapper: (MonthlyTemperatureData data, _) =>
                      data.maxGdd,
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
              annotations: <CartesianChartAnnotation>[
                for (var monthlyData in widget.monthlyTemperatureData)
                  if (monthlyData.gddSum >= 0.5 * monthlyData.maxGdd &&
                      monthlyData.gddSum <= 1.1 * monthlyData.maxGdd)
                    CartesianChartAnnotation(
                      widget: SizedBox(
                        height: 300,
                        child: Text(
                          '${(monthlyData.gddSum / monthlyData.maxGdd * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                      coordinateUnit: CoordinateUnit.point,
                      x: monthlyData.documentID,
                      y: monthlyData.gddSum,
                      verticalAlignment: ChartAlignment.near,
                      horizontalAlignment: ChartAlignment.center,
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
