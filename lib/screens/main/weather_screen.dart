import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:type21/controller/global_controller.dart';
import 'package:type21/library/weather/widget/comfort.dart';
import 'package:type21/library/weather/widget/current_winget.dart';
import 'package:type21/library/weather/widget/daily_forecast.dart';
import 'package:type21/library/weather/widget/header.dart';
import 'package:type21/library/weather/widget/hourly_winget.dart';
import 'package:type21/library/weather/widget/sun.dart'; // Import Google Fonts

class WeatherScreen extends StatelessWidget {
  WeatherScreen({Key? key}) : super(key: key);

  final globalController = Get.put(GlobalController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Weather',
          style: GoogleFonts.openSans(fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(
        () {
          if (globalController.checkStatus().isTrue) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/icons/clouds.png'),
                  const SizedBox(height: 10),
                  const CircularProgressIndicator(),
                ],
              ),
            );
          } else {
            return ListView(
              scrollDirection: Axis.vertical,
              children: [
                const SizedBox(height: 20),
                const HeaderSc(),
                CurrentWeatherWidget(
                  globalController.getWeatherData().currentWeatherData(),
                ),
                const SizedBox(height: 20),
                HourlyDataWidget(
                  hourlyWeatherData:
                      globalController.getWeatherData().hourlyWeatherData(),
                ),
                SunInfo(
                  currentWeatherData:
                      globalController.getWeatherData().currentWeatherData(),
                ),
                DailyForecast(
                  dailyWeatherData:
                      globalController.getWeatherData().dailyWeatherData(),
                ),
                const Divider(),
                ComfortLevel(
                  currentWeatherData:
                      globalController.getWeatherData().currentWeatherData(),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}