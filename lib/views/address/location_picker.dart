// // screens/location_picker_screen.dart
// import 'dart:convert';
// import 'package:consultation_app/auth/views/address/location_search_dart';
// import 'package:consultation_app/model/address_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:http/http.dart' as http;


// class LocationPickerScreen extends StatefulWidget {
//   final bool isEditing;
//   final AddressModel? existingAddress;
//   final String userId;

//   const LocationPickerScreen({
//     super.key, 
//     required this.isEditing, 
//     required this.userId,
//     this.existingAddress,
//   });

//   @override
//   State<LocationPickerScreen> createState() => _LocationPickerScreenState();
// }

// class _LocationPickerScreenState extends State<LocationPickerScreen> {
//   final MapController _mapController = MapController();
//   LatLng _currentLatLng = LatLng(12.9716, 77.5946); // Default to Bangalore
//   String _address = "Loading address...";

//   @override
//   void initState() {
//     super.initState();
//     if (widget.isEditing && widget.existingAddress != null) {
//       _currentLatLng = LatLng(widget.existingAddress!.lat, widget.existingAddress!.lng);
//       _address = widget.existingAddress!.address;
//     } else {
//       _determinePosition();
//     }
//   }

//   Future<void> _determinePosition() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) return;

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied ||
//         permission == LocationPermission.deniedForever) {
//       permission = await Geolocator.requestPermission();
//       if (permission != LocationPermission.always &&
//           permission != LocationPermission.whileInUse) return;
//     }

//     Position position = await Geolocator.getCurrentPosition();
//     setState(() {
//       _currentLatLng = LatLng(position.latitude, position.longitude);
//     });

//     _mapController.move(_currentLatLng, 16);
//     _getAddressFromLatLng(_currentLatLng);
//   }

//   Future<void> _getAddressFromLatLng(LatLng position) async {
//     final url = Uri.parse(
//         'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}');

//     try {
//       final response = await http.get(url, headers: {
//         'User-Agent': 'FlutterApp', // Required by Nominatim
//       });

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _address = data['display_name'] ?? 'No address found';
//         });
//       } else {
//         setState(() {
//           _address = 'Failed to load address';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _address = 'Failed to load address';
//       });
//     }
//   }

//   void _onMapMoved(LatLng latLng) {
//     setState(() {
//       _currentLatLng = latLng;
//     });
//   }

//   void _onMapIdle() {
//     _getAddressFromLatLng(_currentLatLng);
//   }

//   // Navigate to search screen and handle result
//   void _openSearchScreen() async {
//     final result = await Navigator.push<Map<String, dynamic>>(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const LocationSearchScreen(),
//       ),
//     );

//     if (result != null) {
//       final LatLng selectedLocation = result['location'];
//       final String selectedAddress = result['address'];
      
//       setState(() {
//         _currentLatLng = selectedLocation;
//         _address = selectedAddress;
//       });
      
//       _mapController.move(_currentLatLng, 16);
//     }
//   }

//   // // Navigate to Edit Address Screen
//   void _confirmLocation() {

//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           FlutterMap(
//             mapController: _mapController,
//             options: MapOptions(
//               initialCenter: _currentLatLng,
//               initialZoom: 16.0,
//               onMapEvent: (event) {
//                 if (event is MapEventMove) {
//                   _onMapMoved(_mapController.camera.center);
//                 } else if (event is MapEventMoveEnd) {
//                   _onMapIdle();
//                 }
//               },
//             ),
//             children: [
//               TileLayer(
//                 urlTemplate:
//                     'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
//                 subdomains: const ['a', 'b', 'c'],
//               ),
//             ],
//           ),

//           // Top Search Bar
//           Positioned(
//             top: MediaQuery.of(context).padding.top,
//             left: 0,
//             right: 0,
//             child: Container(
//               color: Colors.white,
//               padding: EdgeInsets.all(16),
//               child: Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () => Navigator.pop(context),
//                     child: Icon(Icons.arrow_back),
//                   ),
//                   SizedBox(width: 16),
//                   Expanded(
//                     child: GestureDetector(
//                       onTap: _openSearchScreen,
//                       child: Container(
//                         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                         decoration: BoxDecoration(
//                           color: Colors.grey[100],
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(Icons.search, color: Colors.grey),
//                             SizedBox(width: 12),
//                             Expanded(
//                               child: Text(
//                                 'Search for a location...',
//                                 style: TextStyle(color: Colors.grey, fontSize: 16),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Center pin icon
//           Center(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   width: 32,
//                   height: 32,
//                   decoration: BoxDecoration(
//                     color: Colors.orange,
//                     shape: BoxShape.circle,
//                     border: Border.all(color: Colors.white, width: 3),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black26,
//                         blurRadius: 4,
//                         offset: Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Center(
//                     child: Container(
//                       width: 8,
//                       height: 8,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 40),
//               ],
//             ),
//           ),

//           // Current Location Button
//           Positioned(
//             bottom: 300,
//             right: 16,
//             child: GestureDetector(
//               onTap: _determinePosition,
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(8),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black26,
//                       blurRadius: 4,
//                       offset: Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(Icons.my_location, size: 18, color: Colors.orange),
//                       SizedBox(width: 4),
//                       Text(
//                         'Current location',
//                         style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
          
//           // Bottom Sheet
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black26,
//                     blurRadius: 10,
//                     offset: Offset(0, -2),
//                   ),
//                 ],
//               ),
//               child: Padding(
//                 padding: EdgeInsets.all(24),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       'Place the pin at exact delivery location',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                     SizedBox(height: 16),
//                     Row(
//                       children: [
//                         Icon(Icons.location_on, color: Colors.orange),
//                         SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             _address,
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 24),
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: _confirmLocation,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.orange,
//                           padding: EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         child: Text(
//                           'Confirm & proceed',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }




















// screens/location_picker_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:veegify/provider/LocationProvider/location_provider.dart';
import 'package:veegify/views/LocationScreen/location_picker_screen.dart';


class LocationPickerScreen extends StatefulWidget {
  final bool isEditing;
  final String userId;

  const LocationPickerScreen({
    super.key, 
    required this.isEditing, 
    required this.userId,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final MapController _mapController = MapController();
  LatLng _currentLatLng = LatLng(12.9716, 77.5946); // Default to Bangalore
  String _address = "Loading address...";
  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();

      _determinePosition();
    
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentLatLng = LatLng(position.latitude, position.longitude);
    });

    _mapController.move(_currentLatLng, 16);
    _getAddressFromLatLng(_currentLatLng);
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    setState(() {
      _isLoadingAddress = true;
      _address = "Loading address...";
    });

    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=18&addressdetails=1');

    try {
      final response = await http.get(url, headers: {
        'User-Agent': 'FlutterApp/1.0', // Required by Nominatim
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _address = data['display_name'] ?? 'No address found';
          _isLoadingAddress = false;
        });
      } else {
        setState(() {
          _address = 'Failed to load address';
          _isLoadingAddress = false;
        });
      }
    } catch (e) {
      print('Error getting address: $e');
      setState(() {
        _address = 'Failed to load address';
        _isLoadingAddress = false;
      });
    }
  }

  void _onMapMoved(LatLng latLng) {
    setState(() {
      _currentLatLng = latLng;
    });
  }

  void _onMapIdle() {
    _getAddressFromLatLng(_currentLatLng);
  }

  // Navigate to search screen and handle result
  void _openSearchScreen() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationSearchScreen(),
      ),
    );

    if (result != null) {
      final LatLng selectedLocation = result['location'];
      final String selectedAddress = result['address'];
      
      setState(() {
        _currentLatLng = selectedLocation;
        _address = selectedAddress;
      });
      
      _mapController.move(_currentLatLng, 16);
    }
  }

  // Navigate to Edit Address Screen
void _confirmLocation() async {
  // Access the provider
  final locationProvider = Provider.of<LocationProvider>(context, listen: false);

  // Create new coordinates list
  final newCoordinates = [
    _currentLatLng.latitude,
    _currentLatLng.longitude,
  ];

  // Call updateLocation on the provider
  await locationProvider.updateLocation(_address, newCoordinates, widget.userId);

  // Then navigate back or proceed to next screen
  Navigator.pop(context, {
    'location': _currentLatLng,
    'address': _address,
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLatLng,
              initialZoom: 16.0,
              onMapEvent: (event) {
                if (event is MapEventMove) {
                  _onMapMoved(_mapController.camera.center);
                } else if (event is MapEventMoveEnd) {
                  _onMapIdle();
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
            ],
          ),

          // Top Search Bar
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: _openSearchScreen,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: Colors.grey),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Search for a location...',
                                style: TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Center pin icon
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40),
              ],
            ),
          ),

          // Current Location Button
          Positioned(
            bottom: 300,
            right: 16,
            child: GestureDetector(
              onTap: _determinePosition,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.my_location, size: 18, color: Colors.orange),
                      SizedBox(width: 4),
                      Text(
                        'Current location',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Bottom Sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Place the pin at exact delivery location',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.orange),
                        SizedBox(width: 8),
                        Expanded(
                          child: _isLoadingAddress
                              ? Row(
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Loading address...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  _address,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoadingAddress ? null : _confirmLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Confirm & proceed',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
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
}