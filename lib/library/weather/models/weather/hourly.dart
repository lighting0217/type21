import 'weather.dart';

class Hourly {
  int? dt;
  double? temp;
  double? feelsLike;
  int? pressure;
  int? humidity;
  double? dewPoint;
  double? uvi;
  int? clouds;
  int? visibility;
  double? windSpeed;
  int? windDeg;
  double? windGust;
  List<Weather>? weather;
  int? pop;

  Hourly({
    this.dt,
    this.temp,
    this.feelsLike,
    this.pressure,
    this.humidity,
    this.dewPoint,
    this.uvi,
    this.clouds,
    this.visibility,
    this.windSpeed,
    this.windDeg,
    this.windGust,
    this.weather,
    this.pop,
  });

  factory Hourly.fromJson(Map<String, dynamic> json) => Hourly(
        dt: json['dt'] as int?,
        temp: json['temp']?.toDouble(),
        feelsLike: json['feels_like']?.toDouble(),
        pressure: json['pressure'] as int?,
        humidity: json['humidity'] as int?,
        dewPoint: json['dew_point']?.toDouble(),
        uvi: json['uvi']?.toDouble(),
        clouds: json['clouds'] as int?,
        visibility: json['visibility'] as int?,
        windSpeed: json['wind_speed']?.toDouble(),
        windDeg: json['wind_deg'] as int?,
        windGust: json['wind_gust']?.toDouble(),
        weather: (json['weather'] as List<dynamic>?)?.map((e) => Weather.fromJson(e)).toList(),
        pop: json['pop'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'dt': dt,
        'temp': temp,
        'feels_like': feelsLike,
        'pressure': pressure,
        'humidity': humidity,
        'dew_point': dewPoint,
        'uvi': uvi,
        'clouds': clouds,
        'visibility': visibility,
        'wind_speed': windSpeed,
        'wind_deg': windDeg,
        'wind_gust': windGust,
        'weather': weather?.map((e) => e.toJson()).toList(),
        'pop': pop,
      };
}
