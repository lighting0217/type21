import 'package:geolocator/geolocator.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:type21/controller/myapi.dart';
import 'package:type21/library/weather/models/weather_data.dart';

/// This class is responsible for controlling the global state of the application.
/// It fetches the user's location and weather data using the Geolocator and WeatherDataFetcher classes respectively.
/// It also provides getters and setters for the latitude, longitude, weather data, and loading status.
/// The [getLocation] method is used to fetch the user's location and weather data.
/// The [getIndex] method returns the current card index.
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

  /// This method fetches the user's location and weather data.
  /// It first checks if the location service is enabled and if not, throws an error.
  /// It then checks the location permission and requests it if it is not granted.
  /// After getting the user's location, it fetches the weather data using the [WeatherDataFetcher] class.
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

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _lat.value = position.latitude;
    _lng.value = position.longitude;
    WeatherData data =
        await _weatherDataFetcher.fetchData(_lat.value, _lng.value);
    weatherData.value = data;
    _isLoading.value = false;
  }
}
