import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:veegify/core/app_lifecycle_service.dart';

import 'package:veegify/provider/AuthProvider/auth_provider.dart';
import 'package:veegify/provider/BannerProvider/banner_provider.dart';
import 'package:veegify/provider/BannerProvider/home_layout_provider.dart';
import 'package:veegify/provider/BookingProvider/booking_provider.dart';
import 'package:veegify/provider/CartProvider/cart_provider.dart';
import 'package:veegify/provider/CategoryProvider/category_provider.dart';
import 'package:veegify/provider/CouponProvider/coupon_provider.dart';
import 'package:veegify/provider/Credential/credential_provider.dart';
import 'package:veegify/provider/LocationProvider/location_provider.dart';
import 'package:veegify/provider/MaintenanceProvider/maintenance_provider.dart';
import 'package:veegify/provider/ProfileProvider.dart/profile_provider.dart';
import 'package:veegify/provider/RestaurantProvider/nearby_restaurants_provider.dart';
import 'package:veegify/provider/RestaurantProvider/restaurant_products_provider.dart';
import 'package:veegify/provider/RestaurantProvider/top_restaurants_provider.dart';
import 'package:veegify/provider/VersionProvider/version_provider.dart';
import 'package:veegify/provider/WishListProvider/wishlist_provider.dart';
import 'package:veegify/provider/address_provider.dart';
import 'package:veegify/provider/theme_provider.dart';

import 'package:veegify/services/BookingService/booking_service.dart';
import 'package:veegify/views/MaintenanceScreen/maintenance_screen.dart';
import 'package:veegify/views/Version/global_watcher.dart';
import 'package:veegify/views/theme/app_theme.dart';
import 'package:veegify/views/splash_screen.dart';
import 'package:veegify/widgets/bottom_navbar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppLifecycleService.instance.init();
  runApp(const MyApp());
}

/// ---------------------------------------------------------------------------
/// ROOT APP
/// ---------------------------------------------------------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final orderService = OrderService(baseUrl: 'https://api.vegiffyy.com');

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => BottomNavbarProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => RestaurantProvider()),
        ChangeNotifierProvider(create: (_) => TopRestaurantsProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(
          create: (_) => OrderProvider(service: orderService),
        ),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => BannerProvider()),
        ChangeNotifierProvider(create: (_) => RestaurantProductsProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => MaintenanceProvider()),
        ChangeNotifierProvider(create: (_) => VersionProvider()),
        ChangeNotifierProvider(create: (_) => HomeLayoutProvider()),
        ChangeNotifierProvider(create: (_) => CredentialProvider()),
        ChangeNotifierProvider(create: (_) => CouponProvider()),
      ],
      child: const _AppBootstrapper(),
    );
  }
}

/// ---------------------------------------------------------------------------
/// BOOTSTRAPPER (runs once, NO UI, NO rebuild loops)
/// ---------------------------------------------------------------------------
class _AppBootstrapper extends StatefulWidget {
  const _AppBootstrapper();

  @override
  State<_AppBootstrapper> createState() => _AppBootstrapperState();
}

class _AppBootstrapperState extends State<_AppBootstrapper> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    // Run AFTER first frame (no UI blocking)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MaintenanceProvider>().checkMaintenance();
      context.read<VersionProvider>().checkVersion();
    });

    // App resume hook (set once)
    AppLifecycleService.instance.onAppResumed ??= () {
      debugPrint('🔁 App resumed → re-check maintenance & version');
      context.read<MaintenanceProvider>().checkMaintenance();
      context.read<VersionProvider>().checkVersion();
    };
  }

  @override
  Widget build(BuildContext context) {
    return const _AppView();
  }
}

/// ---------------------------------------------------------------------------
/// APP VIEW (UI ONLY)
/// ---------------------------------------------------------------------------
class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final maintenance = context.watch<MaintenanceProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const SplashScreen(),
      builder: (context, child) {
        Widget screen = child ?? const SizedBox.shrink();

        // Force maintenance screen if enabled
        if (maintenance.isMaintenance) {
          screen = const MaintenanceScreen();
        }

        // Always wrap with version watcher
        return UpgradeWatcher(child: screen);
      },
    );
  }
}
