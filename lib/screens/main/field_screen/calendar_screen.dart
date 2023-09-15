import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';

import '../../../library/th_format_date.dart';
import '../../../models/temp_data_models.dart';

class CalendarScreen extends StatefulWidget {
  final List<TemperatureData> temperatureData;
  final List<MonthlyTemperatureData> monthlyTemperatureData;
  final List<AccumulatedGddData> accumulatedGddData;
  final List<Field> field;

  const CalendarScreen({
    Key? key,
    required this.temperatureData,
    required this.monthlyTemperatureData,
    required this.accumulatedGddData,
    required this.field,
  }) : super(key: key);

  @override
  State<CalendarScreen> createState() => _TestCalendarScreenState();
}

class _TestCalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print(widget.temperatureData);
      print(widget.monthlyTemperatureData);
      print(widget.accumulatedGddData);
      print(widget.field);
    }
  }

  double getMonthlyMinTemps(int month) {
    var filteredData = widget.temperatureData
        .where((data) => data.date.month == month)
        .toList();
    if (filteredData.isEmpty) return 0.0;
    return filteredData
        .map((data) => data.minTemp)
        .reduce((a, b) => a < b ? a : b);
  }

  double getMonthlyMaxTemps(int month) {
    var filteredData = widget.temperatureData
        .where((data) => data.date.month == month)
        .toList();
    if (filteredData.isEmpty) return 0.0;
    return filteredData
        .map((data) => data.maxTemp)
        .reduce((a, b) => a > b ? a : b);
  }

  double getMonthlyGdd(int month) {
    var filteredData = widget.temperatureData
        .where((data) => data.date.month == month)
        .toList();
    if (filteredData.isEmpty) return 0.0;
    return filteredData.map((data) => data.gdd).reduce((a, b) => a + b);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เดือน'),
      ),
      body: Column(
        children: [
          buildCalendar(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget buildCalendar() {
    return SizedBox(
        height: 400,
        child: CalendarCarousel(
          onDayPressed: (DateTime date, List<dynamic> events) {},
          thisMonthDayBorderColor: Colors.grey,
          daysTextStyle: const TextStyle(color: Colors.black),
          todayBorderColor: Colors.blue,
          todayButtonColor: Colors.blue,
          selectedDayBorderColor: Colors.orange,
          selectedDayButtonColor: Colors.orange,
          weekendTextStyle: const TextStyle(color: Colors.red),
          customDayBuilder: (bool isSelectable,
              int index,
              bool isSelectedDay,
              bool isToday,
              bool isPrevMonthDay,
              TextStyle textStyle,
              bool isNextMonthDay,
              bool isThisMonthDay,
              DateTime day) {
            final gddValue = widget.temperatureData
                .firstWhere(
                  (data) =>
                      data.date.year == day.year &&
                      data.date.month == day.month &&
                      data.date.day == day.day,
                  orElse: () => TemperatureData(
                    date: DateTime.now(),
                    maxTemp: 0,
                    minTemp: 0,
                    gdd: 0,
                    documentID: "",
                  ),
                )
                .gdd;
            return GestureDetector(
              onTap: () => _showDayDetails(day),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(day.day.toString(), style: textStyle),
                    Text(gddValue.toStringAsFixed(2)),
                  ],
                ),
              ),
            );
          },
        ));
  }

  void _showDayDetails(DateTime date) {
    final formattedDate = thFormatDateYMD(date.toIso8601String());
    final data = widget.temperatureData.firstWhere(
      (data) =>
          data.date.year == date.year &&
          data.date.month == date.month &&
          data.date.day == date.day,
      orElse: () => TemperatureData(
        date: DateTime.now(),
        maxTemp: 0,
        minTemp: 0,
        gdd: 0,
        documentID: "",
      ),
    );

    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Wrap(
          children: <Widget>[
            ListTile(
              title: Text('วันที่: $formattedDate'),
            ),
            ListTile(
              title: Text('อุณหภูมิต่ำสุดของวัน: ${data.minTemp}'),
            ),
            ListTile(
              title: Text('อุณหภูมิสูงสุดของวัน: ${data.maxTemp}'),
            ),
            ListTile(
              title: Text('ค่า GDD ของวัน: ${data.gdd}'),
            ),
          ],
        );
      },
    );
  }
}
