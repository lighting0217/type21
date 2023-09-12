import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:type21/library/th_format_date.dart';
import 'package:type21/models/temp_data_models.dart';

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
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });
    Field? selectedField;
    for (var field in widget.field) {
      if (field.selectedDate?.isAtSameMomentAs(selectedDay) ?? false) {
        selectedField = field;
        break;
      }
    }

    if (selectedField != null) {
      final accumulatedGddDataForSelectedDate =
          selectedField.accumulatedGddData;
      if (accumulatedGddDataForSelectedDate.isNotEmpty) {
        final agddValue = accumulatedGddDataForSelectedDate[0].accumulatedGdd;

        if (_shouldShowAlert(agddValue, selectedField.riceMaxGdd)) {
          _showAlertDialog('ควรเก็บเกี่ยวได้แล้ว');
        }
      }
    }
  }

  bool _shouldShowAlert(double agdd, double maxGdd) {
    final threshold = (0.8 * maxGdd);
    return agdd > threshold;
  }

  void _showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(thFormatDateMonthShortNumber(
              '${_focusedDay.month}-${_focusedDay.year}')),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 500,
                child: TableCalendar(
                  firstDay: DateTime.utc(2023, 1, 1),
                  lastDay: DateTime.utc(2023, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  onDaySelected: (selectedDay, focusedDay) {
                    _onDaySelected(selectedDay, focusedDay);
                  },
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, date, _) {
                      final gddValue = widget.temperatureData
                          .firstWhere(
                              (data) => data.date.isAtSameMomentAs(date),
                              orElse: () => TemperatureData(
                                  date: DateTime.now(),
                                  maxTemp: 0,
                                  minTemp: 0,
                                  gdd: 0,
                                  documentID: ""))
                          .gdd;
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(date.day.toString()),
                            Text(gddValue.toString())
                          ],
                        ),
                      );
                    },
                    todayBuilder: (context, date, _) {
                      return Center(
                        child: Container(
                          margin: const EdgeInsets.all(4.0),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue,
                          ),
                          child: Center(
                            child: Text(
                              date.day.toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    },
                    selectedBuilder: (context, date, _) {
                      return Center(
                        child: Container(
                          margin: const EdgeInsets.all(4.0),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.orange,
                          ),
                          child: Center(
                            child: Text(
                              date.day.toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    },
                    markerBuilder: (context, date, _) {
                      if (widget.field.any((field) =>
                          field.forecastedHarvestDate?.isAtSameMomentAs(date) ??
                          false)) {
                        return Positioned(
                          bottom: 1,
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const SizedBox(
                height: 300,
                child: Text('Test Sized Box'),
              )
            ],
          ),
        ));
  }
}
