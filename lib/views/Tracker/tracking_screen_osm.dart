
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


















// // lib/screens/tracking_screen_google.dart
// import 'dart:async';
// import 'dart:convert';
// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart'; // Add this for debugPrint
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
//   static const String googleKey = "AIzaSyDaJzdZ5-Q2Lv2KArStqAtGXf4SukdHwig";

//   @override
//   void initState() {
//     super.initState();
    
//     debugPrint("🚀 TrackingScreenGoogle initState - START");
//     debugPrint("📦 deliveryBoyId: ${widget.deliveryBoyId}");
//     debugPrint("📦 userId: ${widget.userId}");
//     debugPrint("📍 destination: ${widget.destination.latitude}, ${widget.destination.longitude}");

//     _destMarker = Marker(
//       markerId: const MarkerId("dest"),
//       position: widget.destination,
//     );

//     _startTracking();
//     debugPrint("🚀 TrackingScreenGoogle initState - END");
//   }

//   @override
//   void dispose() {
//     debugPrint("🗑️ TrackingScreenGoogle dispose");
//     _pollTimer?.cancel();
//     _animationController?.dispose();
//     super.dispose();
//   }

//   void _startTracking() async {
//     debugPrint("🎯 _startTracking called");
    
//     // First fetch to get initial position
//     debugPrint("📡 Calling _fetchLocationOnce with initialFetch=true");
//     await _fetchLocationOnce(initialFetch: true);
    
//     debugPrint("⏰ Starting periodic timer every ${widget.pollingInterval.inSeconds} seconds");
//     // Start periodic polling
//     _pollTimer = Timer.periodic(widget.pollingInterval, (_) {
//       debugPrint("⏰ Timer tick - calling _fetchLocationOnce");
//       _fetchLocationOnce();
//     });
    
//     debugPrint("✅ _startTracking completed");
//   }

//   Future<void> _fetchLocationOnce({bool initialFetch = false}) async {
//     debugPrint("📡 _fetchLocationOnce called - initialFetch: $initialFetch");
    
//     try {
//       final url = Uri.parse(
//           "$_apiBase/api/delivery-boy/location/${widget.deliveryBoyId}/${widget.userId}");
      
//       debugPrint("🔗 URL: $url");

//       debugPrint("⏳ Sending HTTP request...");
//       final resp = await http.get(url).timeout(const Duration(seconds: 8));
      
//       debugPrint("📥 Response received - Status code: ${resp.statusCode}");
//       debugPrint("📥 Response body: ${resp.body}");

//       if (resp.statusCode != 200) {
//         debugPrint("❌ Error: Non-200 status code: ${resp.statusCode}");
//         if (initialFetch) {
//           setState(() {
//             _errorMessage = "Failed to get rider location (Status: ${resp.statusCode})";
//             _isLoading = false;
//           });
//         }
//         return;
//       }

//       debugPrint("✅ Status code 200 OK");
      
//       final body = json.decode(resp.body);
//       debugPrint("📊 Parsed JSON body: $body");

//       if (body["success"] != true) {
//         debugPrint("❌ Error: success != true. Value: ${body["success"]}");
//         if (initialFetch) {
//           setState(() {
//             _errorMessage = "Rider location not available";
//             _isLoading = false;
//           });
//         }
//         return;
//       }

//       debugPrint("✅ success = true");

//       final data = body["data"];
//       debugPrint("📁 data field: $data");
      
//       if (data == null) {
//         debugPrint("❌ Error: data is null");
//         if (initialFetch) {
//           setState(() {
//             _errorMessage = "No location data available";
//             _isLoading = false;
//           });
//         }
//         return;
//       }

//       debugPrint("✅ data is not null");

//       final lat = (data["latitude"] as num?)?.toDouble();
//       final lng = (data["longitude"] as num?)?.toDouble();

//       debugPrint("📍 Extracted - lat: $lat, lng: $lng");

//       if (lat == null || lng == null) {
//         debugPrint("❌ Error: lat or lng is null");
//         if (initialFetch) {
//           setState(() {
//             _errorMessage = "Invalid location coordinates";
//             _isLoading = false;
//           });
//         }
//         return;
//       }

//       debugPrint("✅ Valid coordinates received");

//       final newPos = LatLng(lat, lng);

//       // Store initial position if this is first fetch
//       if (initialFetch) {
//         debugPrint("💾 Storing initial rider position");
//         _initialRiderPos = newPos;
//         setState(() {
//           _isLoading = false;
//         });
//       }

//       // Print rider coordinates every update - THIS SHOULD NOW PRINT
//       debugPrint("🚴 Rider location: ${newPos.latitude}, ${newPos.longitude}");

//       if (_currentRiderPos == null) {
//         debugPrint("🆕 Setting initial marker");
//         _setInitialMarker(newPos);
//       } else {
//         debugPrint("🔄 Animating marker to new position");
//         _animateMarker(newPos);
//       }

//       debugPrint("🗺️ Updating polyline");
//       await _updatePolyline(newPos);

//       debugPrint("📷 Moving camera");
//       _moveCamera(newPos);
      
//       debugPrint("✅ _fetchLocationOnce completed successfully");
      
//     } catch (e) {
//       debugPrint("🔥 Exception in _fetchLocationOnce: $e");
//       debugPrint("🔥 Exception type: ${e.runtimeType}");
      
//       if (initialFetch) {
//         setState(() {
//           _errorMessage = "Network error: ${e.toString()}";
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   void _setInitialMarker(LatLng pos) {
//     debugPrint("📍 _setInitialMarker called with position: ${pos.latitude}, ${pos.longitude}");
//     _currentRiderPos = pos;

//     _riderMarker = Marker(
//       markerId: const MarkerId("rider"),
//       position: pos,
//       anchor: const Offset(0.5, 0.5),
//     );

//     setState(() {});
//     debugPrint("✅ _setInitialMarker completed");
//   }

//   void _animateMarker(LatLng newPos) {
//     debugPrint("🎬 _animateMarker from ${_currentRiderPos?.latitude},${_currentRiderPos?.longitude} to ${newPos.latitude},${newPos.longitude}");
    
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
    
//     debugPrint("✅ _animateMarker started");
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
//     debugPrint("📷 _moveCamera to ${pos.latitude}, ${pos.longitude}");
    
//     if (!_mapCtl.isCompleted) {
//       debugPrint("⚠️ Map controller not ready yet");
//       return;
//     }

//     final map = await _mapCtl.future;
//     await map.animateCamera(CameraUpdate.newLatLng(pos));
//     debugPrint("✅ _moveCamera completed");
//   }

//   /// Google Directions API polyline
//   Future<void> _updatePolyline(LatLng origin) async {
//     debugPrint("🗺️ _updatePolyline called");
    
//     try {
//       final url =
//           "https://maps.googleapis.com/maps/api/directions/json?"
//           "origin=${origin.latitude},${origin.longitude}"
//           "&destination=${widget.destination.latitude},${widget.destination.longitude}"
//           "&key=$googleKey";

//       debugPrint("🗺️ Directions URL: $url");

//       final res = await http.get(Uri.parse(url));

//       if (res.statusCode != 200) {
//         debugPrint("❌ Directions API error: ${res.statusCode}");
//         return;
//       }

//       final data = json.decode(res.body);

//       if (data["routes"].isEmpty) {
//         debugPrint("❌ No routes found");
//         return;
//       }

//       final points = data["routes"][0]["overview_polyline"]["points"];
//       debugPrint("✅ Got polyline points (length: ${points.length})");

//       final decoded = _decodePolyline(points);
//       debugPrint("✅ Decoded ${decoded.length} points");

//       setState(() {
//         _routePolyline = Polyline(
//           polylineId: const PolylineId("route"),
//           width: 6,
//           color: Colors.blue,
//           points: decoded,
//         );
//       });
      
//       debugPrint("✅ _updatePolyline completed");
//     } catch (e) {
//       debugPrint("🔥 Error updating polyline: $e");
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
//     debugPrint("🎨 Building UI - isLoading: $_isLoading, errorMessage: $_errorMessage");
    
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
//               debugPrint("🗺️ Map created");
//               if (!_mapCtl.isCompleted) {
//                 _mapCtl.complete(map);
//                 debugPrint("✅ Map controller completed");
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

//         print("lllllllllllllllllllllllllll$lat1");
//                 print("lllllllllllllllllllllllllll$lon1");
//         print("lllllllllllllllllllllllllll$lat2");
//         print("lllllllllllllllllllllllllll$lon2");

//                 print("lllllllllllllllllllllllllll${riderPos.latitude}");
//                 print("lllllllllllllllllllllllllll${riderPos.longitude}");
//         print("lllllllllllllllllllllllllll${widget.destination.latitude}");
//         print("lllllllllllllllllllllllllll${widget.destination.longitude}");



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













// // lib/screens/tracking_screen_google.dart
// import 'dart:async';
// import 'dart:convert';
// import 'dart:math' as math;
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'dart:ui' as ui;
// import 'package:flutter/services.dart' show rootBundle;

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
//   GoogleMapController? _mapController;

//   LatLng? _currentRiderPos;
//   LatLng? _initialRiderPos;

//   Marker? _riderMarker;
//   Marker? _destMarker;

//   Set<Polyline> _polylines = {};
//   Set<Marker> _markers = {};

//   Timer? _pollTimer;
//   bool _isLoading = true;
//   String? _errorMessage;

//   AnimationController? _animationController;
//   LatLngTween? _latLngTween;

//   static const String _apiBase = "https://api.vegiffyy.com";

//   /// Google Directions API Key
//   static const String googleKey = "AIzaSyDaJzdZ5-Q2Lv2KArStqAtGXf4SukdHwig";

//   // Custom marker icons
//   BitmapDescriptor? _riderIcon;
//   BitmapDescriptor? _destIcon;
//   bool _iconsLoaded = false;
//   int _updateCount = 0;
//   bool _mapInitialized = false;

//   @override
//   void initState() {
//     super.initState();
    
//     debugPrint("🚀 TrackingScreenGoogle initState - START");
//     debugPrint("📦 deliveryBoyId: ${widget.deliveryBoyId}");
//     debugPrint("📦 userId: ${widget.userId}");
//     debugPrint("📍 destination: ${widget.destination.latitude}, ${widget.destination.longitude}");

//     _loadMarkerIcons().then((_) {
//       _initializeDestinationMarker();
//       _startTracking();
//     });
    
//     debugPrint("🚀 TrackingScreenGoogle initState - END");
//   }

//   @override
//   void dispose() {
//     debugPrint("🗑️ TrackingScreenGoogle dispose");
//     _pollTimer?.cancel();
//     _animationController?.dispose();
//     super.dispose();
//   }

//   /// Load marker icons scaled to desired pixel size
//   Future<void> _loadMarkerIcons() async {
//     try {
//       debugPrint("🖼️ Loading marker icons from assets...");
      
//       final riderBytes = await _getBytesFromAsset('assets/images/rider.png', 120);
//       final destBytes = await _getBytesFromAsset('assets/images/destination.png', 100);

//       if (riderBytes != null) {
//         _riderIcon = BitmapDescriptor.fromBytes(riderBytes);
//         debugPrint("✅ Rider icon loaded successfully");
//       } else {
//         debugPrint("⚠️ Rider icon failed to load, using default");
//         _riderIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
//       }

//       if (destBytes != null) {
//         _destIcon = BitmapDescriptor.fromBytes(destBytes);
//         debugPrint("✅ Destination icon loaded successfully");
//       } else {
//         debugPrint("⚠️ Destination icon failed to load, using default");
//         _destIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
//       }
//     } catch (e) {
//       debugPrint('❌ Error loading marker assets: $e');
//       _riderIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
//       _destIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
//     } finally {
//       setState(() {
//         _iconsLoaded = true;
//       });
//     }
//   }

//   /// Helper: load asset, decode and resize to [width] px (maintains aspect) and return bytes
//   Future<Uint8List?> _getBytesFromAsset(String path, int width) async {
//     try {
//       debugPrint("📸 Loading asset: $path with width: $width");
//       final ByteData data = await rootBundle.load(path);
//       final Uint8List bytes = data.buffer.asUint8List();

//       // decode image
//       final ui.Codec codec = await ui.instantiateImageCodec(bytes, targetWidth: width);
//       final ui.FrameInfo fi = await codec.getNextFrame();
//       final ByteData? resized = await fi.image.toByteData(format: ui.ImageByteFormat.png);
      
//       if (resized == null) {
//         debugPrint("⚠️ Resized image bytes are null");
//         return null;
//       }
      
//       debugPrint("✅ Asset loaded and resized successfully");
//       return resized.buffer.asUint8List();
//     } catch (e) {
//       debugPrint('❌ Error in _getBytesFromAsset: $e');
//       return null;
//     }
//   }

//   void _initializeDestinationMarker() {
//     debugPrint("📍 Initializing destination marker");
    
//     if (_destIcon == null) {
//       debugPrint("⚠️ Destination icon not loaded yet, using default");
//       _destIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
//     }

//     _destMarker = Marker(
//       markerId: const MarkerId("destination"),
//       position: widget.destination,
//       icon: _destIcon!,
//       infoWindow: const InfoWindow(title: "Delivery Location"),
//       anchor: const Offset(0.5, 0.5),
//     );

//     setState(() {
//       _markers.add(_destMarker!);
//     });
    
//     debugPrint("✅ Destination marker initialized");
//   }

//   void _startTracking() async {
//     debugPrint("🎯 _startTracking called");
    
//     // First fetch to get initial position
//     debugPrint("📡 Calling _fetchLocationOnce with initialFetch=true");
//     await _fetchLocationOnce(initialFetch: true);
    
//     debugPrint("⏰ Starting periodic timer every ${widget.pollingInterval.inSeconds} seconds");
//     // Start periodic polling
//     _pollTimer = Timer.periodic(widget.pollingInterval, (_) {
//       debugPrint("⏰ Timer tick - calling _fetchLocationOnce");
//       _fetchLocationOnce();
//     });
    
//     debugPrint("✅ _startTracking completed");
//   }

//   Future<void> _fetchLocationOnce({bool initialFetch = false}) async {
//     debugPrint("📡 _fetchLocationOnce called - initialFetch: $initialFetch");
    
//     try {
//       final url = Uri.parse(
//           "$_apiBase/api/delivery-boy/location/${widget.deliveryBoyId}/${widget.userId}");
      
//       debugPrint("🔗 URL: $url");

//       debugPrint("⏳ Sending HTTP request...");
//       final resp = await http.get(url).timeout(const Duration(seconds: 8));
      
//       debugPrint("📥 Response received - Status code: ${resp.statusCode}");
//       debugPrint("📥 Response body: ${resp.body.substring(0, math.min(200, resp.body.length))}...");

//       if (resp.statusCode != 200) {
//         debugPrint("❌ Error: Non-200 status code: ${resp.statusCode}");
//         if (initialFetch) {
//           setState(() {
//             _errorMessage = "Failed to get rider location (Status: ${resp.statusCode})";
//             _isLoading = false;
//           });
//         }
//         return;
//       }

//       debugPrint("✅ Status code 200 OK");
      
//       final Map<String, dynamic> body = json.decode(resp.body);
//       debugPrint("📊 Parsed JSON body keys: ${body.keys.join(', ')}");

//       if (body["success"] != true) {
//         debugPrint("❌ Error: success != true. Value: ${body["success"]}");
//         if (initialFetch) {
//           setState(() {
//             _errorMessage = "Rider location not available";
//             _isLoading = false;
//           });
//         }
//         return;
//       }

//       debugPrint("✅ success = true");

//       final data = body["data"];
//       debugPrint("📁 data type: ${data.runtimeType}");
      
//       if (data == null) {
//         debugPrint("❌ Error: data is null");
//         if (initialFetch) {
//           setState(() {
//             _errorMessage = "No location data available";
//             _isLoading = false;
//           });
//         }
//         return;
//       }

//       debugPrint("✅ data is not null");

//       final lat = (data["latitude"] as num?)?.toDouble();
//       final lng = (data["longitude"] as num?)?.toDouble();

//       debugPrint("📍 Extracted - lat: $lat, lng: $lng");

//       if (lat == null || lng == null) {
//         debugPrint("❌ Error: lat or lng is null");
//         if (initialFetch) {
//           setState(() {
//             _errorMessage = "Invalid location coordinates";
//             _isLoading = false;
//           });
//         }
//         return;
//       }

//       debugPrint("✅ Valid coordinates received");

//       final newPos = LatLng(lat, lng);
//       _updateCount++;
//       debugPrint("🔄 Update #$_updateCount - Rider location: $lat, $lng");

//       // Store initial position if this is first fetch
//       if (initialFetch) {
//         debugPrint("💾 Storing initial rider position");
//         _initialRiderPos = newPos;
//         setState(() {
//           _isLoading = false;
//         });
//       }

//       if (_currentRiderPos == null) {
//         debugPrint("🆕 Setting initial marker");
//         _setInitialMarker(newPos);
//       } else {
//         debugPrint("🔄 Animating marker to new position");
//         _animateMarker(newPos);
//       }

//       // Update polyline if we have a valid position
//       if (_currentRiderPos != null) {
//         debugPrint("🗺️ Attempting to update polyline");
//         await _updatePolyline(newPos);
//       }

//       // Move camera if map is initialized
//       if (_mapInitialized) {
//         debugPrint("📷 Moving camera");
//         _moveCamera(newPos);
//       } else {
//         debugPrint("⚠️ Map not initialized yet, skipping camera move");
//       }
      
//       debugPrint("✅ _fetchLocationOnce completed successfully");
      
//     } catch (e, stackTrace) {
//       debugPrint("🔥 Exception in _fetchLocationOnce: $e");
//       debugPrint("🔥 Exception type: ${e.runtimeType}");
//       debugPrint("🔥 Stack trace: $stackTrace");
      
//       if (initialFetch) {
//         setState(() {
//           _errorMessage = "Network error: ${e.toString()}";
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   void _setInitialMarker(LatLng pos) {
//     debugPrint("📍 _setInitialMarker called with position: ${pos.latitude}, ${pos.longitude}");
//     _currentRiderPos = pos;

//     if (_riderIcon == null) {
//       debugPrint("⚠️ Rider icon not loaded yet, using default");
//       _riderIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
//     }

//     final marker = Marker(
//       markerId: const MarkerId("rider"),
//       position: pos,
//       icon: _riderIcon!,
//       anchor: const Offset(0.5, 0.5),
//       flat: true,
//       rotation: 0,
//       infoWindow: const InfoWindow(title: "Delivery Boy"),
//     );

//     setState(() {
//       _riderMarker = marker;
//       _markers.removeWhere((m) => m.markerId.value == "rider");
//       _markers.add(marker);
//     });
    
//     debugPrint("✅ _setInitialMarker completed. Total markers: ${_markers.length}");
//   }

//   void _animateMarker(LatLng newPos) {
//     debugPrint("🎬 _animateMarker from ${_currentRiderPos?.latitude},${_currentRiderPos?.longitude} to ${newPos.latitude},${newPos.longitude}");
    
//     final oldPos = _currentRiderPos!;
//     final bearing = _calculateBearing(oldPos, newPos);
//     debugPrint("🧭 Calculated bearing: $bearing");

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
//         final updatedMarker = Marker(
//           markerId: const MarkerId("rider"),
//           position: v,
//           icon: _riderIcon!,
//           anchor: const Offset(0.5, 0.5),
//           flat: true,
//           rotation: bearing,
//           infoWindow: const InfoWindow(title: "Delivery Boy"),
//         );
        
//         _markers.removeWhere((m) => m.markerId.value == "rider");
//         _markers.add(updatedMarker);
//         _riderMarker = updatedMarker;
//       });
//     });

//     _animationController!.forward();
//     _currentRiderPos = newPos;
    
//     debugPrint("✅ _animateMarker started");
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
//     debugPrint("📷 _moveCamera to ${pos.latitude}, ${pos.longitude}");
    
//     if (!_mapCtl.isCompleted) {
//       debugPrint("⚠️ Map controller not ready yet");
//       return;
//     }

//     try {
//       final map = await _mapCtl.future;
//       await map.animateCamera(CameraUpdate.newLatLngZoom(pos, 15));
//       debugPrint("✅ _moveCamera completed");
//     } catch (e) {
//       debugPrint("🔥 Error moving camera: $e");
//     }
//   }

//   /// Google Directions API polyline
//   Future<void> _updatePolyline(LatLng origin) async {
//     debugPrint("🗺️ _updatePolyline called with origin: ${origin.latitude}, ${origin.longitude}");
    
//     if (googleKey.isEmpty) {
//       debugPrint("❌ Google Maps API key is empty!");
//       return;
//     }

//     try {
//       final url = Uri.parse(
//           "https://maps.googleapis.com/maps/api/directions/json?"
//           "origin=${origin.latitude},${origin.longitude}"
//           "&destination=${widget.destination.latitude},${widget.destination.longitude}"
//           "&key=$googleKey");

//       debugPrint("🗺️ Directions URL: $url");

//       final response = await http.get(url).timeout(const Duration(seconds: 10));

//       debugPrint("🗺️ Directions Response Status: ${response.statusCode}");
      
//       if (response.statusCode != 200) {
//         debugPrint("❌ Directions API error: ${response.statusCode}");
//         return;
//       }

//       final Map<String, dynamic> data = json.decode(response.body);
//       debugPrint("🗺️ Directions API Response Status: ${data['status']}");
      
//       if (data['status'] != 'OK') {
//         debugPrint("❌ Directions API returned status: ${data['status']}");
//         if (data['error_message'] != null) {
//           debugPrint("❌ Error message: ${data['error_message']}");
//         }
//         return;
//       }

//       final routes = data['routes'] as List;
//       if (routes.isEmpty) {
//         debugPrint("❌ No routes found");
//         return;
//       }

//       final points = routes[0]['overview_polyline']['points'] as String;
//       debugPrint("✅ Got polyline points (length: ${points.length})");

//       final List<LatLng> decodedPoints = _decodePolyline(points);
//       debugPrint("✅ Decoded ${decodedPoints.length} points");

//       // Verify decoded points
//       if (decodedPoints.isNotEmpty) {
//         debugPrint("📍 First point: ${decodedPoints.first.latitude}, ${decodedPoints.first.longitude}");
//         debugPrint("📍 Last point: ${decodedPoints.last.latitude}, ${decodedPoints.last.longitude}");
//       }

//       setState(() {
//         _polylines.clear();
//         _polylines.add(
//           Polyline(
//             polylineId: const PolylineId("route"),
//             points: decodedPoints,
//             color: Colors.blue,
//             width: 6,
//             geodesic: true,
//           ),
//         );
//       });
      
//       debugPrint("✅ _updatePolyline completed. Polyline count: ${_polylines.length}");
      
//     } catch (e, stackTrace) {
//       debugPrint("🔥 Error updating polyline: $e");
//       debugPrint("🔥 Stack trace: $stackTrace");
      
//       // Fallback to straight line if directions API fails
//       setState(() {
//         _polylines.clear();
//         _polylines.add(
//           Polyline(
//             polylineId: const PolylineId("route"),
//             points: [origin, widget.destination],
//             color: Colors.blue,
//             width: 6,
//             geodesic: true,
//           ),
//         );
//       });
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
//     debugPrint("🎨 Building UI - isLoading: $_isLoading, errorMessage: $_errorMessage");
//     debugPrint("🎨 Markers count: ${_markers.length}, Polylines count: ${_polylines.length}");
    
//     // Determine camera target
//     CameraPosition camera;
//     if (_currentRiderPos != null) {
//       camera = CameraPosition(target: _currentRiderPos!, zoom: 15);
//     } else if (_initialRiderPos != null) {
//       camera = CameraPosition(target: _initialRiderPos!, zoom: 15);
//     } else {
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
//                 const SizedBox(width: 12),
//                 Text(
//                   "Updates: $_updateCount",
//                   style: const TextStyle(fontSize: 12),
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
//             markers: _markers,
//             polylines: _polylines,
//             onMapCreated: (GoogleMapController controller) {
//               debugPrint("🗺️ Map created successfully");
//               if (!_mapCtl.isCompleted) {
//                 _mapCtl.complete(controller);
//                 _mapController = controller;
//                 _mapInitialized = true;
//                 debugPrint("✅ Map controller completed");
                
//                 // Move camera to rider position if available
//                 if (_currentRiderPos != null) {
//                   controller.animateCamera(
//                     CameraUpdate.newLatLngZoom(_currentRiderPos!, 15),
//                   );
//                 }
//               }
//             },
//             // onMapReady: () {
//             //   debugPrint("🗺️ Map is ready");
//             // },
//             mapType: MapType.normal,
//             compassEnabled: true,
//             zoomControlsEnabled: true,
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

//           // Debug info
//           if (kDebugMode && _currentRiderPos != null)
//             Positioned(
//               top: 80,
//               right: 16,
//               child: Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.9),
//                   borderRadius: BorderRadius.circular(8),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.1),
//                       blurRadius: 4,
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Rider: ${_currentRiderPos!.latitude.toStringAsFixed(4)}, ${_currentRiderPos!.longitude.toStringAsFixed(4)}",
//                       style: const TextStyle(fontSize: 10),
//                     ),
//                     Text(
//                       "Updates: $_updateCount",
//                       style: const TextStyle(fontSize: 10),
//                     ),
//                   ],
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
//                       // ElevatedButton(
//                       //   onPressed: () {
//                       //     // Call rider or show more details
//                       //   },
//                       //   style: ElevatedButton.styleFrom(
//                       //     backgroundColor: Colors.green,
//                       //     foregroundColor: Colors.white,
//                       //   ),
//                       //   child: const Text("CONTACT RIDER"),
//                       // ),
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

//     debugPrint("📍 Distance calculation:");
//     debugPrint("  Rider: ${riderPos.latitude}, ${riderPos.longitude}");
//     debugPrint("  Destination: ${widget.destination.latitude}, ${widget.destination.longitude}");

//     double dLat = lat2 - lat1;
//     double dLon = lon2 - lon1;

//     double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
//         math.cos(lat1) * math.cos(lat2) *
//         math.sin(dLon / 2) * math.sin(dLon / 2);

//     double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
//     double distance = R * c;

//     debugPrint("  Distance: ${distance.toStringAsFixed(2)} meters");

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
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import 'package:flutter/services.dart' show rootBundle;

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
  GoogleMapController? _mapController;

  LatLng? _currentRiderPos;
  LatLng? _initialRiderPos;

  Marker? _riderMarker;
  Marker? _destMarker;

  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};

  Timer? _pollTimer;
  bool _isLoading = true;
  String? _errorMessage;

  AnimationController? _animationController;
  LatLngTween? _latLngTween;

  static const String _apiBase = "https://api.vegiffyy.com";

  /// Google Directions API Key - ADD YOUR KEY HERE
  static const String googleKey = "AIzaSyDaJzdZ5-Q2Lv2KArStqAtGXf4SukdHwig";

  // Custom marker icons
  BitmapDescriptor? _riderIcon;
  BitmapDescriptor? _destIcon;
  bool _iconsLoaded = false;
  int _updateCount = 0;
  bool _mapInitialized = false;

  // ETA related variables
  String _etaText = "Calculating ETA...";
  Duration _etaDuration = Duration.zero;
  bool _isEtaLoading = false;
  double _distanceInKm = 0.0;

  @override
  void initState() {
    super.initState();
    
    debugPrint("🚀 TrackingScreenGoogle initState - START");
    debugPrint("📦 deliveryBoyId: ${widget.deliveryBoyId}");
    debugPrint("📦 userId: ${widget.userId}");
    debugPrint("📍 destination: ${widget.destination.latitude}, ${widget.destination.longitude}");

    _loadMarkerIcons().then((_) {
      _initializeDestinationMarker();
      _startTracking();
    });
    
    debugPrint("🚀 TrackingScreenGoogle initState - END");
  }

  @override
  void dispose() {
    debugPrint("🗑️ TrackingScreenGoogle dispose");
    _pollTimer?.cancel();
    _animationController?.dispose();
    super.dispose();
  }

  /// Load marker icons scaled to desired pixel size
  Future<void> _loadMarkerIcons() async {
    try {
      debugPrint("🖼️ Loading marker icons from assets...");
      
      final riderBytes = await _getBytesFromAsset('assets/images/rider.png', 120);
      final destBytes = await _getBytesFromAsset('assets/images/logolocation.png', 100);

      if (riderBytes != null) {
        _riderIcon = BitmapDescriptor.fromBytes(riderBytes);
        debugPrint("✅ Rider icon loaded successfully");
      } else {
        debugPrint("⚠️ Rider icon failed to load, using default");
        _riderIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
      }

      if (destBytes != null) {
        _destIcon = BitmapDescriptor.fromBytes(destBytes);
        debugPrint("✅ Destination icon loaded successfully");
      } else {
        debugPrint("⚠️ Destination icon failed to load, using default");
        _destIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      }
    } catch (e) {
      debugPrint('❌ Error loading marker assets: $e');
      _riderIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
      _destIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    } finally {
      setState(() {
        _iconsLoaded = true;
      });
    }
  }

  /// Helper: load asset, decode and resize to [width] px (maintains aspect) and return bytes
  Future<Uint8List?> _getBytesFromAsset(String path, int width) async {
    try {
      debugPrint("📸 Loading asset: $path with width: $width");
      final ByteData data = await rootBundle.load(path);
      final Uint8List bytes = data.buffer.asUint8List();

      // decode image
      final ui.Codec codec = await ui.instantiateImageCodec(bytes, targetWidth: width);
      final ui.FrameInfo fi = await codec.getNextFrame();
      final ByteData? resized = await fi.image.toByteData(format: ui.ImageByteFormat.png);
      
      if (resized == null) {
        debugPrint("⚠️ Resized image bytes are null");
        return null;
      }
      
      debugPrint("✅ Asset loaded and resized successfully");
      return resized.buffer.asUint8List();
    } catch (e) {
      debugPrint('❌ Error in _getBytesFromAsset: $e');
      return null;
    }
  }

void _initializeDestinationMarker() {
  debugPrint("📍 Initializing destination marker");
  
  if (_destIcon == null) {
    debugPrint("⚠️ Destination icon not loaded yet, using default");
    // Load home icon specifically for destination
    _loadHomeIcon().then((icon) {
      setState(() {
        _destMarker = Marker(
          markerId: const MarkerId("destination"),
          position: widget.destination,
          icon: icon,
          infoWindow: const InfoWindow(title: "Delivery Location"),
          anchor: const Offset(0.5, 0.5),
        );
        _markers.add(_destMarker!);
      });
    });
  } else {
    _destMarker = Marker(
      markerId: const MarkerId("destination"),
      position: widget.destination,
      icon: _destIcon!,
      infoWindow: const InfoWindow(title: "Delivery Location"),
      anchor: const Offset(0.5, 0.5),
    );

    setState(() {
      _markers.add(_destMarker!);
    });
  }
  
  debugPrint("✅ Destination marker initialized");
}

// Add this new method to load home icon
Future<BitmapDescriptor> _loadHomeIcon() async {
  try {
    final homeIconBytes = await _getBytesFromAsset('assets/images/logolocation.png', 100);
    if (homeIconBytes != null) {
      return BitmapDescriptor.fromBytes(homeIconBytes);
    }
  } catch (e) {
    debugPrint('❌ Error loading home icon: $e');
  }
  // Fallback to default marker
  return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
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
            debugPrint("📥 Response received - Status code: ${resp.body}");

      debugPrint("📥 Response body: ${resp.body.substring(0, math.min(200, resp.body.length))}...");

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
      
      final Map<String, dynamic> body = json.decode(resp.body);
      debugPrint("📊 Parsed JSON body keys: ${body.keys.join(', ')}");

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
      debugPrint("📁 data type: ${data.runtimeType}");
      
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
      _updateCount++;
      debugPrint("🔄 Update #$_updateCount - Rider location: $lat, $lng");

      // Store initial position if this is first fetch
      if (initialFetch) {
        debugPrint("💾 Storing initial rider position");
        _initialRiderPos = newPos;
        setState(() {
          _isLoading = false;
        });
      }

      if (_currentRiderPos == null) {
        debugPrint("🆕 Setting initial marker");
        _setInitialMarker(newPos);
      } else {
        debugPrint("🔄 Animating marker to new position");
        _animateMarker(newPos);
      }

      // Update polyline and ETA if we have a valid position
      if (_currentRiderPos != null) {
        debugPrint("🗺️ Attempting to update polyline and ETA");
        await _updatePolylineAndETA(newPos);
      }

      // Move camera if map is initialized
      if (_mapInitialized) {
        debugPrint("📷 Moving camera");
        _moveCamera(newPos);
      } else {
        debugPrint("⚠️ Map not initialized yet, skipping camera move");
      }
      
      debugPrint("✅ _fetchLocationOnce completed successfully");
      
    } catch (e, stackTrace) {
      debugPrint("🔥 Exception in _fetchLocationOnce: $e");
      debugPrint("🔥 Exception type: ${e.runtimeType}");
      debugPrint("🔥 Stack trace: $stackTrace");
      
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

    if (_riderIcon == null) {
      debugPrint("⚠️ Rider icon not loaded yet, using default");
      _riderIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }

    final marker = Marker(
      markerId: const MarkerId("rider"),
      position: pos,
      icon: _riderIcon!,
      anchor: const Offset(0.5, 0.5),
      flat: true,
      rotation: 0,
      infoWindow: const InfoWindow(title: "Delivery Boy"),
    );

    setState(() {
      _riderMarker = marker;
      _markers.removeWhere((m) => m.markerId.value == "rider");
      _markers.add(marker);
    });
    
    debugPrint("✅ _setInitialMarker completed. Total markers: ${_markers.length}");
  }

  void _animateMarker(LatLng newPos) {
    debugPrint("🎬 _animateMarker from ${_currentRiderPos?.latitude},${_currentRiderPos?.longitude} to ${newPos.latitude},${newPos.longitude}");
    
    final oldPos = _currentRiderPos!;
    final bearing = _calculateBearing(oldPos, newPos);
    debugPrint("🧭 Calculated bearing: $bearing");

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
        final updatedMarker = Marker(
          markerId: const MarkerId("rider"),
          position: v,
          icon: _riderIcon!,
          anchor: const Offset(0.5, 0.5),
          flat: true,
          rotation: bearing,
          infoWindow: const InfoWindow(title: "Delivery Boy"),
        );
        
        _markers.removeWhere((m) => m.markerId.value == "rider");
        _markers.add(updatedMarker);
        _riderMarker = updatedMarker;
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

    try {
      final map = await _mapCtl.future;
      await map.animateCamera(CameraUpdate.newLatLngZoom(pos, 15));
      debugPrint("✅ _moveCamera completed");
    } catch (e) {
      debugPrint("🔥 Error moving camera: $e");
    }
  }

  /// Google Directions API polyline with ETA
  Future<void> _updatePolylineAndETA(LatLng origin) async {
    debugPrint("🗺️ _updatePolylineAndETA called with origin: ${origin.latitude}, ${origin.longitude}");
    
    if (googleKey.isEmpty) {
      debugPrint("❌ Google Maps API key is empty!");
      setState(() {
        _etaText = "ETA unavailable";
      });
      return;
    }

    setState(() {
      _isEtaLoading = true;
    });

    try {
      final url = Uri.parse(
          "https://maps.googleapis.com/maps/api/directions/json?"
          "origin=${origin.latitude},${origin.longitude}"
          "&destination=${widget.destination.latitude},${widget.destination.longitude}"
          "&key=$googleKey");

      debugPrint("🗺️ Directions URL: $url");

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      debugPrint("🗺️ Directions Response Status: ${response.statusCode}");
      
      if (response.statusCode != 200) {
        debugPrint("❌ Directions API error: ${response.statusCode}");
        setState(() {
          _etaText = "ETA unavailable";
          _isEtaLoading = false;
        });
        return;
      }

      final Map<String, dynamic> data = json.decode(response.body);
      debugPrint("🗺️ Directions API Response Status: ${data['status']}");
      
      if (data['status'] != 'OK') {
        debugPrint("❌ Directions API returned status: ${data['status']}");
        if (data['error_message'] != null) {
          debugPrint("❌ Error message: ${data['error_message']}");
        }
        setState(() {
          _etaText = "ETA unavailable";
          _isEtaLoading = false;
        });
        return;
      }

      final routes = data['routes'] as List;
      if (routes.isEmpty) {
        debugPrint("❌ No routes found");
        setState(() {
          _etaText = "No route found";
          _isEtaLoading = false;
        });
        return;
      }

      // Extract duration and distance
      final leg = routes[0]['legs'][0];
      final durationInSeconds = leg['duration']['value'] as int;
      final distanceInMeters = leg['distance']['value'] as int;
      
      _etaDuration = Duration(seconds: durationInSeconds);
      _distanceInKm = distanceInMeters / 1000.0;
      
      // Format ETA text
      _etaText = _formatDuration(_etaDuration);
      
      debugPrint("✅ ETA: $_etaText, Distance: ${_distanceInKm.toStringAsFixed(2)} km");

      // Get polyline points
      final points = routes[0]['overview_polyline']['points'] as String;
      debugPrint("✅ Got polyline points (length: ${points.length})");

      final List<LatLng> decodedPoints = _decodePolyline(points);
      debugPrint("✅ Decoded ${decodedPoints.length} points");

      // Verify decoded points
      if (decodedPoints.isNotEmpty) {
        debugPrint("📍 First point: ${decodedPoints.first.latitude}, ${decodedPoints.first.longitude}");
        debugPrint("📍 Last point: ${decodedPoints.last.latitude}, ${decodedPoints.last.longitude}");
      }

      setState(() {
        _polylines.clear();
        _polylines.add(
          Polyline(
            polylineId: const PolylineId("route"),
            points: decodedPoints,
            color: Colors.green,
            width: 6,
            geodesic: true,
          ),
        );
        _isEtaLoading = false;
      });
      
      debugPrint("✅ _updatePolylineAndETA completed. Polyline count: ${_polylines.length}");
      
    } catch (e, stackTrace) {
      debugPrint("🔥 Error updating polyline and ETA: $e");
      debugPrint("🔥 Stack trace: $stackTrace");
      
      setState(() {
        _etaText = "ETA unavailable";
        _isEtaLoading = false;
      });
      
      // Fallback to straight line if directions API fails
      setState(() {
        _polylines.clear();
        _polylines.add(
          Polyline(
            polylineId: const PolylineId("route"),
            points: [origin, widget.destination],
            color: Colors.blue,
            width: 6,
            geodesic: true,
          ),
        );
      });
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}min';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}min';
    } else {
      return '${duration.inSeconds}s';
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
    debugPrint("🎨 Markers count: ${_markers.length}, Polylines count: ${_polylines.length}");
    
    // Determine camera target
    CameraPosition camera;
    if (_currentRiderPos != null) {
      camera = CameraPosition(target: _currentRiderPos!, zoom: 15);
    } else if (_initialRiderPos != null) {
      camera = CameraPosition(target: _initialRiderPos!, zoom: 15);
    } else {
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
                const SizedBox(width: 12),
                Text(
                  "Updates: $_updateCount",
                  style: const TextStyle(fontSize: 12),
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
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (GoogleMapController controller) {
              debugPrint("🗺️ Map created successfully");
              if (!_mapCtl.isCompleted) {
                _mapCtl.complete(controller);
                _mapController = controller;
                _mapInitialized = true;
                debugPrint("✅ Map controller completed");
                
                // Move camera to rider position if available
                if (_currentRiderPos != null) {
                  controller.animateCamera(
                    CameraUpdate.newLatLngZoom(_currentRiderPos!, 15),
                  );
                }
              }
            },
            mapType: MapType.normal,
            compassEnabled: true,
            zoomControlsEnabled: true,
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

          // ETA Card - Top Center
          // if (_currentRiderPos != null)
          //   Positioned(
          //     top: 16,
          //     left: 16,
          //     right: 16,
          //     child: Material(
          //       elevation: 8,
          //       borderRadius: BorderRadius.circular(30),
          //       child: Container(
          //         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          //         decoration: BoxDecoration(
          //           color: Colors.white,
          //           borderRadius: BorderRadius.circular(30),
          //           boxShadow: [
          //             BoxShadow(
          //               color: Colors.black.withOpacity(0.1),
          //               blurRadius: 10,
          //               offset: const Offset(0, 2),
          //             ),
          //           ],
          //         ),
          //         child: Row(
          //           children: [
          //             Container(
          //               padding: const EdgeInsets.all(8),
          //               decoration: BoxDecoration(
          //                 color: Colors.green.shade50,
          //                 shape: BoxShape.circle,
          //               ),
          //               child: Icon(
          //                 Icons.access_time_filled,
          //                 color: Colors.green.shade700,
          //                 size: 24,
          //               ),
          //             ),
          //             const SizedBox(width: 12),
          //             Expanded(
          //               child: Column(
          //                 crossAxisAlignment: CrossAxisAlignment.start,
          //                 children: [
          //                   Text(
          //                     "Estimated Time",
          //                     style: TextStyle(
          //                       fontSize: 12,
          //                       color: Colors.grey.shade600,
          //                     ),
          //                   ),
          //                   const SizedBox(height: 2),
          //                   _isEtaLoading
          //                       ? Row(
          //                           children: [
          //                             SizedBox(
          //                               width: 16,
          //                               height: 16,
          //                               child: CircularProgressIndicator(
          //                                 strokeWidth: 2,
          //                                 color: Colors.green,
          //                               ),
          //                             ),
          //                             const SizedBox(width: 8),
          //                             const Text(
          //                               "Calculating...",
          //                               style: TextStyle(
          //                                 fontSize: 14,
          //                                 fontWeight: FontWeight.w500,
          //                               ),
          //                             ),
          //                           ],
          //                         )
          //                       : Row(
          //                           children: [
          //                             Text(
          //                               _etaText,
          //                               style: const TextStyle(
          //                                 fontSize: 18,
          //                                 fontWeight: FontWeight.bold,
          //                                 color: Colors.black87,
          //                               ),
          //                             ),
          //                             const SizedBox(width: 8),
          //                             Container(
          //                               padding: const EdgeInsets.symmetric(
          //                                 horizontal: 8,
          //                                 vertical: 2,
          //                               ),
          //                               decoration: BoxDecoration(
          //                                 color: Colors.blue.shade50,
          //                                 borderRadius: BorderRadius.circular(12),
          //                               ),
          //                               child: Text(
          //                                 _distanceInKm > 0
          //                                     ? '${_distanceInKm.toStringAsFixed(1)} km'
          //                                     : '',
          //                                 style: TextStyle(
          //                                   fontSize: 12,
          //                                   color: Colors.blue.shade700,
          //                                   fontWeight: FontWeight.w600,
          //                                 ),
          //                               ),
          //                             ),
          //                           ],
          //                         ),
          //                 ],
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),

          // Debug info
          if (kDebugMode && _currentRiderPos != null)
            Positioned(
              top: 100,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Rider: ${_currentRiderPos!.latitude.toStringAsFixed(4)}, ${_currentRiderPos!.longitude.toStringAsFixed(4)}",
                      style: const TextStyle(fontSize: 10),
                    ),
                    Text(
                      "Updates: $_updateCount",
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),

          // Distance and ETA info at bottom
          if (_currentRiderPos != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Distance",
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getDistanceFromDestination(_currentRiderPos!),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                "ETA",
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              // _isEtaLoading
                              //     ? const SizedBox(
                              //         width: 20,
                              //         height: 20,
                              //         child: CircularProgressIndicator(
                              //           strokeWidth: 2,
                              //         ),
                              //       )
                              //     : 
                                  Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 18,
                                          color: Colors.green.shade700,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _etaText,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Progress bar
                      LinearProgressIndicator(
                        value: _calculateProgress(),
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
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

  double _calculateProgress() {
    if (_currentRiderPos == null) return 0.0;
    
    const R = 6371000;
    double lat1 = _currentRiderPos!.latitude * math.pi / 180;
    double lon1 = _currentRiderPos!.longitude * math.pi / 180;
    double lat2 = widget.destination.latitude * math.pi / 180;
    double lon2 = widget.destination.longitude * math.pi / 180;

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(dLon / 2) * math.sin(dLon / 2);
    
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    double currentDistance = R * c;
    
    // Assuming initial distance (you might want to store this)
    double initialDistance = _calculateInitialDistance();
    
    if (initialDistance <= 0) return 0.0;
    
    double progress = 1 - (currentDistance / initialDistance);
    return progress.clamp(0.0, 1.0);
  }

  double _calculateInitialDistance() {
    if (_initialRiderPos == null) return 1.0;
    
    const R = 6371000;
    double lat1 = _initialRiderPos!.latitude * math.pi / 180;
    double lon1 = _initialRiderPos!.longitude * math.pi / 180;
    double lat2 = widget.destination.latitude * math.pi / 180;
    double lon2 = widget.destination.longitude * math.pi / 180;

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(dLon / 2) * math.sin(dLon / 2);
    
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
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