//Weather Data Fie

import 'current_weather_data.dart';
import 'daily_weather_data.dart';
import 'hourly_weather_data.dart';
import 'location_name.dart';

class WeatherData {
  CurrentWeatherData? current;
  HourlyWeatherData? hourly;
  DailyWeatherData? daily;
  LocationNameData? lname;

  WeatherData([this.current, this.hourly, this.daily, this.lname]);

  CurrentWeatherData currentWeatherData() => current!;

  HourlyWeatherData hourlyWeatherData() => hourly!;

  DailyWeatherData dailyWeatherData() => daily!;

  LocationNameData locationNameData() => lname!;
}
