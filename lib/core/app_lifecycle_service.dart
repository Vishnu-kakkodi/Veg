import 'package:flutter/widgets.dart';
import 'app_lifecycle_enum.dart';

class AppLifecycleService with WidgetsBindingObserver {
  AppLifecycleService._privateConstructor();
  static final AppLifecycleService instance =
      AppLifecycleService._privateConstructor();

  AppLifecycleStateEnum currentState = AppLifecycleStateEnum.foreground;

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
    switch (state) {
      case AppLifecycleState.resumed:
        currentState = AppLifecycleStateEnum.foreground;
        break;

      case AppLifecycleState.inactive:
        currentState = AppLifecycleStateEnum.inactive;
        break;

      case AppLifecycleState.paused:
        currentState = AppLifecycleStateEnum.background;
        break;

      case AppLifecycleState.hidden:
        // 🔥 App is not visible (e.g. web tab hidden) → treat as background
        currentState = AppLifecycleStateEnum.background;
        break;

      case AppLifecycleState.detached:
        currentState = AppLifecycleStateEnum.detached;
        break;
    }

    debugPrint("🔥 App lifecycle changed → $state  → $currentState");
  }
}
