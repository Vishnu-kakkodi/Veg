// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:veegify/provider/AuthProvider/auth_provider.dart';
// import 'package:veegify/provider/BannerProvider/banner_provider.dart';
// import 'package:veegify/provider/BookingProvider/booking_provider.dart';
// import 'package:veegify/provider/CartProvider/cart_provider.dart';
// import 'package:veegify/provider/CategoryProvider/category_provider.dart';
// import 'package:veegify/provider/LocationProvider/location_provider.dart';
// import 'package:veegify/provider/ProfileProvider.dart/profile_provider.dart';
// import 'package:veegify/provider/RestaurantProvider/nearby_restaurants_provider.dart';
// import 'package:veegify/provider/RestaurantProvider/restaurant_products_provider.dart';
// import 'package:veegify/provider/RestaurantProvider/top_restaurants_provider.dart';
// import 'package:veegify/provider/WishListProvider/wishlist_provider.dart';
// import 'package:veegify/services/BookingService/booking_service.dart';
// import 'package:veegify/views/theme/app_theme.dart';
// import 'package:veegify/widgets/bottom_navbar.dart';
// import 'package:veegify/views/splash_screen.dart';
// import 'provider/address_provider.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final orderService = OrderService(baseUrl: 'http://31.97.206.144:5051');

//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider<BottomNavbarProvider>(
//           create: (_) => BottomNavbarProvider(),
//         ),
//         ChangeNotifierProvider(create: (_) => AuthProvider()),
//         ChangeNotifierProvider(create: (_) => CategoryProvider()),
//         ChangeNotifierProvider(create: (_) => LocationProvider()),
//         ChangeNotifierProvider(create: (_) => RestaurantProvider()),
//         ChangeNotifierProvider(create: (_) => TopRestaurantsProvider()),
//         ChangeNotifierProvider(create: (_) => CartProvider()),
//         ChangeNotifierProvider(
//           create: (_) => OrderProvider(service: orderService),
//         ),
//         ChangeNotifierProvider(create: (_) => WishlistProvider()),
//         ChangeNotifierProvider(create: (_) => BannerProvider()),
//         ChangeNotifierProvider(create: (_) => RestaurantProductsProvider()),
//         ChangeNotifierProvider(create: (_) => AddressProvider()),
//         ChangeNotifierProvider(create: (_) => ProfileProvider()), // new
//       ],
//       child: MaterialApp(
//         debugShowCheckedModeBanner: false,
//         home: const SplashScreen(),
//           theme: AppTheme.lightTheme,
//         darkTheme: AppTheme.darkTheme,
//         themeMode: ThemeMode.system, /// <-- this is the mobile built-in theme
//       ),
//     );
//   }
// }















import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veegify/core/app_lifecycle_service.dart';
import 'package:veegify/provider/AuthProvider/auth_provider.dart';
import 'package:veegify/provider/BannerProvider/banner_provider.dart';
import 'package:veegify/provider/BookingProvider/booking_provider.dart';
import 'package:veegify/provider/CartProvider/cart_provider.dart';
import 'package:veegify/provider/CategoryProvider/category_provider.dart';
import 'package:veegify/provider/LocationProvider/location_provider.dart';
import 'package:veegify/provider/ProfileProvider.dart/profile_provider.dart';
import 'package:veegify/provider/RestaurantProvider/nearby_restaurants_provider.dart';
import 'package:veegify/provider/RestaurantProvider/restaurant_products_provider.dart';
import 'package:veegify/provider/RestaurantProvider/top_restaurants_provider.dart';
import 'package:veegify/provider/WishListProvider/wishlist_provider.dart';
import 'package:veegify/services/BookingService/booking_service.dart';
import 'package:veegify/views/theme/app_theme.dart';
import 'package:veegify/widgets/bottom_navbar.dart';
import 'package:veegify/views/splash_screen.dart';
import 'provider/address_provider.dart';
import 'provider/theme_provider.dart'; // Import the new theme provider

void main() {
    WidgetsFlutterBinding.ensureInitialized();

  AppLifecycleService.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final orderService = OrderService(baseUrl: 'http://31.97.206.144:5051');

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>( // Add ThemeProvider
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider<BottomNavbarProvider>(
          create: (_) => BottomNavbarProvider(),
        ),
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
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: const SplashScreen(),
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode, // Use theme from provider
          );
        },
      ),
    );
  }
}