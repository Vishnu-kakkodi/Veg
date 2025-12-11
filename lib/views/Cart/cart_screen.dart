
// // cart_screen.dart
// import 'dart:async'; // 👈 for Timer

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

// // 👇 import your lifecycle service (update path if needed)
// import 'package:veegify/core/app_lifecycle_service.dart';

// class CartScreenWithController extends StatelessWidget {
//   final ScrollController scrollController;

//   const CartScreenWithController({
//     super.key,
//     required this.scrollController,
//   });

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
//       print("✅ Loaded User ID in CartScreen: ${user?.userId}");

//       final cartProvider = Provider.of<CartProvider>(context, listen: false);
//       cartProvider.setUserId(user!.userId.toString());
//     } else {
//       print("⚠️ No user found in UserPreferences");
//     }
//   }

//   void _startCartPolling() {
//     _pollingTimer?.cancel();

//     if (user == null) {
//       print("⛔ Polling not started: user is null");
//       return;
//     }

//     print("✅ Starting cart polling every 5 seconds");

//     _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
//       if (!mounted) return;

//       // 🔒 Only poll when app is visible (foreground)
//       if (!AppLifecycleService.instance.isAppInForeground) {
//         // print("⏸️ App is background/hidden → skip cart polling");
//         return;
//       }

//       // 🔒 Only poll when THIS screen is on top of stack
//       final route = ModalRoute.of(context);
//       final isRouteCurrent = route?.isCurrent ?? true;
//       if (!isRouteCurrent) {
//         // print("⏸️ CartScreen not current route → skip cart polling");
//         return;
//       }

//       final cartProvider =
//           Provider.of<CartProvider>(context, listen: false);

//       print("🔄 [Cart Poll] loadCart for user: ${user?.userId}");
//       await cartProvider.loadCart(user?.userId.toString());

//       // after refresh, check statuses
//       _handleStatusChanges(cartProvider);
//     });
//   }

//   void _stopCartPolling() {
//     print("🛑 Stopping cart polling");
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
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
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
//       final success =
//           await cartProvider.applyCoupon(_couponController.text.trim());

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
//         _showSnackBar(
//           'Remove unavailable items before checkout.',
//           Colors.red,
//         );
//         return;
//       }

//       _showSnackBar('Processing order...', Colors.blue);

//       if (mounted) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const CheckoutScreen(),
//           ),
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
//         _showSnackBar(
//           'Restaurant is closed. Cart cleared.',
//           Colors.red,
//         );
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
//           await cartProvider.removeItem(
//             p.id,
//             user?.userId.toString(),
//           );
//         }
//         if (mounted) {
//           _showSnackBar(
//             'Unavailable items removed from cart.',
//             Colors.orange,
//           );
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
//                   ),
//                 ],
//               ));
//             }

//             if (cartProvider.error != null && !cartProvider.hasItems) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.error_outline,
//                         size: 64, color: colorScheme.error),
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
//               onRefresh: () =>
//                   cartProvider.loadCart(user?.userId.toString()),
//               color: colorScheme.primary,
//               child: SingleChildScrollView(
//                 controller: widget.scrollController,
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _buildHeader(theme, colorScheme),
//                       const SizedBox(height: 20),

//                       // 🔥 Status banners
//                       if (!cartProvider.isVendorActive)
//                         _buildVendorClosedBanner(theme, colorScheme),
//                       if (cartProvider.hasInactiveProducts &&
//                           cartProvider.isVendorActive)
//                         _buildInactiveProductsBanner(
//                             cartProvider, theme, colorScheme),

//                       _buildCartList(cartProvider, theme, colorScheme),
//                       const SizedBox(height: 10),

//                       const SizedBox(height: 20),

//                       // 🎫 Your ticket-style summary
//                       TicketPricingSummary(
//                         cartProvider: cartProvider,
//                         theme: theme,
//                         colorScheme: colorScheme,
//                       ),

//                       const SizedBox(height: 20),
//                       _buildCheckoutButton(cartProvider, theme, colorScheme),
//                       const SizedBox(height: 20),
//                     ],
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

//   Widget _buildCartList(
//       CartProvider cartProvider, ThemeData theme, ColorScheme colorScheme) {
//     for (var item in cartProvider.items) {
//       print(
//           "🛒 Cart Item -> ID: ${item.id}, Name: ${item.name}, Qty: ${item.quantity}");
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
//               await cartProvider.removeItem(
//                 item.id,
//                 user?.userId.toString(),
//               );
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
//       CartProvider cartProvider, ThemeData theme, ColorScheme colorScheme) {
//     final isDisabled = cartProvider.isLoading ||
//         !cartProvider.hasItems ||
//         !cartProvider.isVendorActive ||
//         cartProvider.hasInactiveProducts; // 👈 disable if any issue

//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: isDisabled
//             ? null
//             : () => _handleCheckout(cartProvider),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: colorScheme.primary,
//           foregroundColor: colorScheme.onPrimary,
//           disabledBackgroundColor:
//               colorScheme.onSurface.withOpacity(0.12),
//           disabledForegroundColor:
//               colorScheme.onSurface.withOpacity(0.38),
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

//   Widget _buildVendorClosedBanner(
//       ThemeData theme, ColorScheme colorScheme) {
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
//           Icon(Icons.store_mall_directory,
//               color: colorScheme.onErrorContainer),
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
//       CartProvider cartProvider,
//       ThemeData theme,
//       ColorScheme colorScheme) {
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
//           Icon(Icons.info_outline,
//               color: colorScheme.onTertiaryContainer),
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
//               final provider =
//                   Provider.of<CartProvider>(context, listen: false);
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
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.shopping_cart_outlined,
//             size: 100,
//             color: colorScheme.onSurface.withOpacity(0.5),
//           ),
//           const SizedBox(height: 20),
//           Text(
//             'Your cart is empty',
//             style: theme.textTheme.titleLarge?.copyWith(
//               fontWeight: FontWeight.bold,
//               color: colorScheme.onSurface,
//             ),
//           ),
//           const SizedBox(height: 10),
//           Text(
//             'Add some delicious items to your cart',
//             style: theme.textTheme.bodyMedium?.copyWith(
//               color: colorScheme.onSurface.withOpacity(0.7),
//             ),
//           ),
//           const SizedBox(height: 30),
//         ],
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
//               color: Colors.black.withOpacity(0.1),
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



















// cart_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:veegify/helper/storage_helper.dart';
import 'package:veegify/model/CartModel/cart_model.dart';
import 'package:veegify/model/user_model.dart';
import 'package:veegify/provider/CartProvider/cart_provider.dart';
import 'package:veegify/provider/BookingProvider/booking_provider.dart';
import 'package:veegify/views/Booking/checkout_screen.dart';
import 'package:veegify/views/Cart/cart_summary.dart';
import 'package:veegify/views/PaymentSuccess/payment_success_screen.dart';

// lifecycle
import 'package:veegify/core/app_lifecycle_service.dart';

// responsive util
import 'package:veegify/utils/responsive.dart';

class CartScreenWithController extends StatelessWidget {
  final ScrollController scrollController;

  const CartScreenWithController({
    super.key,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return CartScreen(scrollController: scrollController);
  }
}

class CartScreen extends StatefulWidget {
  final ScrollController? scrollController;

  const CartScreen({super.key, this.scrollController});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _couponController = TextEditingController();
  bool _isCouponLoading = false;
  User? user;

  /// 🔁 Polling timer
  Timer? _pollingTimer;

  /// Dialog flags (so we don’t spam)
  bool _vendorInactiveHandled = false;
  bool _productInactiveHandled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCart();
    });
  }

  Future<void> _initializeCart() async {
    await _loadUserId();

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    await cartProvider.loadCart(user?.userId.toString());

    // handle status once initially
    await _handleStatusChanges(cartProvider);

    // start periodic polling
    _startCartPolling();
  }

  Future<void> _loadUserId() async {
    final userData = UserPreferences.getUser();
    if (userData != null) {
      setState(() {
        user = userData;
      });
      debugPrint("✅ Loaded User ID in CartScreen: ${user?.userId}");

      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.setUserId(user!.userId.toString());
    } else {
      debugPrint("⚠️ No user found in UserPreferences");
    }
  }

  void _startCartPolling() {
    _pollingTimer?.cancel();

    if (user == null) {
      debugPrint("⛔ Polling not started: user is null");
      return;
    }

    debugPrint("✅ Starting cart polling every 5 seconds");

    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!mounted) return;

      // 🔒 Only poll when app is visible (foreground)
      if (!AppLifecycleService.instance.isAppInForeground) {
        return;
      }

      // 🔒 Only poll when THIS screen is on top of stack
      final route = ModalRoute.of(context);
      final isRouteCurrent = route?.isCurrent ?? true;
      if (!isRouteCurrent) {
        return;
      }

      final cartProvider =
          Provider.of<CartProvider>(context, listen: false);

      debugPrint("🔄 [Cart Poll] loadCart for user: ${user?.userId}");
      await cartProvider.loadCart(user?.userId.toString());

      // after refresh, check statuses
      _handleStatusChanges(cartProvider);
    });
  }

  void _stopCartPolling() {
    debugPrint("🛑 Stopping cart polling");
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  void dispose() {
    _stopCartPolling();
    _couponController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _applyCoupon(CartProvider cartProvider) async {
    if (_couponController.text.trim().isEmpty) {
      _showSnackBar('Please enter a coupon code', Colors.red);
      return;
    }

    setState(() => _isCouponLoading = true);

    try {
      final success =
          await cartProvider.applyCoupon(_couponController.text.trim());

      if (!mounted) return;
      setState(() => _isCouponLoading = false);

      if (success) {
        _showSnackBar('Coupon applied successfully!', Colors.green);
        _couponController.clear();
      } else {
        _showSnackBar(
          cartProvider.error ?? 'Failed to apply coupon',
          Colors.red,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCouponLoading = false);
      _showSnackBar('Error: $e', Colors.red);
    }
  }

  Future<void> _removeCoupon(CartProvider cartProvider) async {
    try {
      final success = await cartProvider.removeCoupon();
      if (success) {
        _showSnackBar('Coupon removed', Colors.green);
      } else {
        _showSnackBar(
          cartProvider.error ?? 'Failed to remove coupon',
          Colors.red,
        );
      }
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    }
  }

  Future<void> _handleCheckout(CartProvider cartProvider) async {
    try {
      if (!cartProvider.isVendorActive) {
        _showSnackBar('Restaurant is closed. Cannot proceed.', Colors.red);
        return;
      }
      if (cartProvider.hasInactiveProducts) {
        _showSnackBar(
          'Remove unavailable items before checkout.',
          Colors.red,
        );
        return;
      }

      _showSnackBar('Processing order...', Colors.blue);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CheckoutScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to place order: $e', Colors.red);
      }
    }
  }

  /// 🔥 Checks restaurant & product statuses after each refresh / initial load.
  Future<void> _handleStatusChanges(CartProvider cartProvider) async {
    if (!mounted) return;
    if (!cartProvider.hasItems) return;

    // 1️⃣ Vendor inactive -> clear cart and block
    if (!cartProvider.isVendorActive && !_vendorInactiveHandled) {
      _vendorInactiveHandled = true;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Restaurant Closed'),
            content: const Text(
              'The restaurant is currently inactive/closed. '
              'Your cart items from this vendor will be removed.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      await cartProvider.clearCart();
      if (mounted) {
        _showSnackBar(
          'Restaurant is closed. Cart cleared.',
          Colors.red,
        );
      }
      return;
    }

    // 2️⃣ Some products inactive -> prompt to remove
    if (cartProvider.hasInactiveProducts &&
        !_productInactiveHandled &&
        cartProvider.isVendorActive) {
      _productInactiveHandled = true;

      final inactiveProducts = cartProvider.items
          .where((p) => !p.isProductActive)
          .toList();

      final names = inactiveProducts.map((p) => p.name).join(', ');

      final remove = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Items Unavailable'),
            content: Text(
              'Some items are no longer available:\n\n'
              '$names\n\n'
              'Do you want to remove them from the cart '
              'and continue with remaining items?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Remove & Continue'),
              ),
            ],
          );
        },
      );

      if (remove == true) {
        for (final p in inactiveProducts) {
          await cartProvider.removeItem(
            p.id,
            user?.userId.toString(),
          );
        }
        if (mounted) {
          _showSnackBar(
            'Unavailable items removed from cart.',
            Colors.orange,
          );
        }
      } else {
        // user cancelled, allow showing dialog again later
        _productInactiveHandled = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final isDesktop = Responsive.isDesktop(context);

    final double horizontalPadding = isMobile ? 16 : 24;
    final double maxWidth =
        isDesktop ? 1100 : (isTablet ? 900 : double.infinity);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            if (cartProvider.isLoading && !cartProvider.hasItems) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Loading cart...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (cartProvider.error != null && !cartProvider.hasItems) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 64, color: colorScheme.error),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${cartProvider.error}',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _initializeCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (!cartProvider.hasItems) {
              return EmptyCartWidget(theme: theme, colorScheme: colorScheme);
            }

            return RefreshIndicator(
              onRefresh: () =>
                  cartProvider.loadCart(user?.userId.toString()),
              color: colorScheme.primary,
              child: SingleChildScrollView(
                controller: widget.scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(theme, colorScheme),
                          const SizedBox(height: 20),

                          // 🔥 Status banners
                          if (!cartProvider.isVendorActive)
                            _buildVendorClosedBanner(theme, colorScheme),
                          if (cartProvider.hasInactiveProducts &&
                              cartProvider.isVendorActive)
                            _buildInactiveProductsBanner(
                              cartProvider,
                              theme,
                              colorScheme,
                            ),

                          const SizedBox(height: 10),

                          // 📱 Mobile: stacked layout
                          // 💻 Tablet/Desktop: 2-column layout
                          if (isMobile) ...[
                            _buildCartList(
                              cartProvider,
                              theme,
                              colorScheme,
                            ),
                            // const SizedBox(height: 20),
                            // _buildCouponSection(
                            //   context,
                            //   cartProvider,
                            //   theme,
                            //   colorScheme,
                            // ),
                            const SizedBox(height: 10),
                            TicketPricingSummary(
                              cartProvider: cartProvider,
                              theme: theme,
                              colorScheme: colorScheme,
                            ),
                            const SizedBox(height: 20),
                            _buildCheckoutButton(
                              cartProvider,
                              theme,
                              colorScheme,
                            ),
                            const SizedBox(height: 20),
                          ] else ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Cart list
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildCartList(
                                        cartProvider,
                                        theme,
                                        colorScheme,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 24),
                                // Summary and coupon
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // _buildCouponSection(
                                      //   context,
                                      //   cartProvider,
                                      //   theme,
                                      //   colorScheme,
                                      // ),
                                      // const SizedBox(height: 12),
                                      TicketPricingSummary(
                                        cartProvider: cartProvider,
                                        theme: theme,
                                        colorScheme: colorScheme,
                                      ),
                                      const SizedBox(height: 16),
                                      _buildCheckoutButton(
                                        cartProvider,
                                        theme,
                                        colorScheme,
                                      ),
                                    ],
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

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: colorScheme.primary.withOpacity(0.1),
          child: Icon(Icons.shopping_cart, color: colorScheme.primary),
        ),
        const SizedBox(width: 20),
        Text(
          'My Cart',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCouponSection(
    BuildContext context,
    CartProvider cartProvider,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Have a coupon?',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _couponController,
                  decoration: InputDecoration(
                    hintText: 'Enter coupon code',
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _isCouponLoading
                          ? null
                          : () => _applyCoupon(cartProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isCouponLoading
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  colorScheme.onPrimary,
                                ),
                              ),
                            )
                          : const Text('Apply'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => _removeCoupon(cartProvider),
                      child: const Text('Remove'),
                    ),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _couponController,
                    decoration: InputDecoration(
                      labelText: 'Coupon code',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isCouponLoading
                      ? null
                      : () => _applyCoupon(cartProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isCouponLoading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : const Text('Apply'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _removeCoupon(cartProvider),
                  child: const Text('Remove'),
                ),
              ],
            ),
    );
  }

  Widget _buildCartList(
      CartProvider cartProvider, ThemeData theme, ColorScheme colorScheme) {
    for (var item in cartProvider.items) {
      debugPrint(
          "🛒 Cart Item -> ID: ${item.id}, Name: ${item.name}, Qty: ${item.quantity}");
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cartProvider.items.length,
      itemBuilder: (context, index) {
        final item = cartProvider.items[index];
        return CartItemWidget(
          cartProduct: item,
          onIncrement: () async {
            try {
              await cartProvider.incrementQuantity(
                item.id,
                user?.userId.toString(),
              );
            } catch (e) {
              _showSnackBar('Failed to update: $e', Colors.red);
            }
          },
          onDecrement: () async {
            try {
              await cartProvider.decrementQuantity(
                item.id,
                user?.userId.toString(),
              );
            } catch (e) {
              _showSnackBar('Failed to update: $e', Colors.red);
            }
          },
          onRemove: () async {
            try {
              await cartProvider.removeItem(
                item.id,
                user?.userId.toString(),
              );
              _showSnackBar('Item removed', Colors.green);
            } catch (e) {
              _showSnackBar('Failed to remove: $e', Colors.red);
            }
          },
          theme: theme,
          colorScheme: colorScheme,
        );
      },
    );
  }

  Widget _buildCheckoutButton(
      CartProvider cartProvider, ThemeData theme, ColorScheme colorScheme) {
    final isDisabled = cartProvider.isLoading ||
        !cartProvider.hasItems ||
        !cartProvider.isVendorActive ||
        cartProvider.hasInactiveProducts; // 👈 disable if any issue

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            isDisabled ? null : () => _handleCheckout(cartProvider),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor:
              colorScheme.onSurface.withOpacity(0.12),
          disabledForegroundColor:
              colorScheme.onSurface.withOpacity(0.38),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Checkout',
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildVendorClosedBanner(
      ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.store_mall_directory,
              color: colorScheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'This restaurant is currently closed. '
              'You cannot continue with this cart.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInactiveProductsBanner(
      CartProvider cartProvider,
      ThemeData theme,
      ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline,
              color: colorScheme.onTertiaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Some items in your cart are no longer available. '
              'Please remove them to continue.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onTertiaryContainer,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final provider =
                  Provider.of<CartProvider>(context, listen: false);
              await _handleStatusChanges(provider);
            },
            child: const Text('FIX'),
          ),
        ],
      ),
    );
  }
}

class EmptyCartWidget extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme colorScheme;

  const EmptyCartWidget({
    super.key,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final iconSize = isDesktop ? 140.0 : 100.0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: iconSize,
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            Text(
              'Your cart is empty',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Add some delicious items to your cart',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

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
    final bool isInactive = !cartProduct.isProductActive;

    return Opacity(
      opacity: isInactive ? 0.6 : 1.0,
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
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                cartProduct.image,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 60,
                    height: 60,
                    color: colorScheme.surfaceVariant,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => Container(
                  width: 60,
                  height: 60,
                  color: colorScheme.surfaceVariant,
                  child: Icon(
                    Icons.image,
                    size: 30,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartProduct.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (cartProduct.addOn.variation.isNotEmpty)
                    Text(
                      'Size: ${cartProduct.addOn.variation}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  if (cartProduct.addOn.plateitems > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Plates: ${cartProduct.addOn.plateitems}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '₹${cartProduct.price}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  if (isInactive) ...[
                    const SizedBox(height: 6),
                    Text(
                      'This item is unavailable. Please remove to continue.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: onRemove,
                        child: const Text('Remove'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              children: [
                // Quantity controls (disabled if inactive)
                Row(
                  children: [
                    GestureDetector(
                      onTap: isInactive ? null : onDecrement,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isInactive
                              ? colorScheme.onSurface.withOpacity(0.15)
                              : colorScheme.primary,
                        ),
                        child: Icon(
                          Icons.remove,
                          size: 18,
                          color: isInactive
                              ? colorScheme.onSurface.withOpacity(0.4)
                              : colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 28,
                      child: Text(
                        cartProduct.quantity.toString().padLeft(2, '0'),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: isInactive ? null : onIncrement,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isInactive
                              ? colorScheme.onSurface.withOpacity(0.15)
                              : colorScheme.primary,
                        ),
                        child: Icon(
                          Icons.add,
                          size: 18,
                          color: isInactive
                              ? colorScheme.onSurface.withOpacity(0.4)
                              : colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Delete icon
                GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete,
                      size: 20,
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
              fontWeight: fontWeight,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: valueColor ?? colorScheme.onSurface,
              fontWeight: fontWeight,
            ),
          ),
        ],
      ),
    );
  }
}
