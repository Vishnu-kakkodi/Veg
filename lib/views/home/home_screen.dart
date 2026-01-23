// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:provider/provider.dart';
// import 'package:veegify/helper/storage_helper.dart';
// import 'package:veegify/provider/BannerProvider/banner_provider.dart';
// import 'package:veegify/provider/CategoryProvider/category_provider.dart';
// import 'package:veegify/provider/LocationProvider/location_provider.dart';
// import 'package:veegify/provider/RestaurantProvider/nearby_restaurants_provider.dart';
// import 'package:veegify/provider/RestaurantProvider/top_restaurants_provider.dart';
// import 'package:veegify/utils/responsive.dart';
// import 'package:veegify/views/Category/top_restaurants_screen.dart';
// import 'package:veegify/views/LocationScreen/location_search_screen.dart';
// import 'package:veegify/views/Category/category_screen.dart';
// import 'package:veegify/views/Category/nearby_screen.dart';
// import 'package:veegify/views/LocationScreen/location_screen.dart';
// import 'package:veegify/views/address/location_picker.dart';
// import 'package:veegify/views/home/recommended_screen.dart';
// import 'package:veegify/widgets/Animation/home_popup.dart';
// import 'package:veegify/widgets/home/banner.dart';
// import 'package:veegify/widgets/home/category_list.dart';
// import 'package:veegify/widgets/home/header.dart';
// import 'package:veegify/widgets/home/nearby_restaurant.dart';
// import 'package:veegify/widgets/home/search.dart';
// import 'package:veegify/widgets/home/section_header.dart';
// import 'package:veegify/widgets/home/top_restaurants.dart';
// import 'dart:math' as math;

// import 'package:veegify/widgets/home/video.dart';

// // Main HomeScreen wrapper that accepts scroll controller
// class HomeScreenWithController extends StatelessWidget {
//   final ScrollController scrollController;

//   const HomeScreenWithController({
//     super.key,
//     required this.scrollController,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return HomeScreen(scrollController: scrollController);
//   }
// }

// class HomeScreen extends StatefulWidget {
//   final ScrollController? scrollController;

//   const HomeScreen({super.key, this.scrollController});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
//   bool _isInitializing = true;
//   String? userId;

//   // Scroll controller and banner visibility
//   late ScrollController _scrollController;
//   bool _showAdsBanner = true;
//   double _adsBannerHeight = 200.0;

//   // Sticky search bar
//   final GlobalKey _searchBarKey = GlobalKey();
//   bool _isSearchBarPinned = false;

//   // Animation controllers for different sections
//   late AnimationController _headerController;
//   late AnimationController _searchController;
//   late AnimationController _categoriesController;
//   late AnimationController _bannerController;
//   late AnimationController _nearbyController;
//   late AnimationController _topRestaurantsController;
//   late AnimationController _adsBannerController;

//   // Slide animations
//   late Animation<Offset> _headerSlideAnimation;
//   late Animation<Offset> _searchSlideAnimation;
//   late Animation<Offset> _categoriesSlideAnimation;
//   late Animation<Offset> _bannerSlideAnimation;
//   late Animation<Offset> _nearbySlideAnimation;
//   late Animation<Offset> _topRestaurantsSlideAnimation;

//   // Fade animations
//   late Animation<double> _headerFadeAnimation;
//   late Animation<double> _searchFadeAnimation;
//   late Animation<double> _categoriesFadeAnimation;
//   late Animation<double> _bannerFadeAnimation;
//   late Animation<double> _nearbyFadeAnimation;
//   late Animation<double> _topRestaurantsFadeAnimation;
//   late Animation<double> _adsBannerAnimation;
//   late AnimationController _giftAnimationController;
//   late Animation<double> _giftAnimation;

//   // Pagination for Popular Restaurants
//   final int _topRestaurantsPerPage = 2;
//   int _currentTopRestaurantsPage = 1;
//   bool _isTopRestaurantsLoadingMore = false;

//   @override
//   void initState() {
//     super.initState();
//     _scrollController = widget.scrollController ?? ScrollController();
//     _scrollController.addListener(_onScroll);
//     _initializeAnimations();
//     _initializeData();
//   }

//   void _onScroll() {
//     final offset = _scrollController.offset;
//     final shouldShow = offset < 50; // Hide banner after scrolling 50px

//     if (shouldShow != _showAdsBanner) {
//       setState(() {
//         _showAdsBanner = shouldShow;
//       });

//       if (shouldShow) {
//         _adsBannerController.forward();
//       } else {
//         _adsBannerController.reverse();
//       }
//     }

//     // Sticky search bar logic
//     if (_searchBarKey.currentContext != null) {
//       final box =
//           _searchBarKey.currentContext!.findRenderObject() as RenderBox?;
//       if (box != null) {
//         final offsetPosition = box.localToGlobal(Offset.zero);
//         final topPadding = MediaQuery.of(context).padding.top;
//         final shouldPin = offsetPosition.dy <= topPadding + 8;

//         if (shouldPin != _isSearchBarPinned) {
//           setState(() {
//             _isSearchBarPinned = shouldPin;
//           });
//         }
//       }
//     }

//     // Infinite scroll for Popular Restaurants (vertical section)
//     if (!_isTopRestaurantsLoadingMore &&
//         !_isInitializing &&
//         _canLoadMoreTopRestaurants) {
//       if (_scrollController.position.pixels >=
//           _scrollController.position.maxScrollExtent - 200) {
//         _loadMoreTopRestaurantsPage();
//       }
//     }
//   }

//   bool get _canLoadMoreTopRestaurants {
//     try {
//       final provider = context.read<TopRestaurantsProvider>();
//       if (provider.topRestaurants.isEmpty) return false;

//       final total = provider.topRestaurants.length;
//       final visible = _currentTopRestaurantsPage * _topRestaurantsPerPage;
//       return visible < total;
//     } catch (_) {
//       return false;
//     }
//   }

//   Future<void> _loadMoreTopRestaurantsPage() async {
//     if (!_canLoadMoreTopRestaurants) return;

//     setState(() {
//       _isTopRestaurantsLoadingMore = true;
//     });

//     // Show EasyLoading while "loading" more
//     EasyLoading.show(status: 'Loading more restaurants...');

//     // Simulate delay – in real case you can trigger API call here
//     await Future.delayed(const Duration(milliseconds: 600));

//     if (!mounted) {
//       EasyLoading.dismiss();
//       return;
//     }

//     setState(() {
//       _currentTopRestaurantsPage++;
//       _isTopRestaurantsLoadingMore = false;
//     });

//     EasyLoading.dismiss();
//   }

//   void _initializeAnimations() {
//     // Initialize animation controllers with shorter durations for better UX
//     _headerController = AnimationController(
//       duration: const Duration(milliseconds: 400),
//       vsync: this,
//     );
//     _searchController = AnimationController(
//       duration: const Duration(milliseconds: 400),
//       vsync: this,
//     );
//     _categoriesController = AnimationController(
//       duration: const Duration(milliseconds: 400),
//       vsync: this,
//     );
//     _bannerController = AnimationController(
//       duration: const Duration(milliseconds: 400),
//       vsync: this,
//     );
//     _nearbyController = AnimationController(
//       duration: const Duration(milliseconds: 400),
//       vsync: this,
//     );
//     _topRestaurantsController = AnimationController(
//       duration: const Duration(milliseconds: 400),
//       vsync: this,
//     );
//     _adsBannerController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );

//     // Initialize slide animations (from left to right)
//     _headerSlideAnimation = Tween<Offset>(
//       begin: const Offset(-1.0, 0.0),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _headerController,
//       curve: Curves.easeOutCubic,
//     ));

//     _searchSlideAnimation = Tween<Offset>(
//       begin: const Offset(-1.0, 0.0),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _searchController,
//       curve: Curves.easeOutCubic,
//     ));

//     _categoriesSlideAnimation = Tween<Offset>(
//       begin: const Offset(-1.0, 0.0),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _categoriesController,
//       curve: Curves.easeOutCubic,
//     ));

//     _bannerSlideAnimation = Tween<Offset>(
//       begin: const Offset(1.0, 0.0), // Banner slides from right
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _bannerController,
//       curve: Curves.easeOutCubic,
//     ));

//     _nearbySlideAnimation = Tween<Offset>(
//       begin: const Offset(-1.0, 0.0),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _nearbyController,
//       curve: Curves.easeOutCubic,
//     ));

//     _topRestaurantsSlideAnimation = Tween<Offset>(
//       begin: const Offset(-1.0, 0.0),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _topRestaurantsController,
//       curve: Curves.easeOutCubic,
//     ));

//     // Initialize fade animations
//     _headerFadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(_headerController);

//     _searchFadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(_searchController);

//     _categoriesFadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(_categoriesController);

//     _bannerFadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(_bannerController);

//     _nearbyFadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(_nearbyController);

//     _topRestaurantsFadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(_topRestaurantsController);

//     // Ads banner slide animation (slides up/down)
//     _adsBannerAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _adsBannerController,
//       curve: Curves.easeInOut,
//     ));

//     // Start with ads banner visible
//     _adsBannerController.forward();

//     _giftAnimationController = AnimationController(
//       duration: const Duration(seconds: 1),
//       vsync: this,
//     );

//     _giftAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _giftAnimationController,
//       curve: Curves.easeInOut,
//     ));

//     _startGiftAnimation();
//   }

//   void _startGiftAnimation() {
//     _giftAnimationController.repeat();
//   }

//   void _startAnimations() {
//     // Faster, tighter animation sequence
//     _headerController.forward();

//     Future.delayed(const Duration(milliseconds: 50), () {
//       if (mounted) _searchController.forward();
//     });

//     Future.delayed(const Duration(milliseconds: 100), () {
//       if (mounted) _categoriesController.forward();
//     });

//     Future.delayed(const Duration(milliseconds: 150), () {
//       if (mounted) _bannerController.forward();
//     });

//     Future.delayed(const Duration(milliseconds: 200), () {
//       if (mounted) _nearbyController.forward();
//     });

//     Future.delayed(const Duration(milliseconds: 250), () {
//       if (mounted) _topRestaurantsController.forward();
//     });
//   }

//   Future<void> _initializeData() async {
//     try {
//       // EasyLoading for overall initial load / refresh
//       EasyLoading.show(status: 'Loading...');

//       await _loadUserId();
//       await _handleCurrentLocation();
//       Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
//       Provider.of<RestaurantProvider>(context, listen: false)
//           .getNearbyRestaurants(userId.toString());
//       Provider.of<TopRestaurantsProvider>(context, listen: false)
//           .getTopRestaurants(userId.toString());
//       Provider.of<BannerProvider>(context, listen: false).fetchBanners();

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         final locationProvider =
//             Provider.of<LocationProvider>(context, listen: false);
//         locationProvider.addListener(_onLocationChanged);
//       });

//       // Reset pagination when reloading data
//       _currentTopRestaurantsPage = 1;
//       _isTopRestaurantsLoadingMore = false;
//     } catch (e) {
//       debugPrint('Initialization error: $e');
//     } finally {
//       if (mounted) {
//         setState(() => _isInitializing = false);
//         _startAnimations(); // Start animations after data is loaded
//       }
//       EasyLoading.dismiss();
//     }
//   }

//   void _onLocationChanged() {
//     final locationProvider =
//         Provider.of<LocationProvider>(context, listen: false);

//     if (locationProvider.hasLocation && !locationProvider.isLoading) {
//       if (userId != null) {
//         debugPrint("🔄 Location changed — refreshing restaurants...");
//         Provider.of<RestaurantProvider>(context, listen: false)
//             .getNearbyRestaurants(userId!);
//         Provider.of<TopRestaurantsProvider>(context, listen: false)
//             .getTopRestaurants(userId!);

//         // Reset pagination when location changes
//         setState(() {
//           _currentTopRestaurantsPage = 1;
//           _isTopRestaurantsLoadingMore = false;
//         });
//       }
//     }
//   }

//   Future<void> _loadUserId() async {
//     final user = UserPreferences.getUser();
//     if (user != null && mounted) {
//       setState(() {
//         userId = user.userId;
//       });
//     }
//   }

//   Future<void> _handleCurrentLocation() async {
//     try {
//       final locationProvider =
//           Provider.of<LocationProvider>(context, listen: false);
//       await locationProvider.initLocation(userId.toString());
//     } catch (e) {
//       debugPrint('Location error: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Location error: ${e.toString()}'),
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//         );
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _scrollController.removeListener(_onScroll);
//     if (widget.scrollController == null) {
//       _scrollController.dispose();
//     }
//     _headerController.dispose();
//     _searchController.dispose();
//     _categoriesController.dispose();
//     _bannerController.dispose();
//     _nearbyController.dispose();
//     _topRestaurantsController.dispose();
//     _adsBannerController.dispose();
//     _giftAnimationController.dispose();
//     super.dispose();
//   }

//   Widget _buildAnimatedSection({
//     required Widget child,
//     required Animation<Offset> slideAnimation,
//     required Animation<double> fadeAnimation,
//   }) {
//     return SlideTransition(
//       position: slideAnimation,
//       child: FadeTransition(
//         opacity: fadeAnimation,
//         child: child,
//       ),
//     );
//   }

//   Widget _buildCategorySkeleton() {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     return SizedBox(
//       height: 120,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         physics: const NeverScrollableScrollPhysics(),
//         itemCount: 5,
//         itemBuilder: (context, index) {
//           return Padding(
//             padding: const EdgeInsets.only(right: 12),
//             child: Column(
//               children: [
//                 Container(
//                   width: 80,
//                   height: 80,
//                   decoration: BoxDecoration(
//                     color: isDark ? Colors.grey[700] : Colors.grey[300],
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Center(
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       valueColor: AlwaysStoppedAnimation<Color>(
//                         isDark ? Colors.grey[400]! : Colors.grey,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Container(
//                   width: 60,
//                   height: 12,
//                   decoration: BoxDecoration(
//                     color: isDark ? Colors.grey[700] : Colors.grey[300],
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildRestaurantSkeleton() {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     return SizedBox(
//       height: 270,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         physics: const NeverScrollableScrollPhysics(),
//         itemCount: 3,
//         itemBuilder: (context, index) {
//           return Container(
//             margin: const EdgeInsets.only(right: 12),
//             width: 176,
//             decoration: BoxDecoration(
//               color: isDark ? theme.cardColor : Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(isDark ? 0.3 : 0.1),
//                   spreadRadius: 1,
//                   blurRadius: 4,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   height: 120,
//                   decoration: BoxDecoration(
//                     color: isDark ? Colors.grey[700] : Colors.grey[300],
//                     borderRadius:
//                         const BorderRadius.vertical(top: Radius.circular(12)),
//                   ),
//                   child: Center(
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       valueColor: AlwaysStoppedAnimation<Color>(
//                         isDark ? Colors.grey[400]! : Colors.grey,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Container(
//                         width: 120,
//                         height: 18,
//                         decoration: BoxDecoration(
//                           color:
//                               isDark ? Colors.grey[700] : Colors.grey[300],
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Container(
//                             width: 20,
//                             height: 20,
//                             decoration: BoxDecoration(
//                               color: isDark
//                                   ? Colors.grey[700]
//                                   : Colors.grey[300],
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                           const SizedBox(width: 4),
//                           Container(
//                             width: 30,
//                             height: 16,
//                             decoration: BoxDecoration(
//                               color: isDark
//                                   ? Colors.grey[700]
//                                   : Colors.grey[300],
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Container(
//                         width: 100,
//                         height: 12,
//                         decoration: BoxDecoration(
//                           color:
//                               isDark ? Colors.grey[700] : Colors.grey[300],
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Container(
//                             width: 16,
//                             height: 16,
//                             decoration: BoxDecoration(
//                               color: isDark
//                                   ? Colors.grey[700]
//                                   : Colors.grey[300],
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                           const SizedBox(width: 4),
//                           Container(
//                             width: 60,
//                             height: 12,
//                             decoration: BoxDecoration(
//                               color: isDark
//                                   ? Colors.grey[700]
//                                   : Colors.grey[300],
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   /// Vertical skeleton for Popular Restaurants
//   Widget _buildVerticalRestaurantSkeleton() {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: 4,
//       itemBuilder: (context, index) {
//         return Container(
//           margin: const EdgeInsets.only(bottom: 12),
//           decoration: BoxDecoration(
//             color: isDark ? theme.cardColor : Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(isDark ? 0.3 : 0.1),
//                 spreadRadius: 1,
//                 blurRadius: 4,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Row(
//             children: [
//               Container(
//                 height: 90,
//                 width: 90,
//                 decoration: BoxDecoration(
//                   color: isDark ? Colors.grey[700] : Colors.grey[300],
//                   borderRadius: const BorderRadius.horizontal(
//                     left: Radius.circular(12),
//                   ),
//                 ),
//                 child: Center(
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     valueColor: AlwaysStoppedAnimation<Color>(
//                       isDark ? Colors.grey[400]! : Colors.grey,
//                     ),
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.all(10),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Container(
//                         height: 16,
//                         width: 120,
//                         decoration: BoxDecoration(
//                           color:
//                               isDark ? Colors.grey[700] : Colors.grey[300],
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Container(
//                         height: 14,
//                         width: 160,
//                         decoration: BoxDecoration(
//                           color:
//                               isDark ? Colors.grey[700] : Colors.grey[300],
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Container(
//                             height: 14,
//                             width: 40,
//                             decoration: BoxDecoration(
//                               color: isDark
//                                   ? Colors.grey[700]
//                                   : Colors.grey[300],
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                           ),
//                           const SizedBox(width: 6),
//                           Container(
//                             height: 14,
//                             width: 60,
//                             decoration: BoxDecoration(
//                               color: isDark
//                                   ? Colors.grey[700]
//                                   : Colors.grey[300],
//                               borderRadius: BorderRadius.circular(4),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildBannerSkeleton() {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     return Container(
//       height: 140,
//       decoration: BoxDecoration(
//         color: isDark ? Colors.grey[700] : Colors.grey[300],
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Center(
//         child: CircularProgressIndicator(
//           strokeWidth: 2,
//           valueColor: AlwaysStoppedAnimation<Color>(
//             isDark ? Colors.grey[400]! : Colors.grey,
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//     final topPadding = MediaQuery.of(context).padding.top;

//     final isMobile = Responsive.isMobile(context);
//     final isTablet = Responsive.isTablet(context);
//     final isDesktop = Responsive.isDesktop(context);

//     final horizontalPadding =
//         isMobile ? 16.0 : (isTablet ? 24.0 : 32.0);
//     const double maxContentWidth = 720;

//     return Scaffold(
//       backgroundColor: isDark ? Colors.black : Colors.white,
//       body: Stack(
//         children: [
//           Column(
//             children: [
//               Expanded(
//                 child: SafeArea(
//                   top: true,
//                   child: RefreshIndicator(
//                     onRefresh: () async {
//                       _headerController.reset();
//                       _searchController.reset();
//                       _categoriesController.reset();
//                       _bannerController.reset();
//                       _nearbyController.reset();
//                       _topRestaurantsController.reset();

//                       await _initializeData();
//                     },
//                     child: SingleChildScrollView(
//                       controller: _scrollController,
//                       padding: EdgeInsets.symmetric(
//                         horizontal: horizontalPadding,
//                       ),
//                       child: Center(
//                         child: ConstrainedBox(
//                           constraints: const BoxConstraints(
//                             maxWidth: maxContentWidth,
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const SizedBox(height: 10),

//                               // Header
//                               _isInitializing
//                                   ? Container(
//                                       height: 60,
//                                       decoration: BoxDecoration(
//                                         color: isDark
//                                             ? Colors.grey[700]
//                                             : Colors.grey[300],
//                                         borderRadius:
//                                             BorderRadius.circular(8),
//                                       ),
//                                     )
//                                   : _buildAnimatedSection(
//                                       slideAnimation:
//                                           _headerSlideAnimation,
//                                       fadeAnimation: _headerFadeAnimation,
//                                       child: HomeHeader(
//                                         userId: userId ?? 'unknown',
//                                         onLocationTap: () async {
//                                           await Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                               builder: (_) =>
//                                                   LocationPickerScreen(
//                                                 isEditing: false,
//                                                 userId: userId.toString(),
//                                               ),
//                                             ),
//                                           );
//                                         },
//                                       ),
//                                     ),

//                               const SizedBox(height: 16),

//                               // Search Bar (becomes invisible when pinned)
//                               _isInitializing
//                                   ? Container(
//                                       height: 50,
//                                       decoration: BoxDecoration(
//                                         color: isDark
//                                             ? Colors.grey[700]
//                                             : Colors.grey[300],
//                                         borderRadius:
//                                             BorderRadius.circular(15),
//                                       ),
//                                     )
//                                   : Opacity(
//                                       opacity:
//                                           _isSearchBarPinned ? 0.0 : 1.0,
//                                       child: _buildAnimatedSection(
//                                         slideAnimation:
//                                             _searchSlideAnimation,
//                                         fadeAnimation:
//                                             _searchFadeAnimation,
//                                         child: Container(
//                                           key: _searchBarKey,
//                                           child:
//                                               const SearchBarWithVoice(),
//                                         ),
//                                       ),
//                                     ),

//                               const SizedBox(height: 16),

//                               // Categories Section
//                               Column(
//                                 children: [
//                                   SectionHeader(
//                                     title: 'Categories',
//                                     onSeeAll: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (_) => CategoryScreen(
//                                             userId: userId.toString(),
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                   const SizedBox(height: 10),
//                                   _isInitializing
//                                       ? _buildCategorySkeleton()
//                                       : _buildAnimatedSection(
//                                           slideAnimation:
//                                               _categoriesSlideAnimation,
//                                           fadeAnimation:
//                                               _categoriesFadeAnimation,
//                                           child: _buildCategories(),
//                                         ),
//                                 ],
//                               ),

//                               const SizedBox(height: 16),

//                               // Banner
//                               _isInitializing
//                                   ? _buildBannerSkeleton()
//                                   : _buildAnimatedSection(
//                                       slideAnimation:
//                                           _bannerSlideAnimation,
//                                       fadeAnimation: _bannerFadeAnimation,
//                                       child: const PromoBanner(),
//                                     ),

//                               const SizedBox(height: 16),

//                               // Nearby Restaurants Section (horizontal)
//                               Column(
//                                 children: [
//                                   SectionHeader(
//                                     title: 'Nearby restaurants',
//                                     onSeeAll: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (_) => NearbyScreen(
//                                             userId: userId.toString(),
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                   const SizedBox(height: 10),
//                                   _isInitializing
//                                       ? _buildRestaurantSkeleton()
//                                       : _buildAnimatedSection(
//                                           slideAnimation:
//                                               _nearbySlideAnimation,
//                                           fadeAnimation:
//                                               _nearbyFadeAnimation,
//                                           child: _buildRestaurantList(),
//                                         ),
//                                 ],
//                               ),

//                               const SizedBox(height: 16),

//                               // Top Restaurants Section (VERTICAL)
//                               Column(
//                                 crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                 children: [
//                                   SectionHeader(
//                                     title: 'Popular Restaurants',
//                                     onSeeAll: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (_) =>
//                                               TopRestaurantsScreen(
//                                             userId: userId.toString(),
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                   const SizedBox(height: 10),
//                                   _isInitializing
//                                       ? _buildVerticalRestaurantSkeleton()
//                                       : _buildAnimatedSection(
//                                           slideAnimation:
//                                               _topRestaurantsSlideAnimation,
//                                           fadeAnimation:
//                                               _topRestaurantsFadeAnimation,
//                                           child: _buildTopRestaurants(),
//                                         ),
//                                 ],
//                               ),

//                               const SizedBox(height: 20),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),

//           // Sticky Search Bar (overlay at top)
//           if (!_isInitializing && _isSearchBarPinned)
//             Positioned(
//               top: topPadding + 8,
//               left: horizontalPadding,
//               right: horizontalPadding,
//               child: Center(
//                 child: ConstrainedBox(
//                   constraints: const BoxConstraints(
//                     maxWidth: maxContentWidth,
//                   ),
//                   child: Material(
//                     elevation: 4,
//                     borderRadius: BorderRadius.circular(15),
//                     color: theme.cardColor,
//                     child: const SearchBarWithVoice(),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCategories() {
//     return Consumer<CategoryProvider>(
//       builder: (context, provider, _) {
//         if (provider.isLoading) {
//           return _buildCategorySkeleton();
//         }
//         if (provider.categories.isEmpty) {
//           final theme = Theme.of(context);
//           return SizedBox(
//             height: 120,
//             child: Center(
//               child: Text(
//                 'No categories available',
//                 style: theme.textTheme.bodyMedium?.copyWith(
//                   color:
//                       theme.colorScheme.onSurface.withOpacity(0.6),
//                 ),
//               ),
//             ),
//           );
//         }
//         return SizedBox(
//           height: 120,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: provider.categories.length,
//             itemBuilder: (context, index) {
//               final category = provider.categories[index];
//               return Padding(
//                 padding: const EdgeInsets.only(right: 12),
//                 child: CategoryCard(
//                   id: category.id,
//                   imagePath: category.imageUrl,
//                   title: category.categoryName,
//                   userId: userId.toString(),
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildRestaurantList() {
//     final theme = Theme.of(context);

//     return Consumer<RestaurantProvider>(
//       builder: (context, provider, _) {
//         if (provider.isLoading) {
//           return _buildRestaurantSkeleton();
//         }

//         if (provider.nearbyRestaurants.isEmpty) {
//           return SizedBox(
//             height: 240,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Image.network(
//                   'https://cdn.dribbble.com/users/107759/screenshots/16839013/media/87e30b30c8d92a4b1826c74e6e0ee938.png',
//                   height: 160,
//                   fit: BoxFit.contain,
//                   errorBuilder: (context, error, stackTrace) => Icon(
//                     Icons.restaurant_menu,
//                     size: 80,
//                     color: theme.colorScheme.primary,
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 Text(
//                   'No restaurants nearby',
//                   style: theme.textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Looks like there arent any restaurants around your location.',
//                   textAlign: TextAlign.center,
//                   style: theme.textTheme.bodyMedium?.copyWith(
//                     color:
//                         theme.colorScheme.onSurface.withOpacity(0.6),
//                     height: 1.4,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }

//         return SizedBox(
//           height: 200,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: provider.nearbyRestaurants.length,
//             itemBuilder: (context, index) {
//               final restaurant = provider.nearbyRestaurants[index];
//               return RestaurantCard(
//                 id: restaurant.id,
//                 imagePath: restaurant.imageUrl,
//                 name: restaurant.restaurantName,
//                 rating: restaurant.rating.toDouble(),
//                 description: restaurant.description,
//                 price: restaurant.startingPrice,
//                 locationName: restaurant.locationName,
//                 status: restaurant.status,
//               );
//             },
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildTopRestaurants() {
//     final theme = Theme.of(context);

//     return Consumer<TopRestaurantsProvider>(
//       builder: (context, provider, _) {
//         if (provider.isLoading) {
//           return _buildVerticalRestaurantSkeleton();
//         }

//         if (provider.topRestaurants.isEmpty) {
//           return SizedBox(
//             height: 240,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Image.network(
//                   'https://cdn.dribbble.com/users/107759/screenshots/16839013/media/87e30b30c8d92a4b1826c74e6e0ee938.png',
//                   height: 160,
//                   fit: BoxFit.contain,
//                   errorBuilder: (context, error, stackTrace) => Icon(
//                     Icons.restaurant_menu,
//                     size: 80,
//                     color: theme.colorScheme.primary,
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 Text(
//                   'No restaurants nearby',
//                   style: theme.textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Looks like there aren\'t any restaurants around your location.',
//                   textAlign: TextAlign.center,
//                   style: theme.textTheme.bodyMedium?.copyWith(
//                     color:
//                         theme.colorScheme.onSurface.withOpacity(0.6),
//                     height: 1.4,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }

//         // Pagination logic: show items in pages, with loading indicator between
//         final total = provider.topRestaurants.length;
//         final visibleCount = math.min(
//           total,
//           _currentTopRestaurantsPage * _topRestaurantsPerPage,
//         );

//         return ListView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: visibleCount + 1, // +1 for bottom loader placeholder
//           itemBuilder: (context, index) {
//             if (index < visibleCount) {
//               final restaurant = provider.topRestaurants[index];
//               return Padding(
//                 padding: const EdgeInsets.only(bottom: 12),
//                 child: TicketRestaurantCard(
//                   id: restaurant.id,
//                   imagePath: restaurant.imageUrl,
//                   name: restaurant.restaurantName,
//                   rating: restaurant.rating.toDouble(),
//                   description: restaurant.description,
//                   price: restaurant.startingPrice,
//                   locationName: restaurant.locationName,
//                   status: restaurant.status,
//                 ),
//               );
//             } else {
//               // Bottom "load more" indicator
//               if (_isTopRestaurantsLoadingMore &&
//                   _canLoadMoreTopRestaurants) {
//                 return Padding(
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 16.0),
//                   child: Center(
//                     child: SizedBox(
//                       height: 28,
//                       width: 28,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2.5,
//                         valueColor: AlwaysStoppedAnimation<Color>(
//                           theme.colorScheme.primary,
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               } else if (_canLoadMoreTopRestaurants) {
//                 // Placeholder space when more data is available but not loading yet
//                 return const SizedBox(height: 16);
//               } else {
//                 // No more data
//                 return const SizedBox.shrink();
//               }
//             }
//           },
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:veegify/helper/storage_helper.dart';
import 'package:veegify/provider/BannerProvider/banner_provider.dart';
import 'package:veegify/provider/CategoryProvider/category_provider.dart';
import 'package:veegify/provider/Credential/credential_provider.dart';
import 'package:veegify/provider/LocationProvider/location_provider.dart';
import 'package:veegify/provider/RestaurantProvider/nearby_restaurants_provider.dart';
import 'package:veegify/provider/RestaurantProvider/top_restaurants_provider.dart';
import 'package:veegify/utils/responsive.dart';
import 'package:veegify/views/Category/top_restaurants_screen.dart';
import 'package:veegify/views/LocationScreen/location_search_screen.dart';
import 'package:veegify/views/Category/category_screen.dart';
import 'package:veegify/views/Category/nearby_screen.dart';
import 'package:veegify/views/LocationScreen/location_screen.dart';
import 'package:veegify/views/address/location_picker.dart';
import 'package:veegify/views/home/recommended_screen.dart';
import 'package:veegify/widgets/Animation/home_popup.dart';
import 'package:veegify/widgets/home/banner.dart';
import 'package:veegify/widgets/home/category_list.dart';
import 'package:veegify/widgets/home/header.dart';
import 'package:veegify/widgets/home/nearby_restaurant.dart';
import 'package:veegify/widgets/home/search.dart';
import 'package:veegify/widgets/home/section_header.dart';
import 'package:veegify/widgets/home/top_restaurants.dart';
import 'dart:math' as math;

import 'package:veegify/widgets/home/video.dart';

// Main HomeScreen wrapper that accepts scroll controller
class HomeScreenWithController extends StatelessWidget {
  final ScrollController scrollController;

  const HomeScreenWithController({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return HomeScreen(scrollController: scrollController);
  }
}

class HomeScreen extends StatefulWidget {
  final ScrollController? scrollController;

  const HomeScreen({super.key, this.scrollController});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _isInitializing = true;
  String? userId;

  int _getGridCount(double width) {
    if (width >= 1400) return 4;
    if (width >= 1100) return 3;
    if (width >= 800) return 2;
    return 1;
  }

  // Scroll controller and banner visibility
  late ScrollController _scrollController;
  bool _showAdsBanner = true;
  double _adsBannerHeight = 200.0;

  // Sticky search bar
  final GlobalKey _searchBarKey = GlobalKey();
  bool _isSearchBarPinned = false;

  // Animation controllers for different sections
  late AnimationController _headerController;
  late AnimationController _searchController;
  late AnimationController _categoriesController;
  late AnimationController _bannerController;
  late AnimationController _nearbyController;
  late AnimationController _topRestaurantsController;
  late AnimationController _adsBannerController;

  // Slide animations
  late Animation<Offset> _headerSlideAnimation;
  late Animation<Offset> _searchSlideAnimation;
  late Animation<Offset> _categoriesSlideAnimation;
  late Animation<Offset> _bannerSlideAnimation;
  late Animation<Offset> _nearbySlideAnimation;
  late Animation<Offset> _topRestaurantsSlideAnimation;

  // Fade animations
  late Animation<double> _headerFadeAnimation;
  late Animation<double> _searchFadeAnimation;
  late Animation<double> _categoriesFadeAnimation;
  late Animation<double> _bannerFadeAnimation;
  late Animation<double> _nearbyFadeAnimation;
  late Animation<double> _topRestaurantsFadeAnimation;
  late Animation<double> _adsBannerAnimation;
  late AnimationController _giftAnimationController;
  late Animation<double> _giftAnimation;

  // Pagination for Popular Restaurants
  final int _topRestaurantsPerPage = 6; // Increased for desktop
  int _currentTopRestaurantsPage = 1;
  bool _isTopRestaurantsLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
    _initializeAnimations();
    _initializeData();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final shouldShow = offset < 50;

    if (shouldShow != _showAdsBanner) {
      setState(() {
        _showAdsBanner = shouldShow;
      });

      if (shouldShow) {
        _adsBannerController.forward();
      } else {
        _adsBannerController.reverse();
      }
    }

    // Sticky search bar logic
    if (_searchBarKey.currentContext != null) {
      final box =
          _searchBarKey.currentContext!.findRenderObject() as RenderBox?;
      if (box != null) {
        final offsetPosition = box.localToGlobal(Offset.zero);
        final topPadding = MediaQuery.of(context).padding.top;
        final shouldPin = offsetPosition.dy <= topPadding + 8;

        if (shouldPin != _isSearchBarPinned) {
          setState(() {
            _isSearchBarPinned = shouldPin;
          });
        }
      }
    }

    // Infinite scroll for Popular Restaurants
    if (!_isTopRestaurantsLoadingMore &&
        !_isInitializing &&
        _canLoadMoreTopRestaurants) {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreTopRestaurantsPage();
      }
    }
  }

  bool get _canLoadMoreTopRestaurants {
    try {
      final provider = context.read<TopRestaurantsProvider>();
      if (provider.topRestaurants.isEmpty) return false;

      final total = provider.topRestaurants.length;
      final visible = _currentTopRestaurantsPage * _topRestaurantsPerPage;
      return visible < total;
    } catch (_) {
      return false;
    }
  }

  Future<void> _loadMoreTopRestaurantsPage() async {
    if (!_canLoadMoreTopRestaurants) return;

    setState(() {
      _isTopRestaurantsLoadingMore = true;
    });

    EasyLoading.show(status: 'Loading more restaurants...');
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) {
      EasyLoading.dismiss();
      return;
    }

    setState(() {
      _currentTopRestaurantsPage++;
      _isTopRestaurantsLoadingMore = false;
    });

    EasyLoading.dismiss();
  }

  void _initializeAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _searchController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _categoriesController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _bannerController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _nearbyController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _topRestaurantsController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _adsBannerController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _headerSlideAnimation =
        Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _headerController,
            curve: Curves.easeOutCubic,
          ),
        );

    _searchSlideAnimation =
        Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _searchController,
            curve: Curves.easeOutCubic,
          ),
        );

    _categoriesSlideAnimation =
        Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _categoriesController,
            curve: Curves.easeOutCubic,
          ),
        );

    _bannerSlideAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _bannerController,
            curve: Curves.easeOutCubic,
          ),
        );

    _nearbySlideAnimation =
        Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _nearbyController,
            curve: Curves.easeOutCubic,
          ),
        );

    _topRestaurantsSlideAnimation =
        Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _topRestaurantsController,
            curve: Curves.easeOutCubic,
          ),
        );

    _headerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_headerController);

    _searchFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_searchController);

    _categoriesFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_categoriesController);

    _bannerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_bannerController);

    _nearbyFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_nearbyController);

    _topRestaurantsFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_topRestaurantsController);

    _adsBannerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _adsBannerController, curve: Curves.easeInOut),
    );

    _adsBannerController.forward();

    _giftAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _giftAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _giftAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _startGiftAnimation();
  }

  void _startGiftAnimation() {
    _giftAnimationController.repeat();
  }

  void _startAnimations() {
    _headerController.forward();

    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) _searchController.forward();
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _categoriesController.forward();
    });

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _bannerController.forward();
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _nearbyController.forward();
    });

    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) _topRestaurantsController.forward();
    });
  }

  Future<void> _initializeData() async {
    try {
      EasyLoading.show(status: 'Loading...');

      await _loadUserId();
      await _handleCurrentLocation();
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
      Provider.of<RestaurantProvider>(
        context,
        listen: false,
      ).getNearbyRestaurants(userId.toString());
      Provider.of<TopRestaurantsProvider>(
        context,
        listen: false,
      ).getTopRestaurants(userId.toString());
      Provider.of<BannerProvider>(context, listen: false).fetchBanners();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final locationProvider = Provider.of<LocationProvider>(
          context,
          listen: false,
        );
        locationProvider.addListener(_onLocationChanged);
      });

      context.read<CredentialProvider>().fetchCredentials();

      _currentTopRestaurantsPage = 1;
      _isTopRestaurantsLoadingMore = false;
    } catch (e) {
      debugPrint('Initialization error: $e');
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
        _startAnimations();
      }
      EasyLoading.dismiss();
    }
  }

  void _onLocationChanged() {
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );

    if (locationProvider.hasLocation && !locationProvider.isLoading) {
      if (userId != null) {
        debugPrint("🔄 Location changed — refreshing restaurants...");
        Provider.of<RestaurantProvider>(
          context,
          listen: false,
        ).getNearbyRestaurants(userId!);
        Provider.of<TopRestaurantsProvider>(
          context,
          listen: false,
        ).getTopRestaurants(userId!);

        setState(() {
          _currentTopRestaurantsPage = 1;
          _isTopRestaurantsLoadingMore = false;
        });
      }
    }
  }

  Future<void> _loadUserId() async {
    final user = UserPreferences.getUser();
    if (user != null && mounted) {
      setState(() {
        userId = user.userId;
      });
    }
  }

  Future<void> _handleCurrentLocation() async {
    try {
      final locationProvider = Provider.of<LocationProvider>(
        context,
        listen: false,
      );
      await locationProvider.initLocation(userId.toString());
    } catch (e) {
      debugPrint('Location error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location error: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    _headerController.dispose();
    _searchController.dispose();
    _categoriesController.dispose();
    _bannerController.dispose();
    _nearbyController.dispose();
    _topRestaurantsController.dispose();
    _adsBannerController.dispose();
    _giftAnimationController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedSection({
    required Widget child,
    required Animation<Offset> slideAnimation,
    required Animation<double> fadeAnimation,
  }) {
    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(opacity: fadeAnimation, child: child),
    );
  }

  Widget _buildCategorySkeleton() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);

    return SizedBox(
      height: isDesktop ? 140 : 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: isDesktop ? 8 : (isTablet ? 6 : 5),
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: isDesktop ? 16 : 12),
            child: Column(
              children: [
                Container(
                  width: isDesktop ? 100 : 80,
                  height: isDesktop ? 100 : 80,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? Colors.grey[400]! : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 60,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRestaurantSkeleton() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);

    return SizedBox(
      height: isDesktop ? 300 : 270,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: isDesktop ? 4 : (isTablet ? 3 : 2),
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(right: isDesktop ? 16 : 12),
            width: isDesktop ? 220 : 176,
            decoration: BoxDecoration(
              color: isDark ? theme.cardColor : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(isDark ? 0.3 : 0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: isDesktop ? 140 : 120,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDark ? Colors.grey[400]! : Colors.grey,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 18,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[700] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.grey[700]
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 30,
                            height: 16,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.grey[700]
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 100,
                        height: 12,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[700] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVerticalRestaurantSkeleton() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);

    // For desktop/tablet, use grid layout
    if (isDesktop || isTablet) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 3 : 2,
          childAspectRatio: isDesktop ? 1.2 : 1.1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: isDark ? theme.cardColor : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(isDark ? 0.3 : 0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[700] : Colors.grey[300],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? Colors.grey[400]! : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 16,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[700] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 14,
                          width: 100,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[700] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    // Mobile layout (list)
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? theme.cardColor : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(isDark ? 0.3 : 0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? Colors.grey[400]! : Colors.grey,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: 120,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[700] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 14,
                        width: 160,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[700] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBannerSkeleton() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDesktop = Responsive.isDesktop(context);

    return Container(
      height: isDesktop ? 180 : 140,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[700] : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            isDark ? Colors.grey[400]! : Colors.grey,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;

    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final isDesktop = Responsive.isDesktop(context);

    // Responsive padding and max width
    // final horizontalPadding = Responsive.spacing(
    //   context,
    //   mobile: 16.0,
    //   tablet: 32.0,
    //   desktop: 48.0,
    // );

    final horizontalPadding = Responsive.spacing(
      context,
      mobile: 16.0,
      tablet: 32.0,
      desktop: 64.0, // Increased for desktop
    );

    // final maxContentWidth = Responsive.value(
    //   context,
    //   mobile: double.infinity,
    //   tablet: 900.0,
    //   desktop: double.infinity,
    // );

    final maxContentWidth = Responsive.value(
      context,
      mobile: double.infinity,
      tablet: 900.0,
      desktop: 1200.0, // 👈 limit width for web
    );

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SafeArea(
                  top: true,
                  child: RefreshIndicator(
                    onRefresh: () async {
                      _headerController.reset();
                      _searchController.reset();
                      _categoriesController.reset();
                      _bannerController.reset();
                      _nearbyController.reset();
                      _topRestaurantsController.reset();

                      await _initializeData();
                    },
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Center(
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: maxContentWidth,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: isDesktop ? 20 : 10),

                              // Header
                              _isInitializing
                                  ? Container(
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Colors.grey[700]
                                            : Colors.grey[300],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    )
                                  : _buildAnimatedSection(
                                      slideAnimation: _headerSlideAnimation,
                                      fadeAnimation: _headerFadeAnimation,
                                      child: HomeHeader(
                                        userId: userId ?? 'unknown',
                                        onLocationTap: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  LocationPickerScreen(
                                                    isEditing: false,
                                                    userId: userId.toString(),
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                              SizedBox(height: isDesktop ? 24 : 16),

                              // Search Bar
                              _isInitializing
                                  ? Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Colors.grey[700]
                                            : Colors.grey[300],
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    )
                                  : Opacity(
                                      opacity: _isSearchBarPinned ? 0.0 : 1.0,
                                      child: _buildAnimatedSection(
                                        slideAnimation: _searchSlideAnimation,
                                        fadeAnimation: _searchFadeAnimation,
                                        child: Container(
                                          key: _searchBarKey,
                                          child: const SearchBarWithVoice(),
                                        ),
                                      ),
                                    ),

                              SizedBox(height: isDesktop ? 32 : 16),

                              // Categories Section
                              Column(
                                children: [
                                  SectionHeader(
                                    title: 'Categories',
                                    onSeeAll: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => CategoryScreen(
                                            userId: userId.toString(),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: isDesktop ? 16 : 10),
                                  _isInitializing
                                      ? _buildCategorySkeleton()
                                      : _buildAnimatedSection(
                                          slideAnimation:
                                              _categoriesSlideAnimation,
                                          fadeAnimation:
                                              _categoriesFadeAnimation,
                                          child: _buildCategories(),
                                        ),
                                ],
                              ),

                              SizedBox(height: isDesktop ? 32 : 16),

                              // Banner
                              _isInitializing
                                  ? _buildBannerSkeleton()
                                  : _buildAnimatedSection(
                                      slideAnimation: _bannerSlideAnimation,
                                      fadeAnimation: _bannerFadeAnimation,
                                      child: const PromoBanner(),
                                    ),

                              SizedBox(height: isDesktop ? 32 : 16),

                              // Nearby Restaurants Section
                              Column(
                                children: [
                                  SectionHeader(
                                    title: 'Nearby restaurants',
                                    onSeeAll: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => NearbyScreen(
                                            userId: userId.toString(),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: isDesktop ? 16 : 10),
                                  _isInitializing
                                      ? _buildRestaurantSkeleton()
                                      : _buildAnimatedSection(
                                          slideAnimation: _nearbySlideAnimation,
                                          fadeAnimation: _nearbyFadeAnimation,
                                          child: _buildRestaurantList(),
                                        ),
                                ],
                              ),

                              SizedBox(height: isDesktop ? 32 : 16),

                              // Popular Restaurants Section
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SectionHeader(
                                    title: 'Popular Restaurants',
                                    onSeeAll: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => TopRestaurantsScreen(
                                            userId: userId.toString(),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: isDesktop ? 16 : 10),
                                  _isInitializing
                                      ? _buildVerticalRestaurantSkeleton()
                                      : _buildAnimatedSection(
                                          slideAnimation:
                                              _topRestaurantsSlideAnimation,
                                          fadeAnimation:
                                              _topRestaurantsFadeAnimation,
                                          child: _buildTopRestaurants(),
                                        ),
                                ],
                              ),

                              SizedBox(height: isDesktop ? 40 : 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Sticky Search Bar
          if (!_isInitializing && _isSearchBarPinned)
            Positioned(
              top: topPadding + 8,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(15),
                    color: theme.cardColor,
                    child: const SearchBarWithVoice(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);

    return Consumer<CategoryProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return _buildCategorySkeleton();
        }
        if (provider.categories.isEmpty) {
          final theme = Theme.of(context);
          return SizedBox(
            height: 120,
            child: Center(
              child: Text(
                'No categories available',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          );
        }
        return SizedBox(
          height: isDesktop ? 140 : 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: provider.categories.length,
            itemBuilder: (context, index) {
              final category = provider.categories[index];
              return Padding(
                padding: EdgeInsets.only(right: isDesktop ? 16 : 12),
                child: CategoryCard(
                  id: category.id,
                  imagePath: category.imageUrl,
                  title: category.categoryName,
                  userId: userId.toString(),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildRestaurantList() {
    final theme = Theme.of(context);
    final isDesktop = Responsive.isDesktop(context);

    return Consumer<RestaurantProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return _buildRestaurantSkeleton();
        }

        if (provider.nearbyRestaurants.isEmpty) {
          return SizedBox(
            height: 240,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  'https://cdn.dribbble.com/users/107759/screenshots/16839013/media/87e30b30c8d92a4b1826c74e6e0ee938.png',
                  height: 160,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.restaurant_menu,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No restaurants nearby',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Looks like there aren\'t any restaurants around your location.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          );
        }

        return SizedBox(
          height: Responsive.value(
            context,
            mobile: 200,
            tablet: 260,
            desktop: 320,
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: provider.nearbyRestaurants.length,
            itemBuilder: (context, index) {
              final restaurant = provider.nearbyRestaurants[index];
              return SizedBox(
                width: Responsive.value(
                  context,
                  mobile: 220,
                  tablet: 260,
                  desktop: 300,
                ),
                child: RestaurantCard(
                  id: restaurant.id,
                  imagePath: restaurant.imageUrl,
                  name: restaurant.restaurantName,
                  rating: restaurant.rating.toDouble(),
                  description: restaurant.description,
                  price: restaurant.startingPrice,
                  locationName: restaurant.locationName,
                  status: restaurant.status,
                ),
              );
            },
          ),
        );

        // return SizedBox(
        //   height: isDesktop ? 300 : 200,
        //   child: ListView.builder(
        //     scrollDirection: Axis.horizontal,
        //     itemCount: provider.nearbyRestaurants.length,
        //     itemBuilder: (context, index) {
        //       final restaurant = provider.nearbyRestaurants[index];
        //       return RestaurantCard(
        //         id: restaurant.id,
        //         imagePath: restaurant.imageUrl,
        //         name: restaurant.restaurantName,
        //         rating: restaurant.rating.toDouble(),
        //         description: restaurant.description,
        //         price: restaurant.startingPrice,
        //         locationName: restaurant.locationName,
        //         status: restaurant.status,
        //       );
        //     },
        //   ),
        // );
      },
    );
  }

  Widget _buildTopRestaurants() {
    final theme = Theme.of(context);
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);

    return Consumer<TopRestaurantsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return _buildVerticalRestaurantSkeleton();
        }

        if (provider.topRestaurants.isEmpty) {
          return SizedBox(
            height: 240,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  'https://cdn.dribbble.com/users/107759/screenshots/16839013/media/87e30b30c8d92a4b1826c74e6e0ee938.png',
                  height: 160,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.restaurant_menu,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No restaurants nearby',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Looks like there aren\'t any restaurants around your location.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          );
        }

        final total = provider.topRestaurants.length;
        final visibleCount = math.min(
          total,
          _currentTopRestaurantsPage * _topRestaurantsPerPage,
        );

        // Desktop/Tablet: Grid layout
        if (isDesktop || isTablet) {
          return Column(
            children: [
              // GridView.builder(
              //   shrinkWrap: true,
              //   physics: const NeverScrollableScrollPhysics(),
              //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              //     crossAxisCount: isDesktop ? 3 : 2,
              //     childAspectRatio: isDesktop ? 1.2 : 1.1,
              //     crossAxisSpacing: 16,
              //     mainAxisSpacing: 16,
              //   ),
              //   itemCount: visibleCount,
              //   itemBuilder: (context, index) {
              //     final restaurant = provider.topRestaurants[index];
              //     return TicketRestaurantCard(
              //       id: restaurant.id,
              //       imagePath: restaurant.imageUrl,
              //       name: restaurant.restaurantName,
              //       rating: restaurant.rating.toDouble(),
              //       description: restaurant.description,
              //       price: restaurant.startingPrice,
              //       locationName: restaurant.locationName,
              //       status: restaurant.status,
              //     );
              //   },
              // ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final crossAxisCount = _getGridCount(width);

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: width >= 1100 ? 1.25 : 1.1,
                    ),
                    itemCount: visibleCount,
                    itemBuilder: (context, index) {
                      final restaurant = provider.topRestaurants[index];
                      return TicketRestaurantCard(
                        id: restaurant.id,
                        imagePath: restaurant.imageUrl,
                        name: restaurant.restaurantName,
                        rating: restaurant.rating.toDouble(),
                        description: restaurant.description,
                        price: restaurant.startingPrice,
                        locationName: restaurant.locationName,
                        status: restaurant.status,
                      );
                    },
                  );
                },
              ),

              if (_isTopRestaurantsLoadingMore && _canLoadMoreTopRestaurants)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: SizedBox(
                      height: 28,
                      width: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }

        // Mobile: List layout
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visibleCount + 1,
          itemBuilder: (context, index) {
            if (index < visibleCount) {
              final restaurant = provider.topRestaurants[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TicketRestaurantCard(
                  id: restaurant.id,
                  imagePath: restaurant.imageUrl,
                  name: restaurant.restaurantName,
                  rating: restaurant.rating.toDouble(),
                  description: restaurant.description,
                  price: restaurant.startingPrice,
                  locationName: restaurant.locationName,
                  status: restaurant.status,
                ),
              );
            } else {
              if (_isTopRestaurantsLoadingMore && _canLoadMoreTopRestaurants) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: SizedBox(
                      height: 28,
                      width: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                );
              } else if (_canLoadMoreTopRestaurants) {
                return const SizedBox(height: 16);
              } else {
                return const SizedBox.shrink();
              }
            }
          },
        );
      },
    );
  }
}
