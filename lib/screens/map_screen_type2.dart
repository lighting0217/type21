import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'add_screen_type2.dart';
import 'field_info.dart';

class MapScreenType2 extends StatefulWidget {
  const MapScreenType2({
    Key? key,
    required this.polygons,
    required this.polygonArea,
    required this.lengths,
    required this.onPolygonAreaChanged,
  }) : super(key: key);

  final List<double> lengths;
  final ValueChanged<double> onPolygonAreaChanged;
  final double polygonArea;
  final List<LatLng> polygons;

  @override
  State<MapScreenType2> createState() => _MapScreenType2TestState();
}

class _MapScreenType2TestState extends State<MapScreenType2> {
  List<Field> fields = [];

  bool _addingPolygons = false;
  MapType _currentMapType = MapType.normal;
  Position? _currentPosition;
  GoogleMapController? _mapController;
  Set<Marker> _markerSet = {};
  double _polygonArea = 0;
  final Set<Polygon> _polygonSet = {};
  final List<LatLng> _polygons = [];
  bool _showAddFieldButton = true;
  bool _showCancelButton = false;
  bool _showClearButton = false;
  bool _showGotoAddScreen = false;
  bool _showRedoButton = false;
  double _totalDistance = 0; // Declare and initialize _totalDistance

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  double computeSignedArea(List<LatLng> polygon) {
    int numPoints = polygon.length;
    double signedArea = 0;

    for (int i = 0; i < numPoints; i++) {
      LatLng p1 = polygon[i];
      LatLng p2 = polygon[(i + 1) % numPoints];

      double lat1 = p1.latitude * pi / 180;
      double lat2 = p2.latitude * pi / 180;
      double lon1 = p1.longitude * pi / 180;
      double lon2 = p2.longitude * pi / 180;

      double partialArea = (lon2 - lon1) * (2 + sin(lat1) + sin(lat2));
      signedArea += partialArea;
    }

    signedArea = signedArea * 6378137 * 6378137 / 2;

    if (kDebugMode) {
      print('\nFrom SignedArea: $signedArea');
    }
    return signedArea.abs();
  }

  double calculatePolygonArea(List<LatLng> polygon) {
    int numPoints = polygon.length;
    double area = 0;

    if (numPoints > 2) {
      const double earthRadius = 6371000; // Earth radius in meters
      const double degreesToRadians = pi / 180;

      for (int i = 0; i < numPoints; i++) {
        final LatLng p1 = polygon[i];
        final LatLng p2 = polygon[(i + 1) % numPoints];

        double lat1 = p1.latitude * degreesToRadians;
        double lat2 = p2.latitude * degreesToRadians;
        double lon1 = p1.longitude * degreesToRadians;
        double lon2 = p2.longitude * degreesToRadians;

        double crossProduct = sin(lat1) * sin(lat2) + cos(lat1) * cos(lat2) * cos(lon2 - lon1);
        double deltaLon = lon2 - lon1;

        double angle = atan2(sqrt(1 - crossProduct * crossProduct), crossProduct);
        double segmentArea = angle * earthRadius * earthRadius * deltaLon;

        area += segmentArea;
      }

      area = (area.abs() * 0.5); // Half of the absolute area
    }

    // Convert the area to square meters
    area = area.abs() * 0.000001;

    if (kDebugMode) {
      print('From Area: $area');
    }
    return area;
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _addMarkersToCorners();
  }

  void _changeMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal ? MapType.hybrid : MapType.normal;
    });
  }

  void _goToCurrentLocation() {
    if (_currentPosition != null && _mapController != null) {
      final latLng = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
      _mapController!.animateCamera(CameraUpdate.newLatLngZoom(latLng, 20));
    }
  }

  void _cancelAddPolygon() {
    if (_addingPolygons) {
      _clearPolygons();
    } else {
      if (_polygons.isNotEmpty) {
        _polygons.removeLast();
        _calculatePolygonArea();
      }
    }
  }

  void _addField() {
    setState(() {
      if (!_addingPolygons) {
        _showAddFieldButton = false;
        _addingPolygons = true;
        _showCancelButton = true;
        _showClearButton = true;
        _showRedoButton = true;
        _showGotoAddScreen = true;
      }
    });
  }

  double _calculatePolygonAreaMeters() {
    if (_polygons.length < 3) {
      return 0;
    }

    final polygonLatLngs = _polygons.toList();
    final polygonAreaValue = calculatePolygonArea(polygonLatLngs);

    return polygonAreaValue;
  }

  void _goToAddScreen() {
    final polygonAreaMeters = _calculatePolygonAreaMeters();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddScreenType2(
          polygons: _polygons,
          polygonArea: _polygonArea,
          lengths: widget.lengths,
          polygonAreaMeters: polygonAreaMeters,
          totalDistance: _totalDistance,
        ),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar('', 'Location services are disabled');
      return Future.error('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar('', 'Location permission denied');
        return Future.error('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar('', 'Location permissions are permanently denied');
      return Future.error('Location permissions are permanently denied');
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentPosition = position;
    });
    _moveToCurrentLocation();
  }

  void _measureDistance() {
    if (_polygons.length < 2) {
      return;
    }

    double totalDistance = 0;

    for (int i = 0; i < _polygons.length - 1; i++) {
      final LatLng p1 = _polygons[i];
      final LatLng p2 = _polygons[i + 1];
      final double distance = Geolocator.distanceBetween(
        p1.latitude,
        p1.longitude,
        p2.latitude,
        p2.longitude,
      );
      totalDistance += distance;
    }

    if (_polygons.length > 2) {
      // Calculate the distance between the last and first corners
      final LatLng lastPoint = _polygons.last;
      final LatLng firstPoint = _polygons.first;
      final double distance = Geolocator.distanceBetween(
        lastPoint.latitude,
        lastPoint.longitude,
        firstPoint.latitude,
        firstPoint.longitude,
      );
      totalDistance += distance;
    }

    if (kDebugMode) {
      print('Total Distance: $totalDistance meters');
    }

    setState(() {
      _totalDistance = totalDistance;
    });
  }

  void _clearPolygons() {
    setState(() {
      _polygons.clear();
      _polygonSet.clear();
      _markerSet.clear();
      _showAddFieldButton = true;
      _addingPolygons = false;
      _showCancelButton = false;
      _showClearButton = false;
      _showRedoButton = false;
      _showGotoAddScreen = false;
    });
  }

  void _undoAddMarker() {
    if (!_showAddFieldButton && _polygons.isNotEmpty) {
      setState(() {
        _polygons.removeLast();
      });
      _calculatePolygonArea();
      _addMarkersToCorners();
    }
  }

  void _moveToCurrentLocation() {
    if (_currentPosition != null && _mapController != null) {
      final latLng = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
      _mapController!.animateCamera(CameraUpdate.newLatLngZoom(latLng, 20));
    }
  }

  void _addMarkersToCorners() {
    _markerSet.removeWhere(
      (marker) =>
          marker.markerId.value.startsWith('corner_') ||
          marker.markerId.value.startsWith('distance_'),
    );
    for (int i = 0; i < _polygons.length; i++) {
      final markerId = MarkerId('corner_$i');
      final marker = Marker(
        markerId: markerId,
        position: _polygons[i],
        icon: BitmapDescriptor.defaultMarker,
      );
      _markerSet.add(marker);
    }

    setState(() {
      _markerSet = _markerSet;
    });
  }

  void _addPolygon(LatLng point) {
    if (!_showAddFieldButton) {
      setState(() {
        _polygons.add(point);
        _polygonSet.add(
          Polygon(
            polygonId: PolygonId(_polygons.length.toString()),
            points: _polygons,
            strokeWidth: 2,
            strokeColor: Colors.black,
            fillColor: Colors.greenAccent.withOpacity(0.3),
          ),
        );

        _calculatePolygonArea();
        _measureDistance();
        _addMarkersToCorners();
      });
    }
  }

  void _calculatePolygonArea() {
    if (_polygons.length < 3) {
      setState(() {
        _polygonArea = 0;
      });
      return;
    }

    final polygonLatLngs = _polygons.toList();
    final polygonAreaValue = computeSignedArea(polygonLatLngs);

    setState(() {
      _polygonArea = polygonAreaValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Screen Type 2 Test'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: _currentMapType,
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: LatLng(0, 0),
              zoom: 14.0,
            ),
            polygons: _polygonSet,
            markers: _markerSet,
            onTap: _addingPolygons ? _addPolygon : null,
          ),
          Positioned(
            top: 16.0,
            left: 16.0,
            child: FloatingActionButton(
              onPressed: _changeMapType,
              child: const Icon(Icons.layers),
            ),
          ),
          Positioned(
            top: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: _goToCurrentLocation,
              child: const Icon(Icons.my_location),
            ),
          ),
          Positioned(
            bottom: 30.0,
            left: 16.0,
            child: Row(
              children: [
                Visibility(
                  visible: _showCancelButton,
                  child: FloatingActionButton(
                    onPressed: _cancelAddPolygon,
                    tooltip: 'Cancel',
                    child: const Icon(Icons.cancel_presentation),
                  ),
                ),
                Visibility(
                  visible: _showClearButton,
                  child: FloatingActionButton(
                    onPressed: _clearPolygons,
                    tooltip: 'Clear Polygons',
                    child: const Icon(Icons.clear),
                  ),
                ),
                Visibility(
                  visible: _showRedoButton,
                  child: FloatingActionButton(
                    onPressed: _undoAddMarker,
                    tooltip: 'Redo',
                    child: const Icon(Icons.undo),
                  ),
                ),
                Visibility(
                  visible: _showGotoAddScreen,
                  child: FloatingActionButton(
                    onPressed: _goToAddScreen,
                    tooltip: 'Go to the Add field screen',
                    child: const Icon(Icons.add_box),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 30.0,
            left: 16.0,
            child: Row(
              children: [
                Visibility(
                  visible: _showAddFieldButton,
                  child: FloatingActionButton(
                    onPressed: _addField,
                    tooltip: 'Add field',
                    child: const Icon(Icons.arrow_forward_ios),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
