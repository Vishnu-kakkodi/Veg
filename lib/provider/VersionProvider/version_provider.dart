import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:new_version_plus/new_version_plus.dart';

class VersionProvider extends ChangeNotifier {
  String currentVersion = "";
  String storeVersion = "";
  bool needsUpdate = false;
  bool isChecking = false;

  bool _dialogShown = false;

  bool get shouldShowDialog => needsUpdate && !_dialogShown;

  void markDialogShown() {
    _dialogShown = true;
  }

  VersionProvider() {
    // Check once at startup
    checkVersion();
  }

  Future<void> checkVersion() async {
    if (isChecking) return;
    isChecking = true;
    notifyListeners();

    try {
      // 1️⃣ Get current installed version
      final info = await PackageInfo.fromPlatform();
      currentVersion = info.version; // e.g. "1.0.3"

      // 2️⃣ Configure store lookup
      // ⚠️ Put YOUR real IDs here:
      const androidId = 'com.veggify.veegify';
      const iosId = 'com.yourcompany.veegify';

      final newVersion = NewVersionPlus(
        androidId: androidId,
        iOSId: iosId,
      );

      final status = await newVersion.getVersionStatus();
      if (status != null) {
        storeVersion = status.storeVersion; // e.g. "1.1.0"

        // new_version_plus already tells us if we can update
        needsUpdate = status.canUpdate;
      } else {
        needsUpdate = false;
      }
    } catch (e) {
      debugPrint("❌ Version check error: $e");
      needsUpdate = false;
    } finally {
      isChecking = false;
      notifyListeners();
    }
  }
}
