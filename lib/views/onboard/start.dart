import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veegify/helper/storage_helper.dart';
import 'package:veegify/provider/LocationProvider/location_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _checkLocationStatus();
  }

  Future<void> _loadUserId() async {
    final user = UserPreferences.getUser();
    if (user != null && mounted) {
      setState(() {
        userId = user.userId;
      });
    }
  }

  // Check location status immediately when screen opens
  Future<void> _checkLocationStatus() async {
    setState(() {
      _isCheckingLocation = true;
      _locationError = null;
    });

    try {
      await _loadUserId();

      final locationProvider = Provider.of<LocationProvider>(
        context,
        listen: false,
      );

      // Check if location permission is granted
      final permissionGranted = await locationProvider.isLocationPermissionGranted();
      final servicesEnabled = await locationProvider.areLocationServicesEnabled();

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
        });
      }
    } catch (e) {
      debugPrint('Error checking location: $e');
      setState(() {
        _locationGranted = false;
        _locationUpdated = false;
        _locationError = 'Failed to check location status';
      });
    } finally {
      setState(() {
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
      });
      return;
    }

    setState(() {
      _isLocationUpdating = true;
      _locationUpdated = false;
      _locationError = null;
    });

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
        });
        debugPrint('Location updated successfully: ${locationProvider.address}');
      } else {
        setState(() {
          _locationUpdated = false;
          _locationError = locationProvider.errorMessage.isNotEmpty 
              ? locationProvider.errorMessage 
              : 'Failed to get location';
        });
      }
    } catch (e) {
      debugPrint('Location update error: $e');
      setState(() {
        _locationUpdated = false;
        _locationError = 'Failed to get location: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLocationUpdating = false;
        });
      }
    }
  }

  // Retry fetching location
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
      final permissionGranted = await locationProvider.isLocationPermissionGranted();
      final servicesEnabled = await locationProvider.areLocationServicesEnabled();

      if (!permissionGranted || !servicesEnabled) {
        // If permission not granted, show permission dialog
        setState(() {
          _locationGranted = false;
          _isLoading = false;
        });
        // The permission modal will show automatically because _locationGranted is false
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

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// Background (different for web/mobile)
          if (isDesktop)
            // Web: Split screen layout
            Row(
              children: [
                // Left side - Image (50% width)
                Container(
                  width: screenSize.width * 0.5,
                  height: screenSize.height,
                  child: Image.asset(
                    "assets/images/start.png",
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[900],
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 100,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Right side - Content (50% width)
                Container(
                  width: screenSize.width * 0.5,
                  height: screenSize.height,
                  color: Colors.black,
                ),
              ],
            )
          else
            // Mobile: Full screen background image
            Positioned.fill(
              child: Image.asset(
                "assets/images/start.png",
                fit: BoxFit.cover,
              ),
            ),

          /// Dark Gradient Overlay (only on mobile)
          if (!isDesktop)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),

          /// Content
          isDesktop
              ? _buildWebContent(context)
              : _buildMobileContent(context),

          /// Loading overlay
          // if (_isLoading || _isLocationUpdating)
          //   Container(
          //     color: Colors.black.withOpacity(0.7),
          //     child: Center(
          //       child: Column(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           const CircularProgressIndicator(
          //             color: Colors.green,
          //           ),
          //           const SizedBox(height: 16),
          //           Text(
          //             _isLocationUpdating 
          //                 ? "Getting your location..." 
          //                 : "Please wait...",
          //             style: const TextStyle(
          //               color: Colors.white,
          //               fontSize: 16,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),

          /// Location permission dialog (shown immediately if needed)
          if (!_isCheckingLocation && !_locationGranted && _locationError == null)
            _buildLocationPermissionModal(),
        ],
      ),
    );
  }

  // Location Permission Modal - Non-dismissible
  Widget _buildLocationPermissionModal() {
    final theme = Theme.of(context);
    final isDesktop = Responsive.isDesktop(context);
    
    return PopScope(
      canPop: false,
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: Container(
            width: isDesktop ? 400 : double.infinity,
            margin: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : 24),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.location_on,
                              size: 48,
                              color: Colors.orange,
                            ),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      const Text(
                        "Location Permission is Off",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      Text(
                        "We need your location to find restaurants near you and provide accurate delivery information.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                          height: 1.5,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _requestLocationPermission,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "GRANT PERMISSION",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextButton(
                        onPressed: _isLoading ? null : _openAppSettings,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Request location permission
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
      final permissionGranted = await locationProvider.isLocationPermissionGranted();
      final servicesEnabled = await locationProvider.areLocationServicesEnabled();

      if (permissionGranted && servicesEnabled && mounted) {
        // Permission granted, now update location
        setState(() {
          _locationGranted = true;
          _isLoading = false;
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
        setState(() {
          _locationGranted = false;
          _isLoading = false;
          _locationError = 'Failed to get location permission: $e';
        });
      }
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

  // Mobile Content
  Widget _buildMobileContent(BuildContext context) {
    final bool hasError = _locationError != null && _locationError!.isNotEmpty;
    final bool isButtonEnabled = _locationGranted && 
                                 _locationUpdated && 
                                 !_isLoading && 
                                 !_isLocationUpdating &&
                                 !hasError;

    return Positioned(
      left: 24,
      right: 24,
      bottom: 40,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Fresh & Delicious\nPure Veg Food\nDelivered Fast!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Experience healthy, tasty vegetarian meals\n"
            "made with fresh ingredients and delivered\n"
            "straight to your doorstep.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          
          // Show location status if updating
          if (_isLocationUpdating) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
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
          ],

          // Show error message if any
          if (hasError) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _locationError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Show location address if available
          if (_locationUpdated && _locationAddress != null && !hasError) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.15),
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
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      _locationAddress!,
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: hasError 
                    ? Colors.orange 
                    : (isButtonEnabled 
                        ? const Color(0xFF4CAF50) 
                        : Colors.grey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: hasError 
                  ? _retryLocation 
                  : (isButtonEnabled ? _navigateToHome : null),
              child: Text(
                hasError 
                    ? "Retry Location" 
                    : (_isLocationUpdating 
                        ? "Getting Location..." 
                        : (_locationGranted && !_locationUpdated)
                            ? "Updating Location..."
                            : "Get Started"),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Web Content
  Widget _buildWebContent(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bool hasError = _locationError != null && _locationError!.isNotEmpty;
    final bool isButtonEnabled = _locationGranted && 
                                 _locationUpdated && 
                                 !_isLoading && 
                                 !_isLocationUpdating &&
                                 !hasError;

    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Container(),
        ),
        Expanded(
          flex: 5,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.05,
              vertical: 40,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "100% Vegetarian",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: "Fresh & Delicious\n",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      TextSpan(
                        text: "Pure Veg Food\n",
                        style: TextStyle(
                          color: Color(0xFF4CAF50),
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      TextSpan(
                        text: "Delivered Fast!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

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

                // Location status for web
                if (_isLocationUpdating) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
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
                ],

                // Show error message if any
                if (hasError) ...[
                  const SizedBox(height: 24),
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
                ],

                if (_locationUpdated && _locationAddress != null && !hasError) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
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
                ],

                const SizedBox(height: 40),

                SizedBox(
                  width: 200,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasError 
                          ? Colors.orange 
                          : (isButtonEnabled 
                              ? const Color(0xFF4CAF50) 
                              : Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    onPressed: hasError 
                        ? _retryLocation 
                        : (isButtonEnabled ? _navigateToHome : null),
                    child: Text(
                      hasError 
                          ? "Retry Location" 
                          : (_isLocationUpdating 
                              ? "Getting Location..." 
                              : (_locationGranted && !_locationUpdated)
                                  ? "Updating Location..."
                                  : "Get Started"),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Navigate to home screen
  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const NavbarScreen(initialIndex: 0),
      ),
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
          color: Colors.green,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}