import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:type21/controller/myapi.dart';
import 'package:type21/screens/reg_log_screen/home_screen.dart';

import '../../library/weather/models/wd.dart';
import '../../library/weather/widget/header.dart';
import 'field_screen/field_list.dart';
import 'map_screen_type2.dart';

final auth = FirebaseAuth.instance;

class SelectScreen extends StatefulWidget {
  const SelectScreen({Key? key, required this.locationList}) : super(key: key);

  final List<LatLng> locationList;

  @override
  State<SelectScreen> createState() => _SelectScreenState();
}

class _SelectScreenState extends State<SelectScreen> {
  late WeatherData _weatherData;
  final _weatherFetcher = WeatherDataFetcher();
  final _googleServices = GoogleServices();
  bool _isLoading = true;
  String? locationName;

  void navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  _fetchWeatherData() async {
    Position position = await _googleServices.getCurrentLocation();
    locationName = await _weatherFetcher.fetchLocationName(
        position.latitude, position.longitude);
    WeatherData weatherData =
        await _weatherFetcher.fetchData(position.latitude, position.longitude);

    setState(() {
      _weatherData = weatherData;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "ยินดีต้อนรับ",
          style: GoogleFonts.openSans(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  const HeaderSc(),
                  const SizedBox(height: 20),
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(locationName ?? 'Unknown Location'),
                        Text(
                          '${_weatherData.current?.current.temp ?? ''}°C',
                          style: const TextStyle(fontSize: 40),
                        ),
                        Text(
                          _weatherData
                                  .current?.current.weather?[0].description ??
                              '',
                          style: const TextStyle(fontSize: 24),
                        ),
                        Image.network(
                          'https://openweathermap.org/img/w/${_weatherData.current?.current.weather?[0].icon ?? ''}.png',
                          scale: 0.5,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Detailed Weather Parameters
                  Column(
                    children: <Widget>[
                      ListTile(
                        leading: const Icon(Icons.thermostat_outlined),
                        title: const Text('Feels Like'),
                        trailing: Text(
                            '${_weatherData.current?.current.feels_like ?? ''}°C'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.cloud),
                        title: const Text('Cloudiness'),
                        trailing: Text(
                            '${_weatherData.current?.current.clouds ?? ''}%'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.wind_power),
                        title: const Text('Wind Speed'),
                        trailing: Text(
                            '${_weatherData.current?.current.windSpeed} m/s'),
                      ),
                    ],
                  ),
                ],
              ),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: const Text('ผู้ใช้'),
              accountEmail: Text(auth.currentUser?.email ?? ''),
            ),
            ListTile(
              title: const Text('หน้าแผนที่'),
              trailing: IconButton(
                icon: const Icon(Icons.map),
                onPressed: () {
                  navigateToScreen(
                      context,
                      MapScreenType2(
                        polygons: widget.locationList,
                        polygonArea: 0,
                        lengths: const [],
                        onPolygonAreaChanged: (double value) {},
                      ));
                },
              ),
              onTap: () {
                navigateToScreen(
                  context,
                  MapScreenType2(
                    polygons: widget.locationList,
                    polygonArea: 0,
                    lengths: const [],
                    onPolygonAreaChanged: (double value) {},
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('หน้ารายชื่อแปลง'),
              trailing: IconButton(
                icon: const Icon(Icons.list),
                onPressed: () {
                  navigateToScreen(context,
                      const FieldList(fields: [], monthlyTemperatureData: []));
                },
              ),
              onTap: () {
                navigateToScreen(
                  context,
                  const FieldList(
                    fields: [],
                    monthlyTemperatureData: [],
                  ),
                );
              },
            ),
            ListTile(
                title: const Text("ออกจากระบบ"),
                leading: const Icon(Icons.logout),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: const Text('ออกจากระบบ'),
                          content: const Text('คุณต้องการออกจากระบบ?'),
                          actions: [
                            TextButton(
                              child: const Text(
                                'ยกเลิก',
                              ),
                              onPressed: () {
                                Navigator.pop(dialogContext);
                              },
                            ),
                            TextButton(
                              child: const Text('ยืนยัน'),
                              onPressed: () async {
                                Navigator.pop(dialogContext);
                                await _handleSignOut(context);
                              },
                            ),
                          ],
                        );
                      });
                })
          ],
        ),
      ),
    );
  }

  Future<void> _handleSignOut(BuildContext context) async {
    try {
      await auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out: $e');
      }
    }
  }
}
