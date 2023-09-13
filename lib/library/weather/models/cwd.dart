// ignore_for_file: non_constant_identifier_names

class CurrentWeatherData {
  final Current current;

  CurrentWeatherData({required this.current});

  factory CurrentWeatherData.fromJson(Map<String, dynamic> json) =>
      CurrentWeatherData(current: Current.fromJson(json['current']));
}

class Current {
  int? temp;
  double? feels_like;
  double? uvi;
  int? humidity;
  int? sunrise;
  int? sunset;
  int? clouds;
  double? windSpeed;
  List<Weather>? weather;

  Current({
    this.temp,
    this.humidity,
    this.clouds,
    this.windSpeed,
    this.weather,
    this.feels_like,
    this.sunrise,
    this.sunset,
    this.uvi,
  });

  factory Current.fromJson(Map<String, dynamic> json) => Current(
        temp: (json['temp'] as num?)?.round(),
        humidity: json['humidity'] as int?,
        clouds: json['clouds'] as int?,
        sunrise: json['sunrise'] as int?,
        sunset: json['sunset'] as int?,
        uvi: (json['uvi'] as num?)?.toDouble(),
        feels_like: (json['feels_like'] as num?)?.toDouble(),
        windSpeed: (json['wind_speed'] as num?)?.toDouble(),
        weather: (json['weather'] as List<dynamic>?)
            ?.map((e) => Weather.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'temp': temp,
        'humidity': humidity,
        'clouds': clouds,
        'wind_speed': windSpeed,
        'weather': weather?.map((e) => e.toJson()).toList(),
        'uvi': uvi,
        'feels_like': feels_like,
        'sunrise': sunrise,
        'sunset': sunset,
      };
}

class Weather {
  int? id;
  String? main;
  String? description;
  String? icon;

  Weather({this.id, this.main, this.description, this.icon});

  factory Weather.fromJson(Map<String, dynamic> json) => Weather(
        id: json['id'] as int?,
        main: json['main'] as String?,
        description:
            _translateDescriptionToThai(json['description'] as String?),
        icon: json['icon'] as String?,
      );

  static String? _translateDescriptionToThai(String? description) {
    final Map<String, String> weatherDescriptionsToThai = {
      "clear sky": "ท้องฟ้าแจ่มใส",
      "few clouds": "มีเมฆบางส่วน",
      "scattered clouds": "เมฆกระจัดกระจาย",
      "broken clouds": "มีเมฆมาก",
      "shower rain": "ฝนตกปรอย ๆ",
      "rain": "ฝนตก",
      "light rain": "ฝนตกเบา ๆ",
      "moderate rain": "ฝนตกปานกลาง",
      "heavy intensity rain": "ฝนตกหนัก",
      "very heavy rain": "ฝนตกหนักมาก",
      "extreme rain": "ฝนตกหนักมาก",
      "freezing rain": "ฝนตกหนักมาก",
      "light intensity shower rain": "ฝนตกปรอยเบาๆ",
      "heavy intensity shower rain": "ฝนตกปรอย",
      "ragged shower rain": "ฝนตกปรอยเป็นบางส่วน",
      "thunderstorm": "ฝนฟ้าคะนอง",
      "thunderstorm with light rain": "ฝนฟ้าคะนองพร้อมฝนเบา",
      "thunderstorm with rain": "ฝนฟ้าคะนองพร้อมฝนตก",
      "thunderstorm with heavy rain": "ฝนฟ้าคะนองพร้อมฝนตกหนัก",
      "light thunderstorm": "ฝนฟ้าคะนองเบา ๆ",
      "heavy thunderstorm": "ฝนฟ้าคะนองหนัก",
      "ragged thunderstorm": "ฝนฟ้าคะนองเป็นบางส่วน",
      "drizzle": "ฝนพรำ",
      "light intensity drizzle": "ฝนพรำเบาๆ",
      "heavy intensity drizzle": "ฝนพรำ",
      "light intensity drizzle rain": "ฝนพรำและฝนตกเบาๆ",
      "shower drizzle": "ฝนตกพรำ",
      "heavy shower rain and drizzle": "ฝนตก",
      "snow": "หิมะตก",
      "light snow": "หิมะตกเบา ๆ",
      "heavy snow": "หิมะตกหนัก",
      "sleet": "ลูกเห็บตก",
      "light shower sleet": "ฝนและหิมะตกปรอย ๆ",
      "shower sleet": "ลูกเห็บตกเล็กน้อย",
      "mist": "มีหมอก",
      "smoke": "ควัน",
      "haze": "เมฆควัน",
      "sand/dust whirls": "ทราย/ฝุ่นหมุน",
      "fog": "หมอกหนา",
      "sand": "ทราย",
      "dust": "ฝุ่น",
      "volcanic ash": "เถ้าภูเขาไฟ",
      "squalls": "ลมแรง",
      "tornado": "พายุทอร์นาโด",
      "light shower snow": "หิมะตกปรอยเล็กน้อย"
    };
    return weatherDescriptionsToThai[description] ?? description;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'main': main,
        'description': description,
        'icon': icon,
      };
}
