
class HourlyWeatherData {
  List<Hourly> hourly;

  HourlyWeatherData({required this.hourly});

  factory HourlyWeatherData.fromJson(Map<String, dynamic> json) =>
      HourlyWeatherData(
          hourly:
              List<Hourly>.from(json['hourly'].map((e) => Hourly.fromJson(e))));
}

class Hourly {
  int? dt;
  double? temp;
  List<Weather>? weather;
  double? pop;
  Rain? rain;

  Hourly({
    this.dt,
    this.temp,
    this.weather,
    this.pop,
    this.rain,
  });

  factory Hourly.fromJson(Map<String, dynamic> json) => Hourly(
        dt: json['dt'] as int?,
        temp: _toDouble(json['temp']),
        weather: (json['weather'] as List<dynamic>?)
            ?.map((e) => Weather.fromJson(e as Map<String, dynamic>))
            .toList(),
        pop: _toDouble(json['pop']),
        rain: json['rain'] != null ? Rain.fromJson(json['rain']) : null,
      );

  Map<String, dynamic> toJson() => {
        'dt': dt,
        'temp': temp,
        'weather': weather?.map((e) => e.toJson()).toList(),
        'pop': pop,
        'rain': rain?.toJson(),
      };

  static double? _toDouble(dynamic value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else {
      return null;
    }
  }
}

class Weather {
  int? id;
  String? main;
  String? description;
  String? icon;

  Weather({this.id, this.main, this.description, this.icon});

  factory Weather.fromJson(Map<String, dynamic> json) => Weather(
        id: (json['id'] as int?),
        main: (json['main'] as String?),
        description: (json['description'] as String?),
        icon: (json['icon'] as String?),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'main': main,
        'description': description,
        'icon': icon,
      };
}

class Rain {
  double? rain1h;

  Rain({this.rain1h});

  factory Rain.fromJson(Map<String, dynamic> json) => Rain(
        rain1h: json['1h'] is int
            ? (json['1h'] as int).toDouble()
            : (json['1h'] as double?),
      );

  Map<String, dynamic> toJson() => {
        '1h': rain1h,
      };
}
