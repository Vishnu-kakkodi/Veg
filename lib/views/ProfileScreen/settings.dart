// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:veegify/provider/AuthProvider/auth_provider.dart';
// import 'package:veegify/provider/theme_provider.dart';
// import 'package:veegify/views/Auth/login_page.dart'; // Import theme provider
// import 'package:http/http.dart' as http;

// class LocationSettingsScreen extends StatefulWidget {
//   const LocationSettingsScreen({super.key});

//   @override
//   State<LocationSettingsScreen> createState() => _LocationSettingsScreenState();
// }

// class _LocationSettingsScreenState extends State<LocationSettingsScreen> {
//   bool _isLoading = false;
//   PermissionStatus? _status;
//   late String userId;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();

//     _loadStatus();
//   }

//   Future<void> _loadUserData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       userId = prefs.getString('userId') ?? '';
//       print("kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk$userId");
//     } catch (e) {
//       debugPrint('Error getting user ID: $e');
//     }
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

//   String _getThemeModeLabel(ThemeMode mode) {
//     switch (mode) {
//       case ThemeMode.light:
//         return "Light Mode";
//       case ThemeMode.dark:
//         return "Dark Mode";
//       case ThemeMode.system:
//         return "System Default";
//     }
//   }

//   IconData _getThemeModeIcon(ThemeMode mode) {
//     switch (mode) {
//       case ThemeMode.light:
//         return Icons.light_mode;
//       case ThemeMode.dark:
//         return Icons.dark_mode;
//       case ThemeMode.system:
//         return Icons.phone_iphone;
//     }
//   }

//   void _showThemeModeDialog(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text("Choose Theme Mode"),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // System Default
//               ListTile(
//                 leading: Icon(
//                   Icons.phone_iphone,
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//                 title: const Text("System Default"),
//                 subtitle: const Text("Follow system theme settings"),
//                 trailing: themeProvider.themeMode == ThemeMode.system
//                     ? Icon(
//                         Icons.check,
//                         color: Theme.of(context).colorScheme.primary,
//                       )
//                     : null,
//                 onTap: () {
//                   themeProvider.setThemeMode(ThemeMode.system);
//                   Navigator.of(context).pop();
//                 },
//               ),

//               // Light Mode
//               ListTile(
//                 leading: Icon(
//                   Icons.light_mode,
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//                 title: const Text("Light Mode"),
//                 subtitle: const Text("Always use light theme"),
//                 trailing: themeProvider.themeMode == ThemeMode.light
//                     ? Icon(
//                         Icons.check,
//                         color: Theme.of(context).colorScheme.primary,
//                       )
//                     : null,
//                 onTap: () {
//                   themeProvider.setThemeMode(ThemeMode.light);
//                   Navigator.of(context).pop();
//                 },
//               ),

//               // Dark Mode
//               ListTile(
//                 leading: Icon(
//                   Icons.dark_mode,
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//                 title: const Text("Dark Mode"),
//                 subtitle: const Text("Always use dark theme"),
//                 trailing: themeProvider.themeMode == ThemeMode.dark
//                     ? Icon(
//                         Icons.check,
//                         color: Theme.of(context).colorScheme.primary,
//                       )
//                     : null,
//                 onTap: () {
//                   themeProvider.setThemeMode(ThemeMode.dark);
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text("Close"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _deleteAccount() async {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         backgroundColor: theme.cardColor,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             CircularProgressIndicator(color: colorScheme.primary),
//             const SizedBox(height: 20),
//             Text(
//               'Deleting Account',
//               style: theme.textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//                 color: colorScheme.onSurface,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Please wait while we process your request...',
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 color: colorScheme.onSurface.withOpacity(0.7),
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );

//     try {
//       bool isDeleted = await _deleteUserAccount();
//       Navigator.of(context).pop(); // Close loading dialog

//       if (isDeleted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 Icon(Icons.check_circle_rounded, color: colorScheme.onPrimary),
//                 const SizedBox(width: 12),
//                 const Expanded(child: Text('Account deleted successfully')),
//               ],
//             ),
//             backgroundColor: colorScheme.primary,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(8),
//             ),
//             margin: const EdgeInsets.all(16),
//           ),
//         );
//         _logout();
//       } else {
//         _showErrorSnackBar('Failed to delete account. Please try again.');
//       }
//     } catch (e) {
//       Navigator.of(context).pop(); // Close loading dialog
//       _showErrorSnackBar('Error: ${e.toString()}');
//     }
//   }

//   Future<bool> _deleteUserAccount() async {
//     try {
//       if (userId.isEmpty) {
//         throw Exception('User ID not found');
//       }

//       final response = await http.delete(
//         Uri.parse('https://api.vegiffyy.com/api/delete-user/$userId'),
//         headers: {'Content-Type': 'application/json'},
//       );

//       if (response.statusCode == 200) {
//         final responseData = json.decode(response.body);
//         debugPrint('Delete account response: $responseData');
//         return true;
//       } else {
//         debugPrint('Delete account failed with status: ${response.statusCode}');
//         debugPrint('Response body: ${response.body}');
//         return false;
//       }
//     } catch (e) {
//       debugPrint('Error deleting account: $e');
//       return false;
//     }
//   }

//   void _logout() {
//     Provider.of<AuthProvider>(context, listen: false).logout;
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (ctx) => const LoginPage()),
//       (route) => false,
//     );
//   }

//   void _showErrorSnackBar(String message) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(
//               Icons.error_outline_rounded,
//               color: colorScheme.onError,
//               size: 20,
//             ),
//             const SizedBox(width: 12),
//             Expanded(child: Text(message)),
//           ],
//         ),
//         backgroundColor: colorScheme.error,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         margin: const EdgeInsets.all(16),
//       ),
//     );
//   }

//   void _showDeleteAccountDialog() {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         backgroundColor: theme.cardColor,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Row(
//           children: [
//             Icon(
//               Icons.warning_amber_rounded,
//               color: colorScheme.error,
//               size: 24,
//             ),
//             const SizedBox(width: 12),
//             Text(
//               'Delete Account?',
//               style: theme.textTheme.titleLarge?.copyWith(
//                 color: colorScheme.error,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'This action cannot be undone. All your data will be permanently deleted including:',
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 color: colorScheme.onSurface.withOpacity(0.8),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: colorScheme.error.withOpacity(0.05),
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: colorScheme.error.withOpacity(0.2)),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children:
//                     [
//                           '• Personal information & profile',
//                           '• Booking history & preferences',
//                           '• Account settings & data',
//                         ]
//                         .map(
//                           (item) => Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 2),
//                             child: Text(
//                               item,
//                               style: TextStyle(
//                                 color: colorScheme.error,
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                         )
//                         .toList(),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Cancel',
//               style: TextStyle(
//                 color: colorScheme.onSurface.withOpacity(0.7),
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _deleteAccount();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: colorScheme.error,
//               foregroundColor: colorScheme.onError,
//             ),
//             child: const Text(
//               'Delete Account',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _handleAllow() async {
//     setState(() => _isLoading = true);

//     final status = await Permission.location.request();

//     if (!mounted) return;
//     setState(() {
//       _status = status;
//       _isLoading = false;
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           status.isGranted
//               ? 'Location permission granted'
//               : 'Location permission not granted',
//         ),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//     );
//   }

//   Future<void> _handleDontAllow() async {
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
//       await _loadStatus();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);
//     final theme = Theme.of(context);

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
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               "Change app theme mode",
//               style: TextStyle(
//                 fontSize: 14,
//                 color: theme.colorScheme.onSurface.withOpacity(0.6),
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Theme Mode Card - Now with direct toggle
//             Card(
//               elevation: 2,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               color: theme.cardColor,
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 16,
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       _getThemeModeIcon(themeProvider.themeMode),
//                       color: theme.colorScheme.primary,
//                       size: 32,
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "Theme Mode",
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             _getThemeModeLabel(themeProvider.themeMode),
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: theme.colorScheme.onSurface.withOpacity(
//                                 0.7,
//                               ),
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     IconButton(
//                       onPressed: () => _showThemeModeDialog(context),
//                       icon: Icon(
//                         Icons.settings,
//                         color: theme.colorScheme.primary,
//                       ),
//                       tooltip: "Change theme mode",
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 32),

//             // Location Access Section (keep your existing location code here)
//             const Text(
//               "Location Access",
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
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
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 16,
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.location_on, color: statusColor, size: 32),
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
//                   ElevatedButton.icon(
//                     onPressed: _handleDontAllow,
//                     icon: const Icon(Icons.check),
//                     label: const Text("Allow location"),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: theme.colorScheme.primary,
//                       foregroundColor: theme.colorScheme.onPrimary,
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                     ),
//                   ),
//                   const SizedBox(height: 12),

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

//                   GestureDetector(
//                     onTap: () {
//                       _showDeleteAccountDialog();
//                     },
//                     child: Card(
//                       elevation: 2,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       color: theme.cardColor,
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 16,
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(Icons.delete, color: Colors.red, size: 32),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   const Text(
//                                     "Delete Account",
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
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













// import 'dart:convert';
// import 'package:flutter/foundation.dart'; // ✅ kIsWeb
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:veegify/provider/AuthProvider/auth_provider.dart';
// import 'package:veegify/provider/theme_provider.dart';
// import 'package:veegify/views/Auth/login_page.dart';
// import 'package:http/http.dart' as http;

// class LocationSettingsScreen extends StatefulWidget {
//   const LocationSettingsScreen({super.key});

//   @override
//   State<LocationSettingsScreen> createState() => _LocationSettingsScreenState();
// }

// class _LocationSettingsScreenState extends State<LocationSettingsScreen> {
//   bool _isLoading = false;
//   PermissionStatus? _status;
//   late String userId;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserData();

//     if (!kIsWeb) {
//       _loadStatus();
//     }
//   }

//   Future<void> _loadUserData() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       userId = prefs.getString('userId') ?? '';
//     } catch (e) {
//       debugPrint('Error getting user ID: $e');
//     }
//   }

//   Future<void> _loadStatus() async {
//     final status = await Permission.location.status;
//     if (!mounted) return;
//     setState(() {
//       _status = status;
//     });
//   }

//   // ===================== LOCATION STATUS HELPERS =====================

//   String _statusLabel(PermissionStatus? status) {
//     if (kIsWeb) return "Managed by browser";
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
//     if (kIsWeb) return Colors.blue;
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

//   // ===================== THEME HELPERS =====================

//   String _getThemeModeLabel(ThemeMode mode) {
//     switch (mode) {
//       case ThemeMode.light:
//         return "Light Mode";
//       case ThemeMode.dark:
//         return "Dark Mode";
//       case ThemeMode.system:
//         return "System Default";
//     }
//   }

//   IconData _getThemeModeIcon(ThemeMode mode) {
//     switch (mode) {
//       case ThemeMode.light:
//         return Icons.light_mode;
//       case ThemeMode.dark:
//         return Icons.dark_mode;
//       case ThemeMode.system:
//         return Icons.phone_iphone;
//     }
//   }

//   // ===================== LOCATION HANDLERS =====================

//   Future<void> _handleAllow() async {
//     if (kIsWeb) return;

//     setState(() => _isLoading = true);
//     final status = await Permission.location.request();

//     if (!mounted) return;
//     setState(() {
//       _status = status;
//       _isLoading = false;
//     });
//   }

//   Future<void> _handleDontAllow() async {
//     if (kIsWeb) return;

//     final opened = await openAppSettings();
//     if (!mounted) return;

//     if (opened) {
//       await _loadStatus();
//     }
//   }

//   // ===================== DELETE ACCOUNT =====================

//   void _showDeleteAccountDialog() {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         backgroundColor: theme.cardColor,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Row(
//           children: [
//             Icon(Icons.warning_amber_rounded,
//                 color: colorScheme.error),
//             const SizedBox(width: 12),
//             Text(
//               'Delete Account?',
//               style: theme.textTheme.titleLarge?.copyWith(
//                 color: colorScheme.error,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//         content: Text(
//           'This action cannot be undone. All your data will be permanently deleted.',
//           style: theme.textTheme.bodyMedium,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: colorScheme.error,
//               foregroundColor: colorScheme.onError,
//             ),
//             onPressed: () {
//               Navigator.pop(context);
//               _deleteAccount();
//             },
//             child: const Text('Delete Account'),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _deleteAccount() async {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => AlertDialog(
//         backgroundColor: theme.cardColor,
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             CircularProgressIndicator(color: colorScheme.primary),
//             const SizedBox(height: 16),
//             const Text('Deleting account...'),
//           ],
//         ),
//       ),
//     );

//     try {
//       final response = await http.delete(
//         Uri.parse('https://api.vegiffyy.com/api/delete-user/$userId'),
//       );

//       Navigator.pop(context);

//       if (response.statusCode == 200) {
//         _logout();
//       } else {
//         _showErrorSnackBar('Failed to delete account');
//       }
//     } catch (e) {
//       Navigator.pop(context);
//       _showErrorSnackBar(e.toString());
//     }
//   }

//   void _logout() {
//     Provider.of<AuthProvider>(context, listen: false).logout;
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (_) => const LoginPage()),
//       (_) => false,
//     );
//   }

//   void _showErrorSnackBar(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(msg)),
//     );
//   }

//   // ===================== UI =====================

//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);
//     final theme = Theme.of(context);

//     final statusText = _statusLabel(_status);
//     final statusColor = _statusColor(_status);

//     return Scaffold(
//       appBar: AppBar(title: const Text('Settings')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ================= APPEARANCE =================
//             const Text("Appearance",
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
//             const SizedBox(height: 16),

//             Card(
//               child: ListTile(
//                 leading: Icon(
//                   _getThemeModeIcon(themeProvider.themeMode),
//                   color: theme.colorScheme.primary,
//                 ),
//                 title: const Text("Theme Mode"),
//                 subtitle:
//                     Text(_getThemeModeLabel(themeProvider.themeMode)),
//                 trailing: Icon(Icons.settings,
//                     color: theme.colorScheme.primary),
//                 onTap: () => _showThemeModeDialog(context),
//               ),
//             ),

//             const SizedBox(height: 32),

//             // ================= LOCATION =================
//             const Text("Location Access",
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
//             const SizedBox(height: 16),

//             Card(
//               child: ListTile(
//                 leading: Icon(Icons.location_on,
//                     color: statusColor),
//                 title: const Text("Location permission"),
//                 subtitle: Text(statusText,
//                     style: TextStyle(color: statusColor)),
//               ),
//             ),

//             const SizedBox(height: 16),

//             if (kIsWeb)
//               Card(
//                 child: const Padding(
//                   padding: EdgeInsets.all(16),
//                   child: Text(
//                     "Location permission on web is controlled by your browser.\n"
//                     "Click the 🔒 icon in address bar → Location → Allow.",
//                   ),
//                 ),
//               ),

//             if (!kIsWeb) ...[
//               const SizedBox(height: 12),
//               ElevatedButton(
//                 onPressed: _handleAllow,
//                 child: const Text('Allow location'),
//               ),
//               const SizedBox(height: 8),
//               OutlinedButton(
//                 onPressed: _handleDontAllow,
//                 child: const Text("Don't allow"),
//               ),
//             ],

//             const SizedBox(height: 32),

//             // ================= DELETE ACCOUNT =================
//             GestureDetector(
//               onTap: _showDeleteAccountDialog,
//               child: Card(
//                 color: Colors.red.withOpacity(0.05),
//                 child: const ListTile(
//                   leading: Icon(Icons.delete, color: Colors.red),
//                   title: Text(
//                     'Delete Account',
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.red),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ===================== THEME DIALOG =====================

//   void _showThemeModeDialog(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Choose Theme Mode"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: ThemeMode.values.map((mode) {
//             return ListTile(
//               leading: Icon(_getThemeModeIcon(mode)),
//               title: Text(_getThemeModeLabel(mode)),
//               trailing: themeProvider.themeMode == mode
//                   ? const Icon(Icons.check)
//                   : null,
//               onTap: () {
//                 themeProvider.setThemeMode(mode);
//                 Navigator.pop(context);
//               },
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }
// }

















import 'dart:convert';
import 'package:flutter/foundation.dart'; // ✅ kIsWeb
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veegify/provider/AuthProvider/auth_provider.dart';
import 'package:veegify/provider/theme_provider.dart';
import 'package:veegify/views/Auth/login_page.dart';
import 'package:http/http.dart' as http;

class LocationSettingsScreen extends StatefulWidget {
  const LocationSettingsScreen({super.key});

  @override
  State<LocationSettingsScreen> createState() => _LocationSettingsScreenState();
}

class _LocationSettingsScreenState extends State<LocationSettingsScreen> {
  bool _isLoading = false;
  PermissionStatus? _status;
String userId = '';
  @override
  void initState() {
    super.initState();
    _loadUserData();

    if (!kIsWeb) {
      _loadStatus();
    }
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('userId') ?? '';
    } catch (e) {
      debugPrint('Error getting user ID: $e');
    }
  }

  Future<void> _loadStatus() async {
    final status = await Permission.location.status;
    if (!mounted) return;
    setState(() {
      _status = status;
    });
  }

  // ===================== LOCATION STATUS HELPERS =====================

  String _statusLabel(PermissionStatus? status) {
    if (kIsWeb) return "Managed by browser";
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
    if (kIsWeb) return Colors.blue;
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

  // ===================== THEME HELPERS =====================

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

  // ===================== LOCATION HANDLERS =====================

  Future<void> _handleAllow() async {
    if (kIsWeb) return;

    setState(() => _isLoading = true);
    final status = await Permission.location.request();

    if (!mounted) return;
    setState(() {
      _status = status;
      _isLoading = false;
    });
  }

  Future<void> _handleDontAllow() async {
    if (kIsWeb) return;

    final opened = await openAppSettings();
    if (!mounted) return;

    if (opened) {
      await _loadStatus();
    }
  }

  // ===================== DELETE ACCOUNT =====================

  void _showDeleteAccountDialog() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: colorScheme.error),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                'Delete Account?',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'This action cannot be undone. All your data will be permanently deleted.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: theme.cardColor,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: colorScheme.primary),
            const SizedBox(height: 16),
            const Text('Deleting account...'),
          ],
        ),
      ),
    );

    try {
      final response = await http.delete(
        Uri.parse('https://api.vegiffyy.com/api/delete-user/$userId'),
      );

      Navigator.pop(context);

      if (response.statusCode == 200) {
        _logout();
      } else {
        _showErrorSnackBar('Failed to delete account');
      }
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar(e.toString());
    }
  }

  void _logout() {
    Provider.of<AuthProvider>(context, listen: false).logout;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  void _showErrorSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  // ===================== UI =====================

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWebLayout = screenWidth > 600;

    final statusText = _statusLabel(_status);
    final statusColor = _statusColor(_status);

    return Scaffold(
      backgroundColor: isWebLayout ? Colors.grey.shade50 : null,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: isWebLayout,
        elevation: isWebLayout ? 0 : null,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isWebLayout ? 900 : double.infinity,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isWebLayout ? 24 : 16),
            child: isWebLayout
                ? _buildWebLayout(context, themeProvider, theme, statusText, statusColor)
                : _buildMobileLayout(context, themeProvider, theme, statusText, statusColor),
          ),
        ),
      ),
    );
  }

  // ===================== WEB LAYOUT =====================

  Widget _buildWebLayout(
    BuildContext context,
    ThemeProvider themeProvider,
    ThemeData theme,
    String statusText,
    Color statusColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Page Title
        Text(
          "Settings",
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Manage your preferences and account settings",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 32),

        // Grid Layout for Web
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column - Appearance & Location
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionCard(
                    context: context,
                    title: "Appearance",
                    icon: Icons.palette_outlined,
                    children: [
                      _buildThemeCard(themeProvider, theme),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionCard(
                    context: context,
                    title: "Location Access",
                    icon: Icons.location_on_outlined,
                    children: [
                      _buildLocationCard(theme, statusText, statusColor),
                      const SizedBox(height: 16),
                      if (kIsWeb)
                        _buildWebLocationInfo()
                      else
                        _buildLocationButtons(),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 24),

            // Right Column - Account Management
            Expanded(
              child: _buildSectionCard(
                context: context,
                title: "Account Management",
                icon: Icons.account_circle_outlined,
                children: [
                  _buildDeleteAccountCard(),
                  const SizedBox(height: 16),
                  _buildAccountInfoCard(theme),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===================== MOBILE LAYOUT =====================

  Widget _buildMobileLayout(
    BuildContext context,
    ThemeProvider themeProvider,
    ThemeData theme,
    String statusText,
    Color statusColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ================= APPEARANCE =================
        const Text(
          "Appearance",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),

        Card(
          child: ListTile(
            leading: Icon(
              _getThemeModeIcon(themeProvider.themeMode),
              color: theme.colorScheme.primary,
            ),
            title: const Text("Theme Mode"),
            subtitle: Text(_getThemeModeLabel(themeProvider.themeMode)),
            trailing: Icon(Icons.settings, color: theme.colorScheme.primary),
            onTap: () => _showThemeModeDialog(context),
          ),
        ),

        const SizedBox(height: 32),

        // ================= LOCATION =================
        const Text(
          "Location Access",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),

        Card(
          child: ListTile(
            leading: Icon(Icons.location_on, color: statusColor),
            title: const Text("Location permission"),
            subtitle: Text(statusText, style: TextStyle(color: statusColor)),
          ),
        ),

        const SizedBox(height: 16),

        if (kIsWeb)
          Card(
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Location permission on web is controlled by your browser.\n"
                "Click the 🔒 icon in address bar → Location → Allow.",
              ),
            ),
          ),

        if (!kIsWeb) ...[
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _handleAllow,
            child: const Text('Allow location'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _handleDontAllow,
            child: const Text("Don't allow"),
          ),
        ],

        const SizedBox(height: 32),

        // ================= DELETE ACCOUNT =================
        GestureDetector(
          onTap: _showDeleteAccountDialog,
          child: Card(
            color: Colors.red.withOpacity(0.05),
            child: const ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text(
                'Delete Account',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===================== SECTION CARD (WEB) =====================

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  // ===================== THEME CARD (WEB) =====================

  Widget _buildThemeCard(ThemeProvider themeProvider, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getThemeModeIcon(themeProvider.themeMode),
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Theme Mode",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getThemeModeLabel(themeProvider.themeMode),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => _showThemeModeDialog(context),
            icon: const Icon(Icons.edit, size: 16),
            label: const Text("Change"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== LOCATION CARD (WEB) =====================

  Widget _buildLocationCard(ThemeData theme, String statusText, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.location_on, color: statusColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Location Permission",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================== WEB LOCATION INFO =====================

  Widget _buildWebLocationInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Location permission on web is controlled by your browser. "
              "Click the lock icon (🔒) in the address bar, then navigate to Location settings and select 'Allow'.",
              style: TextStyle(
                color: Colors.blue.shade900,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== LOCATION BUTTONS (MOBILE/WEB) =====================

  Widget _buildLocationButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _handleAllow,
            icon: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check, size: 18),
            label: const Text('Allow Location'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _handleDontAllow,
            icon: const Icon(Icons.settings, size: 18),
            label: const Text("Open Settings"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  // ===================== DELETE ACCOUNT CARD (WEB) =====================

  Widget _buildDeleteAccountCard() {
    return InkWell(
      onTap: _showDeleteAccountDialog,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_forever, color: Colors.red, size: 24),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Delete Account",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Permanently remove your account",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red.shade300),
          ],
        ),
      ),
    );
  }

  // ===================== ACCOUNT INFO CARD (WEB) =====================

  Widget _buildAccountInfoCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.grey.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                "Account Information",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "User ID: ${userId.isNotEmpty ? userId : 'Not available'}",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ===================== THEME DIALOG =====================

  void _showThemeModeDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isWebLayout = MediaQuery.of(context).size.width > 600;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Choose Theme Mode"),
        contentPadding: EdgeInsets.symmetric(
          vertical: isWebLayout ? 20 : 12,
          horizontal: 0,
        ),
        content: SizedBox(
          width: isWebLayout ? 400 : double.minPositive,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ThemeMode.values.map((mode) {
              final isSelected = themeProvider.themeMode == mode;
              return ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isWebLayout ? 32 : 24,
                  vertical: isWebLayout ? 4 : 0,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getThemeModeIcon(mode),
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  ),
                ),
                title: Text(
                  _getThemeModeLabel(mode),
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                trailing: isSelected
                    ? Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  themeProvider.setThemeMode(mode);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}