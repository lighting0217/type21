import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/global_controller.dart';
import '../library/weather/widget/comfort.dart';
import '../library/weather/widget/current_winget.dart';
import '../library/weather/widget/daily_forecast.dart';
import '../library/weather/widget/header.dart';
import '../library/weather/widget/hourly_winget.dart';
import '../library/weather/widget/sun.dart';

class WeatherScreen extends StatelessWidget {
  WeatherScreen({Key? key}) : super(key: key);

  final globalController = Get.put(GlobalController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('My Weather')),
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
                  hourlyWeatherData: globalController.getWeatherData().hourlyWeatherData(),
                ),
                SunInfo(
                  currentWeatherData: globalController.getWeatherData().currentWeatherData(),
                ),
                DailyForecast(
                  dailyWeatherData: globalController.getWeatherData().dailyWeatherData(),
                ),
                const Divider(),
                ComfortLevel(
                  currentWeatherData: globalController.getWeatherData().currentWeatherData(),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
