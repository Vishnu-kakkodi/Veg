
// // cart_screen.dart
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
//   }

//   Future<void> _loadUserId() async {
//     final userData = UserPreferences.getUser();
//     if (userData != null) {
//       setState(() {
//         user = userData;
//       });
//       print("UUUUUUUUUUUU${user?.userId.toString()}");

//       final cartProvider = Provider.of<CartProvider>(context, listen: false);
//       cartProvider.setUserId(user!.userId.toString());
//     }
//   }

//   @override
//   void dispose() {
//     _couponController.dispose();
//     super.dispose();
//   }

//   void _showSnackBar(String message, Color backgroundColor) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: backgroundColor,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           duration: const Duration(seconds: 2),
//         ),
//       );
//     }
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

//       if (mounted) {
//         setState(() => _isCouponLoading = false);

//         if (success) {
//           _showSnackBar('Coupon applied successfully!', Colors.green);
//           _couponController.clear();
//         } else {
//           _showSnackBar(
//               cartProvider.error ?? 'Failed to apply coupon', Colors.red);
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => _isCouponLoading = false);
//         _showSnackBar('Error: $e', Colors.red);
//       }
//     }
//   }

//   Future<void> _removeCoupon(CartProvider cartProvider) async {
//     try {
//       final success = await cartProvider.removeCoupon();
//       if (success) {
//         _showSnackBar('Coupon removed', Colors.green);
//       } else {
//         _showSnackBar(
//             cartProvider.error ?? 'Failed to remove coupon', Colors.red);
//       }
//     } catch (e) {
//       _showSnackBar('Error: $e', Colors.red);
//     }
//   }

//   Future<void> _handleCheckout(CartProvider cartProvider) async {
//     try {
//       _showSnackBar('Processing order...', Colors.blue);

//       if (mounted) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//               builder: (context) => const CheckoutScreen()),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         _showSnackBar('Failed to place order: $e', Colors.red);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//     final isDark = theme.brightness == Brightness.dark;

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       body: SafeArea(
//         child: Consumer<CartProvider>(
//           builder: (context, cartProvider, child) {
//             if (cartProvider.isLoading) {
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
//               onRefresh: () => cartProvider.loadCart(user?.userId.toString()),
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
//                       _buildCartList(cartProvider, theme, colorScheme),
//                       const SizedBox(height: 10),
//                       // _buildCouponSection(cartProvider, theme, colorScheme),
//                       const SizedBox(height: 20),
//                       // _buildPricingSummary(cartProvider, theme, colorScheme),
//                       TicketPricingSummary(
//   cartProvider: cartProvider,
//   theme: theme,
//   colorScheme: colorScheme,
// ),
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

//   Widget _buildCartList(CartProvider cartProvider, ThemeData theme, ColorScheme colorScheme) {
//     // ✅ Print all cart items
//     for (var item in cartProvider.items) {
//       print("Cart Item -> ID: ${item.id}, Name: ${item.name}, Qty: ${item.quantity},");
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
//               await cartProvider.incrementQuantity(item.id,(user?.userId.toString()));
//             } catch (e) {
//               _showSnackBar('Failed to update: $e', Colors.red);
//             }
//           },
//           onDecrement: () async {
//             try {
//               await cartProvider.decrementQuantity(item.id,(user?.userId.toString()));
//             } catch (e) {
//               _showSnackBar('Failed to update: $e', Colors.red);
//             }
//           },
//           onRemove: () async {
//             try {
//               await cartProvider.removeItem(item.id,(user?.userId.toString()) );
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

//   Widget _buildCouponSection(CartProvider cartProvider, ThemeData theme, ColorScheme colorScheme) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: colorScheme.surfaceVariant,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (cartProvider.appliedCoupon != null) ...[
//             Row(
//               children: [
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: colorScheme.primary,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     cartProvider.appliedCoupon!.code,
//                     style: TextStyle(
//                       color: colorScheme.onPrimary,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   '₹${cartProvider.couponDiscount} saved',
//                   style: TextStyle(
//                     color: colorScheme.primary,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const Spacer(),
//                 TextButton(
//                   onPressed: () => _removeCoupon(cartProvider),
//                   child: Text('Remove',
//                       style: TextStyle(color: colorScheme.error)),
//                 ),
//               ],
//             ),
//           ] else ...[
//             // You can uncomment this section if you want to show coupon input
//             /*
//             const Text(
//               'Have a coupon code?',
//               style: TextStyle(fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _couponController,
//                     decoration: InputDecoration(
//                       hintText: 'Enter Coupon Code',
//                       filled: true,
//                       fillColor: theme.cardColor,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 GestureDetector(
//                   onTap: _isCouponLoading
//                       ? null
//                       : () => _applyCoupon(cartProvider),
//                   child: Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: _isCouponLoading ? Colors.grey : colorScheme.primary,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: _isCouponLoading
//                         ? SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(
//                               color: colorScheme.onPrimary,
//                               strokeWidth: 2,
//                             ),
//                           )
//                         : Icon(Icons.arrow_forward, color: colorScheme.onPrimary),
//                   ),
//                 ),
//               ],
//             ),
//             */
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildPricingSummary(CartProvider cartProvider, ThemeData theme, ColorScheme colorScheme) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: colorScheme.surfaceVariant,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [
//           RowItem(
//             label: 'Total Items',
//             value: cartProvider.totalItems.toString().padLeft(2, '0'),
//             theme: theme,
//             colorScheme: colorScheme,
//           ),
//           if (cartProvider.couponDiscount > 0)
//             RowItem(
//               label: 'Coupon Discount',
//               value: '-₹${cartProvider.couponDiscount.toStringAsFixed(2)}',
//               valueColor: colorScheme.primary,
//               theme: theme,
//               colorScheme: colorScheme,
//             ),
//           RowItem(
//             label: 'Delivery charge',
//             value: '₹${cartProvider.deliveryCharge.toStringAsFixed(2)}',
//             theme: theme,
//             colorScheme: colorScheme,
//           ),
//                     RowItem(
//             label: 'PlatForm charge',
//             value: '₹${cartProvider.platformCharge.toStringAsFixed(2)}',
//             theme: theme,
//             colorScheme: colorScheme,
//           ),
//                     RowItem(
//             label: 'GST charge',
//             value: '₹${cartProvider.gstAmount.toStringAsFixed(2)}',
//             theme: theme,
//             colorScheme: colorScheme,
//           ),
//                     RowItem(
//             label: 'Sub Total',
//             value: '₹${cartProvider.subtotal.toStringAsFixed(2)}',
//             theme: theme,
//             colorScheme: colorScheme,
//           ),
//           Divider(color: colorScheme.outline.withOpacity(0.3)),
//           RowItem(
//             label: 'Total Payable',
//             value: '₹${cartProvider.totalPayable.toStringAsFixed(2)}',
//             valueColor: colorScheme.primary,
//             fontWeight: FontWeight.bold,
//             theme: theme,
//             colorScheme: colorScheme,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCheckoutButton(CartProvider cartProvider, ThemeData theme, ColorScheme colorScheme) {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: (cartProvider.isLoading || !cartProvider.hasItems)
//             ? null
//             : () => _handleCheckout(cartProvider),
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
//         child: cartProvider.isLoading
//             ? Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(
//                       color: colorScheme.onPrimary,
//                       strokeWidth: 2,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     'Processing...',
//                     style: theme.textTheme.titleMedium?.copyWith(
//                       color: colorScheme.onPrimary,
//                     ),
//                   ),
//                 ],
//               )
//             : Text(
//                 'Checkout',
//                 style: theme.textTheme.titleMedium?.copyWith(
//                   color: colorScheme.onPrimary,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
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
//           // You can uncomment this button if needed
//           /*
//           ElevatedButton(
//             onPressed: () => Navigator.of(context).pop(),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: colorScheme.primary,
//               foregroundColor: colorScheme.onPrimary,
//               padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: const Text(
//               'Start Shopping',
//               style: TextStyle(fontSize: 16),
//             ),
//           ),
//           */
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
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: theme.cardColor,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             spreadRadius: 1,
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: Image.network(
//               cartProduct.image,
//               width: 60,
//               height: 60,
//               fit: BoxFit.cover,
//               loadingBuilder: (context, child, loadingProgress) {
//                 if (loadingProgress == null) return child;
//                 return Container(
//                   width: 60,
//                   height: 60,
//                   color: colorScheme.surfaceVariant,
//                   child: Center(
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       color: colorScheme.primary,
//                     ),
//                   ),
//                 );
//               },
//               errorBuilder: (_, __, ___) => Container(
//                 width: 60,
//                 height: 60,
//                 color: colorScheme.surfaceVariant,
//                 child: Icon(
//                   Icons.image,
//                   size: 30,
//                   color: colorScheme.onSurfaceVariant,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   cartProduct.name,
//                   style: theme.textTheme.titleSmall?.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Size: ${cartProduct.addOn.variation}',
//                   style: theme.textTheme.bodySmall?.copyWith(
//                     color: colorScheme.onSurface.withOpacity(0.7),
//                   ),
//                 ),
//                 if (cartProduct.addOn.plateitems > 0) ...[
//                   const SizedBox(height: 2),
//                   Text(
//                     'Plates: ${cartProduct.addOn.plateitems}',
//                     style: theme.textTheme.bodySmall?.copyWith(
//                       color: colorScheme.onSurface.withOpacity(0.7),
//                     ),
//                   ),
//                 ],
//                 const SizedBox(height: 4),
//                 Text(
//                   '₹${cartProduct.price}',
//                   style: theme.textTheme.titleSmall?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: colorScheme.primary,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Row(
//             children: [
//               GestureDetector(
//                 onTap: onDecrement,
//                 child: Container(
//                   width: 32,
//                   height: 32,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: colorScheme.primary,
//                   ),
//                   child: Icon(
//                     Icons.remove,
//                     size: 18,
//                     color: colorScheme.onPrimary,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               SizedBox(
//                 width: 28,
//                 child: Text(
//                   cartProduct.quantity.toString().padLeft(2, '0'),
//                   textAlign: TextAlign.center,
//                   style: theme.textTheme.bodyMedium?.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               GestureDetector(
//                 onTap: onIncrement,
//                 child: Container(
//                   width: 32,
//                   height: 32,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: colorScheme.primary,
//                   ),
//                   child: Icon(
//                     Icons.add,
//                     size: 18,
//                     color: colorScheme.onPrimary,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(width: 12),
//           GestureDetector(
//             onTap: onRemove,
//             child: Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: colorScheme.errorContainer,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.delete,
//                 size: 20,
//                 color: colorScheme.onErrorContainer,
//               ),
//             ),
//           ),
//         ],
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
// import 'package:veegify/views/PaymentSuccess/payment_success_screen.dart';

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

//   // 🔁 Polling every 5 seconds
//   Timer? _pollingTimer;

//   // Status dialog flags
//   bool _vendorInactiveHandled = false;
//   bool _productInactiveHandled = false;

//   // Collapsible summary
//   bool _isSummaryExpanded = false;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _initializeCart();
//     });
//   }

//   Future<void> _initializeCart() async {
//     // 1. Load user
//     await _loadUserId();

//     // 2. First cart load
//     final cartProvider = Provider.of<CartProvider>(context, listen: false);
//     await cartProvider.loadCart(user?.userId.toString());

//     // 3. Check statuses once immediately
//     await _handleStatusChanges(cartProvider);

//     // 4. Start polling every 5 seconds
//     _startCartPolling();
//   }

//   Future<void> _loadUserId() async {
//     final userData = UserPreferences.getUser();
//     if (userData != null) {
//       setState(() {
//         user = userData;
//       });
//       print("Loaded User ID: ${user?.userId.toString()}");

//       final cartProvider = Provider.of<CartProvider>(context, listen: false);
//       cartProvider.setUserId(user!.userId.toString());
//     }
//   }

//   void _startCartPolling() {
//     _pollingTimer?.cancel();

//     if (user == null) {
//       print("⛔ No user, polling not started");
//       return;
//     }

//     print("✅ Starting cart polling every 5 seconds");
//     _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
//       if (!mounted) return;

//       final cartProvider =
//           Provider.of<CartProvider>(context, listen: false);

//       print("🔄 Polling: fetching cart for user ${user?.userId}");
//       await cartProvider.loadCart(user?.userId.toString());

//       // After refresh, update statuses
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

//   /// Checks restaurant & product statuses after each refresh / initial load.
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
//               'Do you want to remove them from the cart and continue with remaining items?',
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
//         // If user refused to remove, allow dialog again in future
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

//                       // Status banners
//                       if (!cartProvider.isVendorActive)
//                         _buildVendorClosedBanner(theme, colorScheme),
//                       if (cartProvider.hasInactiveProducts &&
//                           cartProvider.isVendorActive)
//                         _buildInactiveProductsBanner(
//                             cartProvider, theme, colorScheme),

//                       _buildCartList(
//                           cartProvider, theme, colorScheme),
//                       const SizedBox(height: 10),
//                       const SizedBox(height: 20),

//                       // Collapsible Price Summary
//                       _buildPricingSummary(
//                           cartProvider, theme, colorScheme),

//                       const SizedBox(height: 20),
//                       _buildCheckoutButton(
//                           cartProvider, theme, colorScheme),
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
//           "Cart Item -> ID: ${item.id}, Name: ${item.name}, Qty: ${item.quantity}");
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
//                   item.id, (user?.userId.toString()));
//             } catch (e) {
//               _showSnackBar('Failed to update: $e', Colors.red);
//             }
//           },
//           onDecrement: () async {
//             try {
//               await cartProvider.decrementQuantity(
//                   item.id, (user?.userId.toString()));
//             } catch (e) {
//               _showSnackBar('Failed to update: $e', Colors.red);
//             }
//           },
//           onRemove: () async {
//             try {
//               await cartProvider.removeItem(
//                   item.id, (user?.userId.toString()));
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

//   /// Collapsible Price Summary
//   Widget _buildPricingSummary(
//       CartProvider cartProvider, ThemeData theme, ColorScheme colorScheme) {
//     return AnimatedSize(
//       duration: const Duration(milliseconds: 250),
//       curve: Curves.easeInOut,
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: colorScheme.surfaceVariant,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           children: [
//             // Header row: To Pay + arrow
//             InkWell(
//               onTap: () {
//                 setState(() {
//                   _isSummaryExpanded = !_isSummaryExpanded;
//                 });
//               },
//               child: Row(
//                 children: [
//                   Text(
//                     'To Pay',
//                     style: theme.textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const Spacer(),
//                   Text(
//                     '₹${cartProvider.totalPayable.toStringAsFixed(2)}',
//                     style: theme.textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: colorScheme.primary,
//                     ),
//                   ),
//                   const SizedBox(width: 4),
//                   Icon(
//                     _isSummaryExpanded
//                         ? Icons.keyboard_arrow_up
//                         : Icons.keyboard_arrow_down,
//                     color: colorScheme.onSurface,
//                   ),
//                 ],
//               ),
//             ),

//             // Expanded details
//             if (_isSummaryExpanded) ...[
//               const SizedBox(height: 8),
//               const Divider(),
//               const SizedBox(height: 4),
//               RowItem(
//                 label: 'Total Items',
//                 value: cartProvider.totalItems.toString().padLeft(2, '0'),
//                 theme: theme,
//                 colorScheme: colorScheme,
//               ),
//               if (cartProvider.couponDiscount > 0)
//                 RowItem(
//                   label: 'Coupon Discount',
//                   value:
//                       '-₹${cartProvider.couponDiscount.toStringAsFixed(2)}',
//                   valueColor: colorScheme.primary,
//                   theme: theme,
//                   colorScheme: colorScheme,
//                 ),
//               RowItem(
//                 label: 'Delivery charge',
//                 value:
//                     '₹${cartProvider.deliveryCharge.toStringAsFixed(2)}',
//                 theme: theme,
//                 colorScheme: colorScheme,
//               ),
//               RowItem(
//                 label: 'Platform charge',
//                 value:
//                     '₹${cartProvider.platformCharge.toStringAsFixed(2)}',
//                 theme: theme,
//                 colorScheme: colorScheme,
//               ),
//               RowItem(
//                 label: 'GST charge',
//                 value: '₹${cartProvider.gstAmount.toStringAsFixed(2)}',
//                 theme: theme,
//                 colorScheme: colorScheme,
//               ),
//               RowItem(
//                 label: 'Sub Total',
//                 value: '₹${cartProvider.subtotal.toStringAsFixed(2)}',
//                 theme: theme,
//                 colorScheme: colorScheme,
//               ),
//               Divider(color: colorScheme.outline.withOpacity(0.3)),
//               RowItem(
//                 label: 'Total Payable',
//                 value:
//                     '₹${cartProvider.totalPayable.toStringAsFixed(2)}',
//                 valueColor: colorScheme.primary,
//                 fontWeight: FontWeight.bold,
//                 theme: theme,
//                 colorScheme: colorScheme,
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCheckoutButton(
//       CartProvider cartProvider, ThemeData theme, ColorScheme colorScheme) {
//     final isDisabled = cartProvider.isLoading ||
//         !cartProvider.hasItems ||
//         !cartProvider.isVendorActive ||
//         cartProvider.hasInactiveProducts; // disable if any inactive

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
//         child: cartProvider.isLoading
//             ? Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(
//                       color: colorScheme.onPrimary,
//                       strokeWidth: 2,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     'Processing...',
//                     style: theme.textTheme.titleMedium?.copyWith(
//                       color: colorScheme.onPrimary,
//                     ),
//                   ),
//                 ],
//               )
//             : Text(
//                 'Checkout',
//                 style: theme.textTheme.titleMedium?.copyWith(
//                   color: colorScheme.onPrimary,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
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

//       final cartProvider =
//           Provider.of<CartProvider>(context, listen: false);

//       print("🔄 [Timer Tick] Calling loadCart for user: ${user?.userId}");
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
//               'Do you want to remove them from the cart and continue with remaining items?',
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
//         child: cartProvider.isLoading
//             // ? Row(
//             //     mainAxisAlignment: MainAxisAlignment.center,
//             //     children: [
//             //       SizedBox(
//             //         width: 20,
//             //         height: 20,
//             //         child: CircularProgressIndicator(
//             //           color: colorScheme.onPrimary,
//             //           strokeWidth: 2,
//             //         ),
//             //       ),
//             //       const SizedBox(width: 8),
//             //       Text(
//             //         'Processing...',
//             //         style: theme.textTheme.titleMedium?.copyWith(
//             //           color: colorScheme.onPrimary,
//             //         ),
//             //       ),
//             //     ],
//             //   )
//             ? Text(
//                 'Checkout',
//                 style: theme.textTheme.titleMedium?.copyWith(
//                   color: colorScheme.onPrimary,
//                   fontWeight: FontWeight.bold,
//                 ),
//               )
//             : Text(
//                 'Checkout',
//                 style: theme.textTheme.titleMedium?.copyWith(
//                   color: colorScheme.onPrimary,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
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

























// // cart_screen.dart
// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:veegify/helper/storage_helper.dart';
// import 'package:veegify/model/CartModel/cart_model.dart';
// import 'package:veegify/model/user_model.dart';
// import 'package:veegify/provider/CartProvider/cart_provider.dart';
// import 'package:veegify/views/Booking/checkout_screen.dart';
// import 'package:veegify/views/Cart/cart_summary.dart';

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

//   /// Dialog flags (avoid spam)
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

//       // 🔴 IMPORTANT: Only poll when this route is the current / visible one
//       final route = ModalRoute.of(context);
//       if (route == null || !route.isCurrent) {
//         // CartScreen is in the stack but not visible (e.g. Checkout on top)
//         // -> skip API call
//         return;
//       }

//       final cartProvider =
//           Provider.of<CartProvider>(context, listen: false);

//       print("🔄 [Timer Tick] Cart visible → calling loadCart for user: ${user?.userId}");
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
//               'Do you want to remove them from the cart and continue with remaining items?',
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
//         cartProvider.hasInactiveProducts;

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
import 'dart:async'; // 👈 for Timer

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

// 👇 import your lifecycle service (update path if needed)
import 'package:veegify/core/app_lifecycle_service.dart';

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
      print("✅ Loaded User ID in CartScreen: ${user?.userId}");

      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.setUserId(user!.userId.toString());
    } else {
      print("⚠️ No user found in UserPreferences");
    }
  }

  void _startCartPolling() {
    _pollingTimer?.cancel();

    if (user == null) {
      print("⛔ Polling not started: user is null");
      return;
    }

    print("✅ Starting cart polling every 5 seconds");

    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!mounted) return;

      // 🔒 Only poll when app is visible (foreground)
      if (!AppLifecycleService.instance.isAppInForeground) {
        // print("⏸️ App is background/hidden → skip cart polling");
        return;
      }

      // 🔒 Only poll when THIS screen is on top of stack
      final route = ModalRoute.of(context);
      final isRouteCurrent = route?.isCurrent ?? true;
      if (!isRouteCurrent) {
        // print("⏸️ CartScreen not current route → skip cart polling");
        return;
      }

      final cartProvider =
          Provider.of<CartProvider>(context, listen: false);

      print("🔄 [Cart Poll] loadCart for user: ${user?.userId}");
      await cartProvider.loadCart(user?.userId.toString());

      // after refresh, check statuses
      _handleStatusChanges(cartProvider);
    });
  }

  void _stopCartPolling() {
    print("🛑 Stopping cart polling");
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
              ));
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
                child: Padding(
                  padding: const EdgeInsets.all(16),
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
                            cartProvider, theme, colorScheme),

                      _buildCartList(cartProvider, theme, colorScheme),
                      const SizedBox(height: 10),

                      const SizedBox(height: 20),

                      // 🎫 Your ticket-style summary
                      TicketPricingSummary(
                        cartProvider: cartProvider,
                        theme: theme,
                        colorScheme: colorScheme,
                      ),

                      const SizedBox(height: 20),
                      _buildCheckoutButton(cartProvider, theme, colorScheme),
                      const SizedBox(height: 20),
                    ],
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

  Widget _buildCartList(
      CartProvider cartProvider, ThemeData theme, ColorScheme colorScheme) {
    for (var item in cartProvider.items) {
      print(
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
        onPressed: isDisabled
            ? null
            : () => _handleCheckout(cartProvider),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
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
          ),
          const SizedBox(height: 30),
        ],
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
              color: Colors.black.withOpacity(0.1),
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
