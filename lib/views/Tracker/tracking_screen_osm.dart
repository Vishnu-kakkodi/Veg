
// lib/screens/tracking_screen_google.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as ll;
import 'package:veegify/helpers/osm_route_helper.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;

class TrackingScreenGoogle extends StatefulWidget {
  /// supply deliveryBoyId (rider id) and userId (listener)
  final String deliveryBoyId;
  final String userId;

  /// optional static destination and initial camera center
  final LatLng initialCenter;
  final LatLng destination;

  /// polling interval (default 5 seconds)
  final Duration pollingInterval;

  const TrackingScreenGoogle({
    Key? key,
    required this.deliveryBoyId,
    required this.userId,
    this.initialCenter = const LatLng(17.486681, 78.3914777),
    this.destination = const LatLng(17.446681, 78.3114777),
    this.pollingInterval = const Duration(seconds: 5),
  }) : super(key: key);

  @override
  State<TrackingScreenGoogle> createState() => _TrackingScreenGoogleState();
}

class _TrackingScreenGoogleState extends State<TrackingScreenGoogle>
    with TickerProviderStateMixin {
  final Completer<GoogleMapController> _mapCtl = Completer();
  GoogleMapController? _mapController;

  LatLng? _currentRiderPos;
  Marker? _riderMarker;
  Marker? _destMarker;
  Polyline? _routePolyline;

  Timer? _pollTimer;
  bool _isPolling = false;

  AnimationController? _animationController;
  LatLngTween? _latLngTween;

  // server urls
  static const String _apiBase = 'https://api.vegiffyy.com';

  // marker icons loaded from assets
  BitmapDescriptor? _riderIcon;
  BitmapDescriptor? _destIcon;

  bool _iconsLoaded = false;

  @override
  void initState() {
    super.initState();
    // load icons first, then initialize markers and start polling
    _loadMarkerIcons().then((_) {
      _initializeMarkers();
      _fetchInitialAndStartPolling();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _pollTimer?.cancel();
    super.dispose();
  }

/// load marker icons scaled to desired pixel size
Future<void> _loadMarkerIcons() async {
  try {
    final riderBytes = await _getBytesFromAsset('assets/images/rider.png', 245);
    final destBytes = await _getBytesFromAsset('assets/images/destination.png', 205);

    if (riderBytes != null) {
      _riderIcon = BitmapDescriptor.fromBytes(riderBytes);
    } else {
      _riderIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }

    if (destBytes != null) {
      _destIcon = BitmapDescriptor.fromBytes(destBytes);
    } else {
      _destIcon = BitmapDescriptor.defaultMarker;
    }
  } catch (e) {
    debugPrint('Error loading/resizing marker assets: $e');
    _riderIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    _destIcon = BitmapDescriptor.defaultMarker;
  } finally {
    _iconsLoaded = true;
  }
}

/// Helper: load asset, decode and resize to [width] px (maintains aspect) and return bytes
Future<Uint8List?> _getBytesFromAsset(String path, int width) async {
  try {
    final ByteData data = await rootBundle.load(path);
    final Uint8List bytes = data.buffer.asUint8List();

    // decode image
    final ui.Codec codec = await ui.instantiateImageCodec(bytes, targetWidth: width);
    final ui.FrameInfo fi = await codec.getNextFrame();
    final ByteData? resized = await fi.image.toByteData(format: ui.ImageByteFormat.png);
    if (resized == null) return null;
    return resized.buffer.asUint8List();
  } catch (e) {
    debugPrint('Error in _getBytesFromAsset: $e');
    return null;
  }
}


  void _initializeMarkers() {
    _currentRiderPos = widget.initialCenter;

    _riderMarker = Marker(
      markerId: const MarkerId('rider'),
      position: _currentRiderPos!,
      icon: _riderIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      anchor: const Offset(0.5, 0.5),
      rotation: 0.0,
    );

    _destMarker = Marker(
      markerId: const MarkerId('dest'),
      position: widget.destination,
      icon: _destIcon ?? BitmapDescriptor.defaultMarker,
    );

    _routePolyline = Polyline(
      polylineId: const PolylineId('route'),
      points: [_currentRiderPos!, widget.destination],
      color: Colors.blue,
      width: 6,
    );
  }

  Future<void> _fetchInitialAndStartPolling() async {
    // Try HTTP initial fetch (don't crash on error)
    await _fetchLocationOnce();

    // start polling every [pollingInterval]
    _pollTimer = Timer.periodic(widget.pollingInterval, (_) async {
      await _fetchLocationOnce();
    });

    setState(() {
      _isPolling = true;
    });
  }

  Future<void> _fetchLocationOnce() async {
    try {
      final url = Uri.parse(
          '$_apiBase/api/delivery-boy/location/${widget.deliveryBoyId}/${widget.userId}');
      final resp = await http.get(url).timeout(const Duration(seconds: 8));

      debugPrint('Tracking API response: ${resp.statusCode} ${resp.body}');

      if (resp.statusCode == 200) {
        final Map<String, dynamic> body =
            json.decode(resp.body) as Map<String, dynamic>;
        if (body['success'] == true && body['data'] != null) {
          final d = body['data'] as Map<String, dynamic>;
          final lat = (d['latitude'] as num?)?.toDouble();
          final lng = (d['longitude'] as num?)?.toDouble();

          if (lat != null && lng != null) {
            final newPos = LatLng(lat, lng);

            // animate marker to new position and update route
            _animateMarkerTo(newPos);
            await _updateRouteFrom(newPos);

            // move camera slightly to follow the rider
            _animateCameraTo(newPos);

            // if rider is at/near destination, stop polling
            if (_isCloseTo(newPos, widget.destination, thresholdMeters: 5.0)) {
              _pollTimer?.cancel();
              setState(() {
                _isPolling = false;
              });
            }
          }
        } else {
          // API returned success=false or no data - ignore until next poll
          debugPrint('Tracking API returned no data or success=false');
        }
      } else {
        // non-200 - ignore and try next tick
        debugPrint('Tracking API non-200 status: ${resp.statusCode}');
      }
    } catch (e) {
      // network/timeout/parse error - ignore and try on next poll
      debugPrint('Error fetching tracking location: $e');
    }
  }

  void _moveMarkerInstant(LatLng pos) {
    setState(() {
      _currentRiderPos = pos;
      _riderMarker = _riderMarker?.copyWith(positionParam: pos) ??
          Marker(
            markerId: const MarkerId('rider'),
            position: pos,
            icon: _riderIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            anchor: const Offset(0.5, 0.5),
          );
    });
  }

  void _animateMarkerTo(LatLng newPos) {
    final oldPos = _currentRiderPos ?? newPos;

    // dispose previous controller for a fresh animation
    _animationController?.dispose();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));

    _latLngTween = LatLngTween(begin: oldPos, end: newPos);

    final animation = _latLngTween!
        .animate(CurvedAnimation(parent: _animationController!, curve: Curves.linear));

    animation.addListener(() {
      final intermediate = animation.value;
      _updateMarkerPosition(intermediate, newPos);
    });

    _animationController!.forward();

    _currentRiderPos = newPos;
  }

  void _updateMarkerPosition(LatLng intermediate, LatLng headingTo) {
    final rotation = _calculateBearing(intermediate, headingTo);

    setState(() {
      _riderMarker = Marker(
        markerId: const MarkerId('rider'),
        position: intermediate,
        rotation: 0,
        anchor: const Offset(0.9, 0.9),
        flat: true, 
        icon: _riderIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
    });
  }

  Future<void> _animateCameraTo(LatLng pos) async {
    try {
      if (!_mapCtl.isCompleted) return;
      final ctl = await _mapCtl.future;
      await ctl.animateCamera(CameraUpdate.newLatLng(pos));
    } catch (_) {
      // ignore
    }
  }

  /// REAL ROAD ROUTE using OSRM (keeps polyline updated)
  Future<void> _updateRouteFrom(LatLng origin) async {
    try {
      final originLL = ll.LatLng(origin.latitude, origin.longitude);
      final destLL =
          ll.LatLng(widget.destination.latitude, widget.destination.longitude);

      final routePointsLL =
          await OsmRouteHelper.getRoutePoints(origin: originLL, destination: destLL);

      final routePointsGoogle = routePointsLL
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();

      setState(() {
        _routePolyline = Polyline(
          polylineId: const PolylineId('route'),
          points: routePointsGoogle,
          color: Colors.blue,
          width: 6,
        );
      });
    } catch (e) {
      // fallback: simple straight polyline
      setState(() {
        _routePolyline = Polyline(
          polylineId: const PolylineId('route'),
          points: [origin, widget.destination],
          color: Colors.blue,
          width: 6,
        );
      });
    }
  }

  double _calculateBearing(LatLng from, LatLng to) {
    final lat1 = _toRad(from.latitude);
    final lon1 = _toRad(from.longitude);
    final lat2 = _toRad(to.latitude);
    final lon2 = _toRad(to.longitude);

    final dLon = lon2 - lon1;
    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    return (_toDeg(math.atan2(y, x)) + 360) % 360;
  }

  double _toRad(double deg) => deg * math.pi / 180;
  double _toDeg(double rad) => rad * 180 / math.pi;

  bool _isCloseTo(LatLng a, LatLng b, {double thresholdMeters = 5.0}) {
    final d = _haversine(a.latitude, a.longitude, b.latitude, b.longitude);
    return d <= thresholdMeters;
  }

  double _haversine(lat1, lon1, lat2, lon2) {
    const R = 6371000; // Earth radius in meters
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return R * c;
  }

  @override
  Widget build(BuildContext context) {
    final camera = CameraPosition(target: widget.initialCenter, zoom: 15);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rider Tracking'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Row(
              children: [
                Icon(_isPolling ? Icons.sync : Icons.sync_disabled),
                const SizedBox(width: 6),
                Text(_isPolling ? 'Polling' : 'Stopped'),
              ],
            ),
          )
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: camera,
        myLocationEnabled: false,
        markers: {
          if (_riderMarker != null) _riderMarker!,
          if (_destMarker != null) _destMarker!,
        },
        polylines: {
          if (_routePolyline != null) _routePolyline!,
        },
        onMapCreated: (g) {
          if (!_mapCtl.isCompleted) _mapCtl.complete(g);
          _mapController = g;
        },
      ),
    );
  }
}

/// Small helper tween for LatLng interpolation
class LatLngTween extends Tween<LatLng> {
  LatLngTween({required LatLng begin, required LatLng end})
      : super(begin: begin, end: end);

  @override
  LatLng lerp(double t) => LatLng(begin!.latitude + (end!.latitude - begin!.latitude) * t,
      begin!.longitude + (end!.longitude - begin!.longitude) * t);
}
