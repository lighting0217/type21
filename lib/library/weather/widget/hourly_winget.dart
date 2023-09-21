import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controller/global_controller.dart';
import '../models/hourly_weather_data.dart';
import '../util/custom_colors.dart';

class HourlyDataWidget extends StatefulWidget {
  final HourlyWeatherData? hourlyWeatherData;

  const HourlyDataWidget({Key? key, this.hourlyWeatherData}) : super(key: key);

  @override
  State<HourlyDataWidget> createState() => _HourlyDataWidgetState();
}

class _HourlyDataWidgetState extends State<HourlyDataWidget> {
  final GlobalController globalController = Get.find();
  late RxInt cardIndex;

  @override
  void initState() {
    cardIndex = globalController.getIndex();
    super.initState();
  }

  Widget hourlyList() {
    return Container(
      height: 150,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.hourlyWeatherData!.hourly.length.clamp(0, 12),
        itemBuilder: (context, index) {
          return Obx(() {
            final isCardSelected = cardIndex.value == index;
            return GestureDetector(
              onTap: () {
                cardIndex.value = index;
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 80,
                margin: const EdgeInsets.only(left: 15, right: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0.5, 0),
                      blurRadius: 30,
                      spreadRadius: 1,
                      color: CustomColors.dividerLine.withAlpha(150),
                    ),
                  ],
                  gradient: isCardSelected
                      ? const LinearGradient(
                    colors: [
                      CustomColors.firstGradientColor,
                      CustomColors.secondGradientColor,
                    ],
                  )
                      : null,
                ),
                child: HourlyDetails(
                  index: index,
                  cardindex: cardIndex.value,
                  tmp: widget.hourlyWeatherData!.hourly[index].temp!,
                  timeStamp: widget.hourlyWeatherData!.hourly[index].dt!,
                  icon:
                  widget.hourlyWeatherData!.hourly[index].weather![0].icon!,
                ),
              ),
            );
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.topCenter,
          child: const Text(
            'Today',
            style: TextStyle(fontSize: 18),
          ),
        ),
        hourlyList(),
      ],
    );
  }
}

class HourlyDetails extends StatelessWidget {
  final double tmp;
  final int timeStamp;
  final String icon;
  final int index;
  final int cardindex;

  const HourlyDetails({
    Key? key,
    required this.tmp,
    required this.icon,
    required this.timeStamp,
    required this.index,
    required this.cardindex,
  }) : super(key: key);

  String getTime(int dt) {
    final dd = DateTime.fromMillisecondsSinceEpoch(dt * 1000);
    final time = DateFormat.jm().format(dd);
    return time;
  }

  @override
  Widget build(BuildContext context) {
    final isCardSelected = index == cardindex;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 10),
          child: Text(
            getTime(timeStamp),
            style: isCardSelected
                ? const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)
                : null,
          ),
        ),
        Container(
          margin: const EdgeInsets.all(5),
          child: Image.asset(
            "assets/weather/$icon.png",
            height: 40,
            width: 40,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Text(
            '$tmp°',
            style: isCardSelected
                ? const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)
                : null,
          ),
        ),
      ],
    );
  }
}
