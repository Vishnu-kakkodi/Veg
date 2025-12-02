import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:veegify/helper/cart_vendor_guard.dart';
import 'package:veegify/helper/storage_helper.dart';
import 'package:veegify/model/restaurant_product_model.dart' hide CartItem;
import 'package:veegify/provider/CartProvider/cart_provider.dart';
import 'package:veegify/provider/RestaurantProvider/restaurant_products_provider.dart';
import 'package:veegify/provider/WishListProvider/wishlist_provider.dart';
import 'package:veegify/views/Cart/cart_screen.dart';
import 'package:veegify/views/home/detail_screen.dart';
import 'package:veegify/widgets/Restaurants/swinging_closed_banner.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final String restaurantId;
  String? categoryName;

   RestaurantDetailScreen({
    super.key,
    required this.restaurantId,
    this.categoryName
  });

  @override
  State<RestaurantDetailScreen> createState() =>
      _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? userId;

  Timer? _availabilityTimer;
  bool _hasLoadedOnce = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeData();
      await context
          .read<WishlistProvider>()
          .fetchWishlist(userId.toString());
      _startAvailabilityPolling();
    });
  }

  @override
  void dispose() {
    _availabilityTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    try {
      await _loadUserId();

      if (userId == null) {
        debugPrint("User ID not found!");
        return;
      }

      await Provider.of<RestaurantProductsProvider>(
        context,
        listen: false,
      ).fetchRestaurantProducts(widget.restaurantId,widget.categoryName);

      await Provider.of<CartProvider>(context, listen: false)
          .loadCart(userId);

      if (mounted) {
        setState(() {
          _hasLoadedOnce = true;
        });
      }

      debugPrint("Data initialized successfully ✅");
    } catch (e, stack) {
      debugPrint("Error initializing data: $e\n$stack");
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

  void _startAvailabilityPolling() {
    _availabilityTimer?.cancel();
    _availabilityTimer =
        Timer.periodic(const Duration(seconds: 5), (_) async {
      if (!mounted) {
        _availabilityTimer?.cancel();
        return;
      }
      try {
        await Provider.of<RestaurantProductsProvider>(
          context,
          listen: false,
        ).fetchRestaurantProducts(widget.restaurantId,widget.categoryName);
        // No UI "loading" change here, we only rebuild with new data.
      } catch (e) {
        debugPrint('Error polling availability: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? theme.scaffoldBackgroundColor : Colors.white,
      body: SafeArea(
        top: false,
        child:
            Consumer<RestaurantProductsProvider>(builder: (context, restaurantProvider, child) {
          // Only show full-screen loader before first successful load.
          if (restaurantProvider.isLoading && !_hasLoadedOnce) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            );
          }

          if (restaurantProvider.error == "NO_PRODUCTS") {
            return _buildNoProductsUI(
                restaurantProvider, theme, isDark);
          }

          if (restaurantProvider.error == "ERROR") {
            return _buildErrorUI(restaurantProvider, theme);
          }

          final recommendedItems = _searchQuery.isEmpty
              ? restaurantProvider.allRecommendedItems
              : restaurantProvider.searchItems(_searchQuery);

          final specialitiesText =
              restaurantProvider.recommendedProducts.isNotEmpty &&
                      restaurantProvider
                          .recommendedProducts
                          .first
                          .recommendedItem
                          .tags
                          .isNotEmpty
                  ? restaurantProvider
                      .recommendedProducts
                      .first
                      .recommendedItem
                      .tags
                      .join(", ")
                  : "Food, Specialties";

          final rating = restaurantProvider.rating > 0
              ? restaurantProvider.rating.toStringAsFixed(1)
              : "4.0";

          final totalReviews =
              restaurantProvider.totalReviews;

          // ⚠️ Replace `restaurantStatus` with your actual field
          final bool isRestaurantActive =
              (restaurantProvider.restaurantStatus ?? '')
                      .toLowerCase() ==
                  'active';

          return SingleChildScrollView(
            child: Column(
              children: [
                // Top Info Section
                Container(
                  padding: const EdgeInsets.only(
                    top: 50,
                    bottom: 12,
                    left: 12,
                    right: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? theme.cardColor
                        : const Color(0xFFEBF4F1),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color:
                                  theme.colorScheme.onSurface,
                            ),
                            onPressed: () =>
                                Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? theme.cardColor
                                  : Colors.white,
                              borderRadius:
                                  BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  restaurantProvider
                                          .restaurantName
                                          .isNotEmpty
                                      ? restaurantProvider
                                          .restaurantName
                                      : "Restaurant",
                                  style: theme
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                    fontWeight:
                                        FontWeight.bold,
                                    color: theme
                                        .colorScheme
                                        .onSurface,
                                  ),
                                ),
                                Text(
                                  restaurantProvider
                                          .locationName
                                          .isNotEmpty
                                      ? restaurantProvider
                                          .locationName
                                      : "Location",
                                  style: theme
                                      .textTheme.bodyMedium
                                      ?.copyWith(
                                    color: theme
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.timer,
                                      size: 16,
                                      color: theme
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.7),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "25–30 min • 2.4 km",
                                      style: TextStyle(
                                        color: theme
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(
                                                0.7),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons
                                          .location_on_outlined,
                                      size: 16,
                                      color: theme
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.7),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        restaurantProvider
                                                .locationName
                                                .isNotEmpty
                                            ? restaurantProvider
                                                .locationName
                                            : "Location",
                                        style: TextStyle(
                                          color: theme
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(
                                                  0.7),
                                        ),
                                        overflow: TextOverflow
                                            .ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  specialitiesText,
                                  style: TextStyle(
                                    color: theme
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment:
                                      Alignment.centerRight,
                                  child: TextButton(
                                    onPressed:
                                        isRestaurantActive
                                            ? () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) =>
                                                            RestaurantReviewsScreen(
                                                      restaurantName:
                                                          restaurantProvider
                                                              .restaurantName,
                                                      totalRatings:
                                                          restaurantProvider
                                                              .totalRatings,
                                                      totalReviews:
                                                          restaurantProvider
                                                              .totalReviews,
                                                      reviews:
                                                          restaurantProvider
                                                              .restaurantReviews,
                                                    ),
                                                  ),
                                                );
                                              }
                                            : null,
                                    child: Text(
                                      totalReviews > 0
                                          ? 'View reviews ($totalReviews)'
                                          : 'View reviews',
                                      style: TextStyle(
                                        color: isRestaurantActive
                                            ? theme
                                                .colorScheme
                                                .primary
                                            : theme
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(
                                                    0.4),
                                        fontWeight:
                                            FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 20,
                            child: Column(
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal: 14,
                                    vertical: 4,
                                  ),
                                  decoration:
                                      BoxDecoration(
                                    color: theme
                                        .colorScheme
                                        .primary,
                                    borderRadius:
                                        BorderRadius
                                            .circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: theme
                                            .colorScheme
                                            .onPrimary,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        rating,
                                        style: TextStyle(
                                          color: theme
                                              .colorScheme
                                              .onPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  totalReviews > 0
                                      ? '$totalReviews review${totalReviews > 1 ? 's' : ''}'
                                      : 'No reviews',
                                  style: TextStyle(
                                    color: theme
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.6),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Swinging "Currently CLOSED" banner when restaurant is inactive
                          if (!isRestaurantActive)
                            Positioned(
                              top: -30,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: SwingingClosedBanner(
                                  topText: 'Currently',
                                  bottomText: 'CLOSED',
                                  width: 180,
                                  height: 60,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color.fromARGB(255, 32, 203, 20)),
                      borderRadius: BorderRadius.circular(12)
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: TextFormField(
                              controller: _searchController,
                              style: TextStyle(
                                color: theme
                                    .colorScheme.onSurface,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search your food',
                                hintStyle: TextStyle(
                                  color: theme
                                      .colorScheme.onSurface
                                      .withOpacity(0.6),
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: theme
                                      .colorScheme.onSurface
                                      .withOpacity(0.6),
                                ),
                                filled: true,
                                fillColor: isDark
                                    ? theme.cardColor
                                    : Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                          30),
                                  borderSide:
                                      BorderSide.none,
                                ),
                                contentPadding:
                                    const EdgeInsets
                                        .symmetric(
                                            vertical: 0),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                ),

                Divider(
                  height: 30,
                  color: isDark
                      ? Colors.grey[700]
                      : Colors.grey[300],
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recommended',
                        style: theme
                            .textTheme.titleMedium
                            ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme
                              .colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '${restaurantProvider.totalRecommendedItems} items',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface
                              .withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),

                // Dishes List
                recommendedItems.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: theme
                                  .colorScheme.onSurface
                                  .withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No items found',
                              style: theme
                                  .textTheme.bodyMedium
                                  ?.copyWith(
                                color: theme
                                    .colorScheme.onSurface
                                    .withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),
                        itemCount: recommendedItems.length,
                        itemBuilder: (context, index) {
                          final itemWithId =
                              recommendedItems[index];
                          final item =
                              itemWithId.recommendedItem;
                          final productId =
                              itemWithId.productId;
                          final itemId = item.itemId;

                          final product =
                              restaurantProvider
                                  .getProductByRecommendedItem(
                                      item);

                          // ⚠️ Replace `item.status` with your field name if different
                          final bool isProductActive =
                              (item.status ?? '')
                                      .toLowerCase() ==
                                  'active';

                          final bool canInteractProduct =
                              isRestaurantActive &&
                                  isProductActive;

                          // Choose effective unit price for display
                          int basePrice;
                          if (item.halfPlatePrice > 0) {
                            basePrice =
                                item.halfPlatePrice;
                          } else if (item.fullPlatePrice >
                              0) {
                            basePrice =
                                item.fullPlatePrice;
                          } else {
                            basePrice = item.price;
                          }

                          final discountedPrice =
                              item.discount > 0
                                  ? (basePrice -
                                          (basePrice *
                                                  item.discount /
                                                  100))
                                      .round()
                                  : basePrice;

                          return Consumer<CartProvider>(
                            builder: (context, cartProvider,
                                child) {
                              final cartItem =
                                  cartProvider
                                      .getCartProduct(
                                          productId);
                              final isInCart =
                                  cartItem != null;
                              final cartQuantity =
                                  cartItem?.quantity ??
                                      0;

                              return GestureDetector(
                                onTap: canInteractProduct
                                    ? () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    DetailScreen(
                                              productId:
                                                  itemId,
                                              currentUserId:
                                                  userId
                                                      .toString(),
                                                      restaurantId: widget.restaurantId,
                                            ),
                                          ),
                                        );
                                      }
                                    : null,
                                child: Padding(
                                  padding:
                                      const EdgeInsets
                                          .all(8),
                                  child: Opacity(
                                    opacity: isProductActive
                                        ? 1.0
                                        : 0.4,
                                    child: Container(
                                      padding:
                                          const EdgeInsets
                                              .all(8),
                                      decoration:
                                          BoxDecoration(
                                        color: isDark
                                            ? theme
                                                .cardColor
                                            : Colors.white,
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                                    16),
                                        boxShadow: [
                                          if (!isDark &&
                                              isProductActive)
                                            BoxShadow(
                                              color: Colors
                                                  .grey
                                                  .withOpacity(
                                                      0.1),
                                              spreadRadius:
                                                  1,
                                              blurRadius:
                                                  4,
                                              offset:
                                                  const Offset(
                                                      0, 2),
                                            ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          // Left: Dish Info
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets
                                                          .all(
                                                              5),
                                                  decoration:
                                                      BoxDecoration(
                                                    border:
                                                        Border
                                                            .all(
                                                      color: theme
                                                          .colorScheme
                                                          .primary,
                                                    ),
                                                  ),
                                                  child:
                                                      Icon(
                                                    Icons
                                                        .circle,
                                                    size:
                                                        12,
                                                    color: theme
                                                        .colorScheme
                                                        .primary,
                                                  ),
                                                ),
                                                const SizedBox(
                                                    height:
                                                        6),
                                                Text(
                                                  item.name,
                                                  style: theme
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    color: theme
                                                        .colorScheme
                                                        .onSurface,
                                                  ),
                                                ),
                                                const SizedBox(
                                                    height:
                                                        6),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "₹${(item.price -
                                          (item.price *
                                                  item.discount /
                                                  100))}",
                                                      style: theme
                                                          .textTheme
                                                          .bodyLarge
                                                          ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: theme
                                                            .colorScheme
                                                            .onSurface,
                                                      ),
                                                    ),
                                                    if (item.discount >
                                                        0) ...[
                                                      const SizedBox(
                                                          width:
                                                              6),
                                                      Text(
                                                        "₹${item.price}",
                                                        style:
                                                            TextStyle(
                                                          decoration:
                                                              TextDecoration.lineThrough,
                                                          fontSize:
                                                              12,
                                                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          width:
                                                              6),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                          horizontal:
                                                              6,
                                                          vertical:
                                                              2,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: theme.colorScheme.primary.withOpacity(0.1),
                                                          borderRadius:
                                                              BorderRadius.circular(6),
                                                        ),
                                                        child:
                                                            Text(
                                                          '${item.discount}% OFF',
                                                          style:
                                                              TextStyle(
                                                            fontSize: 10,
                                                            color: theme.colorScheme.primary,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                                const SizedBox(
                                                    height:
                                                        6),
                                                if (item.tags
                                                    .isNotEmpty)
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .local_fire_department,
                                                        size:
                                                            16,
                                                        color: theme
                                                            .colorScheme
                                                            .primary,
                                                      ),
                                                      const SizedBox(
                                                          width:
                                                              4),
                                                      Expanded(
                                                        child:
                                                            Text(
                                                          item.tags.join(" · "),
                                                          style:
                                                              TextStyle(
                                                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                const SizedBox(
                                                    height:
                                                        6),
                                                Text(
                                                  item.content
                                                          .isNotEmpty
                                                      ? item
                                                          .content
                                                      : "Delicious food item",
                                                  style:
                                                      TextStyle(
                                                    color: theme
                                                        .colorScheme
                                                        .onSurface
                                                        .withOpacity(
                                                            0.7),
                                                  ),
                                                  maxLines:
                                                      2,
                                                  overflow:
                                                      TextOverflow
                                                          .ellipsis,
                                                ),
                                                const SizedBox(
                                                    height:
                                                        4),
                                                if (item
                                                    .category
                                                    .categoryName
                                                    .isNotEmpty)
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                      horizontal:
                                                          8,
                                                      vertical:
                                                          4,
                                                    ),
                                                    decoration:
                                                        BoxDecoration(
                                                      color: isDark
                                                          ? Colors.grey[800]!
                                                          : Colors.grey[100]!,
                                                      borderRadius:
                                                          BorderRadius.circular(12),
                                                    ),
                                                    child:
                                                        Text(
                                                      item.category.categoryName,
                                                      style:
                                                          TextStyle(
                                                        fontSize: 10,
                                                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                              width: 10),

                                          // Right: Image and Add Button
                                          SizedBox(
                                            width: 150,
                                            child: Column(
                                              children: [
                                                Stack(
                                                  clipBehavior:
                                                      Clip.none,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      child:
                                                          Image.network(
                                                        item.image,
                                                        width:
                                                            150,
                                                        height:
                                                            150,
                                                        fit: BoxFit
                                                            .cover,
                                                        errorBuilder:
                                                            (context, error, stackTrace) {
                                                          return Container(
                                                            width: 150,
                                                            height: 150,
                                                            color: isDark ? Colors.grey[700] : Colors.grey[200],
                                                            child: Icon(
                                                              Icons.image_not_supported,
                                                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                                                              size: 40,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                    // Consumer<
                                                    //     WishlistProvider>(
                                                    //   builder: (context,
                                                    //       wishlistProvider,
                                                    //       child) {
                                                    //     final isInWishlist = wishlistProvider
                                                    //         .isInWishlist(
                                                    //             itemId);
                                                    //     return Positioned(
                                                    //       top:
                                                    //           4,
                                                    //       right:
                                                    //           4,
                                                    //       child:
                                                    //           GestureDetector(
                                                    //         onTap: !isRestaurantActive
                                                    //             ? null
                                                    //             : () async {
                                                    //                 await wishlistProvider.toggleWishlist(
                                                    //                   userId.toString(),
                                                    //                   itemId,
                                                    //                 );
                                                    //               },
                                                    //         child:
                                                    //             CircleAvatar(
                                                    //           backgroundColor: isDark ? theme.cardColor : Colors.white,
                                                    //           radius: 14,
                                                    //           child: Icon(
                                                    //             isInWishlist ? Icons.favorite : Icons.favorite_border,
                                                    //             color: isInWishlist
                                                    //                 ? Colors.red
                                                    //                 : theme.colorScheme.onSurface,
                                                    //             size: 18,
                                                    //           ),
                                                    //         ),
                                                    //       ),
                                                    //     );
                                                    //   },
                                                    // ),

                                                                                                        Consumer<WishlistProvider>(
                                                      builder: (context,
                                                          wishlistProvider,
                                                          child) {
                                                        final isInWishlist =
                                                            wishlistProvider
                                                                .isInWishlist(
                                                                    itemId);

                                                        return Positioned(
                                                          top: 4,
                                                          right: 4,
                                                          child: _WishlistHeart(
                                                            isDark: isDark,
                                                            theme: theme,
                                                            enabled: isRestaurantActive,
                                                            initialIsInWishlist: isInWishlist,
                                                            onToggle: () async {
                                                              await wishlistProvider
                                                                  .toggleWishlist(
                                                                userId.toString(),
                                                                itemId,
                                                              );
                                                            },
                                                          ),
                                                        );
                                                      },
                                                    ),

                                                    Positioned(
                                                      left:
                                                          35,
                                                      bottom:
                                                          -20,
                                                      child:
                                                          _buildProductActionWidget(
                                                        context: context,
                                                        theme: theme,
                                                        isDark: isDark,
                                                        cartProvider: cartProvider,
                                                        canInteractProduct: canInteractProduct,
                                                        isInCart: isInCart,
                                                        cartQuantity: cartQuantity,
                                                        productId: productId,
                                                        product: product,
                                                        item: item,
                                                        restaurantId: widget.restaurantId,
                                                        userId: userId,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                    height:
                                                        25),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),

                const SizedBox(height: 100),
              ],
            ),
          );
        }),
      ),

      // Floating Action Button for Cart
      floatingActionButton:
          Consumer2<CartProvider, RestaurantProductsProvider>(
        builder:
            (context, cartProvider, restaurantProvider, child) {
          final bool isRestaurantActive =
              (restaurantProvider.restaurantStatus ?? '')
                      .toLowerCase() ==
                  'active';

          if (!cartProvider.hasItems ||
              !isRestaurantActive) {
            return const SizedBox.shrink();
          }

          return Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(
                horizontal: 16),
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CartScreen(),
                  ),
                );
              },
              backgroundColor:
                  theme.colorScheme.primary,
              label: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${cartProvider.totalItems} items | ₹${cartProvider.totalPayable.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: theme
                          .colorScheme.onPrimary,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  Text(
                    'View Cart',
                    style: TextStyle(
                      color: theme
                          .colorScheme.onPrimary,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
              icon: Icon(
                Icons.shopping_cart,
                color:
                    theme.colorScheme.onPrimary,
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildProductActionWidget({
    required BuildContext context,
    required ThemeData theme,
    required bool isDark,
    required CartProvider cartProvider,
    required bool canInteractProduct,
    required bool isInCart,
    required int cartQuantity,
    required String productId,
    required RecommendedProduct? product,
    required RecommendedItem item,
    required String restaurantId,
    required String? userId,
  }) {
    // If restaurant or product inactive → show "Unavailable"
    if (!canInteractProduct) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color:
              theme.colorScheme.onSurface.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'Unavailable',
          style: TextStyle(
            color: theme.colorScheme.onSurface
                ,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (isInCart) {
      return Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.remove,
                color: theme.colorScheme.onPrimary,
                size: 16,
              ),
              onPressed: cartProvider.isLoading
                  ? null
                  : () async {
                      if (cartQuantity > 1) {
                        await cartProvider
                            .decrementQuantity(
                                productId, userId);
                      } else {
                        await cartProvider
                            .decrementQuantity(
                                productId, userId);
                      }
                    },
              constraints:
                  const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              padding: EdgeInsets.zero,
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8),
              child: Text(
                cartQuantity.toString(),
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.add,
                color: theme.colorScheme.onPrimary,
                size: 16,
              ),
              onPressed: cartProvider.isLoading
                  ? null
                  : () async {
                      await cartProvider
                          .incrementQuantity(
                              productId, userId);
                    },
              constraints:
                  const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: cartProvider.isLoading
          ? null
          : () {
              if (product != null) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape:
                      const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(
                      top: Radius.circular(25),
                    ),
                  ),
                  builder: (context) =>
                      VegPannerBottomSheet(
                    item: item,
                    product: product,
                    productId: productId,
                    restaurantId: restaurantId,
                    userId: userId.toString(),
                  ),
                );
              }
            },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isDark ? theme.cardColor : Colors.white,
          border: Border.all(
            color: theme.colorScheme.primary,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          'ADD',
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorUI(
      RestaurantProductsProvider provider,
      ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 20),
          Text(
            "Something went wrong",
            style: theme.textTheme.titleMedium
                ?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Please try again later.",
            style: theme.textTheme.bodyMedium
                ?.copyWith(
              color: theme.colorScheme.onSurface
                  .withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              provider.fetchRestaurantProducts(
                  widget.restaurantId,widget.categoryName);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  theme.colorScheme.primary,
              foregroundColor:
                  theme.colorScheme.onPrimary,
            ),
            child: const Text("Retry"),
          )
        ],
      ),
    );
  }

  Widget _buildNoProductsUI(
      RestaurantProductsProvider provider,
      ThemeData theme,
      bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          const SizedBox(height: 80),
          Image.asset(
            "assets/images/no food.png",
            width: 180,
            color: isDark ? null : null,
          ),
          const SizedBox(height: 20),
          Text(
            "No items available",
            style: theme
                .textTheme.headlineSmall
                ?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            provider.restaurantName.isNotEmpty
                ? provider.restaurantName
                : "This restaurant has no items listed.",
            style: theme.textTheme.bodyMedium
                ?.copyWith(
              color: theme.colorScheme.onSurface
                  .withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet for selecting variation + quantity
class VegPannerBottomSheet extends StatefulWidget {
  final RecommendedItem item;
  final RecommendedProduct product;
  final String productId;
  final String restaurantId;
  final String userId;

  const VegPannerBottomSheet({
    super.key,
    required this.item,
    required this.product,
    required this.productId,
    required this.restaurantId,
    required this.userId,
  });

  @override
  _VegPannerBottomSheetState createState() =>
      _VegPannerBottomSheetState();
}

class _VegPannerBottomSheetState
    extends State<VegPannerBottomSheet> {
  late String selectedVariation;
  int quantity = 1;

  List<String> get availableVariations {
    final variations = <String>[];
    if (widget.item.halfPlatePrice > 0) {
      variations.add('Half');
    }
    if (widget.item.fullPlatePrice > 0) {
      variations.add('Full');
    }
    if (variations.isEmpty) {
      variations.add('Regular');
    }
    return variations;
  }

  @override
  void initState() {
    super.initState();
    final vars = availableVariations;
    selectedVariation = vars.first;
  }

  num _unitBasePrice() {
    switch (selectedVariation) {
      case 'Half':
        if (widget.item.halfPlatePrice > 0) {
          return widget.item.halfPlatePrice;
        }
        return widget.item.price;
      case 'Full':
        if (widget.item.fullPlatePrice > 0) {
          return widget.item.fullPlatePrice;
        }
        return widget.item.price;
      default:
        return widget.item.price;
    }
  }

  num _unitPriceWithDiscount() {
    final base = _unitBasePrice();
    if (widget.item.discount > 0) {
      return (base -
              (base * widget.item.discount / 100))
          .round();
    }
    return base;
  }

  num getPrice() {
    return _unitPriceWithDiscount() * quantity;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: SizedBox(
                  height: 40,
                  width: 40,
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(8),
                    child: Image.network(
                      widget.item.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error,
                          stackTrace) {
                        return Container(
                          color: isDark
                              ? Colors.grey[700]
                              : Colors.grey[200],
                          child: Icon(
                            Icons
                                .image_not_supported,
                            color: theme
                                .colorScheme.onSurface
                                .withOpacity(0.5),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                title: Text(
                  widget.item.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        theme.colorScheme.onSurface,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: theme.colorScheme.onSurface,
                  ),
                  onPressed: () =>
                      Navigator.pop(context),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? theme.cardColor
                      : const Color(0xFFEBF4F1),
                ),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Portion',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: theme
                              .colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Select any 1',
                        style: TextStyle(
                          color: theme
                              .colorScheme.onSurface
                              .withOpacity(0.6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(12),
                        color: isDark
                            ? theme.cardColor
                            : Colors.white,
                      ),
                      child: Column(
                        children:
                            availableVariations.map((variation) {
                          num basePrice;
                          if (variation == 'Half') {
                            basePrice =
                                widget.item.halfPlatePrice >
                                        0
                                    ? widget.item
                                        .halfPlatePrice
                                    : widget.item.price;
                          } else if (variation ==
                              'Full') {
                            basePrice =
                                widget.item.fullPlatePrice >
                                        0
                                    ? widget.item
                                        .fullPlatePrice
                                    : widget.item.price;
                          } else {
                            basePrice =
                                widget.item.price;
                          }

                          final discounted =
                              widget.item.discount >
                                      0
                                  ? (basePrice -
                                          (basePrice *
                                                  widget
                                                      .item
                                                      .discount /
                                                  100))
                                      .round()
                                  : basePrice;

                          return ListTile(
                            title: Text(
                              variation,
                              style: TextStyle(
                                color: theme
                                    .colorScheme
                                    .onSurface,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize:
                                  MainAxisSize.min,
                              children: [
                                if (widget.item
                                        .discount >
                                    0) ...[
                                  Text(
                                    '₹$discounted',
                                    style: TextStyle(
                                      color: theme
                                          .colorScheme
                                          .onSurface,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                                  const SizedBox(
                                      width: 6),
                                  Text(
                                    '₹$basePrice',
                                    style:
                                        TextStyle(
                                      decoration:
                                          TextDecoration
                                              .lineThrough,
                                      fontSize: 12,
                                      color: theme
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(
                                              0.6),
                                    ),
                                  ),
                                ] else
                                  Text(
                                    '₹$basePrice',
                                    style: TextStyle(
                                      color: theme
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                              ],
                            ),
                            leading: Radio<String>(
                              value: variation,
                              groupValue:
                                  selectedVariation,
                              onChanged: (val) =>
                                  setState(() =>
                                      selectedVariation =
                                          val!),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    // Quantity selector
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme
                              .colorScheme.onSurface
                              .withOpacity(0.4),
                        ),
                        borderRadius:
                            BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: quantity > 1
                                ? () => setState(
                                    () => quantity--)
                                : null,
                            icon: Icon(
                              Icons.remove,
                              color: theme
                                  .colorScheme
                                  .onSurface,
                            ),
                          ),
                          Text(
                            '$quantity',
                            style: TextStyle(
                              color: theme
                                  .colorScheme.onSurface,
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                setState(() =>
                                    quantity++),
                            icon: Icon(
                              Icons.add,
                              color: theme
                                  .colorScheme
                                  .onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton
                          .styleFrom(
                        backgroundColor: theme
                            .colorScheme.primary,
                        foregroundColor: theme
                            .colorScheme.onPrimary,
                        shape:
                            const StadiumBorder(),
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      onPressed: cartProvider
                              .isLoading
                          ? null
                          : () async {
                              // final success =
                              //     await cartProvider
                              //         .addItemToCart(
                              //   restaurantProductId:
                              //       widget
                              //           .productId,
                              //   recommendedId: widget
                              //       .item.itemId,
                              //   quantity: quantity,
                              //   variation:
                              //       selectedVariation,
                              //   plateItems:
                              //       0, // no extra plate add-ons
                              //   userId: widget.userId
                              //       .toString(),
                              // );
//                               final success = await cartProvider.addItemToCart(
//   restaurantProductId: widget.productId,
//   recommendedId: widget.item.itemId,
//   quantity: quantity,
//   variation: selectedVariation, // "Half" / "Full" / "Regular"
//   plateItems: 0,
//   userId: widget.userId.toString(),
// );
final success = await addToCartWithVendorGuard(
  context: context,
  cartProvider: cartProvider,
  restaurantIdOfProduct: widget.restaurantId, // 🔑 vendor id of this product
  restaurantProductId: widget.productId,
  recommendedId: widget.item.itemId,
  quantity: quantity,
  variation: selectedVariation, // "Half" / "Full" / "Regular"
  plateItems: 0,
  userId: widget.userId.toString(),
);


                              if (success) {
                                Navigator.pop(
                                    context);
                                ScaffoldMessenger
                                        .of(context)
                                    .showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${widget.item.name} added to cart!'),
                                    behavior:
                                        SnackBarBehavior
                                            .floating,
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                                  12),
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger
                                        .of(context)
                                    .showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      cartProvider.error ??
                                          'Failed to add item to cart',
                                    ),
                                    behavior:
                                        SnackBarBehavior
                                            .floating,
                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                                  12),
                                    ),
                                  ),
                                );
                              }
                            },
                      child: cartProvider.isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<
                                        Color>(
                                  theme.colorScheme
                                      .onPrimary,
                                ),
                              ),
                            )
                          : Text(
                              'Add Item | ₹${getPrice()}',
                              style: TextStyle(
                                color: theme
                                    .colorScheme
                                    .onPrimary,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

/// NEW SCREEN: Restaurant Reviews
class RestaurantReviewsScreen extends StatelessWidget {
  final String restaurantName;
  final int totalRatings;
  final int totalReviews;
  final List<RestaurantReview> reviews;

  const RestaurantReviewsScreen({
    super.key,
    required this.restaurantName,
    required this.totalRatings,
    required this.totalReviews,
    required this.reviews,
  });

  double get averageRating {
    if (totalReviews == 0) return 0.0;
    return totalRatings / totalReviews;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avg = averageRating;

    return Scaffold(
      appBar: AppBar(title: const Text('Reviews')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  restaurantName,
                  style: theme
                      .textTheme.titleMedium
                      ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets
                          .symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme
                            .colorScheme.primary,
                        borderRadius:
                            BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: theme
                                .colorScheme.onPrimary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            avg.toStringAsFixed(1),
                            style: TextStyle(
                              color: theme
                                  .colorScheme
                                  .onPrimary,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$totalReviews review${totalReviews == 1 ? '' : 's'}',
                      style: TextStyle(
                        color: theme
                            .colorScheme.onSurface
                            .withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 0),
          Expanded(
            child: reviews.isEmpty
                ? Center(
                    child: Text(
                      'No reviews yet.',
                      style: theme
                          .textTheme.bodyMedium
                          ?.copyWith(
                        color: theme
                            .colorScheme.onSurface
                            .withOpacity(0.6),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviews[index];

                      final userName =
                          review.username.isNotEmpty
                              ? review.username
                              : "User ${index + 1}";

                      final userImage =
                          review.userimage.isNotEmpty
                              ? review.userimage
                              : "https://cdn-icons-png.flaticon.com/512/847/847969.png";

                      return ListTile(
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundImage:
                              NetworkImage(
                                  userImage),
                        ),
                        title: Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                userName,
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .w600,
                                  color: theme
                                      .colorScheme
                                      .onSurface,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize:
                                  MainAxisSize.min,
                              children:
                                  List.generate(
                                5,
                                (i) => Icon(
                                  i < review.stars
                                      ? Icons
                                          .star
                                      : Icons
                                          .star_border,
                                  size: 16,
                                  color: theme
                                      .colorScheme
                                      .primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            const SizedBox(
                                height: 4),
                            Text(
                              review.comment
                                      .isNotEmpty
                                  ? review.comment
                                  : 'No comment',
                              style: TextStyle(
                                  color: theme
                                      .colorScheme
                                      .onSurface),
                            ),
                            const SizedBox(
                                height: 4),
                            Text(
                              DateFormat(
                                      'dd MMM yyyy, hh:mm a')
                                  .format(review
                                      .createdAt
                                      .toLocal()),
                              style: TextStyle(
                                fontSize: 12,
                                color: theme
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(
                                        0.6),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
class _WishlistHeart extends StatefulWidget {
  final bool isDark;
  final ThemeData theme;
  final bool enabled;
  final bool initialIsInWishlist;
  final Future<void> Function() onToggle;

  const _WishlistHeart({
    required this.isDark,
    required this.theme,
    required this.enabled,
    required this.initialIsInWishlist,
    required this.onToggle,
  });

  @override
  State<_WishlistHeart> createState() => _WishlistHeartState();
}

class _WishlistHeartState extends State<_WishlistHeart> {
  late bool _isInWishlist;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _isInWishlist = widget.initialIsInWishlist;
  }

  @override
  void didUpdateWidget(covariant _WishlistHeart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync with provider if it changes externally (e.g. from another screen)
    if (!_isProcessing &&
        oldWidget.initialIsInWishlist != widget.initialIsInWishlist) {
      _isInWishlist = widget.initialIsInWishlist;
    }
  }

  Future<void> _handleTap() async {
    if (!widget.enabled || _isProcessing) return;

    // Optimistic UI update
    setState(() {
      _isInWishlist = !_isInWishlist;
      _isProcessing = true;
    });

    try {
      await widget.onToggle();
    } catch (_) {
      // If API fails you COULD revert, but user only asked for UI,
      // so we keep current state and just stop processing.
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return GestureDetector(
      onTap: _handleTap,
      child: CircleAvatar(
        backgroundColor: widget.isDark ? theme.cardColor : Colors.white,
        radius: 14,
        child: Icon(
          _isInWishlist ? Icons.favorite : Icons.favorite_border,
          color: _isInWishlist ? Colors.red : theme.colorScheme.onSurface,
          size: 18,
        ),
      ),
    );
  }
}
