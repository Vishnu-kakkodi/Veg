// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;

// class MaintenanceProvider extends ChangeNotifier {
//   bool isMaintenance = false;
//   bool isChecking = false;
//   String message = "We are under maintenance. Please try again later.";

//   Timer? _pollTimer;
//   bool _disposed = false;

//   MaintenanceProvider() {
//     // Initial check
//     checkMaintenance();

//     // 🔁 Optional: auto-check every 2 minutes
//     _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
//       checkMaintenance();
//     });
//   }

//   Future<void> checkMaintenance() async {
//     if (_disposed) return;
//     if (isChecking) return;

//     debugPrint("🔍 Checking maintenance status...");

//     isChecking = true;
//     notifyListeners();

//     try {
//       final uri =
//           Uri.parse('http://31.97.206.144:5051/api/maintenance-status'); // <- your API
//       final res = await http.get(uri);

//       if (res.statusCode == 200) {
//         final data = json.decode(res.body);

//         // Adjust these keys to your real response
//         final newStatus = data['maintenance'] == true;
//         final newMessage =
//             (data['message'] as String?) ?? "We are under maintenance.";

//         if (newStatus != isMaintenance || newMessage != message) {
//           debugPrint("⚠️ Maintenance status changed: $newStatus");
//           isMaintenance = newStatus;
//           message = newMessage;
//           notifyListeners();
//         }
//       } else {
//         debugPrint(
//             "❌ Maintenance API error: statusCode = ${res.statusCode}");
//       }
//     } catch (e) {
//       debugPrint("❌ Maintenance API exception: $e");
//     } finally {
//       if (_disposed) return;
//       isChecking = false;
//       notifyListeners();
//     }
//   }

//   @override
//   void dispose() {
//     _disposed = true;
//     _pollTimer?.cancel();
//     super.dispose();
//   }
// }


























import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
class MaintenanceProvider extends ChangeNotifier {
  bool isMaintenance = false;
  /// :fire: Only for showing SplashScreen ONCE during the very first API call
  bool hasInitialCheckCompleted = false;
  bool isChecking = false;
  String message = "We are under maintenance. Please try again later.";
  Timer? _pollTimer;
  bool _disposed = false;
  MaintenanceProvider() {
    // Initial check
    checkMaintenance();
    // :repeat: Poll every 3 seconds
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      checkMaintenance();
    });
  }
  Future<void> checkMaintenance() async {
    if (_disposed) return;
    // :x: do NOT block UI with splash every 3 sec
    // So we do NOT use isChecking for splash logic anymore
    if (isChecking) return;
    isChecking = true;
    notifyListeners();
    try {
      final uri = Uri.parse(
        'http://31.97.206.144:5051/api/maintenance-status',
      );
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final newStatus = data['maintenance'] == true;
        final newMessage =
            (data['message'] as String?) ??
                "We are under maintenance. Please try again later.";
        // Update only if changed
        if (newStatus != isMaintenance || newMessage != message) {
          isMaintenance = newStatus;
          message = newMessage;
          notifyListeners();
        }
      } else {
        debugPrint(":x: Maintenance API failed: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint(":x: Maintenance API exception: $e");
    } finally {
      isChecking = false;
      /// :fire: First check finished → now allow home screen
      if (!hasInitialCheckCompleted) {
        hasInitialCheckCompleted = true;
      }
      if (!_disposed) notifyListeners();
    }
  }
  @override
  void dispose() {
    _disposed = true;
    _pollTimer?.cancel();
    super.dispose();
  }
}