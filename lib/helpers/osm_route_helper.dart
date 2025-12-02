// lib/helpers/osm_route_helper.dart

import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class OsmRouteHelper {
  static Future<List<LatLng>> getRoutePoints({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final url =
        'http://router.project-osrm.org/route/v1/driving/'
        '${origin.longitude},${origin.latitude};'
        '${destination.longitude},${destination.latitude}'
        '?overview=full&geometries=geojson';

    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode != 200) return [];

    final data = jsonDecode(resp.body);

    final coords = data['routes'][0]['geometry']['coordinates'];

    return coords.map<LatLng>((c) {
      return LatLng(c[1], c[0]); // lat, lon
    }).toList();
  }
}
