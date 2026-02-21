import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
import 'package:veegify/widgets/footer.dart';
import 'package:veegify/widgets/home/app_download.dart';
import 'package:veegify/widgets/home/banner.dart';
import 'package:veegify/widgets/home/category_card.dart';
import 'package:veegify/widgets/home/category_list.dart';
import 'package:veegify/widgets/home/header.dart';
import 'package:veegify/widgets/home/hero.dart';
import 'package:veegify/widgets/home/nearby_restaurant.dart';
import 'package:veegify/widgets/home/search.dart';
import 'package:veegify/widgets/home/section_header.dart';
import 'package:veegify/widgets/home/top_restaurants.dart';
import 'dart:math' as math;

import 'package:veegify/widgets/home/video.dart';
import 'package:carousel_slider/carousel_slider.dart';

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
  int _currentIndex = 0;

  int _getGridCount(double width) {
    if (width >= 1400) return 4;
    if (width >= 1100) return 3;
    if (width >= 800) return 2;
    return 1;
  }

  // Scroll controller and banner visibility
  // late ScrollController _scrollController;
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
  final int _topRestaurantsPerPage = 6;
  int _currentTopRestaurantsPage = 1;
  bool _isTopRestaurantsLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeData();
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

  Future<void> _handleRefresh() async {
    try {
      // Reset all animations
      _headerController.reset();
      _searchController.reset();
      _categoriesController.reset();
      _bannerController.reset();
      _nearbyController.reset();
      _topRestaurantsController.reset();

      // Set loading state
      setState(() {
        _isInitializing = true;
      });

      // Refresh data
      await _loadUserId();
      await _handleCurrentLocation();

      // Fetch all data
      await Future.wait([
        Provider.of<CategoryProvider>(context, listen: false).fetchCategories(),
        Provider.of<RestaurantProvider>(context, listen: false)
            .getNearbyRestaurants(userId.toString()),
        Provider.of<TopRestaurantsProvider>(context, listen: false)
            .getTopRestaurants(userId.toString()),
        Provider.of<BannerProvider>(context, listen: false).fetchBanners(),
        Provider.of<CredentialProvider>(context, listen: false)
            .fetchCredentials(),
      ]);

      // Reset pagination
      setState(() {
        _currentTopRestaurantsPage = 1;
        _isTopRestaurantsLoadingMore = false;
      });
    } catch (e) {
      debugPrint('Refresh error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
        // Start animations after data is loaded
        _startAnimations();
      }
    }
  }

  Future<void> _initializeData() async {
    try {
      EasyLoading.show(status: 'Loading...');

      await _loadUserId();
      // await _handleCurrentLocation();
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
        _startDesktopBannerAutoScroll();
      });

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

  void _startDesktopBannerAutoScroll() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 4));
      if (!mounted) return false;

      final banners = context.read<BannerProvider>().banners;
      if (banners.isEmpty) return true;

      setState(() {
        _currentIndex = (_currentIndex + 1) % banners.length;
      });

      return true;
    });
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
                              color:
                                  isDark ? Colors.grey[700] : Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 30,
                            height: 16,
                            decoration: BoxDecoration(
                              color:
                                  isDark ? Colors.grey[700] : Colors.grey[300],
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
      height: isDesktop ? 400 : 180,
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

  // Build static promotional banners (like the reference image)
  Widget _buildStaticPromoBanners() {
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);

    final image1 = _buildImageCard('assets/images/login_bg.png');
    final image2 = _buildImageCard('assets/images/login_bg.png');

    // Mobile → vertical
    if (!isDesktop && !isTablet) {
      return Column(
        children: [
          image1,
          const SizedBox(height: 16),
          image2,
        ],
      );
    }

    // Tablet / Desktop → side by side
    return Row(
      children: [
        Expanded(child: image1),
        const SizedBox(width: 16),
        Expanded(child: image2),
      ],
    );
  }

  Widget _buildImageCard(String imagePath) {
    final isDesktop = Responsive.isDesktop(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        imagePath,
        height: isDesktop ? 340 : 180,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: isDesktop ? 280 : 180,
            color: Colors.grey.shade200,
            child: const Icon(
              Icons.broken_image_outlined,
              size: 60,
              color: Colors.grey,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPromoCard({
    required Color backgroundColor,
    required String title,
    required String subtitle,
    required String imagePath,
    required Color accentColor,
  }) {
    final isDesktop = Responsive.isDesktop(context);

    return Container(
      height: isDesktop ? 280 : 180,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Text content
          Positioned(
            left: isDesktop ? 40 : 20,
            top: isDesktop ? 40 : 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: isDesktop ? 14 : 12,
                      fontWeight: FontWeight.w600,
                      color: accentColor.withOpacity(0.8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isDesktop ? 28 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: isDesktop ? 20 : 12),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to category or products
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 28 : 20,
                      vertical: isDesktop ? 14 : 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'Shop Now',
                    style: TextStyle(
                      fontSize: isDesktop ? 16 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Image
          Positioned(
            right: 0,
            bottom: 0,
            child: Image.asset(
              imagePath,
              height: isDesktop ? 240 : 140,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback if image not found
                return Container(
                  height: isDesktop ? 240 : 140,
                  width: isDesktop ? 240 : 140,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.shopping_basket,
                    size: isDesktop ? 80 : 50,
                    color: accentColor,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;
    final screenWidth = MediaQuery.of(context).size.width;

    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final isDesktop = Responsive.isDesktop(context);

    // WEB-SPECIFIC: Better responsive padding
    final horizontalPadding = kIsWeb && screenWidth > 1024
        ? (screenWidth > 1400 ? 60.0 : 40.0)
        : Responsive.spacing(
            context,
            mobile: 8.0,
            tablet: 32.0,
            desktop: 64.0,
          );

    // WEB-SPECIFIC: Limit max width for better readability
    final maxContentWidth =
        kIsWeb && screenWidth > 1024 ? double.infinity : double.infinity;

    // Use web layout only for desktop/tablet
    final useWebLayout = isDesktop || isTablet;

    return Scaffold(
      backgroundColor:
          isDark ? Colors.black : const Color.fromARGB(255, 255, 255, 255),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SafeArea(
                  top: false,
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
                    child: RefreshIndicator(
                      onRefresh: _handleRefresh,
                      child: SingleChildScrollView(
                        child: useWebLayout
                            ? _buildWebLayout(
                                theme: theme,
                                isDark: isDark,
                                isDesktop: isDesktop,
                                horizontalPadding: horizontalPadding,
                                maxContentWidth: maxContentWidth,
                              )
                            : _buildMobileLayout(
                                theme: theme,
                                isDark: isDark,
                                isDesktop: isDesktop,
                                horizontalPadding: horizontalPadding,
                                maxContentWidth: maxContentWidth,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Sticky Search Bar (Mobile only)
          if (!_isInitializing && _isSearchBarPinned && !useWebLayout)
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

  // Original mobile layout - unchanged
  // Widget _buildMobileLayout({
  //   required ThemeData theme,
  //   required bool isDark,
  //   required bool isDesktop,
  //   required double horizontalPadding,
  //   required double maxContentWidth,
  // }) {
  //   return Center(
  //     child: Container(
  //       constraints: BoxConstraints(
  //         maxWidth: maxContentWidth,
  //       ),
  //       padding: EdgeInsets.symmetric(
  //         horizontal: horizontalPadding,
  //       ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           SizedBox(height: isDesktop ? 20 : 10),

  //           // Header
  //           _isInitializing
  //               ? Container(
  //                   height: 60,
  //                   decoration: BoxDecoration(
  //                     color: isDark
  //                         ? Colors.grey[700]
  //                         : Colors.grey[300],
  //                     borderRadius: BorderRadius.circular(8),
  //                   ),
  //                 )
  //               : _buildAnimatedSection(
  //                   slideAnimation: _headerSlideAnimation,
  //                   fadeAnimation: _headerFadeAnimation,
  //                   child: HomeHeader(
  //                     userId: userId ?? 'unknown',
  //                     onLocationTap: () async {
  //                       await Navigator.push(
  //                         context,
  //                         MaterialPageRoute(
  //                           builder: (_) =>
  //                               LocationPickerScreen(
  //                             isEditing: false,
  //                             userId: userId.toString(),
  //                           ),
  //                         ),
  //                       );
  //                     },
  //                   ),
  //                 ),

  //           SizedBox(height: isDesktop ? 24 : 16),

  //           // Search Bar
  //           _isInitializing
  //               ? Container(
  //                   height: 50,
  //                   decoration: BoxDecoration(
  //                     color: isDark
  //                         ? Colors.grey[700]
  //                         : Colors.grey[300],
  //                     borderRadius: BorderRadius.circular(15),
  //                   ),
  //                 )
  //               : Opacity(
  //                   opacity: _isSearchBarPinned ? 0.0 : 1.0,
  //                   child: _buildAnimatedSection(
  //                     slideAnimation: _searchSlideAnimation,
  //                     fadeAnimation: _searchFadeAnimation,
  //                     child: Container(
  //                       key: _searchBarKey,
  //                       child: const SearchBarWithVoice(),
  //                     ),
  //                   ),
  //                 ),

  //           SizedBox(height: isDesktop ? 32 : 16),

  //           // Categories Section
  //           Column(
  //             children: [
  //               SectionHeader(
  //                 title: 'Categories',
  //                 onSeeAll: () {
  //                   Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                       builder: (_) => CategoryScreen(
  //                         userId: userId.toString(),
  //                       ),
  //                     ),
  //                   );
  //                 },
  //               ),
  //               SizedBox(height: isDesktop ? 16 : 10),
  //               _isInitializing
  //                   ? _buildCategorySkeleton()
  //                   : _buildAnimatedSection(
  //                       slideAnimation:
  //                           _categoriesSlideAnimation,
  //                       fadeAnimation:
  //                           _categoriesFadeAnimation,
  //                       child: _buildCategories(),
  //                     ),
  //             ],
  //           ),

  //           SizedBox(height: isDesktop ? 32 : 16),

  //           // Banner
  //           _isInitializing
  //               ? _buildBannerSkeleton()
  //               : _buildAnimatedSection(
  //                   slideAnimation: _bannerSlideAnimation,
  //                   fadeAnimation: _bannerFadeAnimation,
  //                   child: const PromoBanner(),
  //                 ),

  //           SizedBox(height: isDesktop ? 32 : 16),

  //           // Nearby Restaurants Section
  //           Column(
  //             children: [
  //               SectionHeader(
  //                 title: 'Nearby restaurants',
  //                 onSeeAll: () {
  //                   Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                       builder: (_) => NearbyScreen(
  //                         userId: userId.toString(),
  //                       ),
  //                     ),
  //                   );
  //                 },
  //               ),
  //               SizedBox(height: isDesktop ? 16 : 10),
  //               _isInitializing
  //                   ? _buildRestaurantSkeleton()
  //                   : _buildAnimatedSection(
  //                       slideAnimation: _nearbySlideAnimation,
  //                       fadeAnimation: _nearbyFadeAnimation,
  //                       child: _buildRestaurantList(),
  //                     ),
  //             ],
  //           ),

  //           SizedBox(height: isDesktop ? 32 : 16),

  //           // Popular Restaurants Section
  //           Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               SectionHeader(
  //                 title: 'Popular Restaurants',
  //                 onSeeAll: () {
  //                   Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                       builder: (_) => TopRestaurantsScreen(
  //                         userId: userId.toString(),
  //                       ),
  //                     ),
  //                   );
  //                 },
  //               ),
  //               SizedBox(height: isDesktop ? 16 : 10),
  //               _isInitializing
  //                   ? _buildVerticalRestaurantSkeleton()
  //                   : _buildAnimatedSection(
  //                       slideAnimation:
  //                           _topRestaurantsSlideAnimation,
  //                       fadeAnimation:
  //                           _topRestaurantsFadeAnimation,
  //                       child: _buildTopRestaurants(),
  //                     ),
  //             ],
  //           ),

  //           SizedBox(height: isDesktop ? 40 : 20),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildMobileLayout({
    required ThemeData theme,
    required bool isDark,
    required bool isDesktop,
    required double horizontalPadding,
    required double maxContentWidth,
  }) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔥 TOP STACK SECTION (Banner + Header + Search)
            _isInitializing
                ? _buildBannerSkeleton()
                : SizedBox(
                    height: 270, // 240 banner + 30 overlap space
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        /// Banner Background
                        SizedBox(
                          height: 240,
                          width: double.infinity,
                          child: Consumer<BannerProvider>(
                            builder: (context, bannerProvider, _) {
                              if (bannerProvider.isLoading ||
                                  bannerProvider.banners.isEmpty) {
                                return Container(
                                  color: Colors.grey[300],
                                );
                              }

                              return CarouselSlider(
                                items: bannerProvider.banners.map((banner) {
                                  return Image.network(
                                    banner.imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  );
                                }).toList(),
                                options: CarouselOptions(
                                  height: 240,
                                  viewportFraction: 1.0,
                                  autoPlay: true,
                                ),
                              );
                            },
                          ),
                        ),

                        /// Gradient Overlay
                        Container(
                          height: 240,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.55),
                                Colors.black.withOpacity(0.25),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),

                        /// Header (Only header stays inside image)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: 24,
                          ),
                          child: HomeHeader(
                            userId: userId ?? 'unknown',
                            onLocationTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LocationPickerScreen(
                                    isEditing: false,
                                    userId: userId.toString(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        /// 🔥 SEARCH BAR HALF OVERLAP
                        Positioned(
                          bottom: -4, // move half outside
                          left: horizontalPadding,
                          right: horizontalPadding,
                          child: Container(
                            key: _searchBarKey,
                            child: const SearchBarWithVoice(),
                          ),
                        ),
                      ],
                    ),
                  ),

            const SizedBox(height: 24),

            /// 🔥 Categories Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                children: [
                  _isInitializing
                      ? _buildCategorySkeleton()
                      : _buildCategories(),
                ],
              ),
            ),

            /// 🔥 Nearby Restaurants
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
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
                  _isInitializing
                      ? _buildRestaurantSkeleton()
                      : _buildRestaurantList(),
                ],
              ),
            ),

            /// 🔥 Popular Restaurants
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
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
                  _isInitializing
                      ? _buildVerticalRestaurantSkeleton()
                      : _buildTopRestaurants(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // New web layout
  Widget _buildWebLayout({
    required ThemeData theme,
    required bool isDark,
    required bool isDesktop,
    required double horizontalPadding,
    required double maxContentWidth,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section with full-width banner
        _isInitializing
            ? _buildBannerSkeleton()
            : _buildAnimatedSection(
                slideAnimation: _headerSlideAnimation,
                fadeAnimation: _headerFadeAnimation,
                child: // In your _buildWebLayout method, call it like this:
                    buildHeroSection(
                  context: context,
                  userId: userId,
                  currentIndex: _currentIndex,
                  searchBarKey: _searchBarKey,
                ),
              ),

              SizedBox(height: 30,),

        // Main content with constrained width
        Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: maxContentWidth,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SizedBox(height: isDesktop ? 60 : 30),

                // Categories Section
                _buildAnimatedSection(
                  slideAnimation: _categoriesSlideAnimation,
                  fadeAnimation: _categoriesFadeAnimation,
                  child: Column(
                    children: [
                      // Text(
                      //   'Categories',
                      //   style: theme.textTheme.headlineSmall?.copyWith(
                      //     fontWeight: FontWeight.bold,
                      //     fontSize: isDesktop ? 22 : 16,
                      //   ),
                      //   textAlign: TextAlign.center,
                      // ),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Featured ',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: isDesktop ? 32 : 24,
                                color: Colors.black, // or theme color
                              ),
                            ),
                            TextSpan(
                              text: 'Categories',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: isDesktop ? 32 : 24,
                                color: Colors.green, // match the image
                              ),
                            ),
                          ],
                        ),
                      ),
                      // SizedBox(height: isDesktop ? 30 : 20),
                      _isInitializing
                          ? _buildCategorySkeleton()
                          : _buildCategories(),
                    ],
                  ),
                ),

                // SizedBox(height: isDesktop ? 60 : 0),

                // Static Promotional Banners
                // _buildAnimatedSection(
                //   slideAnimation: _bannerSlideAnimation,
                //   fadeAnimation: _bannerFadeAnimation,
                //   child: _buildStaticPromoBanners(),
                // ),

                // SizedBox(height: isDesktop ? 60 : 0),

                // Nearby Restaurants Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: 'Nearby Restaurants',
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
                    // SizedBox(height: isDesktop ? 24 : 8),
                    _isInitializing
                        ? _buildRestaurantSkeleton()
                        : _buildAnimatedSection(
                            slideAnimation: _nearbySlideAnimation,
                            fadeAnimation: _nearbyFadeAnimation,
                            child: _buildRestaurantList(),
                          ),
                  ],
                ),

                // SizedBox(height: isDesktop ? 60 : 0),

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
                    // SizedBox(height: isDesktop ? 24 : 6),
                    _isInitializing
                        ? _buildVerticalRestaurantSkeleton()
                        : _buildAnimatedSection(
                            slideAnimation: _topRestaurantsSlideAnimation,
                            fadeAnimation: _topRestaurantsFadeAnimation,
                            child: _buildTopRestaurants(),
                          ),
                  ],
                ),

                buildAppDownloadSection(theme: ThemeData(), isDesktop: true),

                SizedBox(height: isDesktop ? 80 : 10),

                buildFooterSection(theme: theme, isDesktop: isDesktop),

// SizedBox(height: isDesktop ? 40 : 20),
              ],
            ),
          ),
        ),
      ],
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

        // For desktop/tablet, show grid
        if (isDesktop || isTablet) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 6 : 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.9,
            ),
            itemCount: math.min(provider.categories.length, isDesktop ? 12 : 8),
            itemBuilder: (context, index) {
              final category = provider.categories[index];
              return CategoryList(
                id: category.id,
                imagePath: category.imageUrl,
                title: category.categoryName,
                userId: userId.toString(),
              );
            },
          );
        }

        // Mobile: horizontal scroll
        return SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: provider.categories.length,
            itemBuilder: (context, index) {
              final category = provider.categories[index];
              return Padding(
                padding: EdgeInsets.only(right: 12),
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
    final isWeb = kIsWeb;

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
            mobile: 120,
            tablet: 120,
            desktop: 180,
          ),
          child: isWeb
              ? Scrollbar(
                  thumbVisibility: false,
                  thickness: 0,
                  radius: const Radius.circular(10),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    itemCount: provider.nearbyRestaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = provider.nearbyRestaurants[index];
                      return SizedBox(
                        width: Responsive.value(
                          context,
                          mobile: 300,
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
                          discount: restaurant.discount,
                        ),
                      );
                    },
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: provider.nearbyRestaurants.length,
                  itemBuilder: (context, index) {
                    final restaurant = provider.nearbyRestaurants[index];
                    return SizedBox(
                      width: Responsive.value(
                        context,
                        mobile: 300,
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
                        discount: restaurant.discount,
                      ),
                    );
                  },
                ),
        );
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
            height: 200,
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
                        discount: restaurant.discount,
                      );
                    },
                  );
                },
              ),
              if (_isTopRestaurantsLoadingMore)
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
                  discount: restaurant.discount,
                ),
              );
            } else {
              if (_isTopRestaurantsLoadingMore) {
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



































// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:veegify/helper/storage_helper.dart';
// import 'package:veegify/provider/BannerProvider/banner_provider.dart';
// import 'package:veegify/provider/CategoryProvider/category_provider.dart';
// import 'package:veegify/provider/Credential/credential_provider.dart';
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
// import 'package:veegify/widgets/home/category_card.dart';
// import 'package:veegify/widgets/home/category_list.dart';
// import 'package:veegify/widgets/home/header.dart';
// import 'package:veegify/widgets/home/nearby_restaurant.dart';
// import 'package:veegify/widgets/home/search.dart';
// import 'package:veegify/widgets/home/section_header.dart';
// import 'package:veegify/widgets/home/top_restaurants.dart';
// import 'dart:math' as math;

// import 'package:veegify/widgets/home/video.dart';
// import 'package:carousel_slider/carousel_slider.dart';

// // Main HomeScreen wrapper that accepts scroll controller
// class HomeScreenWithController extends StatelessWidget {
//   final ScrollController scrollController;

//   const HomeScreenWithController({super.key, required this.scrollController});

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
//   int _currentIndex = 0;
  
//   // Location permission state
//   bool _showLocationModal = false;
//   bool _isLocationLoading = false;

//   int _getGridCount(double width) {
//     if (width >= 1400) return 4;
//     if (width >= 1100) return 3;
//     if (width >= 800) return 2;
//     return 1;
//   }

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
//   final int _topRestaurantsPerPage = 6;
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
//     final shouldShow = offset < 50;

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

//     // Infinite scroll for Popular Restaurants
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

//     EasyLoading.show(status: 'Loading more restaurants...');
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

//     _headerSlideAnimation =
//         Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(
//       CurvedAnimation(
//         parent: _headerController,
//         curve: Curves.easeOutCubic,
//       ),
//     );

//     _searchSlideAnimation =
//         Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(
//       CurvedAnimation(
//         parent: _searchController,
//         curve: Curves.easeOutCubic,
//       ),
//     );

//     _categoriesSlideAnimation =
//         Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(
//       CurvedAnimation(
//         parent: _categoriesController,
//         curve: Curves.easeOutCubic,
//       ),
//     );

//     _bannerSlideAnimation =
//         Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
//       CurvedAnimation(
//         parent: _bannerController,
//         curve: Curves.easeOutCubic,
//       ),
//     );

//     _nearbySlideAnimation =
//         Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(
//       CurvedAnimation(
//         parent: _nearbyController,
//         curve: Curves.easeOutCubic,
//       ),
//     );

//     _topRestaurantsSlideAnimation =
//         Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(
//       CurvedAnimation(
//         parent: _topRestaurantsController,
//         curve: Curves.easeOutCubic,
//       ),
//     );

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

//     _adsBannerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _adsBannerController, curve: Curves.easeInOut),
//     );

//     _adsBannerController.forward();

//     _giftAnimationController = AnimationController(
//       duration: const Duration(seconds: 1),
//       vsync: this,
//     );

//     _giftAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _giftAnimationController,
//         curve: Curves.easeInOut,
//       ),
//     );

//     _startGiftAnimation();
//   }

//   void _startGiftAnimation() {
//     _giftAnimationController.repeat();
//   }

//   void _startAnimations() {
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

//   Future<void> _handleRefresh() async {
//     try {
//       // Reset all animations
//       _headerController.reset();
//       _searchController.reset();
//       _categoriesController.reset();
//       _bannerController.reset();
//       _nearbyController.reset();
//       _topRestaurantsController.reset();
      
//       // Set loading state
//       setState(() {
//         _isInitializing = true;
//       });
      
//       // Refresh data
//       await _loadUserId();
      
//       // Fetch all data
//       await Future.wait([
//         Provider.of<CategoryProvider>(context, listen: false).fetchCategories(),
//         Provider.of<BannerProvider>(context, listen: false).fetchBanners(),
//         Provider.of<CredentialProvider>(context, listen: false).fetchCredentials(),
//       ]);
      
//       // Check location permission
//       _checkLocationPermission();
      
//       // Reset pagination
//       setState(() {
//         _currentTopRestaurantsPage = 1;
//         _isTopRestaurantsLoadingMore = false;
//       });
      
//     } catch (e) {
//       debugPrint('Refresh error: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to refresh: ${e.toString()}'),
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isInitializing = false;
//         });
//         // Start animations after data is loaded
//         _startAnimations();
//       }
//     }
//   }

//   Future<void> _initializeData() async {
//     try {
//       EasyLoading.show(status: 'Loading...');

//       // Load user ID first
//       await _loadUserId();
      
//       // Load non-location dependent data (categories, banners)
//       await Future.wait([
//         Provider.of<CategoryProvider>(context, listen: false).fetchCategories(),
//         Provider.of<BannerProvider>(context, listen: false).fetchBanners(),
//         Provider.of<CredentialProvider>(context, listen: false).fetchCredentials(),
//       ]);

//       // Check location permission and show modal if needed
//       _checkLocationPermission();

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _startDesktopBannerAutoScroll();
//       });

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         final locationProvider = Provider.of<LocationProvider>(
//           context,
//           listen: false,
//         );
//         locationProvider.addListener(_onLocationChanged);
//       });

//       _currentTopRestaurantsPage = 1;
//       _isTopRestaurantsLoadingMore = false;
      
//     } catch (e) {
//       debugPrint('Initialization error: $e');
//     } finally {
//       if (mounted) {
//         setState(() => _isInitializing = false);
//         _startAnimations();
//       }
//       EasyLoading.dismiss();
//     }
//   }

//   // Check location permission and show modal if needed
//   void _checkLocationPermission() {
//     final locationProvider = Provider.of<LocationProvider>(
//       context,
//       listen: false,
//     );
    
//     // If location is not available, show the modal
//     if (!locationProvider.hasLocation && !_showLocationModal) {
//       setState(() {
//         _showLocationModal = true;
//       });
//     } else if (locationProvider.hasLocation) {
//       // If location is available, fetch restaurants
//       _fetchRestaurants();
//     }
//   }

//   // Fetch restaurants that depend on location
//   Future<void> _fetchRestaurants() async {
//     if (userId == null) return;
    
//     setState(() {
//       _isLocationLoading = true;
//     });
    
//     try {
//       await Future.wait([
//         Provider.of<RestaurantProvider>(context, listen: false)
//             .getNearbyRestaurants(userId!),
//         Provider.of<TopRestaurantsProvider>(context, listen: false)
//             .getTopRestaurants(userId!),
//       ]);
//     } catch (e) {
//       debugPrint('Error fetching restaurants: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLocationLoading = false;
//         });
//       }
//     }
//   }

//   // Request location permission
//   Future<void> _requestLocationPermission() async {
//     setState(() {
//       _isLocationLoading = true;
//     });
    
//     try {
//       final locationProvider = Provider.of<LocationProvider>(
//         context,
//         listen: false,
//       );
      
//       await locationProvider.initLocation(userId.toString());
      
//       if (locationProvider.hasLocation && mounted) {
//         setState(() {
//           _showLocationModal = false;
//         });
//         _fetchRestaurants();
//       }
//     } catch (e) {
//       debugPrint('Location permission error: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to get location: ${e.toString()}'),
//             backgroundColor: Colors.red,
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLocationLoading = false;
//         });
//       }
//     }
//   }

//   void _startDesktopBannerAutoScroll() {
//     Future.doWhile(() async {
//       await Future.delayed(const Duration(seconds: 4));
//       if (!mounted) return false;

//       final banners = context.read<BannerProvider>().banners;
//       if (banners.isEmpty) return true;

//       setState(() {
//         _currentIndex = (_currentIndex + 1) % banners.length;
//       });

//       return true;
//     });
//   }

//   void _onLocationChanged() {
//     final locationProvider = Provider.of<LocationProvider>(
//       context,
//       listen: false,
//     );

//     if (locationProvider.hasLocation && !locationProvider.isLoading) {
//       if (userId != null) {
//         debugPrint("🔄 Location changed — refreshing restaurants...");
//         Provider.of<RestaurantProvider>(
//           context,
//           listen: false,
//         ).getNearbyRestaurants(userId!);
//         Provider.of<TopRestaurantsProvider>(
//           context,
//           listen: false,
//         ).getTopRestaurants(userId!);

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
//       child: FadeTransition(opacity: fadeAnimation, child: child),
//     );
//   }

//   Widget _buildCategorySkeleton() {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//     final isDesktop = Responsive.isDesktop(context);
//     final isTablet = Responsive.isTablet(context);

//     return SizedBox(
//       height: isDesktop ? 140 : 120,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         physics: const NeverScrollableScrollPhysics(),
//         itemCount: isDesktop ? 8 : (isTablet ? 6 : 5),
//         itemBuilder: (context, index) {
//           return Padding(
//             padding: EdgeInsets.only(right: isDesktop ? 16 : 12),
//             child: Column(
//               children: [
//                 Container(
//                   width: isDesktop ? 100 : 80,
//                   height: isDesktop ? 100 : 80,
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
//     final isDesktop = Responsive.isDesktop(context);
//     final isTablet = Responsive.isTablet(context);

//     return SizedBox(
//       height: isDesktop ? 300 : 270,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         physics: const NeverScrollableScrollPhysics(),
//         itemCount: isDesktop ? 4 : (isTablet ? 3 : 2),
//         itemBuilder: (context, index) {
//           return Container(
//             margin: EdgeInsets.only(right: isDesktop ? 16 : 12),
//             width: isDesktop ? 220 : 176,
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
//                   height: isDesktop ? 140 : 120,
//                   decoration: BoxDecoration(
//                     color: isDark ? Colors.grey[700] : Colors.grey[300],
//                     borderRadius: const BorderRadius.vertical(
//                       top: Radius.circular(12),
//                     ),
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
//                           color: isDark ? Colors.grey[700] : Colors.grey[300],
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
//                               color:
//                                   isDark ? Colors.grey[700] : Colors.grey[300],
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                           const SizedBox(width: 4),
//                           Container(
//                             width: 30,
//                             height: 16,
//                             decoration: BoxDecoration(
//                               color:
//                                   isDark ? Colors.grey[700] : Colors.grey[300],
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
//                           color: isDark ? Colors.grey[700] : Colors.grey[300],
//                           borderRadius: BorderRadius.circular(4),
//                         ),
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

//   Widget _buildVerticalRestaurantSkeleton() {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//     final isDesktop = Responsive.isDesktop(context);
//     final isTablet = Responsive.isTablet(context);

//     // For desktop/tablet, use grid layout
//     if (isDesktop || isTablet) {
//       return GridView.builder(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: isDesktop ? 3 : 2,
//           childAspectRatio: isDesktop ? 1.2 : 1.1,
//           crossAxisSpacing: 16,
//           mainAxisSpacing: 16,
//         ),
//         itemCount: 6,
//         itemBuilder: (context, index) {
//           return Container(
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
//                 Expanded(
//                   flex: 3,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: isDark ? Colors.grey[700] : Colors.grey[300],
//                       borderRadius: const BorderRadius.vertical(
//                         top: Radius.circular(12),
//                       ),
//                     ),
//                     child: Center(
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         valueColor: AlwaysStoppedAnimation<Color>(
//                           isDark ? Colors.grey[400]! : Colors.grey,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   flex: 2,
//                   child: Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           height: 16,
//                           width: double.infinity,
//                           decoration: BoxDecoration(
//                             color: isDark ? Colors.grey[700] : Colors.grey[300],
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Container(
//                           height: 14,
//                           width: 100,
//                           decoration: BoxDecoration(
//                             color: isDark ? Colors.grey[700] : Colors.grey[300],
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     }

//     // Mobile layout (list)
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
//                           color: isDark ? Colors.grey[700] : Colors.grey[300],
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Container(
//                         height: 14,
//                         width: 160,
//                         decoration: BoxDecoration(
//                           color: isDark ? Colors.grey[700] : Colors.grey[300],
//                           borderRadius: BorderRadius.circular(4),
//                         ),
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
//     final isDesktop = Responsive.isDesktop(context);

//     return Container(
//       height: isDesktop ? 400 : 180,
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

//   // Location Permission Modal - Non-dismissible
//   Widget _buildLocationPermissionModal() {
//     final theme = Theme.of(context);
//     final isDesktop = Responsive.isDesktop(context);
    
//     return PopScope(
//       canPop: false, // Prevent back button from closing
//       child: Material(
//         color: Colors.transparent,
//         child: Container(
//           color: Colors.black.withOpacity(0.7),
//           child: Center(
//             child: Container(
//               width: isDesktop ? 400 : double.infinity,
//               margin: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : 24),
//               decoration: BoxDecoration(
//                 color: theme.cardColor,
//                 borderRadius: BorderRadius.circular(24),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.3),
//                     blurRadius: 20,
//                     offset: const Offset(0, 10),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Top colored bar
//                   Container(
//                     height: 8,
//                     decoration: BoxDecoration(
//                       color: Colors.orange,
//                       borderRadius: const BorderRadius.vertical(
//                         top: Radius.circular(24),
//                       ),
//                     ),
//                   ),
                  
//                   Padding(
//                     padding: const EdgeInsets.all(24),
//                     child: Column(
//                       children: [
//                         // Location icon with red dot
//                         Stack(
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(20),
//                               decoration: BoxDecoration(
//                                 color: Colors.orange.withOpacity(0.1),
//                                 shape: BoxShape.circle,
//                               ),
//                               child: Icon(
//                                 Icons.location_on,
//                                 size: 48,
//                                 color: Colors.orange,
//                               ),
//                             ),
//                             Positioned(
//                               top: 12,
//                               right: 12,
//                               child: Container(
//                                 width: 16,
//                                 height: 16,
//                                 decoration: const BoxDecoration(
//                                   color: Colors.red,
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: const Center(
//                                   child: Icon(
//                                     Icons.close,
//                                     color: Colors.white,
//                                     size: 10,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
                        
//                         const SizedBox(height: 20),
                        
//                         // Title
//                         const Text(
//                           "Location Permission is Off",
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
                        
//                         const SizedBox(height: 12),
                        
//                         // Description
//                         Text(
//                           "Getting location permission will create occasional outages and hassle for delivery",
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: theme.colorScheme.onSurface.withOpacity(0.7),
//                             height: 1.5,
//                           ),
//                         ),
                        
//                         const SizedBox(height: 24),
                        
//                         // Grant button
//                         SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton(
//                             onPressed: _isLocationLoading ? null : _requestLocationPermission,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.orange,
//                               foregroundColor: Colors.white,
//                               padding: const EdgeInsets.symmetric(vertical: 16),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(30),
//                               ),
//                             ),
//                             child: _isLocationLoading
//                                 ? const SizedBox(
//                                     width: 20,
//                                     height: 20,
//                                     child: CircularProgressIndicator(
//                                       strokeWidth: 2,
//                                       color: Colors.white,
//                                     ),
//                                   )
//                                 : const Text(
//                                     "GRANT",
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                       letterSpacing: 1,
//                                     ),
//                                   ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Build static promotional banners (like the reference image)
//   Widget _buildStaticPromoBanners() {
//     final isDesktop = Responsive.isDesktop(context);
//     final isTablet = Responsive.isTablet(context);

//     final image1 = _buildImageCard('assets/images/login_bg.png');
//     final image2 = _buildImageCard('assets/images/login_bg.png');

//     // Mobile → vertical
//     if (!isDesktop && !isTablet) {
//       return Column(
//         children: [
//           image1,
//           const SizedBox(height: 16),
//           image2,
//         ],
//       );
//     }

//     // Tablet / Desktop → side by side
//     return Row(
//       children: [
//         Expanded(child: image1),
//         const SizedBox(width: 16),
//         Expanded(child: image2),
//       ],
//     );
//   }

//   Widget _buildImageCard(String imagePath) {
//     final isDesktop = Responsive.isDesktop(context);

//     return ClipRRect(
//       borderRadius: BorderRadius.circular(16),
//       child: Image.asset(
//         imagePath,
//         height: isDesktop ? 340 : 180,
//         fit: BoxFit.cover,
//         errorBuilder: (context, error, stackTrace) {
//           return Container(
//             height: isDesktop ? 280 : 180,
//             color: Colors.grey.shade200,
//             child: const Icon(
//               Icons.broken_image_outlined,
//               size: 60,
//               color: Colors.grey,
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildPromoCard({
//     required Color backgroundColor,
//     required String title,
//     required String subtitle,
//     required String imagePath,
//     required Color accentColor,
//   }) {
//     final isDesktop = Responsive.isDesktop(context);

//     return Container(
//       height: isDesktop ? 280 : 180,
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Stack(
//         children: [
//           // Text content
//           Positioned(
//             left: isDesktop ? 40 : 20,
//             top: isDesktop ? 40 : 20,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: accentColor.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     subtitle,
//                     style: TextStyle(
//                       fontSize: isDesktop ? 14 : 12,
//                       fontWeight: FontWeight.w600,
//                       color: accentColor.withOpacity(0.8),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: isDesktop ? 28 : 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                     height: 1.2,
//                   ),
//                 ),
//                 SizedBox(height: isDesktop ? 20 : 12),
//                 ElevatedButton(
//                   onPressed: () {
//                     // Navigate to category or products
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: accentColor,
//                     foregroundColor: Colors.white,
//                     padding: EdgeInsets.symmetric(
//                       horizontal: isDesktop ? 28 : 20,
//                       vertical: isDesktop ? 14 : 10,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(25),
//                     ),
//                   ),
//                   child: Text(
//                     'Shop Now',
//                     style: TextStyle(
//                       fontSize: isDesktop ? 16 : 14,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Image
//           Positioned(
//             right: 0,
//             bottom: 0,
//             child: Image.asset(
//               imagePath,
//               height: isDesktop ? 240 : 140,
//               fit: BoxFit.contain,
//               errorBuilder: (context, error, stackTrace) {
//                 // Fallback if image not found
//                 return Container(
//                   height: isDesktop ? 240 : 140,
//                   width: isDesktop ? 240 : 140,
//                   decoration: BoxDecoration(
//                     color: accentColor.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Icon(
//                     Icons.shopping_basket,
//                     size: isDesktop ? 80 : 50,
//                     color: accentColor,
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//     final topPadding = MediaQuery.of(context).padding.top;
//     final screenWidth = MediaQuery.of(context).size.width;

//     final isMobile = Responsive.isMobile(context);
//     final isTablet = Responsive.isTablet(context);
//     final isDesktop = Responsive.isDesktop(context);

//     // WEB-SPECIFIC: Better responsive padding
//     final horizontalPadding = kIsWeb && screenWidth > 1024
//         ? (screenWidth > 1400 ? 60.0 : 40.0)
//         : Responsive.spacing(
//             context,
//             mobile: 8.0,
//             tablet: 32.0,
//             desktop: 64.0,
//           );

//     // WEB-SPECIFIC: Limit max width for better readability
//     final maxContentWidth =
//         kIsWeb && screenWidth > 1024 ? double.infinity : double.infinity;

//     // Use web layout only for desktop/tablet
//     final useWebLayout = isDesktop || isTablet;

//     return Scaffold(
//       backgroundColor: isDark ? Colors.black : const Color.fromARGB(255, 255, 255, 255),
//       body: Stack(
//         children: [
//           // Main content
//           Column(
//             children: [
//               Expanded(
//                 child: SafeArea(
//                   top: false,
//                   child: RefreshIndicator(
//                     onRefresh: _handleRefresh,
//                     child: SingleChildScrollView(
//                       controller: _scrollController,
//                       child: useWebLayout
//                           ? _buildWebLayout(
//                               theme: theme,
//                               isDark: isDark,
//                               isDesktop: isDesktop,
//                               horizontalPadding: horizontalPadding,
//                               maxContentWidth: maxContentWidth,
//                             )
//                           : _buildMobileLayout(
//                               theme: theme,
//                               isDark: isDark,
//                               isDesktop: isDesktop,
//                               horizontalPadding: horizontalPadding,
//                               maxContentWidth: maxContentWidth,
//                             ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),

//           // Sticky Search Bar (Mobile only)
//           if (!_isInitializing && _isSearchBarPinned && !useWebLayout)
//             Positioned(
//               top: topPadding + 8,
//               left: 0,
//               right: 0,
//               child: Center(
//                 child: Container(
//                   constraints: BoxConstraints(maxWidth: maxContentWidth),
//                   margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
//                   child: Material(
//                     elevation: 4,
//                     borderRadius: BorderRadius.circular(15),
//                     color: theme.cardColor,
//                     child: const SearchBarWithVoice(),
//                   ),
//                 ),
//               ),
//             ),
            
//           // Location Permission Modal (non-dismissible)
//           if (_showLocationModal)
//             _buildLocationPermissionModal(),
//         ],
//       ),
//     );
//   }

//   Widget _buildMobileLayout({
//     required ThemeData theme,
//     required bool isDark,
//     required bool isDesktop,
//     required double horizontalPadding,
//     required double maxContentWidth,
//   }) {
//     return Center(
//       child: Container(
//         constraints: BoxConstraints(maxWidth: maxContentWidth),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// 🔥 TOP STACK SECTION (Banner + Header + Search)
//             _isInitializing
//                 ? _buildBannerSkeleton()
//                 : SizedBox(
//                     height: 270,
//                     child: Stack(
//                       clipBehavior: Clip.none,
//                       children: [
//                         /// Banner Background
//                         SizedBox(
//                           height: 240,
//                           width: double.infinity,
//                           child: Consumer<BannerProvider>(
//                             builder: (context, bannerProvider, _) {
//                               if (bannerProvider.isLoading ||
//                                   bannerProvider.banners.isEmpty) {
//                                 return Container(
//                                   color: Colors.grey[300],
//                                 );
//                               }

//                               return CarouselSlider(
//                                 items: bannerProvider.banners.map((banner) {
//                                   return Image.network(
//                                     banner.imageUrl,
//                                     fit: BoxFit.cover,
//                                     width: double.infinity,
//                                   );
//                                 }).toList(),
//                                 options: CarouselOptions(
//                                   height: 240,
//                                   viewportFraction: 1.0,
//                                   autoPlay: true,
//                                 ),
//                               );
//                             },
//                           ),
//                         ),

//                         /// Gradient Overlay
//                         Container(
//                           height: 240,
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               begin: Alignment.bottomCenter,
//                               end: Alignment.topCenter,
//                               colors: [
//                                 Colors.black.withOpacity(0.55),
//                                 Colors.black.withOpacity(0.25),
//                                 Colors.transparent,
//                               ],
//                             ),
//                           ),
//                         ),

//                         /// Header
//                         Padding(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: horizontalPadding,
//                             vertical: 24,
//                           ),
//                           child: HomeHeader(
//                             userId: userId ?? 'unknown',
//                             onLocationTap: () async {
//                               await Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => LocationPickerScreen(
//                                     isEditing: false,
//                                     userId: userId.toString(),
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),

//                         /// SEARCH BAR HALF OVERLAP
//                         Positioned(
//                           bottom: -4,
//                           left: horizontalPadding,
//                           right: horizontalPadding,
//                           child: Container(
//                             key: _searchBarKey,
//                             child: const SearchBarWithVoice(),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//             const SizedBox(height: 24),

//             /// Categories Section
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
//               child: Column(
//                 children: [
//                   SectionHeader(
//                     title: 'Categories',
//                     onSeeAll: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => CategoryScreen(
//                             userId: userId.toString(),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 12),
//                   _isInitializing
//                       ? _buildCategorySkeleton()
//                       : _buildCategories(),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 20),

//             /// Nearby Restaurants
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
//               child: Column(
//                 children: [
//                   SectionHeader(
//                     title: 'Nearby restaurants',
//                     onSeeAll: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => NearbyScreen(
//                             userId: userId.toString(),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 12),
//                   _isInitializing || _isLocationLoading
//                       ? _buildRestaurantSkeleton()
//                       : _buildRestaurantList(),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 20),

//             /// Popular Restaurants
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SectionHeader(
//                     title: 'Popular Restaurants',
//                     onSeeAll: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => TopRestaurantsScreen(
//                             userId: userId.toString(),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 12),
//                   _isInitializing || _isLocationLoading
//                       ? _buildVerticalRestaurantSkeleton()
//                       : _buildTopRestaurants(),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   // Web layout
//   Widget _buildWebLayout({
//     required ThemeData theme,
//     required bool isDark,
//     required bool isDesktop,
//     required double horizontalPadding,
//     required double maxContentWidth,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Header Section with full-width banner
//         _isInitializing
//             ? _buildBannerSkeleton()
//             : _buildAnimatedSection(
//                 slideAnimation: _headerSlideAnimation,
//                 fadeAnimation: _headerFadeAnimation,
//                 child: _buildHeroSection(),
//               ),

//         // Main content with constrained width
//         Center(
//           child: Container(
//             constraints: BoxConstraints(
//               maxWidth: maxContentWidth,
//             ),
//             padding: EdgeInsets.symmetric(
//               horizontal: 10,
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Categories Section
//                 _buildAnimatedSection(
//                   slideAnimation: _categoriesSlideAnimation,
//                   fadeAnimation: _categoriesFadeAnimation,
//                   child: Column(
//                     children: [
//                       const SizedBox(height: 40),
//                       RichText(
//                         textAlign: TextAlign.center,
//                         text: TextSpan(
//                           children: [
//                             TextSpan(
//                               text: 'Featured ',
//                               style: theme.textTheme.headlineSmall?.copyWith(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: isDesktop ? 32 : 24,
//                                 color: Colors.black,
//                               ),
//                             ),
//                             TextSpan(
//                               text: 'Categories',
//                               style: theme.textTheme.headlineSmall?.copyWith(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: isDesktop ? 32 : 24,
//                                 color: Colors.green,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 30),
//                       _isInitializing
//                           ? _buildCategorySkeleton()
//                           : _buildCategories(),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 60),

//                 // Nearby Restaurants Section
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SectionHeader(
//                       title: 'Nearby Restaurants',
//                       onSeeAll: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => NearbyScreen(
//                               userId: userId.toString(),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 24),
//                     _isInitializing || _isLocationLoading
//                         ? _buildRestaurantSkeleton()
//                         : _buildAnimatedSection(
//                             slideAnimation: _nearbySlideAnimation,
//                             fadeAnimation: _nearbyFadeAnimation,
//                             child: _buildRestaurantList(),
//                           ),
//                   ],
//                 ),

//                 const SizedBox(height: 60),

//                 // Popular Restaurants Section
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SectionHeader(
//                       title: 'Popular Restaurants',
//                       onSeeAll: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => TopRestaurantsScreen(
//                               userId: userId.toString(),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 24),
//                     _isInitializing || _isLocationLoading
//                         ? _buildVerticalRestaurantSkeleton()
//                         : _buildAnimatedSection(
//                             slideAnimation: _topRestaurantsSlideAnimation,
//                             fadeAnimation: _topRestaurantsFadeAnimation,
//                             child: _buildTopRestaurants(),
//                           ),
//                   ],
//                 ),

//                 const SizedBox(height: 80),

//                 _buildFooterSection(theme: theme, isDesktop: isDesktop),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildFooterSection({
//     required ThemeData theme,
//     required bool isDesktop,
//   }) {
//     const bgColor = Color(0xFF1A2E1A);
//     const dividerColor = Color(0xFF2E4A2E);
//     const headingColor = Colors.white;
//     const textColor = Color(0xFFB0C8B0);
//     const accentColor = Color(0xFF6FCF97);

//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.symmetric(
//         vertical: isDesktop ? 60 : 40,
//         horizontal: isDesktop ? 60 : 24,
//       ),
//       color: bgColor,
//       child: Column(
//         children: [
//           LayoutBuilder(
//             builder: (context, constraints) {
//               final screenWidth = constraints.maxWidth;
//               int crossAxisCount = 3;
//               if (screenWidth < 700) crossAxisCount = 2;
//               if (screenWidth < 450) crossAxisCount = 1;

//               return GridView.count(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 crossAxisCount: crossAxisCount,
//                 mainAxisSpacing: 36,
//                 crossAxisSpacing: 36,
//                 childAspectRatio: screenWidth < 450 ? 2.2 : 1.7,
//                 children: [
//                   _buildFooterColumn(
//                     title: 'Company',
//                     items: const ['About Us', 'Careers', 'Help & Support'],
//                     links: const ['https://vegiffy.com/', null, null],
//                     textColor: textColor,
//                     headingColor: headingColor,
//                     accentColor: accentColor,
//                   ),
//                   _buildFooterColumn(
//                     title: 'Legal',
//                     items: const ['Privacy Policy', 'Terms & Conditions'],
//                     links: const [
//                       'https://vegiffy-policy.onrender.com/privacy-and-policy',
//                       'https://vegiffy-policy.onrender.com/terms-and-conditions',
//                     ],
//                     textColor: textColor,
//                     headingColor: headingColor,
//                     accentColor: accentColor,
//                   ),
//                   _buildPartnerWithUsColumn(
//                     textColor: textColor,
//                     headingColor: headingColor,
//                     accentColor: accentColor,
//                   ),
//                 ],
//               );
//             },
//           ),

//           SizedBox(height: isDesktop ? 48 : 32),

//           const Divider(color: dividerColor, thickness: 1, height: 1),

//           SizedBox(height: isDesktop ? 36 : 24),

//           _buildAppDownloads(isDesktop: isDesktop, headingColor: headingColor),

//           SizedBox(height: isDesktop ? 36 : 24),

//           const Divider(color: dividerColor, thickness: 1, height: 1),

//           SizedBox(height: isDesktop ? 24 : 16),

//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Image.asset('assets/images/applogo.png', height: 32),
//               Text(
//                 '© ${DateTime.now().year} Vegiffy. All rights reserved.',
//                 style: const TextStyle(
//                   color: textColor,
//                   fontSize: 12,
//                   letterSpacing: 0.3,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPartnerWithUsColumn({
//     required Color textColor,
//     required Color headingColor,
//     required Color accentColor,
//   }) {
//     final partners = [
//       {'label': '🛒  Become a Vendor', 'url': 'https://vendor.vegiffy.in/'},
//       {'label': '🏍️  Ride with Us', 'url': 'https://play.google.com/store/apps/details?id=com.pixelmind.vegiffydeliveryapp'},
//       {'label': '🌟  Become an Ambassador', 'url': 'https://vegiffypanel.vegiffy.in/'},
//     ];

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Partner With Us',
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w700,
//             color: headingColor,
//             letterSpacing: 0.5,
//           ),
//         ),
//         const SizedBox(height: 14),
//         ...partners.map(
//           (partner) => Padding(
//             padding: const EdgeInsets.only(bottom: 10),
//             child: GestureDetector(
//               onTap: () => launchUrl(
//                 Uri.parse(partner['url']!),
//                 mode: LaunchMode.externalApplication,
//               ),
//               child: Text(
//                 partner['label']!,
//                 style: TextStyle(
//                   color: accentColor,
//                   fontSize: 13,
//                   height: 1.6,
//                   decoration: TextDecoration.none,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildFooterColumn({
//     required String title,
//     required List<String> items,
//     required List<String?> links,
//     required Color textColor,
//     required Color headingColor,
//     required Color accentColor,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w700,
//             color: headingColor,
//             letterSpacing: 0.5,
//           ),
//         ),
//         const SizedBox(height: 14),
//         ...List.generate(items.length, (i) {
//           final url = links[i];
//           return Padding(
//             padding: const EdgeInsets.only(bottom: 10),
//             child: GestureDetector(
//               onTap: url != null
//                   ? () => launchUrl(
//                         Uri.parse(url),
//                         mode: LaunchMode.externalApplication,
//                       )
//                   : null,
//               child: Text(
//                 items[i],
//                 style: TextStyle(
//                   color: url != null ? accentColor : textColor,
//                   fontSize: 13,
//                   height: 1.6,
//                 ),
//               ),
//             ),
//           );
//         }),
//       ],
//     );
//   }

//   Widget _buildAppDownloads({
//     required bool isDesktop,
//     required Color headingColor,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Download the Vegiffy App',
//           style: TextStyle(
//             fontSize: isDesktop ? 15 : 13,
//             color: headingColor,
//             fontWeight: FontWeight.w600,
//             letterSpacing: 0.3,
//           ),
//         ),
//         const SizedBox(height: 16),
//         Row(
//           children: [
//             _buildDownloadButton(
//               icon: Icons.apple,
//               platform: 'App Store',
//               onTap: () => launchUrl(
//                 Uri.parse('https://apps.apple.com/in/app/vegiffyy/id6757138352'),
//                 mode: LaunchMode.externalApplication,
//               ),
//             ),
//             const SizedBox(width: 14),
//             _buildDownloadButton(
//               icon: Icons.android,
//               platform: 'Google Play',
//               onTap: () => launchUrl(
//                 Uri.parse('https://play.google.com/store/apps/details?id=com.veggify.veegify'),
//                 mode: LaunchMode.externalApplication,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildDownloadButton({
//     required IconData icon,
//     required String platform,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(10),
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
//         decoration: BoxDecoration(
//           color: const Color(0xFF243B24),
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: const Color(0xFF3A5C3A), width: 1),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, color: Colors.white, size: 20),
//             const SizedBox(width: 10),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Download on',
//                   style: TextStyle(color: Colors.grey[400], fontSize: 10),
//                 ),
//                 Text(
//                   platform,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Hero section with full-width banner
//   Widget _buildHeroSection() {
//     final theme = Theme.of(context);
//     final isDesktop = Responsive.isDesktop(context);

//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             theme.colorScheme.primary.withOpacity(0.1),
//             theme.colorScheme.secondary.withOpacity(0.05),
//           ],
//         ),
//       ),
//       child: Center(
//         child: Container(
//           constraints: const BoxConstraints(maxWidth: 1400),
//           padding: EdgeInsets.symmetric(
//             horizontal: isDesktop ? 120 : 16,
//             vertical: isDesktop ? 80 : 40,
//           ),
//           child: Row(
//             children: [
//               // Left side - Text content
//               Expanded(
//                 flex: isDesktop ? 5 : 6,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 8,
//                       ),
//                       decoration: BoxDecoration(
//                         color: theme.colorScheme.primary.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Text(
//                         'The Best Online Pure Veg Store',
//                         style: TextStyle(
//                           fontSize: isDesktop ? 14 : 12,
//                           fontWeight: FontWeight.w600,
//                           color: theme.colorScheme.primary,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: isDesktop ? 20 : 12),
//                     Text(
//                       'Your One-Stop Destination\nfor Pure Veg Food',
//                       style: theme.textTheme.displaySmall?.copyWith(
//                         fontWeight: FontWeight.bold,
//                         fontSize: isDesktop ? 48 : 28,
//                         height: 1.2,
//                       ),
//                     ),
//                     SizedBox(height: isDesktop ? 20 : 12),
//                     Text(
//                       'Discover delicious vegetarian food delivered\nstraight to your doorstep.',
//                       style: theme.textTheme.bodyLarge?.copyWith(
//                         fontSize: isDesktop ? 16 : 14,
//                         color: theme.colorScheme.onSurface.withOpacity(0.7),
//                         height: 1.5,
//                       ),
//                     ),
//                     SizedBox(height: isDesktop ? 24 : 16),

//                     // Location display (only show if location is available)
//                     Consumer<LocationProvider>(
//                       builder: (context, locationProvider, _) {
//                         if (locationProvider.hasLocation) {
//                           return InkWell(
//                             onTap: () async {
//                               await Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => LocationPickerScreen(
//                                     isEditing: false,
//                                     userId: userId.toString(),
//                                   ),
//                                 ),
//                               );
//                             },
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 16,
//                                 vertical: 12,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: theme.colorScheme.surface,
//                                 borderRadius: BorderRadius.circular(12),
//                                 border: Border.all(
//                                   color: theme.colorScheme.outline
//                                       .withOpacity(0.2),
//                                 ),
//                               ),
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Icon(
//                                     Icons.location_on,
//                                     color: theme.colorScheme.primary,
//                                     size: 20,
//                                   ),
//                                   const SizedBox(width: 8),
//                                   Flexible(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           'Deliver to',
//                                           style: theme.textTheme.bodySmall
//                                               ?.copyWith(
//                                             color: theme.colorScheme.onSurface
//                                                 .withOpacity(0.6),
//                                             fontSize: 11,
//                                           ),
//                                         ),
//                                         Text(
//                                           locationProvider.address ??
//                                               'Select Location',
//                                           style: theme.textTheme.bodyMedium
//                                               ?.copyWith(
//                                             fontWeight: FontWeight.w600,
//                                             fontSize: 14,
//                                           ),
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   const SizedBox(width: 8),
//                                   Icon(
//                                     Icons.keyboard_arrow_down,
//                                     size: 18,
//                                     color: theme.colorScheme.onSurface
//                                         .withOpacity(0.6),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         }
//                         return const SizedBox.shrink();
//                       },
//                     ),

//                     SizedBox(height: isDesktop ? 24 : 16),

//                     // Search bar in hero
//                     Container(
//                       key: _searchBarKey,
//                       constraints: const BoxConstraints(maxWidth: 500),
//                       child: const SearchBarWithVoice(),
//                     ),
//                   ],
//                 ),
//               ),

//               // Right side - Image
//               if (isDesktop)
//                 Expanded(
//                   flex: 6,
//                   child: Padding(
//                     padding: const EdgeInsets.only(left: 40),
//                     child: Consumer<BannerProvider>(
//                       builder: (context, bannerProvider, _) {
//                         if (bannerProvider.isLoading) {
//                           return _desktopBannerPlaceholder(theme);
//                         }

//                         if (bannerProvider.banners.isEmpty) {
//                           return _desktopBannerFallback(theme);
//                         }

//                         final banner = bannerProvider.banners[
//                             _currentIndex % bannerProvider.banners.length];

//                         return AnimatedSwitcher(
//                           duration: const Duration(milliseconds: 600),
//                           switchInCurve: Curves.easeInOut,
//                           switchOutCurve: Curves.easeInOut,
//                           child: ClipRRect(
//                             key: ValueKey(banner.imageUrl),
//                             borderRadius: BorderRadius.circular(20),
//                             child: Image.network(
//                               banner.imageUrl,
//                               fit: BoxFit.cover,
//                               errorBuilder: (_, __, ___) =>
//                                   _desktopBannerFallback(theme),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 )
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _desktopBannerPlaceholder(ThemeData theme) {
//     return Container(
//       height: 400,
//       decoration: BoxDecoration(
//         color: theme.colorScheme.primary.withOpacity(0.08),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: const Center(
//         child: CircularProgressIndicator(strokeWidth: 2.5),
//       ),
//     );
//   }

//   Widget _desktopBannerFallback(ThemeData theme) {
//     return Container(
//       height: 400,
//       decoration: BoxDecoration(
//         color: theme.colorScheme.primary.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Icon(
//         Icons.shopping_basket_rounded,
//         size: 120,
//         color: theme.colorScheme.primary,
//       ),
//     );
//   }

//   Widget _buildCategories() {
//     final isDesktop = Responsive.isDesktop(context);
//     final isTablet = Responsive.isTablet(context);

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
//                   color: theme.colorScheme.onSurface.withOpacity(0.6),
//                 ),
//               ),
//             ),
//           );
//         }

//         // For desktop/tablet, show grid
//         if (isDesktop || isTablet) {
//           return GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: isDesktop ? 6 : 4,
//               mainAxisSpacing: 8,
//               crossAxisSpacing: 8,
//               childAspectRatio: 0.9,
//             ),
//             itemCount: math.min(provider.categories.length, isDesktop ? 12 : 8),
//             itemBuilder: (context, index) {
//               final category = provider.categories[index];
//               return CategoryList(
//                 id: category.id,
//                 imagePath: category.imageUrl,
//                 title: category.categoryName,
//                 userId: userId.toString(),
//               );
//             },
//           );
//         }

//         // Mobile: horizontal scroll
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
//     final isDesktop = Responsive.isDesktop(context);
//     final isWeb = kIsWeb;

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
//                   'Looks like there aren\'t any restaurants around your location.',
//                   textAlign: TextAlign.center,
//                   style: theme.textTheme.bodyMedium?.copyWith(
//                     color: theme.colorScheme.onSurface.withOpacity(0.6),
//                     height: 1.4,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }

//         return SizedBox(
//           height: Responsive.value(
//             context,
//             mobile: 120,
//             tablet: 260,
//             desktop: 320,
//           ),
//           child: isWeb
//               ? Scrollbar(
//                   thumbVisibility: true,
//                   thickness: 6,
//                   radius: const Radius.circular(10),
//                   child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     physics: const ClampingScrollPhysics(),
//                     itemCount: provider.nearbyRestaurants.length,
//                     itemBuilder: (context, index) {
//                       final restaurant = provider.nearbyRestaurants[index];
//                       return SizedBox(
//                         width: Responsive.value(
//                           context,
//                           mobile: 300,
//                           tablet: 260,
//                           desktop: 300,
//                         ),
//                         child: RestaurantCard(
//                           id: restaurant.id,
//                           imagePath: restaurant.imageUrl,
//                           name: restaurant.restaurantName,
//                           rating: restaurant.rating.toDouble(),
//                           description: restaurant.description,
//                           price: restaurant.startingPrice,
//                           locationName: restaurant.locationName,
//                           status: restaurant.status,
//                           discount: restaurant.discount,
//                         ),
//                       );
//                     },
//                   ),
//                 )
//               : ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   physics: const AlwaysScrollableScrollPhysics(),
//                   itemCount: provider.nearbyRestaurants.length,
//                   itemBuilder: (context, index) {
//                     final restaurant = provider.nearbyRestaurants[index];
//                     return SizedBox(
//                       width: Responsive.value(
//                         context,
//                         mobile: 300,
//                         tablet: 260,
//                         desktop: 300,
//                       ),
//                       child: RestaurantCard(
//                         id: restaurant.id,
//                         imagePath: restaurant.imageUrl,
//                         name: restaurant.restaurantName,
//                         rating: restaurant.rating.toDouble(),
//                         description: restaurant.description,
//                         price: restaurant.startingPrice,
//                         locationName: restaurant.locationName,
//                         status: restaurant.status,
//                         discount: restaurant.discount,
//                       ),
//                     );
//                   },
//                 ),
//         );
//       },
//     );
//   }

//   Widget _buildTopRestaurants() {
//     final theme = Theme.of(context);
//     final isDesktop = Responsive.isDesktop(context);
//     final isTablet = Responsive.isTablet(context);

//     return Consumer<TopRestaurantsProvider>(
//       builder: (context, provider, _) {
//         if (provider.isLoading) {
//           return _buildVerticalRestaurantSkeleton();
//         }

//         if (provider.topRestaurants.isEmpty) {
//           return SizedBox(
//             height: 200,
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
//                   'No popular restaurants nearby',
//                   style: theme.textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Check back later for popular restaurants in your area.',
//                   textAlign: TextAlign.center,
//                   style: theme.textTheme.bodyMedium?.copyWith(
//                     color: theme.colorScheme.onSurface.withOpacity(0.6),
//                     height: 1.4,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }

//         final total = provider.topRestaurants.length;
//         final visibleCount = math.min(
//           total,
//           _currentTopRestaurantsPage * _topRestaurantsPerPage,
//         );

//         // Desktop/Tablet: Grid layout
//         if (isDesktop || isTablet) {
//           return Column(
//             children: [
//               LayoutBuilder(
//                 builder: (context, constraints) {
//                   final width = constraints.maxWidth;
//                   final crossAxisCount = _getGridCount(width);

//                   return GridView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: crossAxisCount,
//                       crossAxisSpacing: 16,
//                       mainAxisSpacing: 16,
//                       childAspectRatio: width >= 1100 ? 1.25 : 1.1,
//                     ),
//                     itemCount: visibleCount,
//                     itemBuilder: (context, index) {
//                       final restaurant = provider.topRestaurants[index];
//                       return TicketRestaurantCard(
//                         id: restaurant.id,
//                         imagePath: restaurant.imageUrl,
//                         name: restaurant.restaurantName,
//                         rating: restaurant.rating.toDouble(),
//                         description: restaurant.description,
//                         price: restaurant.startingPrice,
//                         locationName: restaurant.locationName,
//                         status: restaurant.status,
//                         discount: restaurant.discount,
//                       );
//                     },
//                   );
//                 },
//               ),
//               if (_isTopRestaurantsLoadingMore && _canLoadMoreTopRestaurants)
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 16.0),
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
//                 ),
//             ],
//           );
//         }

//         // Mobile: List layout
//         return ListView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: visibleCount + 1,
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
//                   discount: restaurant.discount,
//                 ),
//               );
//             } else {
//               if (_isTopRestaurantsLoadingMore && _canLoadMoreTopRestaurants) {
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 16.0),
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
//                 return const SizedBox(height: 16);
//               } else {
//                 return const SizedBox.shrink();
//               }
//             }
//           },
//         );
//       },
//     );
//   }
// }