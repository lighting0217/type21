import 'location_name.dart';
import 'daily_weather_data.dart';
import 'hourly_weather_data.dart';
import 'current_weather_data.dart';


class WeatherData {
  CurrentWeatherData? current;
  HourlyWeatherData? hourly;
  DailyWeatherData? daily;
  LocationNameData? lname;

  WeatherData([this.current, this.hourly, this.daily, this.lname]);

  /// Returns the [CurrentWeatherData] instance for this weather data.
  CurrentWeatherData currentWeatherData() => current!;

  /// Returns the [HourlyWeatherData] instance for this weather data.
  HourlyWeatherData hourlyWeatherData() => hourly!;

  /// Returns the [DailyWeatherData] instance for this weather data.
  DailyWeatherData dailyWeatherData() => daily!;

  /// Returns the [LocationNameData] instance for this weather data.
  LocationNameData locationNameData() => lname!;
}
