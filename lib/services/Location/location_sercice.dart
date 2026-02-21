import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationService {

  // =========================
  // ADDRESS
  // =========================
  static Future<String?> getCurrentAddress() async {
    try {
      // 🌐 WEB CASE
      if (kIsWeb) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        // Use Google / OpenStreetMap reverse API instead
        final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse'
          '?lat=${position.latitude}'
          '&lon=${position.longitude}'
          '&format=json',
        );

        final response = await http.get(url, headers: {
          'User-Agent': 'FlutterApp',
        });

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return data['display_name'] ?? 'Address not found';
        }

        return 'Address not found';
      }

      // 📱 MOBILE CASE (UNCHANGED)
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return 'Location permission denied.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return 'Location permissions are permanently denied.';
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        return [
          p.street,
          p.locality,
          p.administrativeArea,
          p.country
        ].whereType<String>().where((e) => e.isNotEmpty).join(', ');
      }

      return 'Address not found';
    } catch (e) {
      return 'Failed to get locationnnn: $e';
    }
  }

  // =========================
  // COORDINATES (WORKS ON WEB)
  // =========================
static Future<List<double>?> getCurrentCoordinates() async {
  try {
    // 🌐 WEB: browser handles permission automatically
    if (kIsWeb) {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return [position.latitude, position.longitude];
    }

    // 📱 MOBILE: manual permission handling
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission(); // 🔥 popup
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied');
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return [position.latitude, position.longitude];
  } catch (e) {
    debugPrint('Location error: $e');
    return null;
  }
}

}
