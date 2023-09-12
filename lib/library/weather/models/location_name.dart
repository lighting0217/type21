class LocationNameData {
  final String name;
  final Map<String, String> localNames;
  final double lat;
  final double lon;
  final String country;
  final String state;

  LocationNameData({
    required this.name,
    required this.localNames,
    required this.lat,
    required this.lon,
    required this.country,
    required this.state,
  });

  factory LocationNameData.fromJson(Map<String, dynamic> json) =>
      LocationNameData(
        name: json['name'] as String,
        localNames: Map<String, String>.from(json['local_names']),
        lat: json['lat'] as double,
        lon: json['lon'] as double,
        country: json['country'] as String,
        state: json['state'] as String,
      );
}
