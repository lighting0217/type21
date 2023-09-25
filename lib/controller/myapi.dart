/// This file contains the implementation of the `WeatherDataFetcher` and `GoogleServices` classes.
/// The `WeatherDataFetcher` class is responsible for fetching weather data from the OpenWeatherMap API and location name from Google Maps API.
/// The `GoogleServices` class is responsible for fetching the current location of the device using the Geolocator package.
// ignore_for_file: file_names

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../library/weather/models/current_weather_data.dart';
import '../library/weather/models/daily_weather_data.dart';
import '../library/weather/models/hourly_weather_data.dart';
import '../library/weather/models/location_name.dart';
import '../library/weather/models/weather_data.dart';

// Google API key for location services
const googleAPIKey = "AIzaSyBN5RgBSi2pq5KGV0E8kLsYlIx0h2KHMZk";
// OpenWeatherMap API key for weather data
const openWeatherAPIKey = "a7296ca666d968ee7312a3565a3a28fa";

class WeatherDataFetcher {
  Future<WeatherData> fetchData(double lat, double lng) async {
    final url = _buildAPIUrl(lat, lng);
    final response =
        await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final currentWeatherData = CurrentWeatherData.fromJson(jsonData);
      final hourlyWeatherData = HourlyWeatherData.fromJson(jsonData);
      final dailyWeatherData = DailyWeatherData.fromJson(jsonData);
      final locationNameJson = await fetchLocationName(lat, lng);
      final locationNameData = locationNameJson != null
          ? LocationNameData.fromJson(locationNameJson)
          : null;
      return WeatherData(currentWeatherData, hourlyWeatherData,
          dailyWeatherData, locationNameData);
    } else {
      throw Exception('Failed to fetch weather data: ${response.statusCode}');
    }
  }

  String _buildAPIUrl(double lat, double lng) {
    return "https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$lng&appid=$openWeatherAPIKey&exclude=minutely&units=metric&lang=th";
  }

  Future<Map<String, dynamic>?> fetchLocationName(
      double lat, double lng) async {
    try {
      final url = _buildLocationAPIUrl(lat, lng);
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse.isNotEmpty) {
          return jsonResponse[0];
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching location name: $e');
      }
      throw Exception('Failed to fetch location name: $e');
    }
  }

  String _buildLocationAPIUrl(double lat, double lng) {
    return 'https://api.openweathermap.org/geo/1.0/reverse?lat=$lat&lon=$lng&limit=1&appid=$openWeatherAPIKey&lang=th';
  }
}

class GoogleServices {
  Future<Position> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high)
          .timeout(const Duration(seconds: 10));
      return position;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current location: $e');
      }
      throw Exception('Failed to get current location: $e');
    }
  }
}
