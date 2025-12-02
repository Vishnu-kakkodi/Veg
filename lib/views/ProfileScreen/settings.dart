// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';

// class LocationSettingsScreen extends StatefulWidget {
//   const LocationSettingsScreen({super.key});

//   @override
//   State<LocationSettingsScreen> createState() => _LocationSettingsScreenState();
// }

// class _LocationSettingsScreenState extends State<LocationSettingsScreen> {
//   bool _isLoading = false;
//   PermissionStatus? _status;

//   @override
//   void initState() {
//     super.initState();
//     _loadStatus();
//   }

//   Future<void> _loadStatus() async {
//     final status = await Permission.location.status;
//     if (!mounted) return;
//     setState(() {
//       _status = status;
//     });
//   }

//   String _statusLabel(PermissionStatus? status) {
//     if (status == null) return "Checking...";
//     switch (status) {
//       case PermissionStatus.granted:
//         return "Allowed";
//       case PermissionStatus.denied:
//         return "Denied";
//       case PermissionStatus.restricted:
//         return "Restricted";
//       case PermissionStatus.limited:
//         return "Limited";
//       case PermissionStatus.permanentlyDenied:
//         return "Permanently denied";
//       default:
//         return status.toString();
//     }
//   }

//   Color _statusColor(PermissionStatus? status) {
//     if (status == null) return Colors.grey;
//     switch (status) {
//       case PermissionStatus.granted:
//         return Colors.green;
//       case PermissionStatus.denied:
//       case PermissionStatus.permanentlyDenied:
//         return Colors.red;
//       default:
//         return Colors.orange;
//     }
//   }

//   Future<void> _handleAllow() async {
//     setState(() => _isLoading = true);

//     final status = await Permission.location.request();

//     if (!mounted) return;
//     setState(() {
//       _status = status;
//       _isLoading = false;
//     });

//     // Optional: show a small snackbar
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           status.isGranted
//               ? 'Location permission granted'
//               : 'Location permission not granted',
//         ),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   Future<void> _handleDontAllow() async {
//     // We can't revoke permission directly. Open app settings instead.
//     final opened = await openAppSettings();

//     if (!mounted) return;

//     if (!opened) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Could not open app settings'),
//           duration: Duration(seconds: 2),
//         ),
//       );
//     } else {
//       // When user returns from settings, refresh status
//       await _loadStatus();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final statusText = _statusLabel(_status);
//     final statusColor = _statusColor(_status);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Settings'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "Location Access",
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               "Control whether the app can access your location.",
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[600],
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Card showing current status
//             Card(
//               elevation: 2,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.location_on,
//                       color: statusColor,
//                       size: 32,
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "Location permission",
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             statusText,
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: statusColor,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 24),

//             if (_isLoading)
//               const Center(child: CircularProgressIndicator())
//             else
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   // Allow button
//                   ElevatedButton.icon(
//                     onPressed: _handleAllow,
//                     icon: const Icon(Icons.check),
//                     label: const Text("Allow location"),
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                     ),
//                   ),
//                   const SizedBox(height: 12),

//                   // Don't allow button
//                   OutlinedButton.icon(
//                     onPressed: _handleDontAllow,
//                     icon: const Icon(Icons.close),
//                     label: const Text("Don’t allow"),
//                     style: OutlinedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                     ),
//                   ),

//                   const SizedBox(height: 12),
//                   Text(
//                     "Note: On Android/iOS, apps cannot directly remove permissions. "
//                     "“Don’t allow” will open the system settings so you can turn off location access.",
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }





















// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';

// class LocationSettingsScreen extends StatefulWidget {
//   const LocationSettingsScreen({super.key});

//   @override
//   State<LocationSettingsScreen> createState() => _LocationSettingsScreenState();
// }

// class _LocationSettingsScreenState extends State<LocationSettingsScreen> {
//   bool _isLoading = false;
//   PermissionStatus? _status;

//   @override
//   void initState() {
//     super.initState();
//     _loadStatus();
//   }

//   Future<void> _loadStatus() async {
//     final status = await Permission.location.status;
//     if (!mounted) return;
//     setState(() {
//       _status = status;
//     });
//   }

//   String _statusLabel(PermissionStatus? status) {
//     if (status == null) return "Checking...";
//     switch (status) {
//       case PermissionStatus.granted:
//         return "Allowed";
//       case PermissionStatus.denied:
//         return "Denied";
//       case PermissionStatus.restricted:
//         return "Restricted";
//       case PermissionStatus.limited:
//         return "Limited";
//       case PermissionStatus.permanentlyDenied:
//         return "Permanently denied";
//       default:
//         return status.toString();
//     }
//   }

//   Color _statusColor(PermissionStatus? status) {
//     if (status == null) return Colors.grey;
//     switch (status) {
//       case PermissionStatus.granted:
//         return Colors.green;
//       case PermissionStatus.denied:
//       case PermissionStatus.permanentlyDenied:
//         return Colors.red;
//       default:
//         return Colors.orange;
//     }
//   }

//   Future<void> _handleAllow() async {
//     setState(() => _isLoading = true);

//     final status = await Permission.location.request();

//     if (!mounted) return;
//     setState(() {
//       _status = status;
//       _isLoading = false;
//     });

//     // Optional: show a small snackbar
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           status.isGranted
//               ? 'Location permission granted'
//               : 'Location permission not granted',
//         ),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//     );
//   }

//   Future<void> _handleDontAllow() async {
//     // We can't revoke permission directly. Open app settings instead.
//     final opened = await openAppSettings();

//     if (!mounted) return;

//     if (!opened) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('Could not open app settings'),
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//       );
//     } else {
//       // When user returns from settings, refresh status
//       await _loadStatus();
//     }
//   }

//   void _toggleSystemTheme() {
//     // This will open system settings where user can change theme mode
//     openAppSettings().then((opened) {
//       if (!mounted) return;
      
//       if (!opened) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: const Text('Could not open system settings'),
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: const Text('Open system display settings to change theme mode'),
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//         );
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
    
//     final statusText = _statusLabel(_status);
//     final statusColor = _statusColor(_status);

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       appBar: AppBar(
//         title: const Text('Settings'),
//         backgroundColor: theme.appBarTheme.backgroundColor,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // System Theme Section
//             const Text(
//               "Appearance",
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               "Change system dark/light mode",
//               style: TextStyle(
//                 fontSize: 14,
//                 color: theme.colorScheme.onSurface.withOpacity(0.6),
//               ),
//             ),
//             const SizedBox(height: 16),

//             // System Theme Card
//             Card(
//               elevation: 2,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               color: theme.cardColor,
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                 child: Row(
//                   children: [
//                     Icon(
//                       isDark ? Icons.dark_mode : Icons.light_mode,
//                       color: theme.colorScheme.primary,
//                       size: 32,
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "System Theme",
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             isDark ? "Dark Mode" : "Light Mode",
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: theme.colorScheme.onSurface.withOpacity(0.7),
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     IconButton(
//                       onPressed: _toggleSystemTheme,
//                       icon: Icon(
//                         Icons.settings,
//                         color: theme.colorScheme.primary,
//                       ),
//                       tooltip: "Open system theme settings",
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 32),

//             // Location Access Section
//             const Text(
//               "Location Access",
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               "Control whether the app can access your location.",
//               style: TextStyle(
//                 fontSize: 14,
//                 color: theme.colorScheme.onSurface.withOpacity(0.6),
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Location Card
//             Card(
//               elevation: 2,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               color: theme.cardColor,
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.location_on,
//                       color: statusColor,
//                       size: 32,
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "Location permission",
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             statusText,
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: statusColor,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 24),

//             if (_isLoading)
//               Center(
//                 child: CircularProgressIndicator(
//                   color: theme.colorScheme.primary,
//                 ),
//               )
//             else
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   // Allow button
//                   ElevatedButton.icon(
//                     onPressed: _handleAllow,
//                     icon: const Icon(Icons.check),
//                     label: const Text("Allow location"),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: theme.colorScheme.primary,
//                       foregroundColor: theme.colorScheme.onPrimary,
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                     ),
//                   ),
//                   const SizedBox(height: 12),

//                   // Don't allow button
//                   OutlinedButton.icon(
//                     onPressed: _handleDontAllow,
//                     icon: const Icon(Icons.close),
//                     label: const Text("Don't allow"),
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor: theme.colorScheme.onSurface,
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                       side: BorderSide(
//                         color: theme.colorScheme.onSurface.withOpacity(0.5),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 12),
//                   Text(
//                     "Note: On Android/iOS, apps cannot directly remove permissions. "
//                     "\"Don't allow\" will open the system settings so you can turn off location access.",
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: theme.colorScheme.onSurface.withOpacity(0.6),
//                     ),
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }





























import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:veegify/provider/theme_provider.dart'; // Import theme provider

class LocationSettingsScreen extends StatefulWidget {
  const LocationSettingsScreen({super.key});

  @override
  State<LocationSettingsScreen> createState() => _LocationSettingsScreenState();
}

class _LocationSettingsScreenState extends State<LocationSettingsScreen> {
  bool _isLoading = false;
  PermissionStatus? _status;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final status = await Permission.location.status;
    if (!mounted) return;
    setState(() {
      _status = status;
    });
  }

  String _statusLabel(PermissionStatus? status) {
    if (status == null) return "Checking...";
    switch (status) {
      case PermissionStatus.granted:
        return "Allowed";
      case PermissionStatus.denied:
        return "Denied";
      case PermissionStatus.restricted:
        return "Restricted";
      case PermissionStatus.limited:
        return "Limited";
      case PermissionStatus.permanentlyDenied:
        return "Permanently denied";
      default:
        return status.toString();
    }
  }

  Color _statusColor(PermissionStatus? status) {
    if (status == null) return Colors.grey;
    switch (status) {
      case PermissionStatus.granted:
        return Colors.green;
      case PermissionStatus.denied:
      case PermissionStatus.permanentlyDenied:
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return "Light Mode";
      case ThemeMode.dark:
        return "Dark Mode";
      case ThemeMode.system:
        return "System Default";
    }
  }

  IconData _getThemeModeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.phone_iphone;
    }
  }

  void _showThemeModeDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Choose Theme Mode"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // System Default
              ListTile(
                leading: Icon(Icons.phone_iphone,
                    color: Theme.of(context).colorScheme.primary),
                title: const Text("System Default"),
                subtitle: const Text("Follow system theme settings"),
                trailing: themeProvider.themeMode == ThemeMode.system
                    ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                    : null,
                onTap: () {
                  themeProvider.setThemeMode(ThemeMode.system);
                  Navigator.of(context).pop();
                },
              ),
              
              // Light Mode
              ListTile(
                leading: Icon(Icons.light_mode,
                    color: Theme.of(context).colorScheme.primary),
                title: const Text("Light Mode"),
                subtitle: const Text("Always use light theme"),
                trailing: themeProvider.themeMode == ThemeMode.light
                    ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                    : null,
                onTap: () {
                  themeProvider.setThemeMode(ThemeMode.light);
                  Navigator.of(context).pop();
                },
              ),
              
              // Dark Mode
              ListTile(
                leading: Icon(Icons.dark_mode,
                    color: Theme.of(context).colorScheme.primary),
                title: const Text("Dark Mode"),
                subtitle: const Text("Always use dark theme"),
                trailing: themeProvider.themeMode == ThemeMode.dark
                    ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                    : null,
                onTap: () {
                  themeProvider.setThemeMode(ThemeMode.dark);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleAllow() async {
    setState(() => _isLoading = true);

    final status = await Permission.location.request();

    if (!mounted) return;
    setState(() {
      _status = status;
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          status.isGranted
              ? 'Location permission granted'
              : 'Location permission not granted',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _handleDontAllow() async {
    final opened = await openAppSettings();

    if (!mounted) return;

    if (!opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Could not open app settings'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } else {
      await _loadStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    
    final statusText = _statusLabel(_status);
    final statusColor = _statusColor(_status);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // System Theme Section
            const Text(
              "Appearance",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Change app theme mode",
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),

            // Theme Mode Card - Now with direct toggle
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: theme.cardColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    Icon(
                      _getThemeModeIcon(themeProvider.themeMode),
                      color: theme.colorScheme.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Theme Mode",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getThemeModeLabel(themeProvider.themeMode),
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showThemeModeDialog(context),
                      icon: Icon(
                        Icons.settings,
                        color: theme.colorScheme.primary,
                      ),
                      tooltip: "Change theme mode",
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Location Access Section (keep your existing location code here)
            const Text(
              "Location Access",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Control whether the app can access your location.",
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),

            // Location Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: theme.cardColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: statusColor,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Location permission",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 14,
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            if (_isLoading)
              Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: _handleDontAllow,
                    icon: const Icon(Icons.check),
                    label: const Text("Allow location"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  OutlinedButton.icon(
                    onPressed: _handleDontAllow,
                    icon: const Icon(Icons.close),
                    label: const Text("Don't allow"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.onSurface,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Text(
                    "Note: On Android/iOS, apps cannot directly remove permissions. "
                    "\"Don't allow\" will open the system settings so you can turn off location access.",
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}