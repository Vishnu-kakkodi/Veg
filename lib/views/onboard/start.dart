// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:veegify/helper/storage_helper.dart';
// import 'package:veegify/provider/AuthProvider/auth_provider.dart';
// import 'package:veegify/provider/LocationProvider/location_provider.dart';
// import 'package:veegify/views/Auth/login_page.dart';
// import 'package:veegify/views/Navbar/navbar_screen.dart';
// import 'package:veegify/utils/responsive.dart';

// class Start extends StatefulWidget {
//   const Start({super.key});

//   @override
//   State<Start> createState() => _StartState();
// }

// class _StartState extends State<Start> {
//   bool _isLoading = false;
//   bool _isCheckingLocation = true;
//   bool _locationGranted = false;
//   bool _isLocationUpdating = false;
//   bool _locationUpdated = false;
//   String? userId;
//   String? _locationAddress;
//   String? _locationError;
//   bool _isLoggedIn = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeScreen();
//   }

//   // Initialize screen - check login and location status
//   Future<void> _initializeScreen() async {
//     setState(() {
//       _isCheckingLocation = true;
//       _locationError = null;
//     });

//     try {
//       // Initialize UserPreferences first
//       await UserPreferences.init();

//       // Check login status
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       await authProvider.checkLoginStatus();

//       setState(() {
//         _isLoggedIn = UserPreferences.isLoggedIn();
//       });

//       // If not logged in, stop checking location
//       if (!_isLoggedIn) {
//         setState(() {
//           _isCheckingLocation = false;
//         });
//         return;
//       }

//       // Load user ID if logged in
//       await _loadUserId();

//       // Check location status
//       await _checkLocationStatus();
//     } catch (e) {
//       debugPrint('Error initializing screen: $e');
//       setState(() {
//         _locationError = 'Failed to initialize';
//         _isCheckingLocation = false;
//       });
//     }
//   }

//   Future<void> _loadUserId() async {
//     final user = UserPreferences.getUser();
//     if (user != null && mounted) {
//       setState(() {
//         userId = user.userId;
//       });
//     }
//   }

//   // Check location status if user is logged in
//   Future<void> _checkLocationStatus() async {
//     if (!_isLoggedIn) {
//       setState(() {
//         _isCheckingLocation = false;
//       });
//       return;
//     }

//     try {
//       final locationProvider = Provider.of<LocationProvider>(
//         context,
//         listen: false,
//       );

//       // Check if location permission is granted
//       final permissionGranted =
//           await locationProvider.isLocationPermissionGranted();
//       final servicesEnabled =
//           await locationProvider.areLocationServicesEnabled();

//       if (permissionGranted && servicesEnabled) {
//         // Location permission is granted, now update location
//         setState(() {
//           _locationGranted = true;
//           _isLocationUpdating = true;
//         });

//         // Update location and wait for it to complete
//         await _updateLocation();
//       } else {
//         setState(() {
//           _locationGranted = false;
//           _locationUpdated = false;
//           _isCheckingLocation = false;
//         });
//       }
//     } catch (e) {
//       debugPrint('Error checking location: $e');
//       setState(() {
//         _locationGranted = false;
//         _locationUpdated = false;
//         _locationError = 'Failed to check location status';
//         _isCheckingLocation = false;
//       });
//     }
//   }

//   // Update location and wait for completion
//   Future<void> _updateLocation() async {
//     if (userId == null) {
//       setState(() {
//         _locationError = 'User ID not found';
//         _isLocationUpdating = false;
//         _isCheckingLocation = false;
//       });
//       return;
//     }

//     try {
//       final locationProvider = Provider.of<LocationProvider>(
//         context,
//         listen: false,
//       );

//       // Initialize location and wait for it to complete
//       await locationProvider.initLocation(userId.toString());

//       // Check if location was successfully updated
//       if (locationProvider.hasLocation && mounted) {
//         setState(() {
//           _locationUpdated = true;
//           _locationAddress = locationProvider.address;
//           _locationError = null;
//           _isLocationUpdating = false;
//           _isCheckingLocation = false;
//         });
//         debugPrint(
//             'Location updated successfully: ${locationProvider.address}');
//       } else {
//         setState(() {
//           _locationUpdated = false;
//           _locationError = locationProvider.errorMessage.isNotEmpty
//               ? locationProvider.errorMessage
//               : 'Failed to get location';
//           _isLocationUpdating = false;
//           _isCheckingLocation = false;
//         });
//       }
//     } catch (e) {
//       debugPrint('Location update error: $e');
//       setState(() {
//         _locationUpdated = false;
//         _locationError = 'Failed to get location: $e';
//         _isLocationUpdating = false;
//         _isCheckingLocation = false;
//       });
//     }
//   }

//   // Request location permission (for logged in users)
//   Future<void> _requestLocationPermission() async {
//     setState(() {
//       _isLoading = true;
//       _locationError = null;
//     });

//     try {
//       final locationProvider = Provider.of<LocationProvider>(
//         context,
//         listen: false,
//       );

//       // Try to get location - this will trigger permission request
//       await locationProvider.determinePosition();

//       // Check if permission was granted
//       final permissionGranted =
//           await locationProvider.isLocationPermissionGranted();
//       final servicesEnabled =
//           await locationProvider.areLocationServicesEnabled();

//       if (permissionGranted && servicesEnabled && mounted) {
//         // Permission granted, now update location
//         setState(() {
//           _locationGranted = true;
//           _isLoading = false;
//           _isLocationUpdating = true;
//         });

//         // Update location and wait for it to complete
//         await _updateLocation();
//       } else if (mounted) {
//         setState(() {
//           _locationGranted = false;
//           _isLoading = false;
//           _locationError = 'Location permission not granted';
//         });
//       }
//     } catch (e) {
//       debugPrint('Location permission error: $e');
//       if (mounted) {
//         setState(() {
//           _locationGranted = false;
//           _isLoading = false;
//           _locationError = 'Failed to get location permission: $e';
//         });
//       }
//     }
//   }

//   // Retry fetching location (for logged in users)
//   Future<void> _retryLocation() async {
//     setState(() {
//       _isLoading = true;
//       _locationError = null;
//     });

//     try {
//       final locationProvider = Provider.of<LocationProvider>(
//         context,
//         listen: false,
//       );

//       // Check if permission is granted
//       final permissionGranted =
//           await locationProvider.isLocationPermissionGranted();
//       final servicesEnabled =
//           await locationProvider.areLocationServicesEnabled();

//       if (!permissionGranted || !servicesEnabled) {
//         setState(() {
//           _locationGranted = false;
//           _isLoading = false;
//         });
//         return;
//       }

//       // Permission is granted, try to update location
//       setState(() {
//         _locationGranted = true;
//         _isLocationUpdating = true;
//         _isLoading = false;
//       });

//       await _updateLocation();
//     } catch (e) {
//       debugPrint('Retry error: $e');
//       setState(() {
//         _locationError = 'Failed to get location: $e';
//         _isLoading = false;
//       });
//     }
//   }

//   // Navigate to login screen
//   void _navigateToLogin() {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (_) => const LoginPage(),
//       ),
//     );
//   }

//   // Navigate to home screen (only if logged in and location updated)
//   void _navigateToHome() {
//     if (_isLoggedIn && _locationUpdated) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) => const NavbarScreen(initialIndex: 0),
//         ),
//       );
//     }
//   }

//   // Open app settings
//   Future<void> _openAppSettings() async {
//     try {
//       final locationProvider = Provider.of<LocationProvider>(
//         context,
//         listen: false,
//       );
//       await locationProvider.openAppSettings();
//     } catch (e) {
//       debugPrint('Error opening settings: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDesktop = Responsive.isDesktop(context);
//     final screenSize = MediaQuery.of(context).size;

//     return SafeArea(
//       top: false,
//       bottom: true,
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: Stack(
//           children: [
//             /// Background (different for web/mobile)
//             if (isDesktop)
//               // Web: Split screen layout
//               Row(
//                 children: [
//                   // Left side - Logo/Image (50% width)
//                   Container(
//                     width: screenSize.width * 0.5,
//                     height: screenSize.height,
//                     color: const Color(0xFF4CAF50), // Green background
//                     child: Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           // App Logo
//                           Container(
//                             width: 200,
//                             height: 200,
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(20),
//                               child: Image.asset(
//                                 "assets/images/img.png",
//                                 fit: BoxFit.contain,
//                                 errorBuilder: (context, error, stackTrace) {
//                                   return const Icon(
//                                     Icons.restaurant,
//                                     size: 100,
//                                     color: Color(0xFF4CAF50),
//                                   );
//                                 },
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 24),
//                           const Text(
//                             "Vegiffy",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 36,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           const Text(
//                             "Pure Veg Food Delivery",
//                             style: TextStyle(
//                               color: Colors.white70,
//                               fontSize: 18,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   // Right side - Content (50% width)
//                   Container(
//                     width: screenSize.width * 0.5,
//                     height: screenSize.height,
//                     color: Colors.white,
//                   ),
//                 ],
//               )
//             else
//               // Mobile: Full screen with logo at top
//               const SizedBox(height: 16),

//             Container(
//               // color: Colors.white,
//               child: Column(
//                 children: [
//                   // Logo at top
//                   Container(
//                     height: screenSize.height * 0.4,
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF4CAF50),
//                       borderRadius: const BorderRadius.vertical(
//                         bottom: Radius.circular(30),
//                       ),
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Container(
//                           width: 180,
//                           height: 180,
//                           decoration: BoxDecoration(
//                             // color: Colors.white,
//                             borderRadius: BorderRadius.circular(15),
//                           ),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(15),
//                             child: Image.asset(
//                               "assets/images/img.png",
//                               fit: BoxFit.contain,
//                               errorBuilder: (context, error, stackTrace) {
//                                 return const Icon(
//                                   Icons.restaurant,
//                                   size: 60,
//                                   color: Color(0xFF4CAF50),
//                                 );
//                               },
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 6),
//                         const Text(
//                           "Vegiffy",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 28,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 15),
//                         Text(
//                           "Pure Veg Hai, Boss!",
//                           style: GoogleFonts.tangerine(
//                               fontSize: 34,
//                               color: Colors.white,
//                               fontWeight: FontWeight.w900),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             /// Content Overlay
//             isDesktop
//                 ? _buildWebContent(context)
//                 : _buildMobileContent(context),

//             /// Loading overlay
//             if (_isLoading)
//               Container(
//                 color: Colors.black.withOpacity(0.5),
//                 child: const Center(
//                   child: CircularProgressIndicator(
//                     color: Color(0xFF4CAF50),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Mobile Content
//   Widget _buildMobileContent(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final bool hasError = _locationError != null && _locationError!.isNotEmpty;

//     // Determine button state and text
//     String buttonText;
//     VoidCallback? onPressed;

//     if (!_isLoggedIn) {
//       buttonText = "Login / Sign Up";
//       onPressed = _navigateToLogin;
//     } else if (_isCheckingLocation) {
//       buttonText = "Checking location...";
//       onPressed = null;
//     } else if (hasError) {
//       buttonText = "Retry Location";
//       onPressed = _retryLocation;
//     } else if (_isLocationUpdating) {
//       buttonText = "Getting your location...";
//       onPressed = null;
//     } else if (!_locationGranted) {
//       buttonText = "Grant Location Permission";
//       onPressed = _requestLocationPermission;
//     } else if (!_locationUpdated) {
//       buttonText = "Updating location...";
//       onPressed = null;
//     } else {
//       buttonText = "Get Started";
//       onPressed = _navigateToHome;
//     }

//     return Positioned(
//       left: 24,
//       right: 24,
//       bottom: 130,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const SizedBox(height: 46),

//           // Show location status for logged in users
//           if (_isLoggedIn) ...[
//             if (_isLocationUpdating) ...[
//               const SizedBox(height: 16),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 8,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.orange.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: const [
//                     SizedBox(
//                       width: 16,
//                       height: 16,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: Colors.orange,
//                       ),
//                     ),
//                     SizedBox(width: 8),
//                     Text(
//                       "Getting your location...",
//                       style: TextStyle(
//                         color: Colors.orange,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],

//             // Show error message if any
//             if (hasError) ...[
//               const SizedBox(height: 16),
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.red.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: Colors.red.withOpacity(0.3),
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     const Icon(
//                       Icons.error_outline,
//                       color: Colors.red,
//                       size: 24,
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       _locationError!,
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(
//                         color: Colors.red,
//                         fontSize: 13,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],

//             // Show location address if available
//             if (_locationUpdated && _locationAddress != null && !hasError) ...[
//               const SizedBox(height: 12),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 6,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.green.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(
//                     color: Colors.green.withOpacity(0.3),
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(
//                       Icons.location_on,
//                       color: Colors.green,
//                       size: 14,
//                     ),
//                     const SizedBox(width: 4),
//                     Flexible(
//                       child: Text(
//                         _locationAddress!,
//                         style: const TextStyle(
//                           color: Colors.green,
//                           fontSize: 12,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ],

//           const SizedBox(height: 28),

//           SizedBox(
//             width: double.infinity,
//             height: 55,
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF4CAF50),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//               ),
//               onPressed: onPressed,
//               child: Text(
//                 buttonText,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ),

//           // "Open Settings" link for permission errors
//           if (_isLoggedIn && !_locationGranted && hasError)
//             TextButton(
//               onPressed: _openAppSettings,
//               child: const Text(
//                 "Open Settings",
//                 style: TextStyle(
//                   color: Colors.grey,
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   // Web Content
//   Widget _buildWebContent(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final bool hasError = _locationError != null && _locationError!.isNotEmpty;

//     // Determine button state and text
//     String buttonText;
//     VoidCallback? onPressed;

//     if (!_isLoggedIn) {
//       buttonText = "Login / Sign Up";
//       onPressed = _navigateToLogin;
//     } else if (_isCheckingLocation) {
//       buttonText = "Checking location...";
//       onPressed = null;
//     } else if (hasError) {
//       buttonText = "Retry Location";
//       onPressed = _retryLocation;
//     } else if (_isLocationUpdating) {
//       buttonText = "Getting your location...";
//       onPressed = null;
//     } else if (!_locationGranted) {
//       buttonText = "Grant Location Permission";
//       onPressed = _requestLocationPermission;
//     } else if (!_locationUpdated) {
//       buttonText = "Updating location...";
//       onPressed = null;
//     } else {
//       buttonText = "Get Started";
//       onPressed = _navigateToHome;
//     }

//     return Row(
//       children: [
//         Expanded(
//           flex: 5,
//           child: Container(),
//         ),
//         Expanded(
//           flex: 5,
//           child: Container(
//             padding: EdgeInsets.symmetric(
//               horizontal: screenSize.width * 0.05,
//               vertical: 40,
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Welcome text
//                 // Text(
//                 //   !_isLoggedIn
//                 //       ? "Welcome to Vegiffy!"
//                 //       : "Fresh & Delicious\nPure Veg Food\nDelivered Fast!",
//                 //   style: const TextStyle(
//                 //     color: Color(0xFF4CAF50),
//                 //     fontSize: 48,
//                 //     fontWeight: FontWeight.bold,
//                 //     height: 1.2,
//                 //   ),
//                 // ),
//                 const SizedBox(height: 16),

//                 // Description
//                 // Text(
//                 //   !_isLoggedIn
//                 //       ? "Order Kari Without Fear, Vegiffy Pure Veg Hai Boss,Yeh Hai Crystal Clear!"
//                 //       : "Order Kari Without Fear, Vegiffy Pure Veg Hai Boss,Yeh Hai Crystal Clear!",
//                 //   style: TextStyle(
//                 //     color: Colors.grey[600],
//                 //     fontSize: 16,
//                 //     height: 1.5,
//                 //   ),
//                 // ),
//                 // const SizedBox(height: 32),

//                 // Feature items
//                 Row(
//                   children: [
//                     _buildFeatureItem(
//                       icon: Icons.eco,
//                       label: "Pure Veg",
//                     ),
//                     const SizedBox(width: 24),
//                     _buildFeatureItem(
//                       icon: Icons.timer,
//                       label: "Fast Delivery",
//                     ),
//                     const SizedBox(width: 24),
//                     _buildFeatureItem(
//                       icon: Icons.favorite,
//                       label: "Fresh Food",
//                     ),
//                   ],
//                 ),

//                 // Location status for logged in users
//                 if (_isLoggedIn) ...[
//                   if (_isLocationUpdating) ...[
//                     const SizedBox(height: 24),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 8,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.orange.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: const [
//                           SizedBox(
//                             width: 16,
//                             height: 16,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               color: Colors.orange,
//                             ),
//                           ),
//                           SizedBox(width: 8),
//                           Text(
//                             "Getting your location...",
//                             style: TextStyle(
//                               color: Colors.orange,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],

//                   // Show error message if any
//                   if (hasError) ...[
//                     const SizedBox(height: 24),
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.red.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(
//                           color: Colors.red.withOpacity(0.3),
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           const Icon(
//                             Icons.error_outline,
//                             color: Colors.red,
//                             size: 20,
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Text(
//                               _locationError!,
//                               style: const TextStyle(
//                                 color: Colors.red,
//                                 fontSize: 13,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],

//                   if (_locationUpdated &&
//                       _locationAddress != null &&
//                       !hasError) ...[
//                     const SizedBox(height: 16),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 8,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.green.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(
//                           color: Colors.green.withOpacity(0.3),
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           const Icon(
//                             Icons.location_on,
//                             color: Colors.green,
//                             size: 16,
//                           ),
//                           const SizedBox(width: 4),
//                           Flexible(
//                             child: Text(
//                               _locationAddress!,
//                               style: const TextStyle(
//                                 color: Colors.green,
//                                 fontSize: 13,
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ],

//                 const SizedBox(height: 40),

//                 SizedBox(
//                   width: 200,
//                   height: 55,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF4CAF50),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(30),
//                       ),
//                       elevation: 0,
//                     ),
//                     onPressed: onPressed,
//                     child: Text(
//                       buttonText,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),

//                 // "Open Settings" link for permission errors
//                 if (_isLoggedIn && !_locationGranted && hasError)
//                   TextButton(
//                     onPressed: _openAppSettings,
//                     child: const Text(
//                       "Open Settings",
//                       style: TextStyle(
//                         color: Colors.grey,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildFeatureItem({
//     required IconData icon,
//     required String label,
//   }) {
//     return Row(
//       children: [
//         Icon(
//           icon,
//           color: const Color(0xFF4CAF50),
//           size: 20,
//         ),
//         const SizedBox(width: 8),
//         Text(
//           label,
//           style: const TextStyle(
//             color: Colors.black87,
//             fontSize: 15,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:veegify/helper/storage_helper.dart';
import 'package:veegify/provider/AuthProvider/auth_provider.dart';
import 'package:veegify/provider/LocationProvider/location_provider.dart';
import 'package:veegify/views/Auth/login_page.dart';
import 'package:veegify/views/Navbar/navbar_screen.dart';
import 'package:veegify/utils/responsive.dart';

class Start extends StatefulWidget {
  const Start({super.key});

  @override
  State<Start> createState() => _StartState();
}

class _StartState extends State<Start> {
  bool _isLoading = false;
  bool _isCheckingLocation = true;
  bool _locationGranted = false;
  bool _isLocationUpdating = false;
  bool _locationUpdated = false;
  String? userId;
  String? _locationAddress;
  String? _locationError;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  // Initialize screen - check login and location status
  Future<void> _initializeScreen() async {
    setState(() {
      _isCheckingLocation = true;
      _locationError = null;
    });

    try {
      // Initialize UserPreferences first
      await UserPreferences.init();

      // Check login status
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.checkLoginStatus();

      setState(() {
        _isLoggedIn = UserPreferences.isLoggedIn();
      });

      // If not logged in, stop checking location
      if (!_isLoggedIn) {
        setState(() {
          _isCheckingLocation = false;
        });
        return;
      }

      // Load user ID if logged in
      await _loadUserId();

      // Check location status
      await _checkLocationStatus();
    } catch (e) {
      debugPrint('Error initializing screen: $e');
      setState(() {
        _locationError = 'Failed to initialize';
        _isCheckingLocation = false;
      });
    }
  }

  Future<void> _loadUserId() async {
    final user = UserPreferences.getUser();
    if (user != null && mounted) {
      setState(() {
        userId = user.userId;
      });
    }
  }

  // Check location status if user is logged in
  Future<void> _checkLocationStatus() async {
    if (!_isLoggedIn) {
      setState(() {
        _isCheckingLocation = false;
      });
      return;
    }

    try {
      final locationProvider = Provider.of<LocationProvider>(
        context,
        listen: false,
      );

      // Check if location permission is granted
      final permissionGranted =
          await locationProvider.isLocationPermissionGranted();
      final servicesEnabled =
          await locationProvider.areLocationServicesEnabled();

      if (permissionGranted && servicesEnabled) {
        // Location permission is granted, now update location
        setState(() {
          _locationGranted = true;
          _isLocationUpdating = true;
        });

        // Update location and wait for it to complete
        await _updateLocation();
      } else {
        setState(() {
          _locationGranted = false;
          _locationUpdated = false;
          _isCheckingLocation = false;
        });
      }
    } catch (e) {
      debugPrint('Error checking location: $e');
      setState(() {
        _locationGranted = false;
        _locationUpdated = false;
        _locationError = 'Failed to check location status';
        _isCheckingLocation = false;
      });
    }
  }

  // Update location and wait for completion
  Future<void> _updateLocation() async {
    if (userId == null) {
      setState(() {
        _locationError = 'User ID not found';
        _isLocationUpdating = false;
        _isCheckingLocation = false;
      });
      return;
    }

    try {
      final locationProvider = Provider.of<LocationProvider>(
        context,
        listen: false,
      );

      // Initialize location and wait for it to complete
      await locationProvider.initLocation(userId.toString());

      // Check if location was successfully updated
      if (locationProvider.hasLocation && mounted) {
        setState(() {
          _locationUpdated = true;
          _locationAddress = locationProvider.address;
          _locationError = null;
          _isLocationUpdating = false;
          _isCheckingLocation = false;
        });
        debugPrint(
            'Location updated successfully: ${locationProvider.address}');
      } else {
        setState(() {
          _locationUpdated = false;
          _locationError = locationProvider.errorMessage.isNotEmpty
              ? locationProvider.errorMessage
              : 'Failed to get location';
          _isLocationUpdating = false;
          _isCheckingLocation = false;
        });
      }
    } catch (e) {
      debugPrint('Location update error: $e');
      setState(() {
        _locationUpdated = false;
        _locationError = 'Failed to get location: $e';
        _isLocationUpdating = false;
        _isCheckingLocation = false;
      });
    }
  }

  // Request location permission (for logged in users)
  Future<void> _requestLocationPermission() async {
    setState(() {
      _isLoading = true;
      _locationError = null;
    });

    try {
      final locationProvider = Provider.of<LocationProvider>(
        context,
        listen: false,
      );

      // Try to get location - this will trigger permission request
      await locationProvider.determinePosition();

      // Check if permission was granted
      final permissionGranted =
          await locationProvider.isLocationPermissionGranted();
      final servicesEnabled =
          await locationProvider.areLocationServicesEnabled();

      if (permissionGranted && servicesEnabled && mounted) {
        // Permission granted, now update location
        setState(() {
          _locationGranted = true;
          _isLoading = false;
          _isLocationUpdating = true;
        });

        // Update location and wait for it to complete
        await _updateLocation();
      } else if (mounted) {
        setState(() {
          _locationGranted = false;
          _isLoading = false;
          _locationError = 'Location permission not granted';
        });
      }
    } catch (e) {
      debugPrint('Location permission error: $e');
      if (mounted) {
        String errorMessage = 'Failed to get location permission';

        // Check if error message contains location services related text
        final errorString = e.toString().toLowerCase();
        if (errorString.contains('location services') ||
            errorString.contains('disabled') ||
            errorString.contains('enable')) {
          errorMessage =
              'Location services are disabled. Please enable location services in your device settings.';
        } else if (errorString.contains('permission')) {
          errorMessage =
              'Location permission not granted. Please allow location access in app settings.';
        } else {
          errorMessage = 'Failed to get location permission: $e';
        }

        setState(() {
          _locationGranted = false;
          _isLoading = false;
          _locationError = errorMessage;
        });
      }
    }
  }

  // Retry fetching location (for logged in users)
  Future<void> _retryLocation() async {
    setState(() {
      _isLoading = true;
      _locationError = null;
    });

    try {
      final locationProvider = Provider.of<LocationProvider>(
        context,
        listen: false,
      );

      // Check if permission is granted
      final permissionGranted =
          await locationProvider.isLocationPermissionGranted();
      final servicesEnabled =
          await locationProvider.areLocationServicesEnabled();

      if (!permissionGranted || !servicesEnabled) {
        setState(() {
          _locationGranted = false;
          _isLoading = false;
        });
        return;
      }

      // Permission is granted, try to update location
      setState(() {
        _locationGranted = true;
        _isLocationUpdating = true;
        _isLoading = false;
      });

      await _updateLocation();
    } catch (e) {
      debugPrint('Retry error: $e');
      setState(() {
        _locationError = 'Failed to get location: $e';
        _isLoading = false;
      });
    }
  }

  // Navigate to login screen
  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
    );
  }

  // Navigate to home screen (only if logged in and location updated)
  void _navigateToHome() {
    if (_isLoggedIn && _locationUpdated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const NavbarScreen(initialIndex: 0),
        ),
      );
    }
  }

  // Open app settings
  Future<void> _openAppSettings() async {
    try {
      final locationProvider = Provider.of<LocationProvider>(
        context,
        listen: false,
      );
      await locationProvider.openAppSettings();
    } catch (e) {
      debugPrint('Error opening settings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      backgroundColor: const Color(0xFF4CAF50), // Full green background
      body: Stack(
        children: [
          // Content based on device type
          isDesktop ? _buildWebContent(context) : _buildMobileContent(context),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Mobile Content - Centered with full green background
  Widget _buildMobileContent(BuildContext context) {
    final bool hasError = _locationError != null && _locationError!.isNotEmpty;

    // Determine button state and text
    String buttonText;
    VoidCallback? onPressed;

    if (!_isLoggedIn) {
      buttonText = "Login / Sign Up";
      onPressed = _navigateToLogin;
    } else if (_isCheckingLocation) {
      buttonText = "Checking location...";
      onPressed = null;
    } else if (hasError) {
      buttonText = "Retry Location";
      onPressed = _retryLocation;
    } else if (_isLocationUpdating) {
      buttonText = "Getting your location...";
      onPressed = null;
    } else if (!_locationGranted) {
      buttonText = "Grant Location Permission";
      onPressed = _requestLocationPermission;
    } else if (!_locationUpdated) {
      buttonText = "Updating location...";
      onPressed = null;
    } else {
      buttonText = "Get Started";
      onPressed = _navigateToHome;
    }

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 150,
                height: 150,
                // decoration: BoxDecoration(
                //   color: Colors.white,
                //   borderRadius: BorderRadius.circular(20),
                // ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    "assets/images/img.png",
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.restaurant,
                        size: 80,
                        color: Color(0xFF4CAF50),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title Text
              const Text(
                "Vegiffy",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle Text
              Text(
                "Pure Veg Hai, Boss!",
                style: GoogleFonts.tangerine(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 48),

              // Location status (if logged in)
              if (_isLoggedIn) ...[
                if (_isLocationUpdating) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Getting your location...",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Show error message if any
                if (hasError) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.5),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _locationError!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Show location address if available
                if (_locationUpdated &&
                    _locationAddress != null &&
                    !hasError) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _locationAddress!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ],

              // Main Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  onPressed: onPressed,
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // "Open Settings" link for permission errors
              if (_isLoggedIn && !_locationGranted && hasError)
                TextButton(
                  onPressed: _openAppSettings,
                  child: const Text(
                    "Open Settings",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // Web Content - Split screen layout
  Widget _buildWebContent(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bool hasError = _locationError != null && _locationError!.isNotEmpty;

    // Determine button state and text
    String buttonText;
    VoidCallback? onPressed;

    if (!_isLoggedIn) {
      buttonText = "Login / Sign Up";
      onPressed = _navigateToLogin;
    } else if (_isCheckingLocation) {
      buttonText = "Checking location...";
      onPressed = null;
    } else if (hasError) {
      buttonText = "Retry Location";
      onPressed = _retryLocation;
    } else if (_isLocationUpdating) {
      buttonText = "Getting your location...";
      onPressed = null;
    } else if (!_locationGranted) {
      buttonText = "Grant Location Permission";
      onPressed = _requestLocationPermission;
    } else if (!_locationUpdated) {
      buttonText = "Updating location...";
      onPressed = null;
    } else {
      buttonText = "Get Started";
      onPressed = _navigateToHome;
    }

    return Row(
      children: [
        // Left side - Logo and Branding (50% width)
        Container(
          width: screenSize.width * 0.5,
          height: screenSize.height,
          color: const Color(0xFF4CAF50),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      "assets/images/img.png",
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.restaurant,
                          size: 100,
                          color: Color(0xFF4CAF50),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Vegiffy",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Pure Veg Hai, Boss!",
                  style: GoogleFonts.tangerine(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Right side - Content (50% width)
        Container(
          width: screenSize.width * 0.5,
          height: screenSize.height,
          color: Colors.white,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome message
                  const Text(
                    "Welcome to Vegiffy!",
                    style: TextStyle(
                      color: Color(0xFF4CAF50),
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Order Kari Without Fear, Vegiffy Pure Veg Hai Boss, Yeh Hai Crystal Clear!",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Feature items
                  Row(
                    children: [
                      _buildFeatureItem(
                        icon: Icons.eco,
                        label: "Pure Veg",
                      ),
                      const SizedBox(width: 24),
                      _buildFeatureItem(
                        icon: Icons.timer,
                        label: "Fast Delivery",
                      ),
                      const SizedBox(width: 24),
                      _buildFeatureItem(
                        icon: Icons.favorite,
                        label: "Fresh Food",
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Location status for logged in users
                  if (_isLoggedIn) ...[
                    if (_isLocationUpdating) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.orange,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Getting your location...",
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Show error message if any
                    if (hasError) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _locationError!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (_locationUpdated &&
                        _locationAddress != null &&
                        !hasError) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.green,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                _locationAddress!,
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],

                  // Main Button
                  SizedBox(
                    width: 200,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      onPressed: onPressed,
                      child: Text(
                        buttonText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // "Open Settings" link for permission errors
                  if (_isLoggedIn && !_locationGranted && hasError)
                    TextButton(
                      onPressed: _openAppSettings,
                      child: const Text(
                        "Open Settings",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String label,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF4CAF50),
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
