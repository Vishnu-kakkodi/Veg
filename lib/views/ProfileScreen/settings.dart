import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veegify/provider/AuthProvider/auth_provider.dart';
import 'package:veegify/provider/theme_provider.dart';
import 'package:veegify/views/Auth/login_page.dart'; // Import theme provider
import 'package:http/http.dart' as http;

class LocationSettingsScreen extends StatefulWidget {
  const LocationSettingsScreen({super.key});

  @override
  State<LocationSettingsScreen> createState() => _LocationSettingsScreenState();
}

class _LocationSettingsScreenState extends State<LocationSettingsScreen> {
  bool _isLoading = false;
  PermissionStatus? _status;
  late String userId;

  @override
  void initState() {
    super.initState();
    _loadUserData();

    _loadStatus();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('userId') ?? '';
      print("kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk$userId");
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
                leading: Icon(
                  Icons.phone_iphone,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text("System Default"),
                subtitle: const Text("Follow system theme settings"),
                trailing: themeProvider.themeMode == ThemeMode.system
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  themeProvider.setThemeMode(ThemeMode.system);
                  Navigator.of(context).pop();
                },
              ),

              // Light Mode
              ListTile(
                leading: Icon(
                  Icons.light_mode,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text("Light Mode"),
                subtitle: const Text("Always use light theme"),
                trailing: themeProvider.themeMode == ThemeMode.light
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () {
                  themeProvider.setThemeMode(ThemeMode.light);
                  Navigator.of(context).pop();
                },
              ),

              // Dark Mode
              ListTile(
                leading: Icon(
                  Icons.dark_mode,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text("Dark Mode"),
                subtitle: const Text("Always use dark theme"),
                trailing: themeProvider.themeMode == ThemeMode.dark
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
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

  void _deleteAccount() async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: colorScheme.primary),
            const SizedBox(height: 20),
            Text(
              'Deleting Account',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we process your request...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    try {
      bool isDeleted = await _deleteUserAccount();
      Navigator.of(context).pop(); // Close loading dialog

      if (isDeleted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: colorScheme.onPrimary),
                const SizedBox(width: 12),
                const Expanded(child: Text('Account deleted successfully')),
              ],
            ),
            backgroundColor: colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        _logout();
      } else {
        _showErrorSnackBar('Failed to delete account. Please try again.');
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  Future<bool> _deleteUserAccount() async {
    try {
      if (userId.isEmpty) {
        throw Exception('User ID not found');
      }

      final response = await http.delete(
        Uri.parse('http://31.97.206.144:5051/api/delete-user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        debugPrint('Delete account response: $responseData');
        return true;
      } else {
        debugPrint('Delete account failed with status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error deleting account: $e');
      return false;
    }
  }

  void _logout() {
    Provider.of<AuthProvider>(context, listen: false).logout;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (ctx) => const LoginPage()),
      (route) => false,
    );
  }

  void _showErrorSnackBar(String message) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: colorScheme.onError,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

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
            Icon(
              Icons.warning_amber_rounded,
              color: colorScheme.error,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Delete Account?',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This action cannot be undone. All your data will be permanently deleted including:',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.error.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.error.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    [
                          '• Personal information & profile',
                          '• Booking history & preferences',
                          '• Account settings & data',
                        ]
                        .map(
                          (item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              item,
                              style: TextStyle(
                                color: colorScheme.error,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: const Text(
              'Delete Account',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
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
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: statusColor, size: 32),
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

                  GestureDetector(
                    onTap: () {
                      _showDeleteAccountDialog();
                    },
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: theme.cardColor,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 32),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Delete Account",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
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
