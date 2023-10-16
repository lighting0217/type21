import 'calendar_screen.dart';
import 'temp_chart_screen.dart';
import 'package:flutter/material.dart';
import '../../../library/colors_schema.dart';
import '../../../library/th_format_date.dart';
import '../../../models/temp_data_models.dart';
import 'package:google_fonts/google_fonts.dart';

class TemperatureScreen extends StatelessWidget {
  final List<TemperatureData> temperatureData;
  final List<MonthlyTemperatureData> monthlyTemperatureData;
  final List<AccumulatedGddData> accumulatedGddData;
  final List<Field> field;
  final double riceMaxGdd;

  const TemperatureScreen({
    Key? key,
    required this.temperatureData,
    required this.monthlyTemperatureData,
    required this.accumulatedGddData,
    required this.field,
    required this.riceMaxGdd,
  }) : super(key: key);

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
      subtitle: Text('GDD รายเดือน: $gdd °C\n'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ข้อมูลอุณหภูมิ',
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
        child: temperatureData.isEmpty
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
                        return _buildDailyTemperatureTile(
                            temperatureData[index]);
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
                    riceMaxGdd: riceMaxGdd,
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
