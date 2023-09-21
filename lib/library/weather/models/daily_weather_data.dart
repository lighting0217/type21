// Daily Weather Data File

class DailyWeatherData {
  List<Daily> daily;

  DailyWeatherData({required this.daily});

  factory DailyWeatherData.fromJson(Map<String, dynamic> json) =>
      DailyWeatherData(
          daily: List<Daily>.from(json['daily'].map((e) => Daily.fromJson(e))));
}

class Daily {
  int? dt;
  int? sunrise;
  int? sunset;

  Temp? temp;

  List<Weather>? weather;

  Daily({
    this.dt,
    this.sunrise,
    this.sunset,
    this.weather,
    this.temp,
  });

  factory Daily.fromJson(Map<String, dynamic> json) => Daily(
      dt: json['dt'] as int?,
      sunrise: json['sunrise'] as int?,
      sunset: json['sunset'] as int?,
      temp: json['temp'] == null
          ? null
          : Temp.fromJson(json['temp'] as Map<String, dynamic>),
      weather: (json['weather'] as List<dynamic>?)
          ?.map((e) => Weather.fromJson(e as Map<String, dynamic>))
          .toList());

  Map<String, dynamic> toJson() => {
        'dt': dt,
        'sunrise': sunrise,
        'sunset': sunset,
        'temp': temp?.toJson(),
        'weather': weather?.map((e) => e.toJson()).toList(),
      };
}

class Temp {
  double? day;
  int? min;
  int? max;
  double? night;
  double? eve;
  double? morn;

  Temp({this.day, this.min, this.max, this.night, this.eve, this.morn});

  factory Temp.fromJson(Map<String, dynamic> json) => Temp(
        day: (json['day'] as num?)?.toDouble(),
        min: (json['min'] as num?)?.round(),
        max: (json['max'] as num?)?.round(),
        night: (json['night'] as num?)?.toDouble(),
        eve: (json['eve'] as num?)?.toDouble(),
        morn: (json['morn'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'day': day,
        'min': min,
        'max': max,
        'night': night,
        'eve': eve,
        'morn': morn,
      };
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
        description:
            _translateDescriptionToThai(json['description'] as String?),
        icon: (json['icon'] as String?),
      );

  static String? _translateDescriptionToThai(String? description) {
    final Map<String, String> weatherDescriptionsToThai = {
      "clear sky": "ท้องฟ้าแจ่มใส",
      "few clouds": "มีเมฆบางส่วน",
      "scattered clouds": "มีเมฆกระจัดกระจาย",
      "overcast clouds": "มีเมฆครึ้ม",
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
      "thunderstorm with light drizzle": "ฝนฟ้าคะนองเป็นบางส่วน",
      "thunderstorm with drizzle": "ฝนฟ้าคะนองโดยทั่วไป",
      "thunderstorm with heavy drizzle": "ฝนฟ้าคะนองเป็นส่วนมาก",
      "drizzle": "ฝนพรำ",
      "light intensity drizzle": "ฝนพรำเบาๆ",
      "drizzle rain": "ฝนพรำ",
      "heavy intensity drizzle": "ฝนพรำ",
      "shower rain and drizzle": "ฝนตกพรำ",
      "light intensity drizzle rain": "ฝนพรำและฝนตกเบาๆ",
      "shower drizzle": "ฝนตกพรำ",
      "heavy shower rain and drizzle": "ฝนตก",
      "snow": "หิมะตก",
      "light snow": "หิมะตกเบา ๆ",
      "heavy snow": "หิมะตกหนัก",
      "light rain and snow": "ฝนและหิมะตกบางเบา",
      "rain and snow": "ฝนและหิมะตก",
      "shower snow": "หิมะตกปรอยเบาๆ",
      "heavy shower snow": "หิมะตก",
      "sleet": "ลูกเห็บตก",
      "light shower sleet": "ฝนและลุกเห็บตกปรอย ๆ",
      "shower sleet": "ลูกเห็บตกเล็กน้อย",
      "mist": "มีหมอก",
      "smoke": "ควัน",
      "haze": "มีเมฆควัน",
      "sand/dust whirls": "ทราย/ฝุ่นหมุน",
      "fog": "หมอกหนา",
      "sand": "ทราย",
      "dust": "ฝุ่น",
      "volcanic ash": "เถ้าภูเขาไฟ",
      "squalls": "ลมแรง",
      "tornado": "พายุทอร์นาโด",
      "light shower snow": "หิมะตกปรอยเล็กน้อย",
      "few clouds: 11-25%": "มีเมฆบางส่วน",
      "scattered clouds: 25-50%": "มีเมฆกระจัดกระจาย",
      "broken clouds: 51-84%": "มีเมฆมาก",
      "overcast clouds: 85-100%": "มีเมฆครึ้ม",
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
