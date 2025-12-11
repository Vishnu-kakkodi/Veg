import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veegify/provider/VersionProvider/version_provider.dart';
import 'package:veegify/views/Version/upgrade_dialog.dart';

class UpgradeWatcher extends StatelessWidget {
  final Widget child;

  const UpgradeWatcher({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<VersionProvider>(
      builder: (context, versionProvider, _) {
        if (versionProvider.shouldShowDialog) {
          // Show dialog after build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            versionProvider.markDialogShown();
            showUpgradeDialog(
              context: context,
              currentVersion: versionProvider.currentVersion,
              storeVersion: versionProvider.storeVersion,
            );
          });
        }
        return child;
      },
    );
  }
}
