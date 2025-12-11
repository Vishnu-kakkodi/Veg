
// lib/views/navbar/navbar_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:veegify/helper/storage_helper.dart';
import 'package:veegify/model/user_model.dart';
import 'package:veegify/provider/CartProvider/cart_provider.dart';
import 'package:veegify/provider/VersionProvider/version_provider.dart';
import 'package:veegify/views/Booking/accepted_order_polling_screen.dart';
import 'package:veegify/views/Cart/cart_screen.dart';
import 'package:veegify/views/Booking/history_screen.dart';
import 'package:veegify/views/home/home_screen.dart';
import 'package:veegify/views/ProfileScreen/profile_screen.dart';
import 'package:veegify/views/Wishlist/wishlist_screen.dart';
import 'package:veegify/widgets/bottom_navbar.dart';
import 'package:veegify/model/order.dart';
import 'package:veegify/provider/BookingProvider/booking_provider.dart';
import 'package:url_launcher/url_launcher.dart';



class NavbarScreen extends StatefulWidget {
  /// Optional initial tab index: 0 = Home, 1 = Favourites, 2 = Cart, 3 = History, 4 = Account
  final int initialIndex;

  const NavbarScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<NavbarScreen> createState() => _NavbarScreenState();
}

class _NavbarScreenState extends State<NavbarScreen> {
  final bool _isBottomNavVisible = true;
  User? user;

  bool _showCartSummary = true;
  bool _showBookingSummary = true;
    bool _isUpdateDialogOpen = false; // 👈 NEW


  @override
  void initState() {
    super.initState();
    _initialize();

    // Apply initial index AFTER first frame so Provider is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bottomNavbarProvider =
          Provider.of<BottomNavbarProvider>(context, listen: false);
      bottomNavbarProvider.setIndex(widget.initialIndex.clamp(0, 4));
    });
  }

  Future<void> _initialize() async {
    await _loadUserId();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.loadCart(user?.userId.toString());

      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      orderProvider.loadAllOrders(user?.userId.toString());
    });
  }

  Future<void> _loadUserId() async {
    final userData = UserPreferences.getUser();
    if (userData != null) {
      setState(() {
        user = userData;
      });
    }
  }

  void _attachScrollController(ScrollController? controller) {
    // No-op to avoid scroll-based nav hiding
  }

  void _handleTabChange(int index, BottomNavbarProvider bottomNavbarProvider) {
    if (index == 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        cartProvider.loadCart(user?.userId.toString());
      });
    }

    if (index == 3 || index == 4) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final orderProvider =
            Provider.of<OrderProvider>(context, listen: false);
        orderProvider.loadAllOrders(user?.userId.toString());
      });
    }

    bottomNavbarProvider.setIndex(index);
  }

  

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomNavbarProvider = Provider.of<BottomNavbarProvider>(context);
    final versionProvider = Provider.of<VersionProvider>(context);


    final pages = [
      ScrollableHomeScreen(onScrollControllerCreated: _attachScrollController),
      ScrollableFavouriteScreen(
        onScrollControllerCreated: _attachScrollController,
      ),
      ScrollableCartScreen(onScrollControllerCreated: _attachScrollController),
      ScrollableHistoryScreen(
        onScrollControllerCreated: _attachScrollController,
      ),
      ScrollableProfileScreen(
        onScrollControllerCreated: _attachScrollController,
      ),
    ];

WidgetsBinding.instance.addPostFrameCallback((_) {
  // Show on ANY tab, and keep showing until user updates
  if (versionProvider.needsUpdate && !_isUpdateDialogOpen) {
    _isUpdateDialogOpen = true;
    _showUpdateDialog(context, versionProvider).then((_) {
      // When dialog is closed (after Update redirect), allow it to open again
      _isUpdateDialogOpen = false;
    });
  }
});





    return WillPopScope(
      onWillPop: () async {
        if (bottomNavbarProvider.currentIndex != 0) {
          bottomNavbarProvider.setIndex(0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: bottomNavbarProvider.currentIndex,
                children: pages,
              ),
            ),

            // Booking summary
            Consumer<OrderProvider>(
              builder: (context, orderProvider, child) {
                final activeOrders = orderProvider.orders.where((o) {
                  final status = (o.orderStatus ?? '').toLowerCase();
                  final deliveryStatus = (o.deliveryStatus ?? '').toLowerCase();

                  final isCancelled =
                      status.contains('cancel') ||
                          deliveryStatus.contains('cancel');
                  final isCompleted =
                      status.contains('complete') ||
                          deliveryStatus.contains('deliver');

                  return !isCancelled && !isCompleted;
                }).toList();

                if (!_showBookingSummary ||
                    activeOrders.isEmpty ||
                    bottomNavbarProvider.currentIndex == 3) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Column(
                    children: [
                      for (final order in activeOrders) ...[
                        _buildBookingSummary(
                          context,
                          order,
                          bottomNavbarProvider,
                        ),
                        const SizedBox(height: 6),
                      ],
                    ],
                  ),
                );
              },
            ),

            // Cart summary
            Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                if (!_showCartSummary ||
                    cartProvider.items.isEmpty ||
                    bottomNavbarProvider.currentIndex == 2) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 6.0,
                  ),
                  child: _buildCartSummary(
                    context,
                    cartProvider,
                    bottomNavbarProvider,
                  ),
                );
              },
            ),
          ],
        ),

        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.4),
                offset: const Offset(0, -1),
                blurRadius: 8,
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: bottomNavbarProvider.currentIndex,
            onTap: (index) {
              _handleTabChange(index, bottomNavbarProvider);
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: colorScheme.primary,
            unselectedItemColor:
                colorScheme.onSurface.withOpacity(0.6),
            elevation: 0,
            backgroundColor: colorScheme.surface,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: 'Favourites',
              ),
              BottomNavigationBarItem(
                icon: Consumer<CartProvider>(
                  builder: (context, cartProvider, child) {
                    return Stack(
                      children: [
                        const Icon(Icons.shopping_cart),
                        if (cartProvider.totalItems > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: colorScheme.error,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 12,
                                minHeight: 12,
                              ),
                              child: Text(
                                '${cartProvider.totalItems}',
                                style: TextStyle(
                                  color: colorScheme.onError,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                label: 'Cart',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.list),
                label: 'History',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Account',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartSummary(
    BuildContext context,
    CartProvider cartProvider,
    BottomNavbarProvider navProvider,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.shopping_cart,
                  color: colorScheme.onPrimary,
                  size: 20,
                ),
              ),
              if (cartProvider.totalItems > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${cartProvider.totalItems}',
                      style: TextStyle(
                        color: colorScheme.onError,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${cartProvider.totalItems} item${cartProvider.totalItems > 1 ? 's' : ''}',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Plus taxes and charges',
                  style: TextStyle(
                    color: colorScheme.onPrimary.withOpacity(0.8),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  _handleTabChange(
                    2,
                    Provider.of<BottomNavbarProvider>(context, listen: false),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '₹${cartProvider.totalPayable}',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Checkout',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: colorScheme.primary,
                        size: 12,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showCartSummary = false;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: colorScheme.onPrimary.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingSummary(
    BuildContext context,
    Order order,
    BottomNavbarProvider navProvider,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final restaurantName = order.restaurant.restaurantName;
    final orderId = order.id;

    String total = '';
    try {
      if (order.totalPayable != 0.0) {
        total = '₹${order.totalPayable.toStringAsFixed(2)}';
      } else if (order.subTotal != 0.0) {
        total = '₹${order.subTotal.toStringAsFixed(2)}';
      }
    } catch (_) {
      total = '';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.receipt_long,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurantName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Order: $orderId',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                total,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AcceptedOrderPollingScreen(
                            userId: order.userId,
                            orderId: order.id,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'View',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showBookingSummary = false;
                      });
                    },
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

Future<void> _showUpdateDialog(
  BuildContext context,
  VersionProvider versionProvider,
) async {
  final currentVersion = versionProvider.currentVersion;
  final storeVersion = versionProvider.storeVersion;

  // Your store URLs
  const playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.veggify.veegify';
  const appStoreUrl = 'https://apps.apple.com/app/idYOUR_APP_ID';

  final url = Platform.isIOS ? appStoreUrl : playStoreUrl;
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  await showDialog(
    context: context,
    barrierDismissible: false, // force update feel
    builder: (context) {
      return AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.system_update_rounded,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Updation is Mandotory",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              "A newer version of Veegify is ready. Updating ensures you get the latest features, improvements, and bug fixes.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.8),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),

            // Version info card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Current version",
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentVersion.isEmpty ? "-" : currentVersion,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 20,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "Latest version",
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          storeVersion.isEmpty ? "-" : storeVersion,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.security_rounded,
                  size: 16,
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "This update may include important stability and security fixes.",
                    // style: theme.textTheme.caption?.copyWith(
                    //   color: colorScheme.onSurface.withOpacity(0.7),
                    //   fontSize: 11,
                    // ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Optional secondary action: exit app instead of using old version

            TextButton(
    onPressed: () => Navigator.of(context).pop(),
    child: const Text("Later"),
  ),
          TextButton(
            onPressed: () {
              SystemNavigator.pop();
            },
            child: Text(
              "Close app",
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onPressed: () async {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "Update now",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    },
  );
}


}

// Scrollable wrapper classes remain the same

class ScrollableCartScreen extends StatefulWidget {
  final Function(ScrollController?) onScrollControllerCreated;

  const ScrollableCartScreen({
    super.key,
    required this.onScrollControllerCreated,
  });

  @override
  State<ScrollableCartScreen> createState() => _ScrollableCartScreenState();
}

class _ScrollableCartScreenState extends State<ScrollableCartScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    widget.onScrollControllerCreated(_scrollController);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CartScreenWithController(scrollController: _scrollController);
  }
}

class ScrollableHomeScreen extends StatefulWidget {
  final Function(ScrollController?) onScrollControllerCreated;

  const ScrollableHomeScreen({
    super.key,
    required this.onScrollControllerCreated,
  });

  @override
  State<ScrollableHomeScreen> createState() => _ScrollableHomeScreenState();
}

class _ScrollableHomeScreenState extends State<ScrollableHomeScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    widget.onScrollControllerCreated(_scrollController);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HomeScreenWithController(scrollController: _scrollController);
  }
}

class ScrollableFavouriteScreen extends StatefulWidget {
  final Function(ScrollController?) onScrollControllerCreated;

  const ScrollableFavouriteScreen({
    super.key,
    required this.onScrollControllerCreated,
  });

  @override
  State<ScrollableFavouriteScreen> createState() =>
      _ScrollableFavouriteScreenState();
}

class _ScrollableFavouriteScreenState
    extends State<ScrollableFavouriteScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    widget.onScrollControllerCreated(_scrollController);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const WishlistScreen();
  }
}

class ScrollableHistoryScreen extends StatefulWidget {
  final Function(ScrollController?) onScrollControllerCreated;

  const ScrollableHistoryScreen({
    super.key,
    required this.onScrollControllerCreated,
  });

  @override
  State<ScrollableHistoryScreen> createState() =>
      _ScrollableHistoryScreenState();
}

class _ScrollableHistoryScreenState extends State<ScrollableHistoryScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    widget.onScrollControllerCreated(_scrollController);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HystoryScreenWithController(scrollController: _scrollController);
  }
}

class ScrollableProfileScreen extends StatefulWidget {
  final Function(ScrollController?) onScrollControllerCreated;

  const ScrollableProfileScreen({
    super.key,
    required this.onScrollControllerCreated,
  });

  @override
  State<ScrollableProfileScreen> createState() =>
      _ScrollableProfileScreenState();
}

class _ScrollableProfileScreenState extends State<ScrollableProfileScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    widget.onScrollControllerCreated(_scrollController);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProfileScreenWithController(scrollController: _scrollController);
  }
}
