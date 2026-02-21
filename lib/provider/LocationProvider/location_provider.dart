// import 'package:flutter/foundation.dart';
// import 'package:veegify/helper/storage_helper.dart';
// import 'package:veegify/services/Location/api_location.dart';
// import 'package:veegify/services/Location/location_sercice.dart';

// class LocationProvider extends ChangeNotifier {
//   String _address = 'Fetching location...';
//   List<double>? _coordinates;
//   bool _isLoading = true;
//   bool _hasError = false;
//   String _errorMessage = '';

//   // Getters
//   String get address => _address;
//   List<double>? get coordinates => _coordinates;
//   bool get isLoading => _isLoading;
//   bool get hasError => _hasError;
//   String get errorMessage => _errorMessage;
//   bool get hasLocation => _coordinates != null && _coordinates!.length >= 2;

//   // Initialize location (get current location)
//   Future<void> initLocation(String userId) async {
//     try {
//       print("kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk$userId");
//       _isLoading = true;
//       _hasError = false;
//       _errorMessage = '';
//       notifyListeners();
//       print("kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk11111111111$userId");

//       // Get coordinates first
//       final coords = await LocationService.getCurrentCoordinates();

//             print("kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk22222222222$userId");

//       if (coords == null) {
//         throw Exception('Failed to get coordinates');
//       }

//                   print("kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk222222222223333333$userId");

//       _coordinates = coords;

//       // Get address
//       final fullAddress = await LocationService.getCurrentAddress();
//       if (fullAddress == null) {
//         throw Exception('Failed to get address');
//       }

//       // Check if address contains error messages
//       if (fullAddress.contains('Location services are disabled') ||
//           fullAddress.contains('Location permission denied') ||
//           fullAddress.contains('permanently denied') ||
//           fullAddress.contains('Address not found')) {
//         throw Exception(fullAddress);
//       }

//       _address = _formatAddress(fullAddress);

//       print("ppppppppppppppppppppppppppppppppppppp$_address");

//       print("latitude: ${_coordinates![0].toString()}");
//       print("longitude: ${_coordinates![1].toString()}");

      
//       // Call addLocation API with user's coordinates
//       final isSuccess = await ApiLocationService().addLocation(
//         userId: userId, 
//         latitude: _coordinates![0].toString(), // latitude
//         longitude: _coordinates![1].toString()  // longitude
//       );
      
//       if (!isSuccess) {
//         if (kDebugMode) {
//           print('Warning: Failed to save location to server');
//         }
//         // Note: We don't throw an error here as the location was still fetched successfully
//         // The API call failure shouldn't prevent the user from using the app
//       }

//       _isLoading = false;
//       _hasError = false;
//       notifyListeners();
//     } catch (e) {
//       _isLoading = false;
//       _hasError = true;
//       _errorMessage = e.toString();
//       _address = 'Location not available';
//       _coordinates = null;
//       notifyListeners();
//     }
//   }

//   // Update location manually (from search)
//   Future<void> updateLocation(String newAddress, List<double> newCoordinates, String userId) async {
//     _address = _formatAddress(newAddress);
//     _coordinates = newCoordinates;
//     _isLoading = false;
//     _hasError = false;
//     _errorMessage = '';
//     print("llllllllllllllllllllllllllllllllllll$_address");
//           final isSuccess = await ApiLocationService().addLocation(
//         userId: userId, 
//         latitude: _coordinates![0].toString(), // latitude
//         longitude: _coordinates![1].toString()  // longitude
//       );
//           print("llllllllllllllllllllllllllllllllllll$isSuccess");

//     notifyListeners();
//   }

//   // Format address to show only first 2 parts
//   String _formatAddress(String fullAddress) {
//     if (fullAddress.isEmpty) return 'Unknown location';
    
//     final parts = fullAddress.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
//     if (parts.isEmpty) return 'Unknown location';
    
//     return parts.length > 1 ? '${parts[0]}, ${parts[1]}' : parts[0];  
//   }

//   // Refresh current location
//   // Future<void> refreshLocation() async {
//   //   final user = await UserPreferences.getUser();
//   //   await initLocation("686cfbbbcd2def2c5d950f09");
//   // }

//   // Reset location state
//   void resetLocation() {
//     _address = 'Fetching location...';
//     _coordinates = null;
//     _isLoading = true;
//     _hasError = false;
//     _errorMessage = '';
//     notifyListeners();
//   }
// }
























import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:veegify/helper/storage_helper.dart';
import 'package:veegify/services/Location/api_location.dart';
import 'package:veegify/services/Location/location_sercice.dart';

class LocationProvider extends ChangeNotifier {
  String _address = 'Fetching location...';
  List<double>? _coordinates;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  // Getters
  String get address => _address;
  List<double>? get coordinates => _coordinates;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  bool get hasLocation => _coordinates != null && _coordinates!.length >= 2;

  // Initialize location (get current location)
  // Future<void> initLocation(String userId) async {
  //   try {
  //     print("Initializing location for user: $userId");
  //     _isLoading = true;
  //     _hasError = false;
  //     _errorMessage = '';
  //     notifyListeners();

  //     // Get coordinates first
  //     final coords = await LocationService.getCurrentCoordinates();

  //     if (coords == null) {
  //       throw Exception('Failed to get coordinates');
  //     }

  //     _coordinates = coords;

  //     // Get address
  //     final fullAddress = await LocationService.getCurrentAddress();
  //     if (fullAddress == null) {
  //       throw Exception('Failed to get address');
  //     }

  //     // Check if address contains error messages
  //     if (fullAddress.contains('Location services are disabled') ||
  //         fullAddress.contains('Location permission denied') ||
  //         fullAddress.contains('permanently denied') ||
  //         fullAddress.contains('Address not found')) {
  //       throw Exception(fullAddress);
  //     }

  //     _address = _formatAddress(fullAddress);

  //     print("Address: $_address");
  //     print("latitude: ${_coordinates![0].toString()}");
  //     print("longitude: ${_coordinates![1].toString()}");

  //     // Call addLocation API with user's coordinates
  //     final isSuccess = await ApiLocationService().addLocation(
  //       userId: userId, 
  //       latitude: _coordinates![0].toString(), // latitude
  //       longitude: _coordinates![1].toString()  // longitude
  //     );
      
  //     if (!isSuccess) {
  //       if (kDebugMode) {
  //         print('Warning: Failed to save location to server');
  //       }
  //     }

  //     _isLoading = false;
  //     _hasError = false;
  //     notifyListeners();
  //   } catch (e) {
  //     _isLoading = false;
  //     _hasError = true;
  //     _errorMessage = e.toString();
  //     _address = 'Location not available';
  //     _coordinates = null;
  //     notifyListeners();
  //   }
  // }




  Future<void> initLocation(String userId) async {
  try {
    _isLoading = true;
    notifyListeners();

    // Run both operations in parallel
    final results = await Future.wait([
      LocationService.getCurrentCoordinates(),  // Get coordinates
      LocationService.getCurrentAddress(),      // Get address simultaneously
    ]);

    _coordinates = results[0] as List<double>?;
    final address = results[1] as String?;

    if (_coordinates != null && address != null) {
      _address = _formatAddress(address);
      
      // Fire-and-forget API call (don't wait for it)
      ApiLocationService().addLocation(
        userId: userId,
        latitude: _coordinates![0].toString(),
        longitude: _coordinates![1].toString()
      ).then((success) {
        print("Location saved: $success");
      });

      _isLoading = false;
      notifyListeners();
    }
  } catch (e) {
    // Handle error
  }
}

  // Determine position - checks permissions and gets location
  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    // When permissions are granted and services are enabled, get the position
    return await Geolocator.getCurrentPosition();
  }

  // Update location manually (from search)
  Future<void> updateLocation(String newAddress, List<double> newCoordinates, String userId) async {
    _address = _formatAddress(newAddress);
    _coordinates = newCoordinates;
    _isLoading = false;
    _hasError = false;
    _errorMessage = '';
    print("Updated address: $_address");
    
    final isSuccess = await ApiLocationService().addLocation(
      userId: userId, 
      latitude: _coordinates![0].toString(),
      longitude: _coordinates![1].toString()
    );
    print("Location update success: $isSuccess");

    notifyListeners();
  }

  // Format address to show only first 2 parts
  String _formatAddress(String fullAddress) {
    if (fullAddress.isEmpty) return 'Unknown location';
    
    final parts = fullAddress.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return 'Unknown location';
    
    return parts.length > 1 ? '${parts[0]}, ${parts[1]}' : parts[0];  
  }

  // Refresh current location
  Future<void> refreshLocation(String userId) async {
    await initLocation(userId);
  }

  // Reset location state
  void resetLocation() {
    _address = 'Fetching location...';
    _coordinates = null;
    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();
  }

  // Check if location permission is granted
  Future<bool> isLocationPermissionGranted() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always || 
           permission == LocationPermission.whileInUse;
  }

  // Check if location services are enabled
  Future<bool> areLocationServicesEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Open app settings
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  // Open location settings
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }
}