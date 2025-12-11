// import 'package:flutter/widgets.dart';
// import 'app_lifecycle_enum.dart';

// class AppLifecycleService with WidgetsBindingObserver {
//   AppLifecycleService._privateConstructor();
//   static final AppLifecycleService instance =
//       AppLifecycleService._privateConstructor();

//   AppLifecycleStateEnum currentState = AppLifecycleStateEnum.foreground;

//   bool get isAppInForeground =>
//       currentState == AppLifecycleStateEnum.foreground;

//   void init() {
//     WidgetsBinding.instance.addObserver(this);
//   }

//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     switch (state) {
//       case AppLifecycleState.resumed:
//         currentState = AppLifecycleStateEnum.foreground;
//         break;

//       case AppLifecycleState.inactive:
//         currentState = AppLifecycleStateEnum.inactive;
//         break;

//       case AppLifecycleState.paused:
//         currentState = AppLifecycleStateEnum.background;
//         break;

//       case AppLifecycleState.hidden:
//         // 🔥 App is not visible (e.g. web tab hidden) → treat as background
//         currentState = AppLifecycleStateEnum.background;
//         break;

//       case AppLifecycleState.detached:
//         currentState = AppLifecycleStateEnum.detached;
//         break;
//     }

//     debugPrint("🔥 App lifecycle changed → $state  → $currentState");
//   }
// }

















// import 'package:flutter/widgets.dart';
// import 'app_lifecycle_enum.dart';

// class AppLifecycleService with WidgetsBindingObserver {
//   AppLifecycleService._privateConstructor();
//   static final AppLifecycleService instance =
//       AppLifecycleService._privateConstructor();

//   AppLifecycleStateEnum currentState = AppLifecycleStateEnum.foreground;

//   /// 🔹 Optional callback you can set from anywhere (e.g. main.dart)
//   VoidCallback? onAppResumed;

//   bool get isAppInForeground =>
//       currentState == AppLifecycleStateEnum.foreground;

//   void init() {
//     WidgetsBinding.instance.addObserver(this);
//   }

//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     switch (state) {
//       case AppLifecycleState.resumed:
//         currentState = AppLifecycleStateEnum.foreground;

//         // 🔥 Notify whoever is listening (we'll hook maintenance check here)
//         if (onAppResumed != null) {
//           onAppResumed!.call();
//         }
//         break;

//       case AppLifecycleState.inactive:
//         currentState = AppLifecycleStateEnum.inactive;
//         break;

//       case AppLifecycleState.paused:
//         currentState = AppLifecycleStateEnum.background;
//         break;

//       case AppLifecycleState.hidden:
//         currentState = AppLifecycleStateEnum.background;
//         break;

//       case AppLifecycleState.detached:
//         currentState = AppLifecycleStateEnum.detached;
//         break;
//     }

//     debugPrint("🔥 App lifecycle changed → $state  → $currentState");
//   }
// }
















// import 'package:flutter/widgets.dart';
// import 'app_lifecycle_enum.dart';

// class AppLifecycleService with WidgetsBindingObserver {
//   AppLifecycleService._privateConstructor();
//   static final AppLifecycleService instance =
//       AppLifecycleService._privateConstructor();

//   AppLifecycleStateEnum currentState = AppLifecycleStateEnum.foreground;

//   /// 🔹 This callback will be assigned in main.dart
//   VoidCallback? onAppResumed;

//   bool get isAppInForeground =>
//       currentState == AppLifecycleStateEnum.foreground;

//   void init() {
//     WidgetsBinding.instance.addObserver(this);
//   }

//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//   }

// @override
// void didChangeAppLifecycleState(AppLifecycleState state) {
//   debugPrint("🔥 Lifecycle → $state");

//   switch (state) {
//     case AppLifecycleState.resumed:
//       currentState = AppLifecycleStateEnum.foreground;
//       onAppResumed?.call();  // 🔥 FIRE HERE
//       break;

//     case AppLifecycleState.inactive:
//       // Some Android versions use INACTIVE before RESUMED
//       if (currentState == AppLifecycleStateEnum.background ||
//           currentState == AppLifecycleStateEnum.inactive) {
//         onAppResumed?.call();  // 🔥 FIRE HERE ALSO
//       }
//       currentState = AppLifecycleStateEnum.inactive;
//       break;

//     case AppLifecycleState.hidden:
//       // Web / Android 12 often use HIDDEN instead of PAUSED
//       if (currentState == AppLifecycleStateEnum.background) {
//         onAppResumed?.call(); // 🔥 FIRE
//       }
//       currentState = AppLifecycleStateEnum.background;
//       break;

//     case AppLifecycleState.paused:
//       currentState = AppLifecycleStateEnum.background;
//       break;

//     case AppLifecycleState.detached:
//       currentState = AppLifecycleStateEnum.detached;
//       break;
//   }
// }

// }

















import 'package:flutter/widgets.dart';
import 'app_lifecycle_enum.dart';
class AppLifecycleService with WidgetsBindingObserver {
  AppLifecycleService._privateConstructor();
  static final AppLifecycleService instance =
      AppLifecycleService._privateConstructor();
  AppLifecycleStateEnum currentState = AppLifecycleStateEnum.foreground;
  /// :small_blue_diamond: This callback will be assigned in main.dart
  VoidCallback? onAppResumed;
  bool get isAppInForeground =>
      currentState == AppLifecycleStateEnum.foreground;
  void init() {
    WidgetsBinding.instance.addObserver(this);
  }
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint(":fire: Lifecycle → $state");
    switch (state) {
      case AppLifecycleState.resumed:
        currentState = AppLifecycleStateEnum.foreground;
        onAppResumed?.call();  // :fire: FIRE HERE
        break;
      case AppLifecycleState.inactive:
        // Some Android versions use INACTIVE before RESUMED
        if (currentState == AppLifecycleStateEnum.background ||
            currentState == AppLifecycleStateEnum.inactive) {
          onAppResumed?.call();  // :fire: FIRE HERE ALSO
        }
        currentState = AppLifecycleStateEnum.inactive;
        break;
      case AppLifecycleState.hidden:
        // Web / Android 12 often use HIDDEN instead of PAUSED
        if (currentState == AppLifecycleStateEnum.background) {
          onAppResumed?.call(); // :fire: FIRE
        }
        currentState = AppLifecycleStateEnum.background;
        break;
      case AppLifecycleState.paused:
        currentState = AppLifecycleStateEnum.background;
        break;
      case AppLifecycleState.detached:
        currentState = AppLifecycleStateEnum.detached;
        break;
    }
  }
}