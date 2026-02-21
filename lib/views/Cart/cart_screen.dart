// // cart_screen.dart
// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import 'package:veegify/helper/storage_helper.dart';
// import 'package:veegify/model/CartModel/cart_model.dart';
// import 'package:veegify/model/user_model.dart';
// import 'package:veegify/provider/CartProvider/cart_provider.dart';
// import 'package:veegify/provider/BookingProvider/booking_provider.dart';
// import 'package:veegify/views/Booking/checkout_screen.dart';
// import 'package:veegify/views/Cart/cart_summary.dart';
// import 'package:veegify/views/PaymentSuccess/payment_success_screen.dart';

// // lifecycle
// import 'package:veegify/core/app_lifecycle_service.dart';

// // responsive util
// import 'package:veegify/utils/responsive.dart';

// class CartScreenWithController extends StatelessWidget {
//   final ScrollController scrollController;

//   const CartScreenWithController({super.key, required this.scrollController});

//   @override
//   Widget build(BuildContext context) {
//     return CartScreen(scrollController: scrollController);
//   }
// }

// class CartScreen extends StatefulWidget {
//   final ScrollController? scrollController;

//   const CartScreen({super.key, this.scrollController});

//   @override
//   State<CartScreen> createState() => _CartScreenState();
// }

// class _CartScreenState extends State<CartScreen> {
//   final TextEditingController _couponController = TextEditingController();
//   bool _isCouponLoading = false;
//   User? user;

//   /// 🔁 Polling timer
//   Timer? _pollingTimer;

//   /// Dialog flags (so we don’t spam)
//   bool _vendorInactiveHandled = false;
//   bool _productInactiveHandled = false;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _initializeCart();
//     });
//   }

//   Future<void> _initializeCart() async {
//     await _loadUserId();

//     final cartProvider = Provider.of<CartProvider>(context, listen: false);
//     await cartProvider.loadCart(user?.userId.toString());

//     // handle status once initially
//     await _handleStatusChanges(cartProvider);

//     // start periodic polling
//     _startCartPolling();
//   }

//   Future<void> _loadUserId() async {
//     final userData = UserPreferences.getUser();
//     if (userData != null) {
//       setState(() {
//         user = userData;
//       });
//       debugPrint("✅ Loaded User ID in CartScreen: ${user?.userId}");

//       final cartProvider = Provider.of<CartProvider>(context, listen: false);
//       cartProvider.setUserId(user!.userId.toString());
//     } else {
//       debugPrint("⚠️ No user found in UserPreferences");
//     }
//   }

//   void _startCartPolling() {
//     _pollingTimer?.cancel();

//     if (user == null) {
//       debugPrint("⛔ Polling not started: user is null");
//       return;
//     }

//     debugPrint("✅ Starting cart polling every 5 seconds");

//     _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
//       if (!mounted) return;

//       // 🔒 Only poll when app is visible (foreground)
//       if (!AppLifecycleService.instance.isAppInForeground) {
//         return;
//       }

//       // 🔒 Only poll when THIS screen is on top of stack
//       final route = ModalRoute.of(context);
//       final isRouteCurrent = route?.isCurrent ?? true;
//       if (!isRouteCurrent) {
//         return;
//       }

//       final cartProvider = Provider.of<CartProvider>(context, listen: false);

//       debugPrint("🔄 [Cart Poll] loadCart for user: ${user?.userId}");
//       await cartProvider.loadCart(user?.userId.toString());

//       // after refresh, check statuses
//       _handleStatusChanges(cartProvider);
//     });
//   }

//   void _stopCartPolling() {
//     debugPrint("🛑 Stopping cart polling");
//     _pollingTimer?.cancel();
//     _pollingTimer = null;
//   }

//   @override
//   void dispose() {
//     _stopCartPolling();
//     _couponController.dispose();
//     super.dispose();
//   }

//   void _showSnackBar(String message, Color backgroundColor) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: backgroundColor,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   Future<void> _applyCoupon(CartProvider cartProvider) async {
//     if (_couponController.text.trim().isEmpty) {
//       _showSnackBar('Please enter a coupon code', Colors.red);
//       return;
//     }

//     setState(() => _isCouponLoading = true);

//     try {
//       final success = await cartProvider.applyCoupon(
//         _couponController.text.trim(),
//       );

//       if (!mounted) return;
//       setState(() => _isCouponLoading = false);

//       if (success) {
//         _showSnackBar('Coupon applied successfully!', Colors.green);
//         _couponController.clear();
//       } else {
//         _showSnackBar(
//           cartProvider.error ?? 'Failed to apply coupon',
//           Colors.red,
//         );
//       }
//     } catch (e) {
//       if (!mounted) return;
//       setState(() => _isCouponLoading = false);
//       _showSnackBar('Error: $e', Colors.red);
//     }
//   }

//   Future<void> _removeCoupon(CartProvider cartProvider) async {
//     try {
//       final success = await cartProvider.removeCoupon();
//       if (success) {
//         _showSnackBar('Coupon removed', Colors.green);
//       } else {
//         _showSnackBar(
//           cartProvider.error ?? 'Failed to remove coupon',
//           Colors.red,
//         );
//       }
//     } catch (e) {
//       _showSnackBar('Error: $e', Colors.red);
//     }
//   }

//   Future<void> _handleCheckout(CartProvider cartProvider) async {
//     try {
//       if (!cartProvider.isVendorActive) {
//         _showSnackBar('Restaurant is closed. Cannot proceed.', Colors.red);
//         return;
//       }
//       if (cartProvider.hasInactiveProducts) {
//         _showSnackBar('Remove unavailable items before checkout.', Colors.red);
//         return;
//       }

//       _showSnackBar('Processing order...', Colors.blue);

//       if (mounted) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const CheckoutScreen()),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         _showSnackBar('Failed to place order: $e', Colors.red);
//       }
//     }
//   }

//   /// 🔥 Checks restaurant & product statuses after each refresh / initial load.
//   Future<void> _handleStatusChanges(CartProvider cartProvider) async {
//     if (!mounted) return;
//     if (!cartProvider.hasItems) return;

//     // 1️⃣ Vendor inactive -> clear cart and block
//     if (!cartProvider.isVendorActive && !_vendorInactiveHandled) {
//       _vendorInactiveHandled = true;

//       await showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (ctx) {
//           return AlertDialog(
//             title: const Text('Restaurant Closed'),
//             content: const Text(
//               'The restaurant is currently inactive/closed. '
//               'Your cart items from this vendor will be removed.',
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(ctx).pop(),
//                 child: const Text('OK'),
//               ),
//             ],
//           );
//         },
//       );

//       await cartProvider.clearCart();
//       if (mounted) {
//         _showSnackBar('Restaurant is closed. Cart cleared.', Colors.red);
//       }
//       return;
//     }

//     // 2️⃣ Some products inactive -> prompt to remove
//     if (cartProvider.hasInactiveProducts &&
//         !_productInactiveHandled &&
//         cartProvider.isVendorActive) {
//       _productInactiveHandled = true;

//       final inactiveProducts = cartProvider.items
//           .where((p) => !p.isProductActive)
//           .toList();

//       final names = inactiveProducts.map((p) => p.name).join(', ');

//       final remove = await showDialog<bool>(
//         context: context,
//         barrierDismissible: false,
//         builder: (ctx) {
//           return AlertDialog(
//             title: const Text('Items Unavailable'),
//             content: Text(
//               'Some items are no longer available:\n\n'
//               '$names\n\n'
//               'Do you want to remove them from the cart '
//               'and continue with remaining items?',
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(ctx).pop(false),
//                 child: const Text('Cancel'),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.of(ctx).pop(true),
//                 child: const Text('Remove & Continue'),
//               ),
//             ],
//           );
//         },
//       );

//       if (remove == true) {
//         for (final p in inactiveProducts) {
//           await cartProvider.removeItem(p.id, user?.userId.toString());
//         }
//         if (mounted) {
//           _showSnackBar('Unavailable items removed from cart.', Colors.orange);
//         }
//       } else {
//         // user cancelled, allow showing dialog again later
//         _productInactiveHandled = false;
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     final isMobile = Responsive.isMobile(context);
//     final isTablet = Responsive.isTablet(context);
//     final isDesktop = Responsive.isDesktop(context);

//     final width = MediaQuery.of(context).size.width;

//     final double horizontalPadding = width >= 1200
//         ? 40
//         : width >= 900
//         ? 24
//         : 16;

//     final double maxWidth = width >= 1400
//         ? 1200
//         : width >= 1100
//         ? 1100
//         : width >= 900
//         ? 900
//         : double.infinity;

//     // final double horizontalPadding = isMobile ? 16 : 24;
//     // final double maxWidth =
//     //     isDesktop ? 1100 : (isTablet ? 900 : double.infinity);

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       body: SafeArea(
//         child: Consumer<CartProvider>(
//           builder: (context, cartProvider, child) {
//             if (cartProvider.isLoading && !cartProvider.hasItems) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CircularProgressIndicator(color: colorScheme.primary),
//                     const SizedBox(height: 16),
//                     Text(
//                       'Loading cart...',
//                       style: theme.textTheme.bodyMedium?.copyWith(
//                         color: colorScheme.onSurface.withOpacity(0.7),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }

//             if (cartProvider.error != null && !cartProvider.hasItems) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.error_outline,
//                       size: 64,
//                       color: colorScheme.error,
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       'Error: ${cartProvider.error}',
//                       style: theme.textTheme.bodyMedium,
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 16),
//                     ElevatedButton(
//                       onPressed: _initializeCart,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: colorScheme.primary,
//                         foregroundColor: colorScheme.onPrimary,
//                       ),
//                       child: const Text('Retry'),
//                     ),
//                   ],
//                 ),
//               );
//             }

//             if (!cartProvider.hasItems) {
//               return EmptyCartWidget(theme: theme, colorScheme: colorScheme);
//             }

//             return RefreshIndicator(
//               onRefresh: () => cartProvider.loadCart(user?.userId.toString()),
//               color: colorScheme.primary,
//               child: SingleChildScrollView(
//                 controller: widget.scrollController,
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 child: Center(
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(maxWidth: maxWidth),
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: horizontalPadding,
//                         vertical: 16,
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           _buildHeader(theme, colorScheme),
//                           const SizedBox(height: 20),

//                           // 🔥 Status banners
//                           if (!cartProvider.isVendorActive)
//                             _buildVendorClosedBanner(theme, colorScheme),
//                           if (cartProvider.hasInactiveProducts &&
//                               cartProvider.isVendorActive)
//                             _buildInactiveProductsBanner(
//                               cartProvider,
//                               theme,
//                               colorScheme,
//                             ),

//                           const SizedBox(height: 10),

//                           // 📱 Mobile: stacked layout
//                           // 💻 Tablet/Desktop: 2-column layout
//                           if (isMobile) ...[
//                             // _buildCartList(
//                             //   cartProvider,
//                             //   theme,
//                             //   colorScheme,
//                             // ),
//                             _buildSectionCard(
//                               theme: theme,
//                               colorScheme: colorScheme,
//                               child: _buildCartList(
//                                 cartProvider,
//                                 theme,
//                                 colorScheme,
//                               ),
//                             ),
//                             const SizedBox(height: 20),
//                             _buildCouponSection(
//                               context,
//                               cartProvider,
//                               theme,
//                               colorScheme,
//                             ),
//                             const SizedBox(height: 10),

//                             // TicketPricingSummary(
//                             //   cartProvider: cartProvider,
//                             //   theme: theme,
//                             //   colorScheme: colorScheme,
//                             // ),
//                             _buildSectionCard(
//                               theme: theme,
//                               colorScheme: colorScheme,
//                               child: TicketPricingSummary(
//                                 cartProvider: cartProvider,
//                                 theme: theme,
//                                 colorScheme: colorScheme,
//                               ),
//                             ),
//                             const SizedBox(height: 20),
//                             _buildCheckoutButton(
//                               cartProvider,
//                               theme,
//                               colorScheme,
//                             ),
//                             const SizedBox(height: 20),
//                           ] else ...[
//                             Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 // Cart list
//                                 // Expanded(
//                                 //   flex: isDesktop ? 3 : 4,
//                                 //   // flex: 3,
//                                 //   child: Column(
//                                 //     crossAxisAlignment:
//                                 //         CrossAxisAlignment.start,
//                                 //     children: [
//                                 //       _buildCartList(
//                                 //         cartProvider,
//                                 //         theme,
//                                 //         colorScheme,
//                                 //       ),
//                                 //     ],
//                                 //   ),
//                                 // ),
//                                 Expanded(
//                                   flex: 3,
//                                   child: _buildSectionCard(
//                                     theme: theme,
//                                     colorScheme: colorScheme,
//                                     child: _buildCartList(
//                                       cartProvider,
//                                       theme,
//                                       colorScheme,
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 24),

//                                 Expanded(
//                                   flex: 2,
//                                   child: _StickySummaryCard(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.stretch,
//                                       children: [
//                                         _buildSectionCard(
//                                           theme: theme,
//                                           colorScheme: colorScheme,
//                                           child: TicketPricingSummary(
//                                             cartProvider: cartProvider,
//                                             theme: theme,
//                                             colorScheme: colorScheme,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 14),
//                                         _buildCheckoutButton(
//                                           cartProvider,
//                                           theme,
//                                           colorScheme,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),

//                                 // Summary and coupon
//                                 // Expanded(
//                                 //   flex: isDesktop ? 2 : 3,
//                                 //   // flex: 2,
//                                 //   child: Column(
//                                 //     crossAxisAlignment:
//                                 //         CrossAxisAlignment.stretch,
//                                 //     children: [
//                                 //       // _buildCouponSection(
//                                 //       //   context,
//                                 //       //   cartProvider,
//                                 //       //   theme,
//                                 //       //   colorScheme,
//                                 //       // ),
//                                 //       // const SizedBox(height: 12),
//                                 //       TicketPricingSummary(
//                                 //         cartProvider: cartProvider,
//                                 //         theme: theme,
//                                 //         colorScheme: colorScheme,
//                                 //       ),
//                                 //       const SizedBox(height: 16),
//                                 //       _buildCheckoutButton(
//                                 //         cartProvider,
//                                 //         theme,
//                                 //         colorScheme,
//                                 //       ),
//                                 //     ],
//                                 //   ),
//                                 // ),
//                               ],
//                             ),
//                             const SizedBox(height: 20),
//                           ],
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
//     return Row(
//       children: [
//         CircleAvatar(
//           radius: 25,
//           backgroundColor: colorScheme.primary.withOpacity(0.1),
//           child: Icon(Icons.shopping_cart, color: colorScheme.primary),
//         ),
//         const SizedBox(width: 20),
//         Text(
//           'My Cart',
//           style: theme.textTheme.titleLarge?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCouponSection(
//     BuildContext context,
//     CartProvider cartProvider,
//     ThemeData theme,
//     ColorScheme colorScheme,
//   ) {
//     final isMobile = Responsive.isMobile(context);

//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: theme.cardColor,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
//       ),
//       child: isMobile
//           ? Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Have a coupon?',
//                   style: theme.textTheme.titleSmall?.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 TextField(
//                   controller: _couponController,
//                   decoration: InputDecoration(
//                     hintText: 'Enter coupon code',
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     ElevatedButton(
//                       onPressed: _isCouponLoading
//                           ? null
//                           : () => _applyCoupon(cartProvider),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: colorScheme.primary,
//                         foregroundColor: colorScheme.onPrimary,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 10,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       child: _isCouponLoading
//                           ? SizedBox(
//                               width: 18,
//                               height: 18,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 valueColor: AlwaysStoppedAnimation<Color>(
//                                   colorScheme.onPrimary,
//                                 ),
//                               ),
//                             )
//                           : const Text('Apply'),
//                     ),
//                     const SizedBox(width: 8),
//                     TextButton(
//                       onPressed: () => _removeCoupon(cartProvider),
//                       child: const Text('Remove'),
//                     ),
//                   ],
//                 ),
//               ],
//             )
//           : Row(
//               children: [
//                 Expanded(
//                   flex: 2,
//                   child: TextField(
//                     controller: _couponController,
//                     decoration: InputDecoration(
//                       labelText: 'Coupon code',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 ElevatedButton(
//                   onPressed: _isCouponLoading
//                       ? null
//                       : () => _applyCoupon(cartProvider),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: colorScheme.primary,
//                     foregroundColor: colorScheme.onPrimary,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 18,
//                       vertical: 14,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   child: _isCouponLoading
//                       ? SizedBox(
//                           width: 18,
//                           height: 18,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             valueColor: AlwaysStoppedAnimation<Color>(
//                               colorScheme.onPrimary,
//                             ),
//                           ),
//                         )
//                       : const Text('Apply'),
//                 ),
//                 const SizedBox(width: 8),
//                 TextButton(
//                   onPressed: () => _removeCoupon(cartProvider),
//                   child: const Text('Remove'),
//                 ),
//               ],
//             ),
//     );
//   }

//   Widget _buildCartList(
//     CartProvider cartProvider,
//     ThemeData theme,
//     ColorScheme colorScheme,
//   ) {
//     for (var item in cartProvider.items) {
//       debugPrint(
//         "🛒 Cart Item -> ID: ${item.id}, Name: ${item.name}, Qty: ${item.quantity}",
//       );
//     }

//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: cartProvider.items.length,
//       itemBuilder: (context, index) {
//         final item = cartProvider.items[index];
//         return CartItemWidget(
//           cartProduct: item,
//           onIncrement: () async {
//             try {
//               await cartProvider.incrementQuantity(
//                 item.id,
//                 user?.userId.toString(),
//               );
//             } catch (e) {
//               _showSnackBar('Failed to update: $e', Colors.red);
//             }
//           },
//           onDecrement: () async {
//             try {
//               await cartProvider.decrementQuantity(
//                 item.id,
//                 user?.userId.toString(),
//               );
//             } catch (e) {
//               _showSnackBar('Failed to update: $e', Colors.red);
//             }
//           },
//           onRemove: () async {
//             try {
//               await cartProvider.removeItem(item.id, user?.userId.toString());
//               _showSnackBar('Item removed', Colors.green);
//             } catch (e) {
//               _showSnackBar('Failed to remove: $e', Colors.red);
//             }
//           },
//           theme: theme,
//           colorScheme: colorScheme,
//         );
//       },
//     );
//   }

//   Widget _buildCheckoutButton(
//     CartProvider cartProvider,
//     ThemeData theme,
//     ColorScheme colorScheme,
//   ) {
//     final isDisabled =
//         cartProvider.isLoading ||
//         !cartProvider.hasItems ||
//         !cartProvider.isVendorActive ||
//         cartProvider.hasInactiveProducts; // 👈 disable if any issue

//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: isDisabled ? null : () => _handleCheckout(cartProvider),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: colorScheme.primary,
//           foregroundColor: colorScheme.onPrimary,
//           disabledBackgroundColor: colorScheme.onSurface.withOpacity(0.12),
//           disabledForegroundColor: colorScheme.onSurface.withOpacity(0.38),
//           padding: const EdgeInsets.symmetric(vertical: 16),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//         child: Text(
//           'Checkout',
//           style: theme.textTheme.titleMedium?.copyWith(
//             color: colorScheme.onPrimary,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionCard({
//     required ThemeData theme,
//     required ColorScheme colorScheme,
//     required Widget child,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: theme.cardColor,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: colorScheme.outline.withOpacity(0.15)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }

//   Widget _buildVendorClosedBanner(ThemeData theme, ColorScheme colorScheme) {
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: colorScheme.errorContainer,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.store_mall_directory, color: colorScheme.onErrorContainer),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               'This restaurant is currently closed. '
//               'You cannot continue with this cart.',
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 color: colorScheme.onErrorContainer,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInactiveProductsBanner(
//     CartProvider cartProvider,
//     ThemeData theme,
//     ColorScheme colorScheme,
//   ) {
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: colorScheme.tertiaryContainer,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.info_outline, color: colorScheme.onTertiaryContainer),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               'Some items in your cart are no longer available. '
//               'Please remove them to continue.',
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 color: colorScheme.onTertiaryContainer,
//               ),
//             ),
//           ),
//           TextButton(
//             onPressed: () async {
//               final provider = Provider.of<CartProvider>(
//                 context,
//                 listen: false,
//               );
//               await _handleStatusChanges(provider);
//             },
//             child: const Text('FIX'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class EmptyCartWidget extends StatelessWidget {
//   final ThemeData theme;
//   final ColorScheme colorScheme;

//   const EmptyCartWidget({
//     super.key,
//     required this.theme,
//     required this.colorScheme,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isDesktop = Responsive.isDesktop(context);
//     final iconSize = isDesktop ? 140.0 : 100.0;

//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.shopping_cart_outlined,
//               size: iconSize,
//               color: colorScheme.onSurface.withOpacity(0.5),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Your cart is empty',
//               style: theme.textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//                 color: colorScheme.onSurface,
//               ),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               'Add some delicious items to your cart',
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 color: colorScheme.onSurface.withOpacity(0.7),
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 30),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class CartItemWidget extends StatelessWidget {
//   final CartProduct cartProduct;
//   final VoidCallback onIncrement;
//   final VoidCallback onDecrement;
//   final VoidCallback onRemove;
//   final ThemeData theme;
//   final ColorScheme colorScheme;

//   const CartItemWidget({
//     super.key,
//     required this.cartProduct,
//     required this.onIncrement,
//     required this.onDecrement,
//     required this.onRemove,
//     required this.theme,
//     required this.colorScheme,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final bool isInactive = !cartProduct.isProductActive;

//     return Opacity(
//       opacity: isInactive ? 0.6 : 1.0,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: theme.cardColor,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.06),
//               spreadRadius: 1,
//               blurRadius: 4,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: Image.network(
//                 cartProduct.image,
//                 width: 60,
//                 height: 60,
//                 fit: BoxFit.cover,
//                 loadingBuilder: (context, child, loadingProgress) {
//                   if (loadingProgress == null) return child;
//                   return Container(
//                     width: 60,
//                     height: 60,
//                     color: colorScheme.surfaceVariant,
//                     child: Center(
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: colorScheme.primary,
//                       ),
//                     ),
//                   );
//                 },
//                 errorBuilder: (_, __, ___) => Container(
//                   width: 60,
//                   height: 60,
//                   color: colorScheme.surfaceVariant,
//                   child: Icon(
//                     Icons.image,
//                     size: 30,
//                     color: colorScheme.onSurfaceVariant,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     cartProduct.name,
//                     style: theme.textTheme.titleSmall?.copyWith(
//                       fontWeight: FontWeight.w600,
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 4),
//                   if (cartProduct.addOn.variation.isNotEmpty)
//                     Text(
//                       'Size: ${cartProduct.addOn.variation}',
//                       style: theme.textTheme.bodySmall?.copyWith(
//                         color: colorScheme.onSurface.withOpacity(0.7),
//                       ),
//                     ),
//                   if (cartProduct.addOn.plateitems > 0) ...[
//                     const SizedBox(height: 2),
//                     Text(
//                       'Plates: ${cartProduct.addOn.plateitems}',
//                       style: theme.textTheme.bodySmall?.copyWith(
//                         color: colorScheme.onSurface.withOpacity(0.7),
//                       ),
//                     ),
//                   ],
//                   const SizedBox(height: 4),
//                   Text(
//                     '₹${cartProduct.price}',
//                     style: theme.textTheme.titleSmall?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: colorScheme.primary,
//                     ),
//                   ),
//                   if (isInactive) ...[
//                     const SizedBox(height: 6),
//                     Text(
//                       'This item is unavailable. Please remove to continue.',
//                       style: theme.textTheme.bodySmall?.copyWith(
//                         color: colorScheme.error,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: TextButton(
//                         onPressed: onRemove,
//                         child: const Text('Remove'),
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//             Column(
//               children: [
//                 // Quantity controls (disabled if inactive)
//                 Row(
//                   children: [
//                     GestureDetector(
//                       onTap: isInactive ? null : onDecrement,
//                       child: Container(
//                         width: 32,
//                         height: 32,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: isInactive
//                               ? colorScheme.onSurface.withOpacity(0.15)
//                               : colorScheme.primary,
//                         ),
//                         child: Icon(
//                           Icons.remove,
//                           size: 18,
//                           color: isInactive
//                               ? colorScheme.onSurface.withOpacity(0.4)
//                               : colorScheme.onPrimary,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     SizedBox(
//                       width: 28,
//                       child: Text(
//                         cartProduct.quantity.toString().padLeft(2, '0'),
//                         textAlign: TextAlign.center,
//                         style: theme.textTheme.bodyMedium?.copyWith(
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     GestureDetector(
//                       onTap: isInactive ? null : onIncrement,
//                       child: Container(
//                         width: 32,
//                         height: 32,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: isInactive
//                               ? colorScheme.onSurface.withOpacity(0.15)
//                               : colorScheme.primary,
//                         ),
//                         child: Icon(
//                           Icons.add,
//                           size: 18,
//                           color: isInactive
//                               ? colorScheme.onSurface.withOpacity(0.4)
//                               : colorScheme.onPrimary,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 // Delete icon
//                 GestureDetector(
//                   onTap: onRemove,
//                   child: Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: colorScheme.errorContainer,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       Icons.delete,
//                       size: 20,
//                       color: colorScheme.onErrorContainer,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class RowItem extends StatelessWidget {
//   final String label;
//   final String value;
//   final Color? valueColor;
//   final FontWeight? fontWeight;
//   final ThemeData theme;
//   final ColorScheme colorScheme;

//   const RowItem({
//     super.key,
//     required this.label,
//     required this.value,
//     this.valueColor,
//     this.fontWeight,
//     required this.theme,
//     required this.colorScheme,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: theme.textTheme.bodyMedium?.copyWith(
//               color: colorScheme.onSurface.withOpacity(0.7),
//               fontWeight: fontWeight,
//             ),
//           ),
//           Text(
//             value,
//             style: theme.textTheme.bodyMedium?.copyWith(
//               color: valueColor ?? colorScheme.onSurface,
//               fontWeight: fontWeight,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _StickySummaryCard extends StatelessWidget {
//   final Widget child;

//   const _StickySummaryCard({required this.child});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 4),
//       child: Align(alignment: Alignment.topCenter, child: child),
//     );
//   }
// }



























// // cart_screen.dart
// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:provider/provider.dart';

// import 'package:veegify/helper/storage_helper.dart';
// import 'package:veegify/model/CartModel/cart_model.dart';
// import 'package:veegify/model/user_model.dart';
// import 'package:veegify/provider/CartProvider/cart_provider.dart';
// import 'package:veegify/views/Booking/checkout_screen.dart';
// import 'package:veegify/views/Cart/cart_summary.dart';
// import 'package:veegify/core/app_lifecycle_service.dart';
// import 'package:veegify/utils/responsive.dart';
// import 'package:veegify/views/Coupons/coupon_picker_modal.dart';

// const String _kRemoveCouponUrl = 'https://api.vegiffyy.com/api/remove-coupon';

// // ──────────────────────────────────────────────────────────────────────────
// class CartScreenWithController extends StatelessWidget {
//   final ScrollController scrollController;
//   const CartScreenWithController({super.key, required this.scrollController});

//   @override
//   Widget build(BuildContext context) =>
//       CartScreen(scrollController: scrollController);
// }

// // ──────────────────────────────────────────────────────────────────────────
// class CartScreen extends StatefulWidget {
//   final ScrollController? scrollController;
//   const CartScreen({super.key, this.scrollController});

//   @override
//   State<CartScreen> createState() => _CartScreenState();
// }

// class _CartScreenState extends State<CartScreen> {
//   User? user;
//   Timer? _pollingTimer;
//   bool _vendorInactiveHandled = false;
//   bool _productInactiveHandled = false;

//   // ── Coupon local state (ZERO CartProvider connection) ────────────────────
//   String? _appliedCouponId;   // stored after successful apply
//   String? _appliedCouponCode; // shown in the bar
//   bool _isRemovingCoupon = false;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) => _initializeCart());
//   }

//   @override
//   void dispose() {
//     _stopPolling();
//     super.dispose();
//   }

//   // ── Init ──────────────────────────────────────────────────────────────────
//   Future<void> _initializeCart() async {
//     await _loadUser();
//     final cp = context.read<CartProvider>();
//     await cp.loadCart(user?.userId.toString());
//     await _handleStatusChanges(cp);
//     _startPolling();
//   }

//   Future<void> _loadUser() async {
//     final u = UserPreferences.getUser();
//     if (u != null) {
//       setState(() => user = u);
//       context.read<CartProvider>().setUserId(u.userId.toString());
//     }
//   }

//   // ── Polling ───────────────────────────────────────────────────────────────
//   void _startPolling() {
//     _pollingTimer?.cancel();
//     if (user == null) return;
//     _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
//       if (!mounted) return;
//       if (!AppLifecycleService.instance.isAppInForeground) return;
//       if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;
//       final cp = context.read<CartProvider>();
//       await cp.loadCart(user?.userId.toString());
//       _handleStatusChanges(cp);
//     });
//   }

//   void _stopPolling() {
//     _pollingTimer?.cancel();
//     _pollingTimer = null;
//   }

//   // ── Snackbar ──────────────────────────────────────────────────────────────
//   void _snack(String msg, Color color) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text(msg),
//       backgroundColor: color,
//       behavior: SnackBarBehavior.floating,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       duration: const Duration(seconds: 2),
//     ));
//   }

//   // ── Open coupon picker ────────────────────────────────────────────────────
//   // Only calls showCouponPickerModal — nothing touches CartProvider here.
//   void _openCouponPicker() {
//     if (user == null) {
//       _snack('Please log in to apply coupons', Colors.red);
//       return;
//     }
//     showCouponPickerModal(
//       context: context,
//       userId: user!.userId.toString(),
//       // onCouponApplied: modal calls this after API success.
//       // We receive couponId + code back so we store them locally.
//       onCouponApplied: ({required String couponId, required String couponCode}) {
//         setState(() {
//           _appliedCouponId = couponId;
//           _appliedCouponCode = couponCode;
//         });
//         // Reload cart so prices reflect the discount
//         context.read<CartProvider>().loadCart(user?.userId.toString());
//         _snack('Coupon applied! 🎉', Colors.green);
//       },
//     );
//   }

//   // ── Remove coupon (direct API, no provider) ───────────────────────────────
//   Future<void> _removeCoupon() async {
//     if (_appliedCouponId == null) {
//       _snack('No coupon to remove', Colors.orange);
//       return;
//     }
//     setState(() => _isRemovingCoupon = true);
//     try {
//       final res = await http
//           .post(
//             Uri.parse(_kRemoveCouponUrl),
//             headers: {'Content-Type': 'application/json'},
//             body: json.encode({
//               'userId': user!.userId.toString(),
//               'couponId': _appliedCouponId,
//             }),
//           )
//           .timeout(const Duration(seconds: 12));

//       if (!mounted) return;

//       if (res.statusCode == 200) {
//         setState(() {
//           _appliedCouponId = null;
//           _appliedCouponCode = null;
//           _isRemovingCoupon = false;
//         });
//         // Reload cart so the removed discount reflects in price
//         context.read<CartProvider>().loadCart(user?.userId.toString());
//         _snack('Coupon removed', Colors.green);
//       } else {
//         final msg = (json.decode(res.body) as Map<String, dynamic>)['message']
//                 as String? ??
//             'Failed to remove coupon';
//         setState(() => _isRemovingCoupon = false);
//         _snack(msg, Colors.red);
//       }
//     } catch (e) {
//       if (!mounted) return;
//       setState(() => _isRemovingCoupon = false);
//       _snack('Error: $e', Colors.red);
//     }
//   }

//   // ── Checkout ──────────────────────────────────────────────────────────────
//   Future<void> _handleCheckout(CartProvider cp) async {
//     if (!cp.isVendorActive) {
//       _snack('Restaurant is closed. Cannot proceed.', Colors.red);
//       return;
//     }
//     if (cp.hasInactiveProducts) {
//       _snack('Remove unavailable items before checkout.', Colors.red);
//       return;
//     }
//     if (mounted) {
//       Navigator.push(context,
//           MaterialPageRoute(builder: (_) => const CheckoutScreen()));
//     }
//   }

//   // ── Status dialogs ────────────────────────────────────────────────────────
//   Future<void> _handleStatusChanges(CartProvider cp) async {
//     if (!mounted || !cp.hasItems) return;

//     if (!cp.isVendorActive && !_vendorInactiveHandled) {
//       _vendorInactiveHandled = true;
//       await showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (ctx) => AlertDialog(
//           title: const Text('Restaurant Closed'),
//           content: const Text(
//               'The restaurant is inactive. Your cart will be cleared.'),
//           actions: [
//             TextButton(
//                 onPressed: () => Navigator.of(ctx).pop(),
//                 child: const Text('OK')),
//           ],
//         ),
//       );
//       await cp.clearCart();
//       if (mounted) _snack('Cart cleared — restaurant is closed.', Colors.red);
//       return;
//     }

//     if (cp.hasInactiveProducts &&
//         !_productInactiveHandled &&
//         cp.isVendorActive) {
//       _productInactiveHandled = true;
//       final inactive = cp.items.where((p) => !p.isProductActive).toList();
//       final names = inactive.map((p) => p.name).join(', ');
//       final remove = await showDialog<bool>(
//         context: context,
//         barrierDismissible: false,
//         builder: (ctx) => AlertDialog(
//           title: const Text('Items Unavailable'),
//           content: Text('$names\n\nRemove them and continue?'),
//           actions: [
//             TextButton(
//                 onPressed: () => Navigator.of(ctx).pop(false),
//                 child: const Text('Cancel')),
//             TextButton(
//                 onPressed: () => Navigator.of(ctx).pop(true),
//                 child: const Text('Remove & Continue')),
//           ],
//         ),
//       );
//       if (remove == true) {
//         for (final p in inactive) {
//           await cp.removeItem(p.id, user?.userId.toString());
//         }
//         if (mounted) _snack('Unavailable items removed.', Colors.orange);
//       } else {
//         _productInactiveHandled = false;
//       }
//     }
//   }

//   // ── BUILD ──────────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final cs = theme.colorScheme;
//     final isMobile = Responsive.isMobile(context);
//     final width = MediaQuery.of(context).size.width;
//     final hPad = width >= 1200 ? 40.0 : width >= 900 ? 24.0 : 16.0;
//     final maxW = width >= 1400
//         ? 1200.0
//         : width >= 1100
//             ? 1100.0
//             : width >= 900
//                 ? 900.0
//                 : double.infinity;

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       body: SafeArea(
//         child: Consumer<CartProvider>(
//           builder: (context, cp, _) {
//             // Loading
//             if (cp.isLoading && !cp.hasItems) {
//               return Center(
//                 child: Column(mainAxisSize: MainAxisSize.min, children: [
//                   CircularProgressIndicator(color: cs.primary),
//                   const SizedBox(height: 16),
//                   Text('Loading cart...',
//                       style: theme.textTheme.bodyMedium
//                           ?.copyWith(color: cs.onSurface.withOpacity(0.7))),
//                 ]),
//               );
//             }

//             // Error
//             if (cp.error != null && !cp.hasItems) {
//               return Center(
//                 child: Column(mainAxisSize: MainAxisSize.min, children: [
//                   Icon(Icons.error_outline, size: 64, color: cs.error),
//                   const SizedBox(height: 16),
//                   Text('Error: ${cp.error}',
//                       style: theme.textTheme.bodyMedium,
//                       textAlign: TextAlign.center),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: _initializeCart,
//                     style: ElevatedButton.styleFrom(
//                         backgroundColor: cs.primary,
//                         foregroundColor: cs.onPrimary),
//                     child: const Text('Retry'),
//                   ),
//                 ]),
//               );
//             }

//             // Empty
//             if (!cp.hasItems) {
//               return EmptyCartWidget(theme: theme, colorScheme: cs);
//             }

//             return RefreshIndicator(
//               onRefresh: () => cp.loadCart(user?.userId.toString()),
//               color: cs.primary,
//               child: SingleChildScrollView(
//                 controller: widget.scrollController,
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 child: Center(
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(maxWidth: maxW),
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(
//                           horizontal: hPad, vertical: 16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           _buildHeader(theme, cs),
//                           const SizedBox(height: 20),

//                           if (!cp.isVendorActive)
//                             _vendorBanner(theme, cs),
//                           if (cp.hasInactiveProducts && cp.isVendorActive)
//                             _inactiveBanner(cp, theme, cs),

//                           const SizedBox(height: 10),

//                           if (isMobile) ...[
//                             _sectionCard(theme, cs,
//                                 _buildCartList(cp, theme, cs)),
//                             const SizedBox(height: 20),

//                             // ── Coupon bar (local state only) ──────────────
//                             _buildCouponBar(theme, cs),
//                             const SizedBox(height: 10),

//                             _sectionCard(theme, cs,
//                                 TicketPricingSummary(
//                                     cartProvider: cp,
//                                     theme: theme,
//                                     colorScheme: cs)),
//                             const SizedBox(height: 20),
//                             _checkoutBtn(cp, theme, cs),
//                             const SizedBox(height: 20),
//                           ] else ...[
//                             Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Expanded(
//                                   flex: 3,
//                                   child: Column(children: [
//                                     _sectionCard(theme, cs,
//                                         _buildCartList(cp, theme, cs)),
//                                     const SizedBox(height: 16),

//                                     // ── Coupon bar (local state only) ──────
//                                     _buildCouponBar(theme, cs),
//                                   ]),
//                                 ),
//                                 const SizedBox(width: 24),
//                                 Expanded(
//                                   flex: 2,
//                                   child: _StickySummaryCard(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.stretch,
//                                       children: [
//                                         _sectionCard(theme, cs,
//                                             TicketPricingSummary(
//                                                 cartProvider: cp,
//                                                 theme: theme,
//                                                 colorScheme: cs)),
//                                         const SizedBox(height: 14),
//                                         _checkoutBtn(cp, theme, cs),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 20),
//                           ],
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   // ── Coupon bar ─────────────────────────────────────────────────────────────
//   // 100% local state. CartProvider is NOT read here at all.
//   Widget _buildCouponBar(ThemeData theme, ColorScheme cs) {
//     final hasCoupon = _appliedCouponId != null;

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       decoration: BoxDecoration(
//         color: theme.cardColor,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: cs.outline.withOpacity(0.18)),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(0.04),
//               blurRadius: 8,
//               offset: const Offset(0, 3)),
//         ],
//       ),
//       child: Row(children: [
//         Container(
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: cs.primary.withOpacity(0.08),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(Icons.local_offer_outlined, color: cs.primary, size: 22),
//         ),
//         const SizedBox(width: 12),

//         // Text side
//         Expanded(
//           child: hasCoupon
//               ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   Text('Coupon Applied! 🎉',
//                       style: theme.textTheme.bodyMedium?.copyWith(
//                           fontWeight: FontWeight.w700,
//                           color: Colors.green.shade700)),
//                   const SizedBox(height: 2),
//                   Text(_appliedCouponCode ?? '',
//                       style: theme.textTheme.bodySmall?.copyWith(
//                           color: cs.onSurface.withOpacity(0.55),
//                           letterSpacing: 1.2,
//                           fontWeight: FontWeight.w600)),
//                 ])
//               : Text('Have a coupon code?',
//                   style: theme.textTheme.bodyMedium
//                       ?.copyWith(fontWeight: FontWeight.w600)),
//         ),

//         // Action button
//         if (hasCoupon)
//           _isRemovingCoupon
//               ? SizedBox(
//                   width: 20, height: 20,
//                   child: CircularProgressIndicator(
//                       strokeWidth: 2, color: cs.error))
//               : GestureDetector(
//                   onTap: _removeCoupon, // ← calls direct API, no provider
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 12, vertical: 8),
//                     decoration: BoxDecoration(
//                       color: cs.errorContainer,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text('Remove',
//                         style: TextStyle(
//                             fontSize: 12, fontWeight: FontWeight.w700,
//                             color: cs.onErrorContainer)),
//                   ),
//                 )
//         else
//           GestureDetector(
//             onTap: _openCouponPicker, // ← opens modal, no provider
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
//               decoration: BoxDecoration(
//                 color: cs.primary,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Text('View Coupons',
//                   style: TextStyle(
//                       fontSize: 12, fontWeight: FontWeight.w700,
//                       color: cs.onPrimary)),
//             ),
//           ),
//       ]),
//     );
//   }

//   // ── Helpers ───────────────────────────────────────────────────────────────
//   Widget _buildHeader(ThemeData theme, ColorScheme cs) => Row(children: [
//         CircleAvatar(
//           radius: 25,
//           backgroundColor: cs.primary.withOpacity(0.1),
//           child: Icon(Icons.shopping_cart, color: cs.primary),
//         ),
//         const SizedBox(width: 20),
//         Text('My Cart',
//             style: theme.textTheme.titleLarge
//                 ?.copyWith(fontWeight: FontWeight.bold)),
//       ]);

//   Widget _buildCartList(CartProvider cp, ThemeData theme, ColorScheme cs) =>
//       ListView.builder(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         itemCount: cp.items.length,
//         itemBuilder: (context, i) {
//           final item = cp.items[i];
//           return CartItemWidget(
//             cartProduct: item,
//             onIncrement: () async {
//               try {
//                 await cp.incrementQuantity(item.id, user?.userId.toString());
//               } catch (e) {
//                 _snack('Failed to update: $e', Colors.red);
//               }
//             },
//             onDecrement: () async {
//               try {
//                 await cp.decrementQuantity(item.id, user?.userId.toString());
//               } catch (e) {
//                 _snack('Failed to update: $e', Colors.red);
//               }
//             },
//             onRemove: () async {
//               try {
//                 await cp.removeItem(item.id, user?.userId.toString());
//                 _snack('Item removed', Colors.green);
//               } catch (e) {
//                 _snack('Failed to remove: $e', Colors.red);
//               }
//             },
//             theme: theme,
//             colorScheme: cs,
//           );
//         },
//       );

//   Widget _checkoutBtn(CartProvider cp, ThemeData theme, ColorScheme cs) {
//     final disabled = cp.isLoading ||
//         !cp.hasItems ||
//         !cp.isVendorActive ||
//         cp.hasInactiveProducts;
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: disabled ? null : () => _handleCheckout(cp),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: cs.primary,
//           foregroundColor: cs.onPrimary,
//           disabledBackgroundColor: cs.onSurface.withOpacity(0.12),
//           disabledForegroundColor: cs.onSurface.withOpacity(0.38),
//           padding: const EdgeInsets.symmetric(vertical: 16),
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         ),
//         child: Text('Checkout',
//             style: theme.textTheme.titleMedium
//                 ?.copyWith(color: cs.onPrimary, fontWeight: FontWeight.bold)),
//       ),
//     );
//   }

//   Widget _sectionCard(ThemeData theme, ColorScheme cs, Widget child) =>
//       Container(
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: theme.cardColor,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: cs.outline.withOpacity(0.15)),
//           boxShadow: [
//             BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 8,
//                 offset: const Offset(0, 3))
//           ],
//         ),
//         child: child,
//       );

//   Widget _vendorBanner(ThemeData theme, ColorScheme cs) => Container(
//         width: double.infinity,
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//             color: cs.errorContainer,
//             borderRadius: BorderRadius.circular(12)),
//         child: Row(children: [
//           Icon(Icons.store_mall_directory, color: cs.onErrorContainer),
//           const SizedBox(width: 8),
//           Expanded(
//               child: Text(
//                   'This restaurant is currently closed.',
//                   style: theme.textTheme.bodyMedium
//                       ?.copyWith(color: cs.onErrorContainer))),
//         ]),
//       );

//   Widget _inactiveBanner(
//       CartProvider cp, ThemeData theme, ColorScheme cs) =>
//       Container(
//         width: double.infinity,
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//             color: cs.tertiaryContainer,
//             borderRadius: BorderRadius.circular(12)),
//         child: Row(children: [
//           Icon(Icons.info_outline, color: cs.onTertiaryContainer),
//           const SizedBox(width: 8),
//           Expanded(
//               child: Text(
//                   'Some items are no longer available. Please remove them.',
//                   style: theme.textTheme.bodyMedium
//                       ?.copyWith(color: cs.onTertiaryContainer))),
//           TextButton(
//               onPressed: () async => _handleStatusChanges(cp),
//               child: const Text('FIX')),
//         ]),
//       );
// }

// // ──────────────────────────────────────────────────────────────────────────
// //  EmptyCartWidget
// // ──────────────────────────────────────────────────────────────────────────
// class EmptyCartWidget extends StatelessWidget {
//   final ThemeData theme;
//   final ColorScheme colorScheme;
//   const EmptyCartWidget(
//       {super.key, required this.theme, required this.colorScheme});

//   @override
//   Widget build(BuildContext context) {
//     final iconSize = Responsive.isDesktop(context) ? 140.0 : 100.0;
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//           Icon(Icons.shopping_cart_outlined,
//               size: iconSize, color: colorScheme.onSurface.withOpacity(0.5)),
//           const SizedBox(height: 20),
//           Text('Your cart is empty',
//               style: theme.textTheme.titleLarge
//                   ?.copyWith(fontWeight: FontWeight.bold)),
//           const SizedBox(height: 10),
//           Text('Add some delicious items to your cart',
//               style: theme.textTheme.bodyMedium
//                   ?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
//               textAlign: TextAlign.center),
//           const SizedBox(height: 30),
//         ]),
//       ),
//     );
//   }
// }

// // ──────────────────────────────────────────────────────────────────────────
// //  CartItemWidget (unchanged)
// // ──────────────────────────────────────────────────────────────────────────
// class CartItemWidget extends StatelessWidget {
//   final CartProduct cartProduct;
//   final VoidCallback onIncrement;
//   final VoidCallback onDecrement;
//   final VoidCallback onRemove;
//   final ThemeData theme;
//   final ColorScheme colorScheme;

//   const CartItemWidget({
//     super.key,
//     required this.cartProduct,
//     required this.onIncrement,
//     required this.onDecrement,
//     required this.onRemove,
//     required this.theme,
//     required this.colorScheme,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final bool inactive = !cartProduct.isProductActive;
//     return Opacity(
//       opacity: inactive ? 0.6 : 1.0,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: theme.cardColor,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//                 color: Colors.black.withOpacity(0.06),
//                 spreadRadius: 1,
//                 blurRadius: 4,
//                 offset: const Offset(0, 2))
//           ],
//         ),
//         child: Row(children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: Image.network(
//               cartProduct.image,
//               width: 60, height: 60, fit: BoxFit.cover,
//               loadingBuilder: (_, child, prog) => prog == null
//                   ? child
//                   : Container(
//                       width: 60, height: 60,
//                       color: colorScheme.surfaceVariant,
//                       child: Center(
//                           child: CircularProgressIndicator(
//                               strokeWidth: 2, color: colorScheme.primary))),
//               errorBuilder: (_, __, ___) => Container(
//                   width: 60, height: 60,
//                   color: colorScheme.surfaceVariant,
//                   child: Icon(Icons.image,
//                       size: 30, color: colorScheme.onSurfaceVariant)),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(cartProduct.name,
//                       style: theme.textTheme.titleSmall
//                           ?.copyWith(fontWeight: FontWeight.w600),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis),
//                   const SizedBox(height: 4),
//                   if (cartProduct.addOn.variation.isNotEmpty)
//                     Text('Size: ${cartProduct.addOn.variation}',
//                         style: theme.textTheme.bodySmall?.copyWith(
//                             color: colorScheme.onSurface.withOpacity(0.7))),
//                   if (cartProduct.addOn.plateitems > 0) ...[
//                     const SizedBox(height: 2),
//                     Text('Plates: ${cartProduct.addOn.plateitems}',
//                         style: theme.textTheme.bodySmall?.copyWith(
//                             color: colorScheme.onSurface.withOpacity(0.7))),
//                   ],
//                   const SizedBox(height: 4),
//                   Text('₹${cartProduct.price}',
//                       style: theme.textTheme.titleSmall?.copyWith(
//                           fontWeight: FontWeight.bold,
//                           color: colorScheme.primary)),
//                   if (inactive) ...[
//                     const SizedBox(height: 6),
//                     Text('Unavailable — remove to continue.',
//                         style: theme.textTheme.bodySmall?.copyWith(
//                             color: colorScheme.error,
//                             fontWeight: FontWeight.w600)),
//                     Align(
//                         alignment: Alignment.centerLeft,
//                         child: TextButton(
//                             onPressed: onRemove,
//                             child: const Text('Remove'))),
//                   ],
//                 ]),
//           ),
//           Column(children: [
//             Row(children: [
//               _CircleBtn(
//                   icon: Icons.remove,
//                   color: inactive
//                       ? colorScheme.onSurface.withOpacity(0.15)
//                       : colorScheme.primary,
//                   iconColor: inactive
//                       ? colorScheme.onSurface.withOpacity(0.4)
//                       : colorScheme.onPrimary,
//                   onTap: inactive ? null : onDecrement),
//               const SizedBox(width: 8),
//               SizedBox(
//                 width: 28,
//                 child: Text(
//                     cartProduct.quantity.toString().padLeft(2, '0'),
//                     textAlign: TextAlign.center,
//                     style: theme.textTheme.bodyMedium
//                         ?.copyWith(fontWeight: FontWeight.w600)),
//               ),
//               const SizedBox(width: 8),
//               _CircleBtn(
//                   icon: Icons.add,
//                   color: inactive
//                       ? colorScheme.onSurface.withOpacity(0.15)
//                       : colorScheme.primary,
//                   iconColor: inactive
//                       ? colorScheme.onSurface.withOpacity(0.4)
//                       : colorScheme.onPrimary,
//                   onTap: inactive ? null : onIncrement),
//             ]),
//             const SizedBox(height: 8),
//             GestureDetector(
//               onTap: onRemove,
//               child: Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                     color: colorScheme.errorContainer,
//                     shape: BoxShape.circle),
//                 child: Icon(Icons.delete,
//                     size: 20, color: colorScheme.onErrorContainer),
//               ),
//             ),
//           ]),
//         ]),
//       ),
//     );
//   }
// }

// class _CircleBtn extends StatelessWidget {
//   final IconData icon;
//   final Color color;
//   final Color iconColor;
//   final VoidCallback? onTap;
//   const _CircleBtn(
//       {required this.icon,
//       required this.color,
//       required this.iconColor,
//       this.onTap});

//   @override
//   Widget build(BuildContext context) => GestureDetector(
//         onTap: onTap,
//         child: Container(
//           width: 32, height: 32,
//           decoration: BoxDecoration(shape: BoxShape.circle, color: color),
//           child: Icon(icon, size: 18, color: iconColor),
//         ),
//       );
// }

// // ──────────────────────────────────────────────────────────────────────────
// //  RowItem
// // ──────────────────────────────────────────────────────────────────────────
// class RowItem extends StatelessWidget {
//   final String label;
//   final String value;
//   final Color? valueColor;
//   final FontWeight? fontWeight;
//   final ThemeData theme;
//   final ColorScheme colorScheme;
//   const RowItem({
//     super.key,
//     required this.label,
//     required this.value,
//     this.valueColor,
//     this.fontWeight,
//     required this.theme,
//     required this.colorScheme,
//   });

//   @override
//   Widget build(BuildContext context) => Padding(
//         padding: const EdgeInsets.symmetric(vertical: 4),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(label,
//                 style: theme.textTheme.bodyMedium?.copyWith(
//                     color: colorScheme.onSurface.withOpacity(0.7),
//                     fontWeight: fontWeight)),
//             Text(value,
//                 style: theme.textTheme.bodyMedium?.copyWith(
//                     color: valueColor ?? colorScheme.onSurface,
//                     fontWeight: fontWeight)),
//           ],
//         ),
//       );
// }

// // ──────────────────────────────────────────────────────────────────────────
// //  _StickySummaryCard
// // ──────────────────────────────────────────────────────────────────────────
// class _StickySummaryCard extends StatelessWidget {
//   final Widget child;
//   const _StickySummaryCard({required this.child});

//   @override
//   Widget build(BuildContext context) => Padding(
//         padding: const EdgeInsets.only(top: 4),
//         child: Align(alignment: Alignment.topCenter, child: child),
//       );
// }
























// cart_screen.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:veegify/helper/storage_helper.dart';
import 'package:veegify/model/CartModel/cart_model.dart';
import 'package:veegify/model/user_model.dart';
import 'package:veegify/provider/CartProvider/cart_provider.dart';
import 'package:veegify/views/Booking/checkout_screen.dart';
import 'package:veegify/views/Cart/cart_summary.dart';
import 'package:veegify/core/app_lifecycle_service.dart';
import 'package:veegify/utils/responsive.dart';
import 'package:veegify/views/Coupons/coupon_picker_modal.dart';

const String _kRemoveCouponUrl = 'https://api.vegiffyy.com/api/remove-coupon';

// ──────────────────────────────────────────────────────────────────────────
class CartScreenWithController extends StatelessWidget {
  final ScrollController scrollController;
  const CartScreenWithController({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) =>
      CartScreen(scrollController: scrollController);
}

// ──────────────────────────────────────────────────────────────────────────
class CartScreen extends StatefulWidget {
  final ScrollController? scrollController;
  const CartScreen({super.key, this.scrollController});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  User? user;
  Timer? _pollingTimer;
  bool _vendorInactiveHandled = false;
  bool _productInactiveHandled = false;

  // ── Coupon local state (ZERO CartProvider connection) ────────────────────
  String? _appliedCouponId;   // stored after successful apply
  String? _appliedCouponCode; // shown in the bar
  bool _isRemovingCoupon = false;
  bool _isLoadingCouponState = true; // Track if we're loading coupon state

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeCart());
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }

  // ── Init ──────────────────────────────────────────────────────────────────
  Future<void> _initializeCart() async {
    await _loadUser();
    final cp = context.read<CartProvider>();
    await cp.loadCart(user?.userId.toString());
    
    // After cart loads, extract coupon info from cart provider
    _extractCouponFromProvider(cp);
    
    await _handleStatusChanges(cp);
    _startPolling();
  }

  // Extract coupon information from cart provider (without setState if unchanged)
  void _extractCouponFromProvider(CartProvider cp) {
    final newId = cp.appliedCouponId;
    final newCode = cp.appliedCouponCode;
    
    setState(() {
      _isLoadingCouponState = false;
      // Only update if changed to avoid unnecessary rebuilds
      if (_appliedCouponId != newId || _appliedCouponCode != newCode) {
        _appliedCouponId = newId;
        _appliedCouponCode = newCode;
      }
    });
  }

  Future<void> _loadUser() async {
    final u = UserPreferences.getUser();
    if (u != null) {
      setState(() => user = u);
      context.read<CartProvider>().setUserId(u.userId.toString());
    }
  }

  // ── Polling ───────────────────────────────────────────────────────────────
  void _startPolling() {
    _pollingTimer?.cancel();
    if (user == null) return;
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (!mounted) return;
      if (!AppLifecycleService.instance.isAppInForeground) return;
      if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;
      
      final cp = context.read<CartProvider>();
      await cp.loadCart(user?.userId.toString());
      
      // Update coupon state if changed (but loadCart already only notifies if changed)
      // Still need to sync local state with provider because we're using local state for coupon bar
      if (mounted) {
        _extractCouponFromProvider(cp);
      }
      
      _handleStatusChanges(cp);
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  // ── Snackbar ──────────────────────────────────────────────────────────────
  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ));
  }

  // ── Open coupon picker ────────────────────────────────────────────────────
  void _openCouponPicker() {
    if (user == null) {
      _snack('Please log in to apply coupons', Colors.red);
      return;
    }
    showCouponPickerModal(
      context: context,
      userId: user!.userId.toString(),
      onCouponApplied: ({required String couponId, required String couponCode}) {
        setState(() {
          _appliedCouponId = couponId;
          _appliedCouponCode = couponCode;
        });
        // Reload cart so prices reflect the discount
        context.read<CartProvider>().loadCart(user?.userId.toString());
        _snack('Coupon applied! 🎉', Colors.green);
      },
    );
  }

  // ── Remove coupon (direct API, no provider) ───────────────────────────────
  Future<void> _removeCoupon() async {
    if (_appliedCouponId == null) {
      _snack('No coupon to remove', Colors.orange);
      return;
    }
    setState(() => _isRemovingCoupon = true);
    try {
      final res = await http
          .post(
            Uri.parse(_kRemoveCouponUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'userId': user!.userId.toString(),
              'couponId': _appliedCouponId,
            }),
          )
          .timeout(const Duration(seconds: 12));

      if (!mounted) return;

      if (res.statusCode == 200) {
        setState(() {
          _appliedCouponId = null;
          _appliedCouponCode = null;
          _isRemovingCoupon = false;
        });
        // Reload cart so the removed discount reflects in price
        context.read<CartProvider>().loadCart(user?.userId.toString());
        _snack('Coupon removed', Colors.green);
      } else {
        final msg = (json.decode(res.body) as Map<String, dynamic>)['message']
                as String? ??
            'Failed to remove coupon';
        setState(() => _isRemovingCoupon = false);
        _snack(msg, Colors.red);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isRemovingCoupon = false);
      _snack('Error: $e', Colors.red);
    }
  }

  // ── Checkout ──────────────────────────────────────────────────────────────
  Future<void> _handleCheckout(CartProvider cp) async {
    if (!cp.isVendorActive) {
      _snack('Restaurant is closed. Cannot proceed.', Colors.red);
      return;
    }
    if (cp.hasInactiveProducts) {
      _snack('Remove unavailable items before checkout.', Colors.red);
      return;
    }
    if (mounted) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const CheckoutScreen()));
    }
  }

  // ── Status dialogs ────────────────────────────────────────────────────────
  Future<void> _handleStatusChanges(CartProvider cp) async {
    if (!mounted || !cp.hasItems) return;

    if (!cp.isVendorActive && !_vendorInactiveHandled) {
      _vendorInactiveHandled = true;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Restaurant Closed'),
          content: const Text(
              'The restaurant is inactive. Your cart will be cleared.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK')),
          ],
        ),
      );
      await cp.clearCart();
      if (mounted) _snack('Cart cleared — restaurant is closed.', Colors.red);
      return;
    }

    if (cp.hasInactiveProducts &&
        !_productInactiveHandled &&
        cp.isVendorActive) {
      _productInactiveHandled = true;
      final inactive = cp.items.where((p) => !p.isProductActive).toList();
      final names = inactive.map((p) => p.name).join(', ');
      final remove = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Items Unavailable'),
          content: Text('$names\n\nRemove them and continue?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel')),
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Remove & Continue')),
          ],
        ),
      );
      if (remove == true) {
        for (final p in inactive) {
          await cp.removeItem(p.id, user?.userId.toString());
        }
        if (mounted) _snack('Unavailable items removed.', Colors.orange);
      } else {
        _productInactiveHandled = false;
      }
    }
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isMobile = Responsive.isMobile(context);
    final width = MediaQuery.of(context).size.width;
    final hPad = width >= 1200 ? 40.0 : width >= 900 ? 24.0 : 16.0;
    final maxW = width >= 1400
        ? 1200.0
        : width >= 1100
            ? 1100.0
            : width >= 900
                ? 900.0
                : double.infinity;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<CartProvider>(
          builder: (context, cp, _) {
            // Sync local coupon state with provider when provider changes
            // but avoid calling setState during build
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _extractCouponFromProvider(cp);
              }
            });

            // Loading
            if (!cp.hasItems) {
              return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.shopify,
                            size:  64,
                            color: theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Your cart is empty',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                            fontSize:  18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add items to see them here',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
            }

            // Error
            if (cp.error != null && !cp.hasItems) {
              return Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.error_outline, size: 64, color: cs.error),
                  const SizedBox(height: 16),
                  Text('Error: ${cp.error}',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _initializeCart,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary),
                    child: const Text('Retry'),
                  ),
                ]),
              );
            }

            // Empty
            if (!cp.hasItems) {
              return EmptyCartWidget(theme: theme, colorScheme: cs);
            }

            return RefreshIndicator(
              onRefresh: () => cp.loadCart(user?.userId.toString()),
              color: cs.primary,
              child: SingleChildScrollView(
                controller: widget.scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxW),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: hPad, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(theme, cs),
                          const SizedBox(height: 20),

                          if (!cp.isVendorActive)
                            _vendorBanner(theme, cs),
                          if (cp.hasInactiveProducts && cp.isVendorActive)
                            _inactiveBanner(cp, theme, cs),

                          const SizedBox(height: 10),

                          if (isMobile) ...[
                            _sectionCard(theme, cs,
                                _buildCartList(cp, theme, cs)),
                            const SizedBox(height: 20),

                            // ── Coupon bar (local state only) ──────────────
                            _buildCouponBar(theme, cs),
                            const SizedBox(height: 10),

                            _sectionCard(theme, cs,
                                TicketPricingSummary(
                                    cartProvider: cp,
                                    theme: theme,
                                    colorScheme: cs)),
                            const SizedBox(height: 20),
                            _checkoutBtn(cp, theme, cs),
                            const SizedBox(height: 20),
                          ] else ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(children: [
                                    _sectionCard(theme, cs,
                                        _buildCartList(cp, theme, cs)),
                                    const SizedBox(height: 16),

                                    // ── Coupon bar (local state only) ──────
                                    _buildCouponBar(theme, cs),
                                  ]),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  flex: 2,
                                  child: _StickySummaryCard(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        _sectionCard(theme, cs,
                                            TicketPricingSummary(
                                                cartProvider: cp,
                                                theme: theme,
                                                colorScheme: cs)),
                                        const SizedBox(height: 14),
                                        _checkoutBtn(cp, theme, cs),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Coupon bar ─────────────────────────────────────────────────────────────
  Widget _buildCouponBar(ThemeData theme, ColorScheme cs) {
    final hasCoupon = _appliedCouponId != null && _appliedCouponCode != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cs.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.local_offer_outlined, color: cs.primary, size: 22),
        ),
        const SizedBox(width: 12),

        // Text side
        Expanded(
          child: hasCoupon
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Coupon Applied! 🎉',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.green.shade700)),
                  const SizedBox(height: 2),
                  Text(_appliedCouponCode ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withOpacity(0.55),
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600)),
                ])
              : Text('Have a coupon code?',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
        ),

        // Action button
        if (hasCoupon)
          _isRemovingCoupon
              ? SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: cs.error))
              : GestureDetector(
                  onTap: _removeCoupon, // ← calls direct API, no provider
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: cs.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Remove',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700,
                            color: cs.onErrorContainer)),
                  ),
                )
        else
          GestureDetector(
            onTap: _openCouponPicker, // ← opens modal, no provider
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('View Coupons',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700,
                      color: cs.onPrimary)),
            ),
          ),
      ]),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _buildHeader(ThemeData theme, ColorScheme cs) => Row(children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: cs.primary.withOpacity(0.1),
          child: Icon(Icons.shopping_cart, color: cs.primary),
        ),
        const SizedBox(width: 20),
        Text('My Cart',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
      ]);

  Widget _buildCartList(CartProvider cp, ThemeData theme, ColorScheme cs) =>
      ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cp.items.length,
        itemBuilder: (context, i) {
          final item = cp.items[i];
          return CartItemWidget(
            cartProduct: item,
            onIncrement: () async {
              try {
                await cp.incrementQuantity(item.id, user?.userId.toString());
              } catch (e) {
                _snack('Failed to update: $e', Colors.red);
              }
            },
            onDecrement: () async {
              try {
                await cp.decrementQuantity(item.id, user?.userId.toString());
              } catch (e) {
                _snack('Failed to update: $e', Colors.red);
              }
            },
            onRemove: () async {
              try {
                await cp.removeItem(item.id, user?.userId.toString());
                _snack('Item removed', Colors.green);
              } catch (e) {
                _snack('Failed to remove: $e', Colors.red);
              }
            },
            theme: theme,
            colorScheme: cs,
          );
        },
      );

  Widget _checkoutBtn(CartProvider cp, ThemeData theme, ColorScheme cs) {
    final disabled = 
        !cp.hasItems ||
        !cp.isVendorActive ||
        cp.hasInactiveProducts;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: disabled ? null : () => _handleCheckout(cp),
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          disabledBackgroundColor: cs.onSurface.withOpacity(0.12),
          disabledForegroundColor: cs.onSurface.withOpacity(0.38),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text('Checkout',
            style: theme.textTheme.titleMedium
                ?.copyWith(color: cs.onPrimary, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _sectionCard(ThemeData theme, ColorScheme cs, Widget child) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outline.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: child,
      );

  Widget _vendorBanner(ThemeData theme, ColorScheme cs) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: cs.errorContainer,
            borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Icon(Icons.store_mall_directory, color: cs.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
              child: Text(
                  'This restaurant is currently closed.',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: cs.onErrorContainer))),
        ]),
      );

  Widget _inactiveBanner(
      CartProvider cp, ThemeData theme, ColorScheme cs) =>
      Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: cs.tertiaryContainer,
            borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Icon(Icons.info_outline, color: cs.onTertiaryContainer),
          const SizedBox(width: 8),
          Expanded(
              child: Text(
                  'Some items are no longer available. Please remove them.',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: cs.onTertiaryContainer))),
          TextButton(
              onPressed: () async => _handleStatusChanges(cp),
              child: const Text('FIX')),
        ]),
      );
}

// ──────────────────────────────────────────────────────────────────────────
//  EmptyCartWidget (unchanged)
// ──────────────────────────────────────────────────────────────────────────
class EmptyCartWidget extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme colorScheme;
  const EmptyCartWidget(
      {super.key, required this.theme, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final iconSize = Responsive.isDesktop(context) ? 140.0 : 100.0;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.shopping_cart_outlined,
              size: iconSize, color: colorScheme.onSurface.withOpacity(0.5)),
          const SizedBox(height: 20),
          Text('Your cart is empty',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('Add some delicious items to your cart',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
              textAlign: TextAlign.center),
          const SizedBox(height: 30),
        ]),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
//  CartItemWidget (unchanged)
// ──────────────────────────────────────────────────────────────────────────
class CartItemWidget extends StatelessWidget {
  final CartProduct cartProduct;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const CartItemWidget({
    super.key,
    required this.cartProduct,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final bool inactive = !cartProduct.isProductActive;
    return Opacity(
      opacity: inactive ? 0.6 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              cartProduct.image,
              width: 60, height: 60, fit: BoxFit.cover,
              loadingBuilder: (_, child, prog) => prog == null
                  ? child
                  : Container(
                      width: 60, height: 60,
                      color: colorScheme.surfaceVariant,
                      child: Center(
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: colorScheme.primary))),
              errorBuilder: (_, __, ___) => Container(
                  width: 60, height: 60,
                  color: colorScheme.surfaceVariant,
                  child: Icon(Icons.image,
                      size: 30, color: colorScheme.onSurfaceVariant)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cartProduct.name,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  if (cartProduct.addOn.variation.isNotEmpty)
                    Text('Size: ${cartProduct.addOn.variation}',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7))),
                  if (cartProduct.addOn.plateitems > 0) ...[
                    const SizedBox(height: 2),
                    Text('Plates: ${cartProduct.addOn.plateitems}',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7))),
                  ],
                  const SizedBox(height: 4),
                  Text('₹${cartProduct.price}',
                      style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary)),
                  if (inactive) ...[
                    const SizedBox(height: 6),
                    Text('Unavailable — remove to continue.',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.error,
                            fontWeight: FontWeight.w600)),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                            onPressed: onRemove,
                            child: const Text('Remove'))),
                  ],
                ]),
          ),
          Column(children: [
            Row(children: [
              _CircleBtn(
                  icon: Icons.remove,
                  color: inactive
                      ? colorScheme.onSurface.withOpacity(0.15)
                      : colorScheme.primary,
                  iconColor: inactive
                      ? colorScheme.onSurface.withOpacity(0.4)
                      : colorScheme.onPrimary,
                  onTap: inactive ? null : onDecrement),
              const SizedBox(width: 8),
              SizedBox(
                width: 28,
                child: Text(
                    cartProduct.quantity.toString().padLeft(2, '0'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 8),
              _CircleBtn(
                  icon: Icons.add,
                  color: inactive
                      ? colorScheme.onSurface.withOpacity(0.15)
                      : colorScheme.primary,
                  iconColor: inactive
                      ? colorScheme.onSurface.withOpacity(0.4)
                      : colorScheme.onPrimary,
                  onTap: inactive ? null : onIncrement),
            ]),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    shape: BoxShape.circle),
                child: Icon(Icons.delete,
                    size: 20, color: colorScheme.onErrorContainer),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback? onTap;
  const _CircleBtn(
      {required this.icon,
      required this.color,
      required this.iconColor,
      this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32, height: 32,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          child: Icon(icon, size: 18, color: iconColor),
        ),
      );
}

// ──────────────────────────────────────────────────────────────────────────
//  RowItem (unchanged)
// ──────────────────────────────────────────────────────────────────────────
class RowItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final FontWeight? fontWeight;
  final ThemeData theme;
  final ColorScheme colorScheme;
  const RowItem({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.fontWeight,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: fontWeight)),
            Text(value,
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: valueColor ?? colorScheme.onSurface,
                    fontWeight: fontWeight)),
          ],
        ),
      );
}

// ──────────────────────────────────────────────────────────────────────────
//  _StickySummaryCard (unchanged)
// ──────────────────────────────────────────────────────────────────────────
class _StickySummaryCard extends StatelessWidget {
  final Widget child;
  const _StickySummaryCard({required this.child});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Align(alignment: Alignment.topCenter, child: child),
      );
}