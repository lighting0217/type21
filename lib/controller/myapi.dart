// ignore_for_file: file_names

import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../library/weather/models/cwd.dart';
import '../library/weather/models/dwd.dart';
import '../library/weather/models/hwd.dart';
import '../library/weather/models/wd.dart';

// Google API key for location services
const googleAPIKey = "AIzaSyBN5RgBSi2pq5KGV0E8kLsYlIx0h2KHMZk";
// OpenWeatherMap API key for weather data
const openWeatherAPIKey = "a7296ca666d968ee7312a3565a3a28fa";

class Constants {
  static String appId = " ";
  static String apiKey = " ";
  static String messagingSenderId = " ";
  static String projectId = " ";
}

class WeatherDataFetcher {
  Future<WeatherData> fetchData(double lat, double lng) async {
    final url = _buildAPIUrl(lat, lng);
    final response = await http.get(Uri.parse(url));
    final jsonData = jsonDecode(response.body);

    // Extract current weather data from the JSON
    final currentWeatherData = CurrentWeatherData.fromJson(jsonData);

    // Extract hourly weather data from the JSON
    final hourlyWeatherData = HourlyWeatherData.fromJson(jsonData);

    // Extract daily weather data from the JSON
    final dailyWeatherData = DailyWeatherData.fromJson(jsonData);

    // Return the combined weather data
    return WeatherData(currentWeatherData, hourlyWeatherData, dailyWeatherData);
  }

  String _buildAPIUrl(double lat, double lng) {
    return "https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$lng&appid=$openWeatherAPIKey&exclude=minutely&units=metric";
  }
}

class GoogleServices {
  Future<Position> getCurrentLocation() async {
    // Get the current device location using Geolocator package
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return position;
  }
}

/*เพิ่มมาแก้บั็คเปิดแอปไม่ได้
 Error: Assertion failed:
file:///C:/Users/light/AppData/Local/Pub/Cache/hosted/pub.dev/firebase_core_web-2.5.0/lib/src/firebase_core_web.dart:256
:11
options != null
*/
