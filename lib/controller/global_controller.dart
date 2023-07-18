import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'myapi.dart';
import '../library/weather/models/wd.dart';

class GlobalController extends GetxController {
  final RxBool _isLoading = true.obs;
  final RxDouble _lat = 0.0.obs;
  final RxDouble _lng = 0.0.obs;
  final RxInt cardIndex = 0.obs;
  final weatherData = WeatherData().obs;

  RxBool checkStatus() => _isLoading;

  RxDouble getlat() => _lat;

  RxDouble getlng() => _lng;

  WeatherData getWeatherData() => weatherData.value;

  // Create an instance of WeatherDataFetcher
  final WeatherDataFetcher _weatherDataFetcher = WeatherDataFetcher();

  @override
  void onInit() {
    if (_isLoading.isTrue) {
      getLocation();
    } else {
      getIndex();
    }
    super.onInit();
  }

  RxInt getIndex() => cardIndex;

  getLocation() async {
    bool isEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isEnabled) {
      throw Future.error('Service is not enabled');
    }

    LocationPermission locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.deniedForever) {
      throw Future.error('Service denied forever');
    } else if (locationPermission == LocationPermission.denied) {
      locationPermission = await Geolocator.requestPermission();
      if (locationPermission == LocationPermission.denied) {
        throw Future.error('Service denied');
      }
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
    _lat.value = position.latitude;
    _lng.value = position.longitude;

    // Call the fetchData() method from the WeatherDataFetcher instance
    WeatherData data = await _weatherDataFetcher.fetchData(_lat.value, _lng.value);
    weatherData.value = data;
    _isLoading.value = false;
  }
}
