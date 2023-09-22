import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:type21/library/th_format_date.dart';
import 'package:type21/screens/main/field_screen/calendar_screen.dart';
import 'package:type21/screens/main/field_screen/temp_chart_screen.dart';

import '../../../models/temp_data_models.dart';

/// A screen widget that displays temperature data in Thai language format.
///
/// This screen displays daily and monthly temperature data, as well as GDD (Growing Degree Days) data.
/// The temperature data is passed as a list of [TemperatureData] objects, while the monthly temperature data is passed as a list of [MonthlyTemperatureData] objects.
/// The accumulated GDD data is passed as a list of [AccumulatedGddData] objects, and the field data is passed as a list of [Field] objects.
/// If there is no temperature data, a message will be displayed indicating that no data was found.
/// The screen also contains two floating action buttons, one for navigating to a temperature chart screen and the other for navigating to a calendar screen.
class TemperatureScreen extends StatelessWidget {
  final List<TemperatureData> temperatureData;
  final List<MonthlyTemperatureData> monthlyTemperatureData;
  final List<AccumulatedGddData> accumulatedGddData;
  final List<Field> field;

  const TemperatureScreen({
    Key? key,
    required this.temperatureData,
    required this.monthlyTemperatureData,
    required this.accumulatedGddData,
    required this.field,
  }) : super(key: key);

  /// Builds a [ListTile] widget for daily temperature data.
  ///
  /// The [TemperatureData] object is passed as a parameter, and the formatted date, maximum temperature, minimum temperature, and GDD are extracted from the object.
  /// The formatted date is obtained using the [thFormatDate] function, while the maximum temperature, minimum temperature, and GDD are formatted to two decimal places using the [toStringAsFixed] method.
  /// The formatted date is displayed as the title of the [ListTile], while the maximum temperature, minimum temperature, and GDD are displayed as the subtitle.
  Widget _buildDailyTemperatureTile(TemperatureData temperature) {
    final formattedDate = thFormatDate(temperature.documentID);
    final maxTemp = temperature.maxTemp.toStringAsFixed(2);
    final minTemp = temperature.minTemp.toStringAsFixed(2);
    final gdd = temperature.gdd.toStringAsFixed(2);
    return ListTile(
      title: Text(
        formattedDate,
        style: GoogleFonts.openSans(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text('อุณหภูมิสูงสุด: $maxTemp °C\n'
          'อุณหภูมิต่ำสุด: $minTemp °C\n'
          'GDD: $gdd °C\n'),
    );
  }

  /// Builds a [ListTile] widget for monthly temperature data.
  ///
  /// The [MonthlyTemperatureData] object is passed as a parameter, and the formatted date and GDD are extracted from the object.
  /// The formatted date is obtained using the [thFormatDateMonth] function, while the GDD is formatted to two decimal places using the [toStringAsFixed] method.
  /// The formatted date is displayed as the title of the [ListTile], while the GDD is displayed as the subtitle.
  Widget _buildMonthlyTemperatureTile(
      MonthlyTemperatureData monthlyTemperature) {
    final formattedDate = thFormatDateMonth(monthlyTemperature.documentID);
    final gdd = monthlyTemperature.gddSum.toStringAsFixed(2);
    return ListTile(
      title: Text(
        formattedDate,
        style: GoogleFonts.openSans(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text('(คาดการ์ณ) GDD รายเดือน: $gdd °C\n'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ข้อมูลอุณหภูมิ (รูปแบบภาษาไทย)',
          style: GoogleFonts.openSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: temperatureData.isEmpty
          ? Center(
              child: Text(
                'ไม่พบข้อมูลอุณหภูมิ',
                style: GoogleFonts.openSans(fontSize: 18),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: temperatureData.length,
                    itemBuilder: (context, index) {
                      return _buildDailyTemperatureTile(temperatureData[index]);
                    },
                  ),
                ),
                const SizedBox(height: 10),
                const Center(child: Text('GDD รายเดือน')),
                Expanded(
                  child: ListView.builder(
                    itemCount: monthlyTemperatureData.length,
                    itemBuilder: (context, index) {
                      return _buildMonthlyTemperatureTile(
                          monthlyTemperatureData[index]);
                    },
                  ),
                )
              ],
            ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TempChartScreen(
                    temperatureData: temperatureData,
                    monthlyTemperatureData: monthlyTemperatureData,
                    accumulatedGddData: accumulatedGddData,
                    field: field,
                    maxGdd: field.isNotEmpty ? field[0].maxGdd ?? 0 : 0,
                  ),
                ),
              );
            },
            backgroundColor: Colors.blue,
            heroTag: null,
            child: const Icon(Icons.navigate_next),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CalendarScreen(
                    temperatureData: temperatureData,
                    monthlyTemperatureData: monthlyTemperatureData,
                    accumulatedGddData: accumulatedGddData,
                    field: field,
                  ),
                ),
              );
            },
            heroTag: null,
            child: const Icon(Icons.calendar_month_rounded),
          ),
        ],
      ),
    );
  }
}
