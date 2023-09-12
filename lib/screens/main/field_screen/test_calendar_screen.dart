import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:type21/models/temp_data_models.dart';

class TestCalendarScreen extends StatefulWidget {
  final List<TemperatureData> temperatureData;
  final List<MonthlyTemperatureData> monthlyTemperatureData;
  final List<AccumulatedGddData> accumulatedGddData;
  final List<Field> field;

  const TestCalendarScreen({
    Key? key,
    required this.temperatureData,
    required this.monthlyTemperatureData,
    required this.accumulatedGddData,
    required this.field,
  }) : super(key: key);

  @override
  State<TestCalendarScreen> createState() => _TestCalendarScreenState();
}

class _TestCalendarScreenState extends State<TestCalendarScreen> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เดือน'),
      ),
      body: CalendarCarousel(
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
                (data) => data.date.isAtSameMomentAs(day),
                orElse: () => TemperatureData(
                  date: DateTime.now(),
                  maxTemp: 0,
                  minTemp: 0,
                  gdd: 0,
                  documentID: "",
                ),
              )
              .gdd;
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(day.day.toString(), style: textStyle),
                Text(gddValue.toString()),
              ],
            ),
          );
        },
      ),
    );
  }
}
