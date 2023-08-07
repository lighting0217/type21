// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import '../models/cwd.dart';

class ComfortLevel extends StatelessWidget {
  final CurrentWeatherData currentWeatherData;

  const ComfortLevel({Key? key, required this.currentWeatherData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Comfort Level',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        SleekCircularSlider(
          min: 0,
          max: 100,
          initialValue: currentWeatherData.current.humidity!.toDouble(),
          appearance: CircularSliderAppearance(
            customWidths:
                CustomSliderWidths(trackWidth: 12, progressBarWidth: 12),
            infoProperties: InfoProperties(
              bottomLabelText: "Humidity",
              bottomLabelStyle: const TextStyle(fontSize: 14),
            ),
            animationEnabled: true,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'Feels Like ${currentWeatherData.current.feels_like}',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Text(
                'UV Index ${currentWeatherData.current.uvi}',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
