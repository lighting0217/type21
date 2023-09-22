import 'package:type21/library/weather/models/current_weather_data.dart';
import 'package:type21/library/weather/models/daily_weather_data.dart';
import 'package:type21/library/weather/models/hourly_weather_data.dart';
import 'package:type21/library/weather/models/location_name.dart';

/// A class that represents the weather data for a location.
/// 
/// This class contains the current, hourly, and daily weather data for a location, as well as the location name.
/// 
/// The [current], [hourly], and [daily] properties are instances of [CurrentWeatherData], [HourlyWeatherData], and [DailyWeatherData] respectively.
/// 
/// The [lname] property is an instance of [LocationNameData].
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
