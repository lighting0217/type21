//Weather Data Fie

import 'cwd.dart';
import 'dwd.dart';
import 'hwd.dart';

class WeatherData {
  CurrentWeatherData? current;
  HourlyWeatherData? hourly;
  DailyWeatherData? daily;

  WeatherData([this.current, this.hourly, this.daily]);

  CurrentWeatherData currentWeatherData() => current!;

  HourlyWeatherData hourlyWeatherData() => hourly!;

  DailyWeatherData dailyWeatherData() => daily!;
}
