// lib/services/LiveTracking/location_simulator.dart

import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationSimulator {
  final Duration updateInterval;
  LatLng _current;
  final double deltaLat;
  final double deltaLng;
  Timer? _timer;

  final StreamController<LatLng> _controller =
      StreamController.broadcast();

  LocationSimulator({
    required LatLng startPosition,
    this.updateInterval = const Duration(seconds: 10),
    this.deltaLat = 0.00035,
    this.deltaLng = 0.00018,
  }) : _current = startPosition;

  Stream<LatLng> get stream => _controller.stream;

  void start() {
    _controller.add(_current);

    _timer = Timer.periodic(updateInterval, (_) {
      _current = LatLng(
        _current.latitude + deltaLat,
        _current.longitude + deltaLng,
      );
      _controller.add(_current);
    });
  }

  void setPosition(LatLng pos) {
    _current = pos;
    _controller.add(_current);
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
