import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showUpgradeDialog({
  required BuildContext context,
  required String currentVersion,
  required String storeVersion,
}) async {
  // Your store URLs
  final playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.veggify.veegify';
  final appStoreUrl = 'https://apps.apple.com/in/app/vegiffyy/id6757138352';

  final url = Platform.isIOS ? appStoreUrl : playStoreUrl;

  await showDialog(
    context: context,
    barrierDismissible: true, // change to false if you want force update
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          "Update available",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "A newer version of the app is available.\n\n"
          "Current: $currentVersion\n"
          "Latest: $storeVersion\n\n"
          "Please update to enjoy the latest features and fixes.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // "Later"
            child: const Text("Later"),
          ),
          ElevatedButton(
            onPressed: () async {
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: const Text("Update"),
          ),
        ],
      );
    },
  );
}
