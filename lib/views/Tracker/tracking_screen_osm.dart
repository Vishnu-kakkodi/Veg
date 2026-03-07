
// // lib/screens/tracking_screen_google.dart
// import 'dart:async';
// import 'dart:convert';
// import 'dart:math' as math;
// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'package:latlong2/latlong.dart' as ll;
// import 'package:veegify/helpers/osm_route_helper.dart';
// import 'dart:ui' as ui;
// import 'package:flutter/services.dart' show rootBundle;


// class TrackingScreenGoogle extends StatefulWidget {
//   /// supply deliveryBoyId (rider id) and userId (listener)
//   final String deliveryBoyId;
//   final String userId;

//   /// optional static destination and initial camera center
//   final LatLng initialCenter;
//   final LatLng destination;

//   /// polling interval (default 5 seconds)
//   final Duration pollingInterval;

//   const TrackingScreenGoogle({
//     Key? key,
//     required this.deliveryBoyId,
//     required this.userId,
//     this.initialCenter = const LatLng(17.486681, 78.3914777),
//     this.destination = const LatLng(17.446681, 78.3114777),
//     this.pollingInterval = const Duration(seconds: 5),
//   }) : super(key: key);

//   @override
//   State<TrackingScreenGoogle> createState() => _TrackingScreenGoogleState();
// }

// class _TrackingScreenGoogleState extends State<TrackingScreenGoogle>
//     with TickerProviderStateMixin {
//   final Completer<GoogleMapController> _mapCtl = Completer();
//   GoogleMapController? _mapController;

//   LatLng? _currentRiderPos;
//   Marker? _riderMarker;
//   Marker? _destMarker;
//   Polyline? _routePolyline;

//   Timer? _pollTimer;
//   bool _isPolling = false;

//   AnimationController? _animationController;
//   LatLngTween? _latLngTween;

//   // server urls
//   static const String _apiBase = 'https://api.vegiffyy.com';

//   // marker icons loaded from assets
//   BitmapDescriptor? _riderIcon;
//   BitmapDescriptor? _destIcon;

//   bool _iconsLoaded = false;

//   @override
//   void initState() {
//     super.initState();
//     // load icons first, then initialize markers and start polling
//     _loadMarkerIcons().then((_) {
//       _initializeMarkers();
//       _fetchInitialAndStartPolling();
//       setState(() {});
//     });
//   }

//   @override
//   void dispose() {
//     _animationController?.dispose();
//     _pollTimer?.cancel();
//     super.dispose();
//   }

// /// load marker icons scaled to desired pixel size
// Future<void> _loadMarkerIcons() async {
//   try {
//     final riderBytes = await _getBytesFromAsset('assets/images/rider.png', 245);
//     final destBytes = await _getBytesFromAsset('assets/images/destination.png', 205);

//     if (riderBytes != null) {
//       _riderIcon = BitmapDescriptor.fromBytes(riderBytes);
//     } else {
//       _riderIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
//     }

//     if (destBytes != null) {
//       _destIcon = BitmapDescriptor.fromBytes(destBytes);
//     } else {
//       _destIcon = BitmapDescriptor.defaultMarker;
//     }
//   } catch (e) {
//     debugPrint('Error loading/resizing marker assets: $e');
//     _riderIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
//     _destIcon = BitmapDescriptor.defaultMarker;
//   } finally {
//     _iconsLoaded = true;
//   }
// }

// /// Helper: load asset, decode and resize to [width] px (maintains aspect) and return bytes
// Future<Uint8List?> _getBytesFromAsset(String path, int width) async {
//   try {
//     final ByteData data = await rootBundle.load(path);
//     final Uint8List bytes = data.buffer.asUint8List();

//     // decode image
//     final ui.Codec codec = await ui.instantiateImageCodec(bytes, targetWidth: width);
//     final ui.FrameInfo fi = await codec.getNextFrame();
//     final ByteData? resized = await fi.image.toByteData(format: ui.ImageByteFormat.png);
//     if (resized == null) return null;
//     return resized.buffer.asUint8List();
//   } catch (e) {
//     debugPrint('Error in _getBytesFromAsset: $e');
//     return null;
//   }
// }


//   void _initializeMarkers() {
//     _currentRiderPos = widget.initialCenter;

//     _riderMarker = Marker(
//       markerId: const MarkerId('rider'),
//       position: _currentRiderPos!,
//       icon: _riderIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
//       anchor: const Offset(0.5, 0.5),
//       rotation: 0.0,
//     );

//     _destMarker = Marker(
//       markerId: const MarkerId('dest'),
//       position: widget.destination,
//       icon: _destIcon ?? BitmapDescriptor.defaultMarker,
//     );

//     _routePolyline = Polyline(
//       polylineId: const PolylineId('route'),
//       points: [_currentRiderPos!, widget.destination],
//       color: Colors.blue,
//       width: 6,
//     );
//   }

//   Future<void> _fetchInitialAndStartPolling() async {
//     // Try HTTP initial fetch (don't crash on error)
//     await _fetchLocationOnce();

//     // start polling every [pollingInterval]
//     _pollTimer = Timer.periodic(widget.pollingInterval, (_) async {
//       await _fetchLocationOnce();
//     });

//     setState(() {
//       _isPolling = true;
//     });
//   }

//   Future<void> _fetchLocationOnce() async {
//     try {
//       final url = Uri.parse(
//           '$_apiBase/api/delivery-boy/location/${widget.deliveryBoyId}/${widget.userId}');
//       final resp = await http.get(url).timeout(const Duration(seconds: 8));

//       debugPrint('Tracking API response: ${resp.statusCode} ${resp.body}');

//       if (resp.statusCode == 200) {
//         final Map<String, dynamic> body =
//             json.decode(resp.body) as Map<String, dynamic>;
//         if (body['success'] == true && body['data'] != null) {
//           final d = body['data'] as Map<String, dynamic>;
//           final lat = (d['latitude'] as num?)?.toDouble();
//           final lng = (d['longitude'] as num?)?.toDouble();

//           if (lat != null && lng != null) {
//             final newPos = LatLng(lat, lng);

//             // animate marker to new position and update route
//             _animateMarkerTo(newPos);
//             await _updateRouteFrom(newPos);

//             // move camera slightly to follow the rider
//             _animateCameraTo(newPos);

//             // if rider is at/near destination, stop polling
//             if (_isCloseTo(newPos, widget.destination, thresholdMeters: 5.0)) {
//               _pollTimer?.cancel();
//               setState(() {
//                 _isPolling = false;
//               });
//             }
//           }
//         } else {
//           // API returned success=false or no data - ignore until next poll
//           debugPrint('Tracking API returned no data or success=false');
//         }
//       } else {
//         // non-200 - ignore and try next tick
//         debugPrint('Tracking API non-200 status: ${resp.statusCode}');
//       }
//     } catch (e) {
//       // network/timeout/parse error - ignore and try on next poll
//       debugPrint('Error fetching tracking location: $e');
//     }
//   }

//   void _moveMarkerInstant(LatLng pos) {
//     setState(() {
//       _currentRiderPos = pos;
//       _riderMarker = _riderMarker?.copyWith(positionParam: pos) ??
//           Marker(
//             markerId: const MarkerId('rider'),
//             position: pos,
//             icon: _riderIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
//             anchor: const Offset(0.5, 0.5),
//           );
//     });
//   }

//   void _animateMarkerTo(LatLng newPos) {
//     final oldPos = _currentRiderPos ?? newPos;

//     // dispose previous controller for a fresh animation
//     _animationController?.dispose();
//     _animationController = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 900));

//     _latLngTween = LatLngTween(begin: oldPos, end: newPos);

//     final animation = _latLngTween!
//         .animate(CurvedAnimation(parent: _animationController!, curve: Curves.linear));

//     animation.addListener(() {
//       final intermediate = animation.value;
//       _updateMarkerPosition(intermediate, newPos);
//     });

//     _animationController!.forward();

//     _currentRiderPos = newPos;
//   }

//   void _updateMarkerPosition(LatLng intermediate, LatLng headingTo) {
//     final rotation = _calculateBearing(intermediate, headingTo);

//     setState(() {
//       _riderMarker = Marker(
//         markerId: const MarkerId('rider'),
//         position: intermediate,
//         rotation: 0,
//         anchor: const Offset(0.9, 0.9),
//         flat: true, 
//         icon: _riderIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
//       );
//     });
//   }

//   Future<void> _animateCameraTo(LatLng pos) async {
//     try {
//       if (!_mapCtl.isCompleted) return;
//       final ctl = await _mapCtl.future;
//       await ctl.animateCamera(CameraUpdate.newLatLng(pos));
//     } catch (_) {
//       // ignore
//     }
//   }

//   /// REAL ROAD ROUTE using OSRM (keeps polyline updated)
//   Future<void> _updateRouteFrom(LatLng origin) async {
//     try {
//       final originLL = ll.LatLng(origin.latitude, origin.longitude);
//       final destLL =
//           ll.LatLng(widget.destination.latitude, widget.destination.longitude);

//       final routePointsLL =
//           await OsmRouteHelper.getRoutePoints(origin: originLL, destination: destLL);

//       final routePointsGoogle = routePointsLL
//           .map((p) => LatLng(p.latitude, p.longitude))
//           .toList();

//       setState(() {
//         _routePolyline = Polyline(
//           polylineId: const PolylineId('route'),
//           points: routePointsGoogle,
//           color: Colors.blue,
//           width: 6,
//         );
//       });
//     } catch (e) {
//       // fallback: simple straight polyline
//       setState(() {
//         _routePolyline = Polyline(
//           polylineId: const PolylineId('route'),
//           points: [origin, widget.destination],
//           color: Colors.blue,
//           width: 6,
//         );
//       });
//     }
//   }

//   double _calculateBearing(LatLng from, LatLng to) {
//     final lat1 = _toRad(from.latitude);
//     final lon1 = _toRad(from.longitude);
//     final lat2 = _toRad(to.latitude);
//     final lon2 = _toRad(to.longitude);

//     final dLon = lon2 - lon1;
//     final y = math.sin(dLon) * math.cos(lat2);
//     final x = math.cos(lat1) * math.sin(lat2) -
//         math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

//     return (_toDeg(math.atan2(y, x)) + 360) % 360;
//   }

//   double _toRad(double deg) => deg * math.pi / 180;
//   double _toDeg(double rad) => rad * 180 / math.pi;

//   bool _isCloseTo(LatLng a, LatLng b, {double thresholdMeters = 5.0}) {
//     final d = _haversine(a.latitude, a.longitude, b.latitude, b.longitude);
//     return d <= thresholdMeters;
//   }

//   double _haversine(lat1, lon1, lat2, lon2) {
//     const R = 6371000; // Earth radius in meters
//     final dLat = _toRad(lat2 - lat1);
//     final dLon = _toRad(lon2 - lon1);

//     final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
//         math.cos(_toRad(lat1)) *
//             math.cos(_toRad(lat2)) *
//             math.sin(dLon / 2) *
//             math.sin(dLon / 2);

//     final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

//     return R * c;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final camera = CameraPosition(target: widget.initialCenter, zoom: 15);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Rider Tracking'),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 12.0),
//             child: Row(
//               children: [
//                 Icon(_isPolling ? Icons.sync : Icons.sync_disabled),
//                 const SizedBox(width: 6),
//                 Text(_isPolling ? 'Polling' : 'Stopped'),
//               ],
//             ),
//           )
//         ],
//       ),
//       body: GoogleMap(
//         initialCameraPosition: camera,
//         myLocationEnabled: false,
//         markers: {
//           if (_riderMarker != null) _riderMarker!,
//           if (_destMarker != null) _destMarker!,
//         },
//         polylines: {
//           if (_routePolyline != null) _routePolyline!,
//         },
//         onMapCreated: (g) {
//           if (!_mapCtl.isCompleted) _mapCtl.complete(g);
//           _mapController = g;
//         },
//       ),
//     );
//   }
// }

// /// Small helper tween for LatLng interpolation
// class LatLngTween extends Tween<LatLng> {
//   LatLngTween({required LatLng begin, required LatLng end})
//       : super(begin: begin, end: end);

//   @override
//   LatLng lerp(double t) => LatLng(begin!.latitude + (end!.latitude - begin!.latitude) * t,
//       begin!.longitude + (end!.longitude - begin!.longitude) * t);
// }













// // lib/screens/tracking_screen_google.dart
// import 'dart:async';
// import 'dart:convert';
// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;

// class TrackingScreenGoogle extends StatefulWidget {
//   final String deliveryBoyId;
//   final String userId;
//   final LatLng destination;
//   final Duration pollingInterval;

//   const TrackingScreenGoogle({
//     super.key,
//     required this.deliveryBoyId,
//     required this.userId,
//     required this.destination,
//     this.pollingInterval = const Duration(seconds: 5),
//   });

//   @override
//   State<TrackingScreenGoogle> createState() => _TrackingScreenGoogleState();
// }

// class _TrackingScreenGoogleState extends State<TrackingScreenGoogle>
//     with TickerProviderStateMixin {
//   final Completer<GoogleMapController> _mapCtl = Completer();

//   LatLng? _currentRiderPos;
//   LatLng? _initialRiderPos;

//   Marker? _riderMarker;
//   Marker? _destMarker;

//   Polyline? _routePolyline;

//   Timer? _pollTimer;
//   bool _isLoading = true;
//   String? _errorMessage;

//   AnimationController? _animationController;
//   LatLngTween? _latLngTween;

//   static const String _apiBase = "https://api.vegiffyy.com";

//   /// Google Directions API Key
//   static const String googleKey = "YOUR_GOOGLE_API_KEY";

//   @override
//   void initState() {
//     super.initState();

//     _destMarker = Marker(
//       markerId: const MarkerId("dest"),
//       position: widget.destination,
//     );

//     _startTracking();
//   }

//   @override
//   void dispose() {
//     _pollTimer?.cancel();
//     _animationController?.dispose();
//     super.dispose();
//   }

//   void _startTracking() async {
//     // First fetch to get initial position
//     await _fetchLocationOnce(initialFetch: true);

//     // Start periodic polling
//     _pollTimer = Timer.periodic(widget.pollingInterval, (_) {
//       _fetchLocationOnce();
//     });
//   }

//   Future<void> _fetchLocationOnce({bool initialFetch = false}) async {
//     try {
//       final url = Uri.parse(
//           "$_apiBase/api/delivery-boy/location/${widget.deliveryBoyId}/${widget.userId}");

//       final resp = await http.get(url).timeout(const Duration(seconds: 8));

//       if (resp.statusCode != 200) {
//         if (initialFetch) {
//           setState(() {
//             _errorMessage = "Failed to get rider location";
//             _isLoading = false;
//           });
//         }
//         return;
//       }

//       final body = json.decode(resp.body);

//       if (body["success"] != true) {
//         if (initialFetch) {
//           setState(() {
//             _errorMessage = "Rider location not available";
//             _isLoading = false;
//           });
//         }
//         return;
//       }

//       final data = body["data"];
//       if (data == null) {
//         if (initialFetch) {
//           setState(() {
//             _errorMessage = "No location data available";
//             _isLoading = false;
//           });
//         }
//         return;
//       }

//       final lat = (data["latitude"] as num?)?.toDouble();
//       final lng = (data["longitude"] as num?)?.toDouble();

//       if (lat == null || lng == null) {
//         if (initialFetch) {
//           setState(() {
//             _errorMessage = "Invalid location coordinates";
//             _isLoading = false;
//           });
//         }
//         return;
//       }

//       final newPos = LatLng(lat, lng);

//       // Store initial position if this is first fetch
//       if (initialFetch) {
//         _initialRiderPos = newPos;
//         setState(() {
//           _isLoading = false;
//         });
//       }

//       // Print rider coordinates every update
//       print("🚴 Rider location: ${newPos.latitude}, ${newPos.longitude}");

//       if (_currentRiderPos == null) {
//         _setInitialMarker(newPos);
//       } else {
//         _animateMarker(newPos);
//       }

//       await _updatePolyline(newPos);

//       _moveCamera(newPos);
//     } catch (e) {
//       print("Tracking error: $e");
//       if (initialFetch) {
//         setState(() {
//           _errorMessage = "Network error: $e";
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   void _setInitialMarker(LatLng pos) {
//     _currentRiderPos = pos;

//     _riderMarker = Marker(
//       markerId: const MarkerId("rider"),
//       position: pos,
//       anchor: const Offset(0.5, 0.5),
//     );

//     setState(() {});
//   }

//   void _animateMarker(LatLng newPos) {
//     final oldPos = _currentRiderPos!;

//     _animationController?.dispose();

//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 900),
//     );

//     _latLngTween = LatLngTween(begin: oldPos, end: newPos);

//     final animation = _latLngTween!.animate(_animationController!);

//     animation.addListener(() {
//       final v = animation.value;

//       setState(() {
//         _riderMarker = Marker(
//           markerId: const MarkerId("rider"),
//           position: v,
//           flat: true,
//           rotation: _calculateBearing(oldPos, newPos),
//         );
//       });
//     });

//     _animationController!.forward();
//     _currentRiderPos = newPos;
//   }

//   double _calculateBearing(LatLng from, LatLng to) {
//     double lat1 = from.latitude * math.pi / 180;
//     double lon1 = from.longitude * math.pi / 180;
//     double lat2 = to.latitude * math.pi / 180;
//     double lon2 = to.longitude * math.pi / 180;

//     double dLon = lon2 - lon1;
//     double y = math.sin(dLon) * math.cos(lat2);
//     double x = math.cos(lat1) * math.sin(lat2) -
//         math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

//     double bearing = math.atan2(y, x) * 180 / math.pi;
//     return (bearing + 360) % 360;
//   }

//   Future<void> _moveCamera(LatLng pos) async {
//     if (!_mapCtl.isCompleted) return;

//     final map = await _mapCtl.future;
//     map.animateCamera(CameraUpdate.newLatLng(pos));
//   }

//   /// Google Directions API polyline
//   Future<void> _updatePolyline(LatLng origin) async {
//     try {
//       final url =
//           "https://maps.googleapis.com/maps/api/directions/json?"
//           "origin=${origin.latitude},${origin.longitude}"
//           "&destination=${widget.destination.latitude},${widget.destination.longitude}"
//           "&key=$googleKey";

//       final res = await http.get(Uri.parse(url));

//       if (res.statusCode != 200) return;

//       final data = json.decode(res.body);

//       if (data["routes"].isEmpty) return;

//       final points = data["routes"][0]["overview_polyline"]["points"];

//       final decoded = _decodePolyline(points);

//       setState(() {
//         _routePolyline = Polyline(
//           polylineId: const PolylineId("route"),
//           width: 6,
//           color: Colors.blue,
//           points: decoded,
//         );
//       });
//     } catch (e) {
//       print("Error updating polyline: $e");
//     }
//   }

//   List<LatLng> _decodePolyline(String poly) {
//     List<LatLng> list = [];
//     int index = 0;
//     int lat = 0;
//     int lng = 0;

//     while (index < poly.length) {
//       int b, shift = 0, result = 0;

//       do {
//         b = poly.codeUnitAt(index++) - 63;
//         result |= (b & 0x1f) << shift;
//         shift += 5;
//       } while (b >= 0x20);

//       int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
//       lat += dlat;

//       shift = 0;
//       result = 0;

//       do {
//         b = poly.codeUnitAt(index++) - 63;
//         result |= (b & 0x1f) << shift;
//         shift += 5;
//       } while (b >= 0x20);

//       int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
//       lng += dlng;

//       list.add(LatLng(lat / 1E5, lng / 1E5));
//     }

//     return list;
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Determine camera target - use current rider position if available,
//     // otherwise show loading state
//     CameraPosition camera;
//     if (_currentRiderPos != null) {
//       camera = CameraPosition(target: _currentRiderPos!, zoom: 15);
//     } else if (_initialRiderPos != null) {
//       camera = CameraPosition(target: _initialRiderPos!, zoom: 15);
//     } else {
//       // Fallback to destination while loading
//       camera = CameraPosition(target: widget.destination, zoom: 12);
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Track Your Order"),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 12.0),
//             child: Row(
//               children: [
//                 Container(
//                   width: 8,
//                   height: 8,
//                   decoration: BoxDecoration(
//                     color: _pollTimer?.isActive == true ? Colors.green : Colors.grey,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//                 const SizedBox(width: 6),
//                 Text(
//                   _pollTimer?.isActive == true ? 'Live' : 'Stopped',
//                   style: TextStyle(
//                     color: _pollTimer?.isActive == true ? Colors.green : Colors.grey,
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: camera,
//             myLocationEnabled: false,
//             markers: {
//               if (_riderMarker != null) _riderMarker!,
//               if (_destMarker != null) _destMarker!,
//             },
//             polylines: {
//               if (_routePolyline != null) _routePolyline!,
//             },
//             onMapCreated: (map) {
//               if (!_mapCtl.isCompleted) {
//                 _mapCtl.complete(map);
//               }
//             },
//           ),

//           // Loading indicator
//           if (_isLoading)
//             Container(
//               color: Colors.black.withOpacity(0.3),
//               child: const Center(
//                 child: Card(
//                   child: Padding(
//                     padding: EdgeInsets.all(16.0),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         CircularProgressIndicator(),
//                         SizedBox(height: 12),
//                         Text("Fetching rider location..."),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//           // Error message
//           if (_errorMessage != null)
//             Positioned(
//               top: 16,
//               left: 16,
//               right: 16,
//               child: Card(
//                 color: Colors.red.shade50,
//                 child: Padding(
//                   padding: const EdgeInsets.all(12.0),
//                   child: Row(
//                     children: [
//                       Icon(Icons.error, color: Colors.red.shade700),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           _errorMessage!,
//                           style: TextStyle(color: Colors.red.shade700),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//           // Distance info
//           if (_currentRiderPos != null)
//             Positioned(
//               bottom: 16,
//               left: 16,
//               right: 16,
//               child: Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "Rider is",
//                             style: TextStyle(fontSize: 12, color: Colors.grey),
//                           ),
//                           Text(
//                             _getDistanceFromDestination(_currentRiderPos!),
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                       ElevatedButton(
//                         onPressed: () {
//                           // Call rider or show more details
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green,
//                           foregroundColor: Colors.white,
//                         ),
//                         child: const Text("CONTACT RIDER"),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   String _getDistanceFromDestination(LatLng riderPos) {
//     const R = 6371000; // Earth radius in meters
//     double lat1 = riderPos.latitude * math.pi / 180;
//     double lon1 = riderPos.longitude * math.pi / 180;
//     double lat2 = widget.destination.latitude * math.pi / 180;
//     double lon2 = widget.destination.longitude * math.pi / 180;

//     double dLat = lat2 - lat1;
//     double dLon = lon2 - lon1;

//     double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
//         math.cos(lat1) * math.cos(lat2) *
//         math.sin(dLon / 2) * math.sin(dLon / 2);

//     double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
//     double distance = R * c;

//     if (distance < 1000) {
//       return "${distance.toStringAsFixed(0)} meters away";
//     } else {
//       return "${(distance / 1000).toStringAsFixed(1)} km away";
//     }
//   }
// }

// /// LatLng animation tween
// class LatLngTween extends Tween<LatLng> {
//   LatLngTween({required LatLng begin, required LatLng end})
//       : super(begin: begin, end: end);

//   @override
//   LatLng lerp(double t) {
//     return LatLng(
//       begin!.latitude + (end!.latitude - begin!.latitude) * t,
//       begin!.longitude + (end!.longitude - begin!.longitude) * t,
//     );
//   }
// }


















// lib/screens/tracking_screen_google.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Add this for debugPrint
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class TrackingScreenGoogle extends StatefulWidget {
  final String deliveryBoyId;
  final String userId;
  final LatLng destination;
  final Duration pollingInterval;

  const TrackingScreenGoogle({
    super.key,
    required this.deliveryBoyId,
    required this.userId,
    required this.destination,
    this.pollingInterval = const Duration(seconds: 5),
  });

  @override
  State<TrackingScreenGoogle> createState() => _TrackingScreenGoogleState();
}

class _TrackingScreenGoogleState extends State<TrackingScreenGoogle>
    with TickerProviderStateMixin {
  final Completer<GoogleMapController> _mapCtl = Completer();

  LatLng? _currentRiderPos;
  LatLng? _initialRiderPos;

  Marker? _riderMarker;
  Marker? _destMarker;

  Polyline? _routePolyline;

  Timer? _pollTimer;
  bool _isLoading = true;
  String? _errorMessage;

  AnimationController? _animationController;
  LatLngTween? _latLngTween;

  static const String _apiBase = "https://api.vegiffyy.com";

  /// Google Directions API Key
  static const String googleKey = "YOUR_GOOGLE_API_KEY";

  @override
  void initState() {
    super.initState();
    
    debugPrint("🚀 TrackingScreenGoogle initState - START");
    debugPrint("📦 deliveryBoyId: ${widget.deliveryBoyId}");
    debugPrint("📦 userId: ${widget.userId}");
    debugPrint("📍 destination: ${widget.destination.latitude}, ${widget.destination.longitude}");

    _destMarker = Marker(
      markerId: const MarkerId("dest"),
      position: widget.destination,
    );

    _startTracking();
    debugPrint("🚀 TrackingScreenGoogle initState - END");
  }

  @override
  void dispose() {
    debugPrint("🗑️ TrackingScreenGoogle dispose");
    _pollTimer?.cancel();
    _animationController?.dispose();
    super.dispose();
  }

  void _startTracking() async {
    debugPrint("🎯 _startTracking called");
    
    // First fetch to get initial position
    debugPrint("📡 Calling _fetchLocationOnce with initialFetch=true");
    await _fetchLocationOnce(initialFetch: true);
    
    debugPrint("⏰ Starting periodic timer every ${widget.pollingInterval.inSeconds} seconds");
    // Start periodic polling
    _pollTimer = Timer.periodic(widget.pollingInterval, (_) {
      debugPrint("⏰ Timer tick - calling _fetchLocationOnce");
      _fetchLocationOnce();
    });
    
    debugPrint("✅ _startTracking completed");
  }

  Future<void> _fetchLocationOnce({bool initialFetch = false}) async {
    debugPrint("📡 _fetchLocationOnce called - initialFetch: $initialFetch");
    
    try {
      final url = Uri.parse(
          "$_apiBase/api/delivery-boy/location/${widget.deliveryBoyId}/${widget.userId}");
      
      debugPrint("🔗 URL: $url");

      debugPrint("⏳ Sending HTTP request...");
      final resp = await http.get(url).timeout(const Duration(seconds: 8));
      
      debugPrint("📥 Response received - Status code: ${resp.statusCode}");
      debugPrint("📥 Response body: ${resp.body}");

      if (resp.statusCode != 200) {
        debugPrint("❌ Error: Non-200 status code: ${resp.statusCode}");
        if (initialFetch) {
          setState(() {
            _errorMessage = "Failed to get rider location (Status: ${resp.statusCode})";
            _isLoading = false;
          });
        }
        return;
      }

      debugPrint("✅ Status code 200 OK");
      
      final body = json.decode(resp.body);
      debugPrint("📊 Parsed JSON body: $body");

      if (body["success"] != true) {
        debugPrint("❌ Error: success != true. Value: ${body["success"]}");
        if (initialFetch) {
          setState(() {
            _errorMessage = "Rider location not available";
            _isLoading = false;
          });
        }
        return;
      }

      debugPrint("✅ success = true");

      final data = body["data"];
      debugPrint("📁 data field: $data");
      
      if (data == null) {
        debugPrint("❌ Error: data is null");
        if (initialFetch) {
          setState(() {
            _errorMessage = "No location data available";
            _isLoading = false;
          });
        }
        return;
      }

      debugPrint("✅ data is not null");

      final lat = (data["latitude"] as num?)?.toDouble();
      final lng = (data["longitude"] as num?)?.toDouble();

      debugPrint("📍 Extracted - lat: $lat, lng: $lng");

      if (lat == null || lng == null) {
        debugPrint("❌ Error: lat or lng is null");
        if (initialFetch) {
          setState(() {
            _errorMessage = "Invalid location coordinates";
            _isLoading = false;
          });
        }
        return;
      }

      debugPrint("✅ Valid coordinates received");

      final newPos = LatLng(lat, lng);

      // Store initial position if this is first fetch
      if (initialFetch) {
        debugPrint("💾 Storing initial rider position");
        _initialRiderPos = newPos;
        setState(() {
          _isLoading = false;
        });
      }

      // Print rider coordinates every update - THIS SHOULD NOW PRINT
      debugPrint("🚴 Rider location: ${newPos.latitude}, ${newPos.longitude}");

      if (_currentRiderPos == null) {
        debugPrint("🆕 Setting initial marker");
        _setInitialMarker(newPos);
      } else {
        debugPrint("🔄 Animating marker to new position");
        _animateMarker(newPos);
      }

      debugPrint("🗺️ Updating polyline");
      await _updatePolyline(newPos);

      debugPrint("📷 Moving camera");
      _moveCamera(newPos);
      
      debugPrint("✅ _fetchLocationOnce completed successfully");
      
    } catch (e) {
      debugPrint("🔥 Exception in _fetchLocationOnce: $e");
      debugPrint("🔥 Exception type: ${e.runtimeType}");
      
      if (initialFetch) {
        setState(() {
          _errorMessage = "Network error: ${e.toString()}";
          _isLoading = false;
        });
      }
    }
  }

  void _setInitialMarker(LatLng pos) {
    debugPrint("📍 _setInitialMarker called with position: ${pos.latitude}, ${pos.longitude}");
    _currentRiderPos = pos;

    _riderMarker = Marker(
      markerId: const MarkerId("rider"),
      position: pos,
      anchor: const Offset(0.5, 0.5),
    );

    setState(() {});
    debugPrint("✅ _setInitialMarker completed");
  }

  void _animateMarker(LatLng newPos) {
    debugPrint("🎬 _animateMarker from ${_currentRiderPos?.latitude},${_currentRiderPos?.longitude} to ${newPos.latitude},${newPos.longitude}");
    
    final oldPos = _currentRiderPos!;

    _animationController?.dispose();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _latLngTween = LatLngTween(begin: oldPos, end: newPos);

    final animation = _latLngTween!.animate(_animationController!);

    animation.addListener(() {
      final v = animation.value;

      setState(() {
        _riderMarker = Marker(
          markerId: const MarkerId("rider"),
          position: v,
          flat: true,
          rotation: _calculateBearing(oldPos, newPos),
        );
      });
    });

    _animationController!.forward();
    _currentRiderPos = newPos;
    
    debugPrint("✅ _animateMarker started");
  }

  double _calculateBearing(LatLng from, LatLng to) {
    double lat1 = from.latitude * math.pi / 180;
    double lon1 = from.longitude * math.pi / 180;
    double lat2 = to.latitude * math.pi / 180;
    double lon2 = to.longitude * math.pi / 180;

    double dLon = lon2 - lon1;
    double y = math.sin(dLon) * math.cos(lat2);
    double x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    double bearing = math.atan2(y, x) * 180 / math.pi;
    return (bearing + 360) % 360;
  }

  Future<void> _moveCamera(LatLng pos) async {
    debugPrint("📷 _moveCamera to ${pos.latitude}, ${pos.longitude}");
    
    if (!_mapCtl.isCompleted) {
      debugPrint("⚠️ Map controller not ready yet");
      return;
    }

    final map = await _mapCtl.future;
    await map.animateCamera(CameraUpdate.newLatLng(pos));
    debugPrint("✅ _moveCamera completed");
  }

  /// Google Directions API polyline
  Future<void> _updatePolyline(LatLng origin) async {
    debugPrint("🗺️ _updatePolyline called");
    
    try {
      final url =
          "https://maps.googleapis.com/maps/api/directions/json?"
          "origin=${origin.latitude},${origin.longitude}"
          "&destination=${widget.destination.latitude},${widget.destination.longitude}"
          "&key=$googleKey";

      debugPrint("🗺️ Directions URL: $url");

      final res = await http.get(Uri.parse(url));

      if (res.statusCode != 200) {
        debugPrint("❌ Directions API error: ${res.statusCode}");
        return;
      }

      final data = json.decode(res.body);

      if (data["routes"].isEmpty) {
        debugPrint("❌ No routes found");
        return;
      }

      final points = data["routes"][0]["overview_polyline"]["points"];
      debugPrint("✅ Got polyline points (length: ${points.length})");

      final decoded = _decodePolyline(points);
      debugPrint("✅ Decoded ${decoded.length} points");

      setState(() {
        _routePolyline = Polyline(
          polylineId: const PolylineId("route"),
          width: 6,
          color: Colors.blue,
          points: decoded,
        );
      });
      
      debugPrint("✅ _updatePolyline completed");
    } catch (e) {
      debugPrint("🔥 Error updating polyline: $e");
    }
  }

  List<LatLng> _decodePolyline(String poly) {
    List<LatLng> list = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < poly.length) {
      int b, shift = 0, result = 0;

      do {
        b = poly.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = poly.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      list.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("🎨 Building UI - isLoading: $_isLoading, errorMessage: $_errorMessage");
    
    // Determine camera target - use current rider position if available,
    // otherwise show loading state
    CameraPosition camera;
    if (_currentRiderPos != null) {
      camera = CameraPosition(target: _currentRiderPos!, zoom: 15);
    } else if (_initialRiderPos != null) {
      camera = CameraPosition(target: _initialRiderPos!, zoom: 15);
    } else {
      // Fallback to destination while loading
      camera = CameraPosition(target: widget.destination, zoom: 12);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Track Your Order"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _pollTimer?.isActive == true ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _pollTimer?.isActive == true ? 'Live' : 'Stopped',
                  style: TextStyle(
                    color: _pollTimer?.isActive == true ? Colors.green : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: camera,
            myLocationEnabled: false,
            markers: {
              if (_riderMarker != null) _riderMarker!,
              if (_destMarker != null) _destMarker!,
            },
            polylines: {
              if (_routePolyline != null) _routePolyline!,
            },
            onMapCreated: (map) {
              debugPrint("🗺️ Map created");
              if (!_mapCtl.isCompleted) {
                _mapCtl.complete(map);
                debugPrint("✅ Map controller completed");
              }
            },
          ),

          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text("Fetching rider location..."),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Error message
          if (_errorMessage != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Distance info
          if (_currentRiderPos != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Rider is",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            _getDistanceFromDestination(_currentRiderPos!),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Call rider or show more details
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("CONTACT RIDER"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getDistanceFromDestination(LatLng riderPos) {
    const R = 6371000; // Earth radius in meters
    double lat1 = riderPos.latitude * math.pi / 180;
    double lon1 = riderPos.longitude * math.pi / 180;
    double lat2 = widget.destination.latitude * math.pi / 180;
    double lon2 = widget.destination.longitude * math.pi / 180;

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) *
        math.sin(dLon / 2) * math.sin(dLon / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    double distance = R * c;

    if (distance < 1000) {
      return "${distance.toStringAsFixed(0)} meters away";
    } else {
      return "${(distance / 1000).toStringAsFixed(1)} km away";
    }
  }
}

/// LatLng animation tween
class LatLngTween extends Tween<LatLng> {
  LatLngTween({required LatLng begin, required LatLng end})
      : super(begin: begin, end: end);

  @override
  LatLng lerp(double t) {
    return LatLng(
      begin!.latitude + (end!.latitude - begin!.latitude) * t,
      begin!.longitude + (end!.longitude - begin!.longitude) * t,
    );
  }
}