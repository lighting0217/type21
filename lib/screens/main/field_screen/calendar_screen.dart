import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
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
    final threshold = (0.9 * maxGdd);
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
        title: const Text('Calendar Screen'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2023, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            onDaySelected: _onDaySelected,
          ),
        ],
      ),
    );
  }
}
