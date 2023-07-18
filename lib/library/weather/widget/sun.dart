import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/cwd.dart';

class SunInfo extends StatelessWidget {
  final CurrentWeatherData currentWeatherData;

  const SunInfo({Key? key, required this.currentWeatherData}) : super(key: key);

  String getTime(int x) {
    final date = DateTime.fromMillisecondsSinceEpoch(x * 1000);
    final formattedTime = DateFormat.jm().format(date);
    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/icons/sunrise.png',
          height: 80,
        ),
        Container(
          alignment: Alignment.center,
          height: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Sun Rise',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                getTime(currentWeatherData.current.sunrise!),
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        Container(
          width: 30,
        ),
        Image.asset(
          'assets/icons/sunset.png',
          height: 120,
        ),
        Container(
          alignment: Alignment.center,
          height: 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Sun Set',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                getTime(currentWeatherData.current.sunset!),
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
