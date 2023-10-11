import 'map_screen.dart';
import '../../controller/myapi.dart';
import 'field_screen/field_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../../library/colors_schema.dart';
import '../reg_log_screen/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../library/weather/models/weather_data.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// ignore_for_file: use_build_context_synchronously



final auth = FirebaseAuth.instance;

class SelectScreen extends StatefulWidget {
  const SelectScreen({Key? key, required this.locationList}) : super(key: key);
  final List<LatLng> locationList;

  @override
  State<SelectScreen> createState() => _SelectScreenState();
}

class _SelectScreenState extends State<SelectScreen> {
  var _weatherData = WeatherData();
  final _weatherFetcher = WeatherDataFetcher();
  final _googleServices = GoogleServices();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  _fetchWeatherData() async {
    try {
      final status = await Permission.location.request();

      if (status.isGranted) {
        Position position = await _googleServices.getCurrentLocation();
        WeatherData weatherData = await _weatherFetcher.fetchData(
            position.latitude, position.longitude);
        setState(() {
          _weatherData = weatherData;
          _isLoading = false;
        });

        if (kDebugMode) {
          print('Weather data: $weatherData');
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        if (kDebugMode) {
          print('Location permission denied.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching weather data: $e");
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  void navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
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
          backgroundColor: myColorScheme.primary,
        ),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: const Text('ผู้ใช้'),
                accountEmail: Text(auth.currentUser?.email ?? ''),
              ),
              ListTile(
                title: const Text('หน้ารายชื่อแปลง'),
                leading: const Icon(Icons.list),
                trailing: const Icon(Icons.arrow_forward_ios),
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
                title: const Text('หน้าแผนที่'),
                leading: const Icon(Icons.map),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  navigateToScreen(
                    context,
                    MapScreen(
                      polygons: widget.locationList,
                      polygonArea: 0,
                      lengths: const [],
                      onPolygonAreaChanged: (double value) {},
                      selectedDate: DateTime.now(),
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
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: myGradient,
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          _weatherData.locationNameData().localNames['th'] ??
                              'ไม่รู้จักตำแหน่ง',
                          style:  TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: myColorScheme.error
                          ),
                        ),
                        Text(
                          _weatherData.locationNameData().state,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _weatherData.locationNameData().country == 'TH'
                              ? 'ประเทศไทย'
                              : _weatherData.locationNameData().country,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                '${_weatherData.currentWeatherData().current.temp ?? ''}°C',
                                style: const TextStyle(fontSize: 40),
                              ),
                              Text(
                                _weatherData
                                        .currentWeatherData()
                                        .current
                                        .weather?[0]
                                        .description ??
                                    '',
                                style: const TextStyle(fontSize: 24),
                              ),
                              Image.network(
                                'https://openweathermap.org/img/w/${_weatherData.currentWeatherData().current.weather?[0].icon ?? ''}.png',
                                scale: 0.5,
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _weatherData
                                    .hourlyWeatherData()
                                    .hourly
                                    .length,
                                itemBuilder: (context, index) {
                                  var hourlyData = _weatherData
                                      .hourlyWeatherData()
                                      .hourly[index];
                                  return ListTile(
                                    leading: Image.network(
                                      'https://openweathermap.org/img/w/${hourlyData.weather?[0].icon ?? ''}.png',
                                      scale: 0.5,
                                    ),
                                    title: Text(
                                      '${DateTime.fromMillisecondsSinceEpoch((hourlyData.dt ?? 0) * 1000).hour}:00',
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          hourlyData.weather?[0].description ??
                                              'ไม่ทราบสภาพอากาศ',
                                        ),
                                        Text(
                                          'อุณหภูมิ: ${hourlyData.temp?.toStringAsFixed(2) ?? ''}°C',
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                        Text(
                                          'โอกาสเกิดฝน: ${(hourlyData.pop ?? 0) * 100}%',
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                        Text(
                                          'ปริมาณน้ำฝน: ${hourlyData.rain?.rain1h?.toStringAsFixed(2) ?? 0} mm',
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ));
  }

  Future<void> _handleSignOut(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);

      final currentUser = auth.currentUser;
      if (currentUser != null) {
        if (currentUser.providerData[0].providerId == 'google.com') {
          final GoogleSignIn googleSignIn = GoogleSignIn();
          await googleSignIn.signOut();
        }

        await auth.signOut();
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out: $e');
      }
    }
  }
}
