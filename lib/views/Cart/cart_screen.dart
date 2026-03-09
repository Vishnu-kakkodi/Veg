
// // // cart_screen.dart
// // import 'dart:async';
// // import 'dart:convert';

// // import 'package:flutter/foundation.dart';
// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:provider/provider.dart';

// // import 'package:veegify/helper/storage_helper.dart';
// // import 'package:veegify/model/CartModel/cart_model.dart';
// // import 'package:veegify/model/user_model.dart';
// // import 'package:veegify/provider/CartProvider/cart_provider.dart';
// // import 'package:veegify/views/Booking/checkout_screen.dart';
// // import 'package:veegify/views/Booking/checkout_screen_web.dart';
// // import 'package:veegify/views/Cart/cart_summary.dart';
// // import 'package:veegify/core/app_lifecycle_service.dart';
// // import 'package:veegify/utils/responsive.dart';
// // import 'package:veegify/views/Coupons/coupon_picker_modal.dart';

// // const String _kRemoveCouponUrl = 'https://api.vegiffyy.com/api/remove-coupon';

// // // ──────────────────────────────────────────────────────────────────────────
// // class CartScreenWithController extends StatelessWidget {
// //   final ScrollController scrollController;
// //   const CartScreenWithController({super.key, required this.scrollController});

// //   @override
// //   Widget build(BuildContext context) =>
// //       CartScreen(scrollController: scrollController);
// // }

// // // ──────────────────────────────────────────────────────────────────────────
// // class CartScreen extends StatefulWidget {
// //   final ScrollController? scrollController;
// //   const CartScreen({super.key, this.scrollController});

// //   @override
// //   State<CartScreen> createState() => _CartScreenState();
// // }

// // class _CartScreenState extends State<CartScreen> {
// //   User? user;
// //   Timer? _pollingTimer;
// //   bool _vendorInactiveHandled = false;
// //   bool _productInactiveHandled = false;

// //   // ── Coupon local state (ZERO CartProvider connection) ────────────────────
// //   String? _appliedCouponId;   // stored after successful apply
// //   String? _appliedCouponCode; // shown in the bar
// //   bool _isRemovingCoupon = false;
// //   bool _isLoadingCouponState = true; // Track if we're loading coupon state

// //   @override
// //   void initState() {
// //     super.initState();
// //     WidgetsBinding.instance.addPostFrameCallback((_) => _initializeCart());
// //   }

// //   @override
// //   void dispose() {
// //     _stopPolling();
// //     super.dispose();
// //   }

// //   // ── Init ──────────────────────────────────────────────────────────────────
// //   Future<void> _initializeCart() async {
// //     print("User Id printing in cart Screen: ${user?.userId}");
// //     await _loadUser();
// //     final cp = context.read<CartProvider>();
// //     await cp.loadCart(user?.userId.toString());
    
// //     // After cart loads, extract coupon info from cart provider
// //     _extractCouponFromProvider(cp);
    
// //     await _handleStatusChanges(cp);
// //     _startPolling();
// //   }

// //   // Extract coupon information from cart provider (without setState if unchanged)
// //   void _extractCouponFromProvider(CartProvider cp) {
// //     final newId = cp.appliedCouponId;
// //     final newCode = cp.appliedCouponCode;
    
// //     setState(() {
// //       _isLoadingCouponState = false;
// //       // Only update if changed to avoid unnecessary rebuilds
// //       if (_appliedCouponId != newId || _appliedCouponCode != newCode) {
// //         _appliedCouponId = newId;
// //         _appliedCouponCode = newCode;
// //       }
// //     });
// //   }

// //   Future<void> _loadUser() async {
// //     final u = UserPreferences.getUser();
// //     if (u != null) {
// //       setState(() => user = u);
// //       context.read<CartProvider>().setUserId(u.userId.toString());
// //     }
// //   }

// //   // ── Polling ───────────────────────────────────────────────────────────────
// //   void _startPolling() {
// //     _pollingTimer?.cancel();
// //     if (user == null) return;
// //     _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
// //       if (!mounted) return;
// //       if (!AppLifecycleService.instance.isAppInForeground) return;
// //       if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;
      
// //       final cp = context.read<CartProvider>();
// //       await cp.loadCart(user?.userId.toString());
      
// //       // Update coupon state if changed (but loadCart already only notifies if changed)
// //       // Still need to sync local state with provider because we're using local state for coupon bar
// //       if (mounted) {
// //         _extractCouponFromProvider(cp);
// //       }
      
// //       _handleStatusChanges(cp);
// //     });
// //   }

// //   void _stopPolling() {
// //     _pollingTimer?.cancel();
// //     _pollingTimer = null;
// //   }

// //   // ── Snackbar ──────────────────────────────────────────────────────────────
// //   void _snack(String msg, Color color) {
// //     if (!mounted) return;
// //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
// //       content: Text(msg),
// //       backgroundColor: color,
// //       behavior: SnackBarBehavior.floating,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //       duration: const Duration(seconds: 2),
// //     ));
// //   }

// //   // ── Open coupon picker ────────────────────────────────────────────────────
// //   void _openCouponPicker() {
// //     if (user == null) {
// //       _snack('Please log in to apply coupons', Colors.red);
// //       return;
// //     }
// //     showCouponPickerModal(
// //       context: context,
// //       userId: user!.userId.toString(),
// //       onCouponApplied: ({required String couponId, required String couponCode}) {
// //         setState(() {
// //           _appliedCouponId = couponId;
// //           _appliedCouponCode = couponCode;
// //         });
// //         // Reload cart so prices reflect the discount
// //         context.read<CartProvider>().loadCart(user?.userId.toString());
// //         _snack('Coupon applied! 🎉', Colors.green);
// //       },
// //     );
// //   }

// //   // ── Remove coupon (direct API, no provider) ───────────────────────────────
// //   Future<void> _removeCoupon() async {
// //     if (_appliedCouponId == null) {
// //       _snack('No coupon to remove', Colors.orange);
// //       return;
// //     }
// //     setState(() => _isRemovingCoupon = true);
// //     try {
// //       final res = await http
// //           .post(
// //             Uri.parse(_kRemoveCouponUrl),
// //             headers: {'Content-Type': 'application/json'},
// //             body: json.encode({
// //               'userId': user!.userId.toString(),
// //               'couponId': _appliedCouponId,
// //             }),
// //           )
// //           .timeout(const Duration(seconds: 12));

// //       if (!mounted) return;

// //       if (res.statusCode == 200) {
// //         setState(() {
// //           _appliedCouponId = null;
// //           _appliedCouponCode = null;
// //           _isRemovingCoupon = false;
// //         });
// //         // Reload cart so the removed discount reflects in price
// //         context.read<CartProvider>().loadCart(user?.userId.toString());
// //         _snack('Coupon removed', Colors.green);
// //       } else {
// //         final msg = (json.decode(res.body) as Map<String, dynamic>)['message']
// //                 as String? ??
// //             'Failed to remove coupon';
// //         setState(() => _isRemovingCoupon = false);
// //         _snack(msg, Colors.red);
// //       }
// //     } catch (e) {
// //       if (!mounted) return;
// //       setState(() => _isRemovingCoupon = false);
// //       _snack('Error: $e', Colors.red);
// //     }
// //   }

// //   // ── Checkout ──────────────────────────────────────────────────────────────
// //   Future<void> _handleCheckout(CartProvider cp) async {
// //     if (!cp.isVendorActive) {
// //       _snack('Restaurant is closed. Cannot proceed.', Colors.red);
// //       return;
// //     }
// //     if (cp.hasInactiveProducts) {
// //       _snack('Remove unavailable items before checkout.', Colors.red);
// //       return;
// //     }
// //     if (mounted) {

// //   Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen()));
// // //  Navigator.push(context, MaterialPageRoute(builder: (_) => CheckoutScreenWeb()));
// //     }
// //   }

// //   // ── Status dialogs ────────────────────────────────────────────────────────
// //   Future<void> _handleStatusChanges(CartProvider cp) async {
// //     if (!mounted || !cp.hasItems) return;

// //     if (!cp.isVendorActive && !_vendorInactiveHandled) {
// //       _vendorInactiveHandled = true;
// //       await showDialog(
// //         context: context,
// //         barrierDismissible: false,
// //         builder: (ctx) => AlertDialog(
// //           title: const Text('Restaurant Closed'),
// //           content: const Text(
// //               'The restaurant is inactive. Your cart will be cleared.'),
// //           actions: [
// //             TextButton(
// //                 onPressed: () => Navigator.of(ctx).pop(),
// //                 child: const Text('OK')),
// //           ],
// //         ),
// //       );
// //       await cp.clearCart();
// //       if (mounted) _snack('Cart cleared — restaurant is closed.', Colors.red);
// //       return;
// //     }

// //     if (cp.hasInactiveProducts &&
// //         !_productInactiveHandled &&
// //         cp.isVendorActive) {
// //       _productInactiveHandled = true;
// //       final inactive = cp.items.where((p) => !p.isProductActive).toList();
// //       final names = inactive.map((p) => p.name).join(', ');
// //       final remove = await showDialog<bool>(
// //         context: context,
// //         barrierDismissible: false,
// //         builder: (ctx) => AlertDialog(
// //           title: const Text('Items Unavailable'),
// //           content: Text('$names\n\nRemove them and continue?'),
// //           actions: [
// //             TextButton(
// //                 onPressed: () => Navigator.of(ctx).pop(false),
// //                 child: const Text('Cancel')),
// //             TextButton(
// //                 onPressed: () => Navigator.of(ctx).pop(true),
// //                 child: const Text('Remove & Continue')),
// //           ],
// //         ),
// //       );
// //       if (remove == true) {
// //         for (final p in inactive) {
// //           await cp.removeItem(p.id, user?.userId.toString());
// //         }
// //         if (mounted) _snack('Unavailable items removed.', Colors.orange);
// //       } else {
// //         _productInactiveHandled = false;
// //       }
// //     }
// //   }

// //   // ── BUILD ──────────────────────────────────────────────────────────────────
// //   @override
// //   Widget build(BuildContext context) {
// //     final theme = Theme.of(context);
// //     final cs = theme.colorScheme;
// //     final isMobile = Responsive.isMobile(context);
// //     final width = MediaQuery.of(context).size.width;
// //     final hPad = width >= 1200 ? 40.0 : width >= 900 ? 24.0 : 16.0;
// //     final maxW = width >= 1400
// //         ? 1200.0
// //         : width >= 1100
// //             ? 1100.0
// //             : width >= 900
// //                 ? 900.0
// //                 : double.infinity;

// //     return Scaffold(
// //       backgroundColor: theme.scaffoldBackgroundColor,
// //       body: SafeArea(
// //         child: Consumer<CartProvider>(
// //           builder: (context, cp, _) {
// //             // Sync local coupon state with provider when provider changes
// //             // but avoid calling setState during build
// //             WidgetsBinding.instance.addPostFrameCallback((_) {
// //               if (mounted) {
// //                 _extractCouponFromProvider(cp);
// //               }
// //             });

// //             // Loading
// //             if (!cp.hasItems) {
// //               return Center(
// //                     child: Column(
// //                       mainAxisAlignment: MainAxisAlignment.center,
// //                       children: [
// //                         Container(
// //                           padding: const EdgeInsets.all(24),
// //                           decoration: BoxDecoration(
// //                             shape: BoxShape.circle,
// //                           ),
// //                           child: Icon(
// //                             Icons.shopify,
// //                             size:  64,
// //                             color: theme.colorScheme.onSurface.withOpacity(0.4),
// //                           ),
// //                         ),
// //                         const SizedBox(height: 24),
// //                         Text(
// //                           'Your cart is empty',
// //                           style: theme.textTheme.titleMedium?.copyWith(
// //                             fontWeight: FontWeight.w600,
// //                             color: theme.colorScheme.onSurface,
// //                             fontSize:  18,
// //                           ),
// //                         ),
// //                         const SizedBox(height: 8),
// //                         Text(
// //                           'Add items to see them here',
// //                           style: theme.textTheme.bodySmall?.copyWith(
// //                             color: theme.colorScheme.onSurface.withOpacity(0.7),
// //                             fontSize: 14,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   );
// //             }

// //             // Error
// //             if (cp.error != null && !cp.hasItems) {
// //               return Center(
// //                 child: Column(mainAxisSize: MainAxisSize.min, children: [
// //                   Icon(Icons.error_outline, size: 64, color: cs.error),
// //                   const SizedBox(height: 16),
// //                   Text('Error: ${cp.error}',
// //                       style: theme.textTheme.bodyMedium,
// //                       textAlign: TextAlign.center),
// //                   const SizedBox(height: 16),
// //                   ElevatedButton(
// //                     onPressed: _initializeCart,
// //                     style: ElevatedButton.styleFrom(
// //                         backgroundColor: cs.primary,
// //                         foregroundColor: cs.onPrimary),
// //                     child: const Text('Retry'),
// //                   ),
// //                 ]),
// //               );
// //             }

// //             // Empty
// //             if (!cp.hasItems) {
// //               return EmptyCartWidget(theme: theme, colorScheme: cs);
// //             }

// //             return RefreshIndicator(
// //               onRefresh: () => cp.loadCart(user?.userId.toString()),
// //               color: cs.primary,
// //               child: SingleChildScrollView(
// //                 controller: widget.scrollController,
// //                 physics: const AlwaysScrollableScrollPhysics(),
// //                 child: Center(
// //                   child: ConstrainedBox(
// //                     constraints: BoxConstraints(maxWidth: maxW),
// //                     child: Padding(
// //                       padding: EdgeInsets.symmetric(
// //                           horizontal: hPad, vertical: 16),
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           _buildHeader(theme, cs),
// //                           const SizedBox(height: 20),

// //                           if (!cp.isVendorActive)
// //                             _vendorBanner(theme, cs),
// //                           if (cp.hasInactiveProducts && cp.isVendorActive)
// //                             _inactiveBanner(cp, theme, cs),

// //                           const SizedBox(height: 10),

// //                           if (isMobile) ...[
// //                             _sectionCard(theme, cs,
// //                                 _buildCartList(cp, theme, cs)),
// //                             const SizedBox(height: 20),

// //                             // ── Coupon bar (local state only) ──────────────
// //                             _buildCouponBar(theme, cs),
// //                             const SizedBox(height: 10),

// //                             _sectionCard(theme, cs,
// //                                 TicketPricingSummary(
// //                                     cartProvider: cp,
// //                                     theme: theme,
// //                                     colorScheme: cs)),
// //                             const SizedBox(height: 20),
// //                             _checkoutBtn(cp, theme, cs),
// //                             const SizedBox(height: 20),
// //                           ] else ...[
// //                             Row(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               children: [
// //                                 Expanded(
// //                                   flex: 3,
// //                                   child: Column(children: [
// //                                     _sectionCard(theme, cs,
// //                                         _buildCartList(cp, theme, cs)),
// //                                     const SizedBox(height: 16),

// //                                     // ── Coupon bar (local state only) ──────
// //                                     _buildCouponBar(theme, cs),
// //                                   ]),
// //                                 ),
// //                                 const SizedBox(width: 24),
// //                                 Expanded(
// //                                   flex: 2,
// //                                   child: _StickySummaryCard(
// //                                     child: Column(
// //                                       crossAxisAlignment:
// //                                           CrossAxisAlignment.stretch,
// //                                       children: [
// //                                         _sectionCard(theme, cs,
// //                                             TicketPricingSummary(
// //                                                 cartProvider: cp,
// //                                                 theme: theme,
// //                                                 colorScheme: cs)),
// //                                         const SizedBox(height: 14),
// //                                         _checkoutBtn(cp, theme, cs),
// //                                       ],
// //                                     ),
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                             const SizedBox(height: 20),
// //                           ],
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             );
// //           },
// //         ),
// //       ),
// //     );
// //   }

// //   // ── Coupon bar ─────────────────────────────────────────────────────────────
// //   Widget _buildCouponBar(ThemeData theme, ColorScheme cs) {
// //     final hasCoupon = _appliedCouponId != null && _appliedCouponCode != null;

// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
// //       decoration: BoxDecoration(
// //         color: theme.cardColor,
// //         borderRadius: BorderRadius.circular(14),
// //         border: Border.all(color: cs.outline.withOpacity(0.18)),
// //         boxShadow: [
// //           BoxShadow(
// //               color: Colors.black.withOpacity(0.04),
// //               blurRadius: 8,
// //               offset: const Offset(0, 3)),
// //         ],
// //       ),
// //       child: Row(children: [
// //         Container(
// //           padding: const EdgeInsets.all(10),
// //           decoration: BoxDecoration(
// //             color: cs.primary.withOpacity(0.08),
// //             borderRadius: BorderRadius.circular(10),
// //           ),
// //           child: Icon(Icons.local_offer_outlined, color: cs.primary, size: 22),
// //         ),
// //         const SizedBox(width: 12),

// //         // Text side
// //         Expanded(
// //           child: hasCoupon
// //               ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// //                   Text('Coupon Applied! 🎉',
// //                       style: theme.textTheme.bodyMedium?.copyWith(
// //                           fontWeight: FontWeight.w700,
// //                           color: Colors.green.shade700)),
// //                   const SizedBox(height: 2),
// //                   Text(_appliedCouponCode ?? '',
// //                       style: theme.textTheme.bodySmall?.copyWith(
// //                           color: cs.onSurface.withOpacity(0.55),
// //                           letterSpacing: 1.2,
// //                           fontWeight: FontWeight.w600)),
// //                 ])
// //               : Text('Have a coupon code?',
// //                   style: theme.textTheme.bodyMedium
// //                       ?.copyWith(fontWeight: FontWeight.w600)),
// //         ),

// //         // Action button
// //         if (hasCoupon)
// //           _isRemovingCoupon
// //               ? SizedBox(
// //                   width: 20, height: 20,
// //                   child: CircularProgressIndicator(
// //                       strokeWidth: 2, color: cs.error))
// //               : GestureDetector(
// //                   onTap: _removeCoupon, // ← calls direct API, no provider
// //                   child: Container(
// //                     padding: const EdgeInsets.symmetric(
// //                         horizontal: 12, vertical: 8),
// //                     decoration: BoxDecoration(
// //                       color: cs.errorContainer,
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                     child: Text('Remove',
// //                         style: TextStyle(
// //                             fontSize: 12, fontWeight: FontWeight.w700,
// //                             color: cs.onErrorContainer)),
// //                   ),
// //                 )
// //         else
// //           GestureDetector(
// //             onTap: _openCouponPicker, // ← opens modal, no provider
// //             child: Container(
// //               padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
// //               decoration: BoxDecoration(
// //                 color: cs.primary,
// //                 borderRadius: BorderRadius.circular(10),
// //               ),
// //               child: Text('View Coupons',
// //                   style: TextStyle(
// //                       fontSize: 12, fontWeight: FontWeight.w700,
// //                       color: cs.onPrimary)),
// //             ),
// //           ),
// //       ]),
// //     );
// //   }

// //   // ── Helpers ───────────────────────────────────────────────────────────────
// //   Widget _buildHeader(ThemeData theme, ColorScheme cs) => Row(children: [
// //         CircleAvatar(
// //           radius: 25,
// //           backgroundColor: cs.primary.withOpacity(0.1),
// //           child: Icon(Icons.shopping_cart, color: cs.primary),
// //         ),
// //         const SizedBox(width: 20),
// //         Text('My Cart',
// //             style: theme.textTheme.titleLarge
// //                 ?.copyWith(fontWeight: FontWeight.bold)),
// //       ]);

// //   Widget _buildCartList(CartProvider cp, ThemeData theme, ColorScheme cs) =>
// //       ListView.builder(
// //         shrinkWrap: true,
// //         physics: const NeverScrollableScrollPhysics(),
// //         itemCount: cp.items.length,
// //         itemBuilder: (context, i) {
// //           final item = cp.items[i];
// //           return CartItemWidget(
// //             cartProduct: item,
// //             onIncrement: () async {
// //               try {
// //                 await cp.incrementQuantity(item.id, user?.userId.toString());
// //               } catch (e) {
// //                 _snack('Failed to update: $e', Colors.red);
// //               }
// //             },
// //             onDecrement: () async {
// //               try {
// //                 await cp.decrementQuantity(item.id, user?.userId.toString());
// //               } catch (e) {
// //                 _snack('Failed to update: $e', Colors.red);
// //               }
// //             },
// //             onRemove: () async {
// //               try {
// //                 await cp.removeItem(item.id, user?.userId.toString());
// //                 _snack('Item removed', Colors.green);
// //               } catch (e) {
// //                 _snack('Failed to remove: $e', Colors.red);
// //               }
// //             },
// //             theme: theme,
// //             colorScheme: cs,
// //           );
// //         },
// //       );

// //   Widget _checkoutBtn(CartProvider cp, ThemeData theme, ColorScheme cs) {
// //     final disabled = 
// //         !cp.hasItems ||
// //         !cp.isVendorActive ||
// //         cp.hasInactiveProducts;
// //     return SizedBox(
// //       width: double.infinity,
// //       child: ElevatedButton(
// //         onPressed: disabled ? null : () => _handleCheckout(cp),
// //         style: ElevatedButton.styleFrom(
// //           backgroundColor: cs.primary,
// //           foregroundColor: cs.onPrimary,
// //           disabledBackgroundColor: cs.onSurface.withOpacity(0.12),
// //           disabledForegroundColor: cs.onSurface.withOpacity(0.38),
// //           padding: const EdgeInsets.symmetric(vertical: 16),
// //           shape:
// //               RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //         ),
// //         child: Text('Checkout',
// //             style: theme.textTheme.titleMedium
// //                 ?.copyWith(color: cs.onPrimary, fontWeight: FontWeight.bold)),
// //       ),
// //     );
// //   }

// //   Widget _sectionCard(ThemeData theme, ColorScheme cs, Widget child) =>
// //       Container(
// //         padding: const EdgeInsets.all(14),
// //         decoration: BoxDecoration(
// //           color: theme.cardColor,
// //           borderRadius: BorderRadius.circular(14),
// //           border: Border.all(color: cs.outline.withOpacity(0.15)),
// //           boxShadow: [
// //             BoxShadow(
// //                 color: Colors.black.withOpacity(0.05),
// //                 blurRadius: 8,
// //                 offset: const Offset(0, 3))
// //           ],
// //         ),
// //         child: child,
// //       );

// //   Widget _vendorBanner(ThemeData theme, ColorScheme cs) => Container(
// //         width: double.infinity,
// //         margin: const EdgeInsets.only(bottom: 12),
// //         padding: const EdgeInsets.all(12),
// //         decoration: BoxDecoration(
// //             color: cs.errorContainer,
// //             borderRadius: BorderRadius.circular(12)),
// //         child: Row(children: [
// //           Icon(Icons.store_mall_directory, color: cs.onErrorContainer),
// //           const SizedBox(width: 8),
// //           Expanded(
// //               child: Text(
// //                   'This restaurant is currently closed.',
// //                   style: theme.textTheme.bodyMedium
// //                       ?.copyWith(color: cs.onErrorContainer))),
// //         ]),
// //       );

// //   Widget _inactiveBanner(
// //       CartProvider cp, ThemeData theme, ColorScheme cs) =>
// //       Container(
// //         width: double.infinity,
// //         margin: const EdgeInsets.only(bottom: 12),
// //         padding: const EdgeInsets.all(12),
// //         decoration: BoxDecoration(
// //             color: cs.tertiaryContainer,
// //             borderRadius: BorderRadius.circular(12)),
// //         child: Row(children: [
// //           Icon(Icons.info_outline, color: cs.onTertiaryContainer),
// //           const SizedBox(width: 8),
// //           Expanded(
// //               child: Text(
// //                   'Some items are no longer available. Please remove them.',
// //                   style: theme.textTheme.bodyMedium
// //                       ?.copyWith(color: cs.onTertiaryContainer))),
// //           TextButton(
// //               onPressed: () async => _handleStatusChanges(cp),
// //               child: const Text('FIX')),
// //         ]),
// //       );
// // }

// // // ──────────────────────────────────────────────────────────────────────────
// // //  EmptyCartWidget (unchanged)
// // // ──────────────────────────────────────────────────────────────────────────
// // class EmptyCartWidget extends StatelessWidget {
// //   final ThemeData theme;
// //   final ColorScheme colorScheme;
// //   const EmptyCartWidget(
// //       {super.key, required this.theme, required this.colorScheme});

// //   @override
// //   Widget build(BuildContext context) {
// //     final iconSize = Responsive.isDesktop(context) ? 140.0 : 100.0;
// //     return Center(
// //       child: Padding(
// //         padding: const EdgeInsets.all(24),
// //         child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
// //           Icon(Icons.shopping_cart_outlined,
// //               size: iconSize, color: colorScheme.onSurface.withOpacity(0.5)),
// //           const SizedBox(height: 20),
// //           Text('Your cart is empty',
// //               style: theme.textTheme.titleLarge
// //                   ?.copyWith(fontWeight: FontWeight.bold)),
// //           const SizedBox(height: 10),
// //           Text('Add some delicious items to your cart',
// //               style: theme.textTheme.bodyMedium
// //                   ?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
// //               textAlign: TextAlign.center),
// //           const SizedBox(height: 30),
// //         ]),
// //       ),
// //     );
// //   }
// // }

// // // ──────────────────────────────────────────────────────────────────────────
// // //  CartItemWidget (unchanged)
// // // ──────────────────────────────────────────────────────────────────────────
// // class CartItemWidget extends StatelessWidget {
// //   final CartProduct cartProduct;
// //   final VoidCallback onIncrement;
// //   final VoidCallback onDecrement;
// //   final VoidCallback onRemove;
// //   final ThemeData theme;
// //   final ColorScheme colorScheme;

// //   const CartItemWidget({
// //     super.key,
// //     required this.cartProduct,
// //     required this.onIncrement,
// //     required this.onDecrement,
// //     required this.onRemove,
// //     required this.theme,
// //     required this.colorScheme,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     final bool inactive = !cartProduct.isProductActive;
// //     return Opacity(
// //       opacity: inactive ? 0.6 : 1.0,
// //       child: Container(
// //         margin: const EdgeInsets.only(bottom: 12),
// //         padding: const EdgeInsets.all(12),
// //         decoration: BoxDecoration(
// //           color: theme.cardColor,
// //           borderRadius: BorderRadius.circular(12),
// //           boxShadow: [
// //             BoxShadow(
// //                 color: Colors.black.withOpacity(0.06),
// //                 spreadRadius: 1,
// //                 blurRadius: 4,
// //                 offset: const Offset(0, 2))
// //           ],
// //         ),
// //         child: Row(children: [
// //           ClipRRect(
// //             borderRadius: BorderRadius.circular(8),
// //             child: Image.network(
// //               cartProduct.image,
// //               width: 60, height: 60, fit: BoxFit.cover,
// //               loadingBuilder: (_, child, prog) => prog == null
// //                   ? child
// //                   : Container(
// //                       width: 60, height: 60,
// //                       color: colorScheme.surfaceVariant,
// //                       child: Center(
// //                           child: CircularProgressIndicator(
// //                               strokeWidth: 2, color: colorScheme.primary))),
// //               errorBuilder: (_, __, ___) => Container(
// //                   width: 60, height: 60,
// //                   color: colorScheme.surfaceVariant,
// //                   child: Icon(Icons.image,
// //                       size: 30, color: colorScheme.onSurfaceVariant)),
// //             ),
// //           ),
// //           const SizedBox(width: 12),
// //           Expanded(
// //             child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(cartProduct.name,
// //                       style: theme.textTheme.titleSmall
// //                           ?.copyWith(fontWeight: FontWeight.w600),
// //                       maxLines: 2,
// //                       overflow: TextOverflow.ellipsis),
// //                   const SizedBox(height: 4),
// //                   if (cartProduct.addOn.variation.isNotEmpty)
// //                     Text('Size: ${cartProduct.addOn.variation}',
// //                         style: theme.textTheme.bodySmall?.copyWith(
// //                             color: colorScheme.onSurface.withOpacity(0.7))),
// //                   if (cartProduct.addOn.plateitems > 0) ...[
// //                     const SizedBox(height: 2),
// //                     Text('Plates: ${cartProduct.addOn.plateitems}',
// //                         style: theme.textTheme.bodySmall?.copyWith(
// //                             color: colorScheme.onSurface.withOpacity(0.7))),
// //                   ],
// //                   const SizedBox(height: 4),
// //                   Text('₹${cartProduct.price}',
// //                       style: theme.textTheme.titleSmall?.copyWith(
// //                           fontWeight: FontWeight.bold,
// //                           color: colorScheme.primary)),
// //                   if (inactive) ...[
// //                     const SizedBox(height: 6),
// //                     Text('Unavailable — remove to continue.',
// //                         style: theme.textTheme.bodySmall?.copyWith(
// //                             color: colorScheme.error,
// //                             fontWeight: FontWeight.w600)),
// //                     Align(
// //                         alignment: Alignment.centerLeft,
// //                         child: TextButton(
// //                             onPressed: onRemove,
// //                             child: const Text('Remove'))),
// //                   ],
// //                 ]),
// //           ),
// //           Column(children: [
// //             Row(children: [
// //               _CircleBtn(
// //                   icon: Icons.remove,
// //                   color: inactive
// //                       ? colorScheme.onSurface.withOpacity(0.15)
// //                       : colorScheme.primary,
// //                   iconColor: inactive
// //                       ? colorScheme.onSurface.withOpacity(0.4)
// //                       : colorScheme.onPrimary,
// //                   onTap: inactive ? null : onDecrement),
// //               const SizedBox(width: 8),
// //               SizedBox(
// //                 width: 28,
// //                 child: Text(
// //                     cartProduct.quantity.toString().padLeft(2, '0'),
// //                     textAlign: TextAlign.center,
// //                     style: theme.textTheme.bodyMedium
// //                         ?.copyWith(fontWeight: FontWeight.w600)),
// //               ),
// //               const SizedBox(width: 8),
// //               _CircleBtn(
// //                   icon: Icons.add,
// //                   color: inactive
// //                       ? colorScheme.onSurface.withOpacity(0.15)
// //                       : colorScheme.primary,
// //                   iconColor: inactive
// //                       ? colorScheme.onSurface.withOpacity(0.4)
// //                       : colorScheme.onPrimary,
// //                   onTap: inactive ? null : onIncrement),
// //             ]),
// //             const SizedBox(height: 8),
// //             GestureDetector(
// //               onTap: onRemove,
// //               child: Container(
// //                 padding: const EdgeInsets.all(8),
// //                 decoration: BoxDecoration(
// //                     color: colorScheme.errorContainer,
// //                     shape: BoxShape.circle),
// //                 child: Icon(Icons.delete,
// //                     size: 20, color: colorScheme.onErrorContainer),
// //               ),
// //             ),
// //           ]),
// //         ]),
// //       ),
// //     );
// //   }
// // }

// // class _CircleBtn extends StatelessWidget {
// //   final IconData icon;
// //   final Color color;
// //   final Color iconColor;
// //   final VoidCallback? onTap;
// //   const _CircleBtn(
// //       {required this.icon,
// //       required this.color,
// //       required this.iconColor,
// //       this.onTap});

// //   @override
// //   Widget build(BuildContext context) => GestureDetector(
// //         onTap: onTap,
// //         child: Container(
// //           width: 32, height: 32,
// //           decoration: BoxDecoration(shape: BoxShape.circle, color: color),
// //           child: Icon(icon, size: 18, color: iconColor),
// //         ),
// //       );
// // }

// // // ──────────────────────────────────────────────────────────────────────────
// // //  RowItem (unchanged)
// // // ──────────────────────────────────────────────────────────────────────────
// // class RowItem extends StatelessWidget {
// //   final String label;
// //   final String value;
// //   final Color? valueColor;
// //   final FontWeight? fontWeight;
// //   final ThemeData theme;
// //   final ColorScheme colorScheme;
// //   const RowItem({
// //     super.key,
// //     required this.label,
// //     required this.value,
// //     this.valueColor,
// //     this.fontWeight,
// //     required this.theme,
// //     required this.colorScheme,
// //   });

// //   @override
// //   Widget build(BuildContext context) => Padding(
// //         padding: const EdgeInsets.symmetric(vertical: 4),
// //         child: Row(
// //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //           children: [
// //             Text(label,
// //                 style: theme.textTheme.bodyMedium?.copyWith(
// //                     color: colorScheme.onSurface.withOpacity(0.7),
// //                     fontWeight: fontWeight)),
// //             Text(value,
// //                 style: theme.textTheme.bodyMedium?.copyWith(
// //                     color: valueColor ?? colorScheme.onSurface,
// //                     fontWeight: fontWeight)),
// //           ],
// //         ),
// //       );
// // }

// // // ──────────────────────────────────────────────────────────────────────────
// // //  _StickySummaryCard (unchanged)
// // // ──────────────────────────────────────────────────────────────────────────
// // class _StickySummaryCard extends StatelessWidget {
// //   final Widget child;
// //   const _StickySummaryCard({required this.child});

// //   @override
// //   Widget build(BuildContext context) => Padding(
// //         padding: const EdgeInsets.only(top: 4),
// //         child: Align(alignment: Alignment.topCenter, child: child),
// //       );
// // }

















// // import 'dart:async';
// // import 'dart:convert';

// // import 'package:flutter/foundation.dart';
// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:provider/provider.dart';

// // import 'package:veegify/helper/storage_helper.dart';
// // import 'package:veegify/model/CartModel/cart_model.dart';
// // import 'package:veegify/model/user_model.dart';
// // import 'package:veegify/provider/CartProvider/cart_provider.dart';
// // import 'package:veegify/views/Booking/checkout_screen.dart';
// // import 'package:veegify/views/Booking/checkout_screen_web.dart';
// // import 'package:veegify/views/Cart/cart_summary.dart';
// // import 'package:veegify/core/app_lifecycle_service.dart';
// // import 'package:veegify/utils/responsive.dart';
// // import 'package:veegify/views/Coupons/coupon_picker_modal.dart';

// // const String _kRemoveCouponUrl = 'https://api.vegiffyy.com/api/remove-coupon';

// // // ──────────────────────────────────────────────────────────────────────────
// // class CartScreenWithController extends StatelessWidget {
// //   final ScrollController scrollController;
// //   const CartScreenWithController({super.key, required this.scrollController});

// //   @override
// //   Widget build(BuildContext context) =>
// //       CartScreen(scrollController: scrollController);
// // }

// // // ──────────────────────────────────────────────────────────────────────────
// // class CartScreen extends StatefulWidget {
// //   final ScrollController? scrollController;
// //   const CartScreen({super.key, this.scrollController});

// //   @override
// //   State<CartScreen> createState() => _CartScreenState();
// // }

// // class _CartScreenState extends State<CartScreen> {
// //   User? user;
// //   Timer? _pollingTimer;
// //   bool _vendorInactiveHandled = false;
// //   bool _productInactiveHandled = false;

// //   // ── Coupon local state ────────────────────
// //   String? _appliedCouponId;
// //   String? _appliedCouponCode;
// //   bool _isRemovingCoupon = false;
// //   bool _isLoadingCouponState = true;

// //   @override
// //   void initState() {
// //     super.initState();
// //     WidgetsBinding.instance.addPostFrameCallback((_) => _initializeCart());
// //   }

// //   @override
// //   void dispose() {
// //     _stopPolling();
// //     super.dispose();
// //   }

// //   // ── Init ──────────────────────────────────────────────────────────────────
// //   Future<void> _initializeCart() async {
// //     print("User Id printing in cart Screen: ${user?.userId}");
// //     await _loadUser();
// //     final cp = context.read<CartProvider>();
// //     await cp.loadCart(user?.userId.toString());
    
// //     // After cart loads, extract coupon info from cart provider
// //     _extractCouponFromProvider(cp);
    
// //     await _handleStatusChanges(cp);
// //     _startPolling();
// //   }

// //   // Extract coupon information from cart provider
// //   void _extractCouponFromProvider(CartProvider cp) {
// //     final newId = cp.appliedCouponId;
// //     final newCode = cp.appliedCouponCode;
    
// //     setState(() {
// //       _isLoadingCouponState = false;
// //       if (_appliedCouponId != newId || _appliedCouponCode != newCode) {
// //         _appliedCouponId = newId;
// //         _appliedCouponCode = newCode;
// //       }
// //     });
// //   }

// //   Future<void> _loadUser() async {
// //     final u = UserPreferences.getUser();
// //     if (u != null) {
// //       setState(() => user = u);
// //       context.read<CartProvider>().setUserId(u.userId.toString());
// //     }
// //   }

// //   // ── Polling ───────────────────────────────────────────────────────────────
// //   void _startPolling() {
// //     _pollingTimer?.cancel();
// //     if (user == null) return;
// //     _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
// //       if (!mounted) return;
// //       if (!AppLifecycleService.instance.isAppInForeground) return;
// //       if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;
      
// //       final cp = context.read<CartProvider>();
// //       await cp.loadCart(user?.userId.toString());
      
// //       if (mounted) {
// //         _extractCouponFromProvider(cp);
// //       }
      
// //       _handleStatusChanges(cp);
// //     });
// //   }

// //   void _stopPolling() {
// //     _pollingTimer?.cancel();
// //     _pollingTimer = null;
// //   }

// //   // ── Snackbar ──────────────────────────────────────────────────────────────
// //   void _snack(String msg, Color color) {
// //     if (!mounted) return;
// //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
// //       content: Text(msg),
// //       backgroundColor: color,
// //       behavior: SnackBarBehavior.floating,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //       duration: const Duration(seconds: 2),
// //     ));
// //   }

// //   // ── Open coupon picker ────────────────────────────────────────────────────
// //   void _openCouponPicker() {
// //     if (user == null) {
// //       _snack('Please log in to apply coupons', Colors.red);
// //       return;
// //     }
// //     showCouponPickerModal(
// //       context: context,
// //       userId: user!.userId.toString(),
// //       onCouponApplied: ({required String couponId, required String couponCode}) {
// //         setState(() {
// //           _appliedCouponId = couponId;
// //           _appliedCouponCode = couponCode;
// //         });
// //         context.read<CartProvider>().loadCart(user?.userId.toString());
// //         _snack('Coupon applied! 🎉', Colors.green);
// //       },
// //     );
// //   }

// //   // ── Remove coupon ───────────────────────────────────────────────
// //   Future<void> _removeCoupon() async {
// //     if (_appliedCouponId == null) {
// //       _snack('No coupon to remove', Colors.orange);
// //       return;
// //     }
// //     setState(() => _isRemovingCoupon = true);
// //     try {
// //       final res = await http
// //           .post(
// //             Uri.parse(_kRemoveCouponUrl),
// //             headers: {'Content-Type': 'application/json'},
// //             body: json.encode({
// //               'userId': user!.userId.toString(),
// //               'couponId': _appliedCouponId,
// //             }),
// //           )
// //           .timeout(const Duration(seconds: 12));

// //       if (!mounted) return;

// //       if (res.statusCode == 200) {
// //         setState(() {
// //           _appliedCouponId = null;
// //           _appliedCouponCode = null;
// //           _isRemovingCoupon = false;
// //         });
// //         context.read<CartProvider>().loadCart(user?.userId.toString());
// //         _snack('Coupon removed', Colors.green);
// //       } else {
// //         final msg = (json.decode(res.body) as Map<String, dynamic>)['message']
// //                 as String? ??
// //             'Failed to remove coupon';
// //         setState(() => _isRemovingCoupon = false);
// //         _snack(msg, Colors.red);
// //       }
// //     } catch (e) {
// //       if (!mounted) return;
// //       setState(() => _isRemovingCoupon = false);
// //       _snack('Error: $e', Colors.red);
// //     }
// //   }

// //   // ── Checkout ──────────────────────────────────────────────────────────────
// //   Future<void> _handleCheckout(CartProvider cp) async {
// //     if (!cp.isVendorActive) {
// //       _snack('Restaurant is closed. Cannot proceed.', Colors.red);
// //       return;
// //     }
// //     if (cp.hasInactiveProducts) {
// //       _snack('Remove unavailable items before checkout.', Colors.red);
// //       return;
// //     }
// //     if (mounted) {
// //       Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen()));
// //     }
// //   }

// //   // ── Status dialogs ────────────────────────────────────────────────────────
// //   Future<void> _handleStatusChanges(CartProvider cp) async {
// //     if (!mounted || !cp.hasItems) return;

// //     if (!cp.isVendorActive && !_vendorInactiveHandled) {
// //       _vendorInactiveHandled = true;
// //       await showDialog(
// //         context: context,
// //         barrierDismissible: false,
// //         builder: (ctx) => AlertDialog(
// //           title: const Text('Restaurant Closed'),
// //           content: const Text(
// //               'The restaurant is inactive. Your cart will be cleared.'),
// //           actions: [
// //             TextButton(
// //                 onPressed: () => Navigator.of(ctx).pop(),
// //                 child: const Text('OK')),
// //           ],
// //         ),
// //       );
// //       await cp.clearCart();
// //       if (mounted) _snack('Cart cleared — restaurant is closed.', Colors.red);
// //       return;
// //     }

// //     if (cp.hasInactiveProducts &&
// //         !_productInactiveHandled &&
// //         cp.isVendorActive) {
// //       _productInactiveHandled = true;
// //       final inactive = cp.items.where((p) => !p.isProductActive).toList();
// //       final names = inactive.map((p) => p.name).join(', ');
// //       final remove = await showDialog<bool>(
// //         context: context,
// //         barrierDismissible: false,
// //         builder: (ctx) => AlertDialog(
// //           title: const Text('Items Unavailable'),
// //           content: Text('$names\n\nRemove them and continue?'),
// //           actions: [
// //             TextButton(
// //                 onPressed: () => Navigator.of(ctx).pop(false),
// //                 child: const Text('Cancel')),
// //             TextButton(
// //                 onPressed: () => Navigator.of(ctx).pop(true),
// //                 child: const Text('Remove & Continue')),
// //           ],
// //         ),
// //       );
// //       if (remove == true) {
// //         for (final p in inactive) {
// //           await cp.removeItem(p.id, user?.userId.toString());
// //         }
// //         if (mounted) _snack('Unavailable items removed.', Colors.orange);
// //       } else {
// //         _productInactiveHandled = false;
// //       }
// //     }
// //   }

// //   // ── BUILD ──────────────────────────────────────────────────────────────────
// //   @override
// //   Widget build(BuildContext context) {
// //     final theme = Theme.of(context);
// //     final cs = theme.colorScheme;
// //     final isMobile = Responsive.isMobile(context);
// //     final width = MediaQuery.of(context).size.width;
// //     final hPad = width >= 1200 ? 40.0 : width >= 900 ? 24.0 : 16.0;
// //     final maxW = width >= 1400
// //         ? 1200.0
// //         : width >= 1100
// //             ? 1100.0
// //             : width >= 900
// //                 ? 900.0
// //                 : double.infinity;

// //     return Scaffold(
// //       backgroundColor: theme.scaffoldBackgroundColor,
// //       body: SafeArea(
// //         child: Consumer<CartProvider>(
// //           builder: (context, cp, _) {
// //             // Sync local coupon state with provider when provider changes
// //             WidgetsBinding.instance.addPostFrameCallback((_) {
// //               if (mounted) {
// //                 _extractCouponFromProvider(cp);
// //               }
// //             });

// //             // ✅ SHOW SKELETON LOADING while cart is loading
// //             if (cp.isLoading && !cp.hasItems) {
// //               return _buildSkeletonLoading(theme, cs, isMobile, hPad, maxW);
// //             }

// //             // Error state
// //             if (cp.error != null && !cp.hasItems) {
// //               return Center(
// //                 child: Column(mainAxisSize: MainAxisSize.min, children: [
// //                   Icon(Icons.error_outline, size: 64, color: cs.error),
// //                   const SizedBox(height: 16),
// //                   Text('Error: ${cp.error}',
// //                       style: theme.textTheme.bodyMedium,
// //                       textAlign: TextAlign.center),
// //                   const SizedBox(height: 16),
// //                   ElevatedButton(
// //                     onPressed: _initializeCart,
// //                     style: ElevatedButton.styleFrom(
// //                         backgroundColor: cs.primary,
// //                         foregroundColor: cs.onPrimary),
// //                     child: const Text('Retry'),
// //                   ),
// //                 ]),
// //               );
// //             }

// //             // Empty state
// //             if (!cp.hasItems) {
// //               return EmptyCartWidget(theme: theme, colorScheme: cs);
// //             }

// //             // Cart with items
// //             return RefreshIndicator(
// //               onRefresh: () => cp.loadCart(user?.userId.toString()),
// //               color: cs.primary,
// //               child: SingleChildScrollView(
// //                 controller: widget.scrollController,
// //                 physics: const AlwaysScrollableScrollPhysics(),
// //                 child: Center(
// //                   child: ConstrainedBox(
// //                     constraints: BoxConstraints(maxWidth: maxW),
// //                     child: Padding(
// //                       padding: EdgeInsets.symmetric(
// //                           horizontal: hPad, vertical: 16),
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           _buildHeader(theme, cs),
// //                           const SizedBox(height: 20),

// //                           if (!cp.isVendorActive)
// //                             _vendorBanner(theme, cs),
// //                           if (cp.hasInactiveProducts && cp.isVendorActive)
// //                             _inactiveBanner(cp, theme, cs),

// //                           const SizedBox(height: 10),

// //                           if (isMobile) ...[
// //                             _sectionCard(theme, cs,
// //                                 _buildCartList(cp, theme, cs)),
// //                             const SizedBox(height: 20),

// //                             // ── Coupon bar ──────────────
// //                             _buildCouponBar(theme, cs),
// //                             const SizedBox(height: 10),

// //                             _sectionCard(theme, cs,
// //                                 TicketPricingSummary(
// //                                     cartProvider: cp,
// //                                     theme: theme,
// //                                     colorScheme: cs)),
// //                             const SizedBox(height: 20),
// //                             _checkoutBtn(cp, theme, cs),
// //                             const SizedBox(height: 20),
// //                           ] else ...[
// //                             Row(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               children: [
// //                                 Expanded(
// //                                   flex: 3,
// //                                   child: Column(children: [
// //                                     _sectionCard(theme, cs,
// //                                         _buildCartList(cp, theme, cs)),
// //                                     const SizedBox(height: 16),

// //                                     // ── Coupon bar ──────
// //                                     _buildCouponBar(theme, cs),
// //                                   ]),
// //                                 ),
// //                                 const SizedBox(width: 24),
// //                                 Expanded(
// //                                   flex: 2,
// //                                   child: _StickySummaryCard(
// //                                     child: Column(
// //                                       crossAxisAlignment:
// //                                           CrossAxisAlignment.stretch,
// //                                       children: [
// //                                         _sectionCard(theme, cs,
// //                                             TicketPricingSummary(
// //                                                 cartProvider: cp,
// //                                                 theme: theme,
// //                                                 colorScheme: cs)),
// //                                         const SizedBox(height: 14),
// //                                         _checkoutBtn(cp, theme, cs),
// //                                       ],
// //                                     ),
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                             const SizedBox(height: 20),
// //                           ],
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             );
// //           },
// //         ),
// //       ),
// //     );
// //   }

// //   // ── SKELETON LOADING UI ──────────────────────────────────────────────────
// //   Widget _buildSkeletonLoading(ThemeData theme, ColorScheme cs, bool isMobile, double hPad, double maxW) {
// //     return SingleChildScrollView(
// //       physics: const NeverScrollableScrollPhysics(),
// //       child: Center(
// //         child: ConstrainedBox(
// //           constraints: BoxConstraints(maxWidth: maxW),
// //           child: Padding(
// //             padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 // Header skeleton
// //                 Row(children: [
// //                   Container(
// //                     width: 50,
// //                     height: 50,
// //                     decoration: BoxDecoration(
// //                       color: Colors.grey[300],
// //                       shape: BoxShape.circle,
// //                     ),
// //                   ),
// //                   const SizedBox(width: 20),
// //                   Container(
// //                     width: 120,
// //                     height: 32,
// //                     decoration: BoxDecoration(
// //                       color: Colors.grey[300],
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                   ),
// //                 ]),
// //                 const SizedBox(height: 20),

// //                 if (isMobile) ...[
// //                   // Cart items skeleton for mobile
// //                   _buildCartItemsSkeleton(theme),
// //                   const SizedBox(height: 20),

// //                   // Coupon bar skeleton
// //                   _buildCouponSkeleton(theme, cs),
// //                   const SizedBox(height: 10),

// //                   // Summary skeleton
// //                   _buildSummarySkeleton(theme, cs),
// //                   const SizedBox(height: 20),

// //                   // Checkout button skeleton
// //                   _buildCheckoutButtonSkeleton(theme, cs),
// //                 ] else ...[
// //                   // Desktop layout skeleton
// //                   Row(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Expanded(
// //                         flex: 3,
// //                         child: Column(children: [
// //                           _buildCartItemsSkeleton(theme),
// //                           const SizedBox(height: 16),
// //                           _buildCouponSkeleton(theme, cs),
// //                         ]),
// //                       ),
// //                       const SizedBox(width: 24),
// //                       Expanded(
// //                         flex: 2,
// //                         child: Column(
// //                           children: [
// //                             _buildSummarySkeleton(theme, cs),
// //                             const SizedBox(height: 14),
// //                             _buildCheckoutButtonSkeleton(theme, cs),
// //                           ],
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ],
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildCartItemsSkeleton(ThemeData theme) {
// //     return Container(
// //       padding: const EdgeInsets.all(14),
// //       decoration: BoxDecoration(
// //         color: theme.cardColor,
// //         borderRadius: BorderRadius.circular(14),
// //         border: Border.all(color: Colors.grey[300]!),
// //       ),
// //       child: Column(
// //         children: List.generate(3, (index) => Padding(
// //           padding: const EdgeInsets.only(bottom: 12),
// //           child: Row(
// //             children: [
// //               // Image skeleton
// //               Container(
// //                 width: 60,
// //                 height: 60,
// //                 decoration: BoxDecoration(
// //                   color: Colors.grey[300],
// //                   borderRadius: BorderRadius.circular(8),
// //                 ),
// //               ),
// //               const SizedBox(width: 12),
// //               // Content skeleton
// //               Expanded(
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Container(
// //                       width: 150,
// //                       height: 16,
// //                       decoration: BoxDecoration(
// //                         color: Colors.grey[300],
// //                         borderRadius: BorderRadius.circular(4),
// //                       ),
// //                     ),
// //                     const SizedBox(height: 8),
// //                     Container(
// //                       width: 100,
// //                       height: 14,
// //                       decoration: BoxDecoration(
// //                         color: Colors.grey[300],
// //                         borderRadius: BorderRadius.circular(4),
// //                       ),
// //                     ),
// //                     const SizedBox(height: 8),
// //                     Container(
// //                       width: 80,
// //                       height: 16,
// //                       decoration: BoxDecoration(
// //                         color: Colors.grey[300],
// //                         borderRadius: BorderRadius.circular(4),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               // Quantity buttons skeleton
// //               Column(
// //                 children: [
// //                   Row(
// //                     children: [
// //                       Container(
// //                         width: 32,
// //                         height: 32,
// //                         decoration: BoxDecoration(
// //                           color: Colors.grey[300],
// //                           shape: BoxShape.circle,
// //                         ),
// //                       ),
// //                       const SizedBox(width: 8),
// //                       Container(
// //                         width: 28,
// //                         height: 20,
// //                         decoration: BoxDecoration(
// //                           color: Colors.grey[300],
// //                           borderRadius: BorderRadius.circular(4),
// //                         ),
// //                       ),
// //                       const SizedBox(width: 8),
// //                       Container(
// //                         width: 32,
// //                         height: 32,
// //                         decoration: BoxDecoration(
// //                           color: Colors.grey[300],
// //                           shape: BoxShape.circle,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                   const SizedBox(height: 8),
// //                   Container(
// //                     width: 32,
// //                     height: 32,
// //                     decoration: BoxDecoration(
// //                       color: Colors.grey[300],
// //                       shape: BoxShape.circle,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         )),
// //       ),
// //     );
// //   }

// //   Widget _buildCouponSkeleton(ThemeData theme, ColorScheme cs) {
// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
// //       decoration: BoxDecoration(
// //         color: theme.cardColor,
// //         borderRadius: BorderRadius.circular(14),
// //         border: Border.all(color: Colors.grey[300]!),
// //       ),
// //       child: Row(children: [
// //         Container(
// //           width: 42,
// //           height: 42,
// //           decoration: BoxDecoration(
// //             color: Colors.grey[300],
// //             borderRadius: BorderRadius.circular(10),
// //           ),
// //         ),
// //         const SizedBox(width: 12),
// //         Expanded(
// //           child: Container(
// //             width: double.infinity,
// //             height: 20,
// //             decoration: BoxDecoration(
// //               color: Colors.grey[300],
// //               borderRadius: BorderRadius.circular(4),
// //             ),
// //           ),
// //         ),
// //         const SizedBox(width: 12),
// //         Container(
// //           width: 80,
// //           height: 36,
// //           decoration: BoxDecoration(
// //             color: Colors.grey[300],
// //             borderRadius: BorderRadius.circular(10),
// //           ),
// //         ),
// //       ]),
// //     );
// //   }

// //   Widget _buildSummarySkeleton(ThemeData theme, ColorScheme cs) {
// //     return Container(
// //       padding: const EdgeInsets.all(14),
// //       decoration: BoxDecoration(
// //         color: theme.cardColor,
// //         borderRadius: BorderRadius.circular(14),
// //         border: Border.all(color: Colors.grey[300]!),
// //       ),
// //       child: Column(
// //         children: List.generate(5, (index) => Padding(
// //           padding: const EdgeInsets.symmetric(vertical: 8),
// //           child: Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               Container(
// //                 width: 100,
// //                 height: 16,
// //                 decoration: BoxDecoration(
// //                   color: Colors.grey[300],
// //                   borderRadius: BorderRadius.circular(4),
// //                 ),
// //               ),
// //               Container(
// //                 width: 60,
// //                 height: 16,
// //                 decoration: BoxDecoration(
// //                   color: Colors.grey[300],
// //                   borderRadius: BorderRadius.circular(4),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         )),
// //       ),
// //     );
// //   }

// //   Widget _buildCheckoutButtonSkeleton(ThemeData theme, ColorScheme cs) {
// //     return Container(
// //       width: double.infinity,
// //       height: 56,
// //       decoration: BoxDecoration(
// //         color: Colors.grey[300],
// //         borderRadius: BorderRadius.circular(12),
// //       ),
// //     );
// //   }

// //   // ── Coupon bar ─────────────────────────────────────────────────────────────
// //   Widget _buildCouponBar(ThemeData theme, ColorScheme cs) {
// //     final hasCoupon = _appliedCouponId != null && _appliedCouponCode != null;

// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
// //       decoration: BoxDecoration(
// //         color: theme.cardColor,
// //         borderRadius: BorderRadius.circular(14),
// //         border: Border.all(color: cs.outline.withOpacity(0.18)),
// //         boxShadow: [
// //           BoxShadow(
// //               color: Colors.black.withOpacity(0.04),
// //               blurRadius: 8,
// //               offset: const Offset(0, 3)),
// //         ],
// //       ),
// //       child: Row(children: [
// //         Container(
// //           padding: const EdgeInsets.all(10),
// //           decoration: BoxDecoration(
// //             color: cs.primary.withOpacity(0.08),
// //             borderRadius: BorderRadius.circular(10),
// //           ),
// //           child: Icon(Icons.local_offer_outlined, color: cs.primary, size: 22),
// //         ),
// //         const SizedBox(width: 12),

// //         // Text side
// //         Expanded(
// //           child: hasCoupon
// //               ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
// //                   Text('Coupon Applied! 🎉',
// //                       style: theme.textTheme.bodyMedium?.copyWith(
// //                           fontWeight: FontWeight.w700,
// //                           color: Colors.green.shade700)),
// //                   const SizedBox(height: 2),
// //                   Text(_appliedCouponCode ?? '',
// //                       style: theme.textTheme.bodySmall?.copyWith(
// //                           color: cs.onSurface.withOpacity(0.55),
// //                           letterSpacing: 1.2,
// //                           fontWeight: FontWeight.w600)),
// //                 ])
// //               : Text('Have a coupon code?',
// //                   style: theme.textTheme.bodyMedium
// //                       ?.copyWith(fontWeight: FontWeight.w600)),
// //         ),

// //         // Action button
// //         if (hasCoupon)
// //           _isRemovingCoupon
// //               ? SizedBox(
// //                   width: 20, height: 20,
// //                   child: CircularProgressIndicator(
// //                       strokeWidth: 2, color: cs.error))
// //               : GestureDetector(
// //                   onTap: _removeCoupon,
// //                   child: Container(
// //                     padding: const EdgeInsets.symmetric(
// //                         horizontal: 12, vertical: 8),
// //                     decoration: BoxDecoration(
// //                       color: cs.errorContainer,
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                     child: Text('Remove',
// //                         style: TextStyle(
// //                             fontSize: 12, fontWeight: FontWeight.w700,
// //                             color: cs.onErrorContainer)),
// //                   ),
// //                 )
// //         else
// //           GestureDetector(
// //             onTap: _openCouponPicker,
// //             child: Container(
// //               padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
// //               decoration: BoxDecoration(
// //                 color: cs.primary,
// //                 borderRadius: BorderRadius.circular(10),
// //               ),
// //               child: Text('View Coupons',
// //                   style: TextStyle(
// //                       fontSize: 12, fontWeight: FontWeight.w700,
// //                       color: cs.onPrimary)),
// //             ),
// //           ),
// //       ]),
// //     );
// //   }

// //   // ── Helpers ───────────────────────────────────────────────────────────────
// //   Widget _buildHeader(ThemeData theme, ColorScheme cs) => Row(children: [
// //         CircleAvatar(
// //           radius: 25,
// //           backgroundColor: cs.primary.withOpacity(0.1),
// //           child: Icon(Icons.shopping_cart, color: cs.primary),
// //         ),
// //         const SizedBox(width: 20),
// //         Text('My Cart',
// //             style: theme.textTheme.titleLarge
// //                 ?.copyWith(fontWeight: FontWeight.bold)),
// //       ]);

// //   Widget _buildCartList(CartProvider cp, ThemeData theme, ColorScheme cs) =>
// //       ListView.builder(
// //         shrinkWrap: true,
// //         physics: const NeverScrollableScrollPhysics(),
// //         itemCount: cp.items.length,
// //         itemBuilder: (context, i) {
// //           final item = cp.items[i];
// //           return CartItemWidget(
// //             cartProduct: item,
// //             onIncrement: () async {
// //               try {
// //                 await cp.incrementQuantity(item.id, user?.userId.toString());
// //               } catch (e) {
// //                 _snack('Failed to update: $e', Colors.red);
// //               }
// //             },
// //             onDecrement: () async {
// //               try {
// //                 await cp.decrementQuantity(item.id, user?.userId.toString());
// //               } catch (e) {
// //                 _snack('Failed to update: $e', Colors.red);
// //               }
// //             },
// //             onRemove: () async {
// //               try {
// //                 await cp.removeItem(item.id, user?.userId.toString());
// //                 _snack('Item removed', Colors.green);
// //               } catch (e) {
// //                 _snack('Failed to remove: $e', Colors.red);
// //               }
// //             },
// //             theme: theme,
// //             colorScheme: cs,
// //           );
// //         },
// //       );

// //   Widget _checkoutBtn(CartProvider cp, ThemeData theme, ColorScheme cs) {
// //     final disabled = 
// //         !cp.hasItems ||
// //         !cp.isVendorActive ||
// //         cp.hasInactiveProducts;
// //     return SizedBox(
// //       width: double.infinity,
// //       child: ElevatedButton(
// //         onPressed: disabled ? null : () => _handleCheckout(cp),
// //         style: ElevatedButton.styleFrom(
// //           backgroundColor: cs.primary,
// //           foregroundColor: cs.onPrimary,
// //           disabledBackgroundColor: cs.onSurface.withOpacity(0.12),
// //           disabledForegroundColor: cs.onSurface.withOpacity(0.38),
// //           padding: const EdgeInsets.symmetric(vertical: 16),
// //           shape:
// //               RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //         ),
// //         child: Text('Checkout',
// //             style: theme.textTheme.titleMedium
// //                 ?.copyWith(color: cs.onPrimary, fontWeight: FontWeight.bold)),
// //       ),
// //     );
// //   }

// //   Widget _sectionCard(ThemeData theme, ColorScheme cs, Widget child) =>
// //       Container(
// //         padding: const EdgeInsets.all(14),
// //         decoration: BoxDecoration(
// //           color: theme.cardColor,
// //           borderRadius: BorderRadius.circular(14),
// //           border: Border.all(color: cs.outline.withOpacity(0.15)),
// //           boxShadow: [
// //             BoxShadow(
// //                 color: Colors.black.withOpacity(0.05),
// //                 blurRadius: 8,
// //                 offset: const Offset(0, 3))
// //           ],
// //         ),
// //         child: child,
// //       );

// //   Widget _vendorBanner(ThemeData theme, ColorScheme cs) => Container(
// //         width: double.infinity,
// //         margin: const EdgeInsets.only(bottom: 12),
// //         padding: const EdgeInsets.all(12),
// //         decoration: BoxDecoration(
// //             color: cs.errorContainer,
// //             borderRadius: BorderRadius.circular(12)),
// //         child: Row(children: [
// //           Icon(Icons.store_mall_directory, color: cs.onErrorContainer),
// //           const SizedBox(width: 8),
// //           Expanded(
// //               child: Text(
// //                   'This restaurant is currently closed.',
// //                   style: theme.textTheme.bodyMedium
// //                       ?.copyWith(color: cs.onErrorContainer))),
// //         ]),
// //       );

// //   Widget _inactiveBanner(
// //       CartProvider cp, ThemeData theme, ColorScheme cs) =>
// //       Container(
// //         width: double.infinity,
// //         margin: const EdgeInsets.only(bottom: 12),
// //         padding: const EdgeInsets.all(12),
// //         decoration: BoxDecoration(
// //             color: cs.tertiaryContainer,
// //             borderRadius: BorderRadius.circular(12)),
// //         child: Row(children: [
// //           Icon(Icons.info_outline, color: cs.onTertiaryContainer),
// //           const SizedBox(width: 8),
// //           Expanded(
// //               child: Text(
// //                   'Some items are no longer available. Please remove them.',
// //                   style: theme.textTheme.bodyMedium
// //                       ?.copyWith(color: cs.onTertiaryContainer))),
// //           TextButton(
// //               onPressed: () async => _handleStatusChanges(cp),
// //               child: const Text('FIX')),
// //         ]),
// //       );
// // }

// // // ──────────────────────────────────────────────────────────────────────────
// // //  EmptyCartWidget
// // // ──────────────────────────────────────────────────────────────────────────
// // class EmptyCartWidget extends StatelessWidget {
// //   final ThemeData theme;
// //   final ColorScheme colorScheme;
// //   const EmptyCartWidget(
// //       {super.key, required this.theme, required this.colorScheme});

// //   @override
// //   Widget build(BuildContext context) {
// //     final iconSize = Responsive.isDesktop(context) ? 140.0 : 100.0;
// //     return Center(
// //       child: Padding(
// //         padding: const EdgeInsets.all(24),
// //         child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
// //           Icon(Icons.shopping_cart_outlined,
// //               size: iconSize, color: colorScheme.onSurface.withOpacity(0.5)),
// //           const SizedBox(height: 20),
// //           Text('Your cart is empty',
// //               style: theme.textTheme.titleLarge
// //                   ?.copyWith(fontWeight: FontWeight.bold)),
// //           const SizedBox(height: 10),
// //           Text('Add some delicious items to your cart',
// //               style: theme.textTheme.bodyMedium
// //                   ?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
// //               textAlign: TextAlign.center),
// //           const SizedBox(height: 30),
// //         ]),
// //       ),
// //     );
// //   }
// // }

// // // ──────────────────────────────────────────────────────────────────────────
// // //  CartItemWidget
// // // ──────────────────────────────────────────────────────────────────────────
// // class CartItemWidget extends StatelessWidget {
// //   final CartProduct cartProduct;
// //   final VoidCallback onIncrement;
// //   final VoidCallback onDecrement;
// //   final VoidCallback onRemove;
// //   final ThemeData theme;
// //   final ColorScheme colorScheme;

// //   const CartItemWidget({
// //     super.key,
// //     required this.cartProduct,
// //     required this.onIncrement,
// //     required this.onDecrement,
// //     required this.onRemove,
// //     required this.theme,
// //     required this.colorScheme,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     final bool inactive = !cartProduct.isProductActive;
// //     return Opacity(
// //       opacity: inactive ? 0.6 : 1.0,
// //       child: Container(
// //         margin: const EdgeInsets.only(bottom: 12),
// //         padding: const EdgeInsets.all(12),
// //         decoration: BoxDecoration(
// //           color: theme.cardColor,
// //           borderRadius: BorderRadius.circular(12),
// //           boxShadow: [
// //             BoxShadow(
// //                 color: Colors.black.withOpacity(0.06),
// //                 spreadRadius: 1,
// //                 blurRadius: 4,
// //                 offset: const Offset(0, 2))
// //           ],
// //         ),
// //         child: Row(children: [
// //           ClipRRect(
// //             borderRadius: BorderRadius.circular(8),
// //             child: Image.network(
// //               cartProduct.image,
// //               width: 60, height: 60, fit: BoxFit.cover,
// //               loadingBuilder: (_, child, prog) => prog == null
// //                   ? child
// //                   : Container(
// //                       width: 60, height: 60,
// //                       color: colorScheme.surfaceVariant,
// //                       child: Center(
// //                           child: CircularProgressIndicator(
// //                               strokeWidth: 2, color: colorScheme.primary))),
// //               errorBuilder: (_, __, ___) => Container(
// //                   width: 60, height: 60,
// //                   color: colorScheme.surfaceVariant,
// //                   child: Icon(Icons.image,
// //                       size: 30, color: colorScheme.onSurfaceVariant)),
// //             ),
// //           ),
// //           const SizedBox(width: 12),
// //           Expanded(
// //             child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(cartProduct.name,
// //                       style: theme.textTheme.titleSmall
// //                           ?.copyWith(fontWeight: FontWeight.w600),
// //                       maxLines: 2,
// //                       overflow: TextOverflow.ellipsis),
// //                   const SizedBox(height: 4),
// //                   if (cartProduct.addOn.variation.isNotEmpty)
// //                     Text('Size: ${cartProduct.addOn.variation}',
// //                         style: theme.textTheme.bodySmall?.copyWith(
// //                             color: colorScheme.onSurface.withOpacity(0.7))),
// //                   if (cartProduct.addOn.plateitems > 0) ...[
// //                     const SizedBox(height: 2),
// //                     Text('Plates: ${cartProduct.addOn.plateitems}',
// //                         style: theme.textTheme.bodySmall?.copyWith(
// //                             color: colorScheme.onSurface.withOpacity(0.7))),
// //                   ],
// //                   const SizedBox(height: 4),
// //                   Text('₹${cartProduct.price}',
// //                       style: theme.textTheme.titleSmall?.copyWith(
// //                           fontWeight: FontWeight.bold,
// //                           color: colorScheme.primary)),
// //                   if (inactive) ...[
// //                     const SizedBox(height: 6),
// //                     Text('Unavailable — remove to continue.',
// //                         style: theme.textTheme.bodySmall?.copyWith(
// //                             color: colorScheme.error,
// //                             fontWeight: FontWeight.w600)),
// //                     Align(
// //                         alignment: Alignment.centerLeft,
// //                         child: TextButton(
// //                             onPressed: onRemove,
// //                             child: const Text('Remove'))),
// //                   ],
// //                 ]),
// //           ),
// //           Column(children: [
// //             Row(children: [
// //               _CircleBtn(
// //                   icon: Icons.remove,
// //                   color: inactive
// //                       ? colorScheme.onSurface.withOpacity(0.15)
// //                       : colorScheme.primary,
// //                   iconColor: inactive
// //                       ? colorScheme.onSurface.withOpacity(0.4)
// //                       : colorScheme.onPrimary,
// //                   onTap: inactive ? null : onDecrement),
// //               const SizedBox(width: 8),
// //               SizedBox(
// //                 width: 28,
// //                 child: Text(
// //                     cartProduct.quantity.toString().padLeft(2, '0'),
// //                     textAlign: TextAlign.center,
// //                     style: theme.textTheme.bodyMedium
// //                         ?.copyWith(fontWeight: FontWeight.w600)),
// //               ),
// //               const SizedBox(width: 8),
// //               _CircleBtn(
// //                   icon: Icons.add,
// //                   color: inactive
// //                       ? colorScheme.onSurface.withOpacity(0.15)
// //                       : colorScheme.primary,
// //                   iconColor: inactive
// //                       ? colorScheme.onSurface.withOpacity(0.4)
// //                       : colorScheme.onPrimary,
// //                   onTap: inactive ? null : onIncrement),
// //             ]),
// //             const SizedBox(height: 8),
// //             GestureDetector(
// //               onTap: onRemove,
// //               child: Container(
// //                 padding: const EdgeInsets.all(8),
// //                 decoration: BoxDecoration(
// //                     color: colorScheme.errorContainer,
// //                     shape: BoxShape.circle),
// //                 child: Icon(Icons.delete,
// //                     size: 20, color: colorScheme.onErrorContainer),
// //               ),
// //             ),
// //           ]),
// //         ]),
// //       ),
// //     );
// //   }
// // }

// // class _CircleBtn extends StatelessWidget {
// //   final IconData icon;
// //   final Color color;
// //   final Color iconColor;
// //   final VoidCallback? onTap;
// //   const _CircleBtn(
// //       {required this.icon,
// //       required this.color,
// //       required this.iconColor,
// //       this.onTap});

// //   @override
// //   Widget build(BuildContext context) => GestureDetector(
// //         onTap: onTap,
// //         child: Container(
// //           width: 32, height: 32,
// //           decoration: BoxDecoration(shape: BoxShape.circle, color: color),
// //           child: Icon(icon, size: 18, color: iconColor),
// //         ),
// //       );
// // }

// // // ──────────────────────────────────────────────────────────────────────────
// // //  RowItem
// // // ──────────────────────────────────────────────────────────────────────────
// // class RowItem extends StatelessWidget {
// //   final String label;
// //   final String value;
// //   final Color? valueColor;
// //   final FontWeight? fontWeight;
// //   final ThemeData theme;
// //   final ColorScheme colorScheme;
// //   const RowItem({
// //     super.key,
// //     required this.label,
// //     required this.value,
// //     this.valueColor,
// //     this.fontWeight,
// //     required this.theme,
// //     required this.colorScheme,
// //   });

// //   @override
// //   Widget build(BuildContext context) => Padding(
// //         padding: const EdgeInsets.symmetric(vertical: 4),
// //         child: Row(
// //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //           children: [
// //             Text(label,
// //                 style: theme.textTheme.bodyMedium?.copyWith(
// //                     color: colorScheme.onSurface.withOpacity(0.7),
// //                     fontWeight: fontWeight)),
// //             Text(value,
// //                 style: theme.textTheme.bodyMedium?.copyWith(
// //                     color: valueColor ?? colorScheme.onSurface,
// //                     fontWeight: fontWeight)),
// //           ],
// //         ),
// //       );
// // }

// // // ──────────────────────────────────────────────────────────────────────────
// // //  _StickySummaryCard
// // // ──────────────────────────────────────────────────────────────────────────
// // class _StickySummaryCard extends StatelessWidget {
// //   final Widget child;
// //   const _StickySummaryCard({required this.child});

// //   @override
// //   Widget build(BuildContext context) => Padding(
// //         padding: const EdgeInsets.only(top: 4),
// //         child: Align(alignment: Alignment.topCenter, child: child),
// //       );
// // }



















// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:provider/provider.dart';

// import 'package:veegify/helper/storage_helper.dart';
// import 'package:veegify/model/CartModel/cart_model.dart';
// import 'package:veegify/model/user_model.dart';
// import 'package:veegify/provider/CartProvider/cart_provider.dart';
// import 'package:veegify/views/Booking/checkout_screen.dart';
// import 'package:veegify/views/Booking/checkout_screen_web.dart';
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

// class _CartScreenState extends State<CartScreen> with AutomaticKeepAliveClientMixin {
//   User? user;
//   Timer? _pollingTimer;
//   bool _vendorInactiveHandled = false;
//   bool _productInactiveHandled = false;

//   // Track whether we've done the first load ever
//   bool _hasInitialized = false;

//   // ── Coupon local state ────────────────────
//   String? _appliedCouponId;
//   String? _appliedCouponCode;
//   bool _isRemovingCoupon = false;

//   // Keep the widget alive across tab switches so data is never lost
//   @override
//   bool get wantKeepAlive => true;

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

//   // ── Init ─────────────────────────────────────────────────────────────────
//   // Called once on first build. On subsequent tab visits the widget is kept
//   // alive (wantKeepAlive = true) so this is NOT re-called — no more flicker.
//   Future<void> _initializeCart() async {
//     if (_hasInitialized) return; // guard against double-init
//     _hasInitialized = true;

//     await _loadUser();

//     final cp = context.read<CartProvider>();

//     // Only show a full load if the provider has no data yet.
//     // If provider already has items (e.g. loaded from navbar), we just sync
//     // coupon state and skip the skeleton.
//     if (!cp.hasItems) {
//       await cp.loadCart(user?.userId.toString());
//     }

//     _syncCouponFromProvider(cp);
//     await _handleStatusChanges(cp);
//     _startPolling();
//   }

//   // Sync local coupon vars from provider (no setState if nothing changed)
//   void _syncCouponFromProvider(CartProvider cp) {
//     final newId = cp.appliedCouponId;
//     final newCode = cp.appliedCouponCode;
//     if (_appliedCouponId != newId || _appliedCouponCode != newCode) {
//       if (mounted) {
//         setState(() {
//           _appliedCouponId = newId;
//           _appliedCouponCode = newCode;
//         });
//       }
//     }
//   }

//   Future<void> _loadUser() async {
//     final u = UserPreferences.getUser();
//     if (u != null && mounted) {
//       setState(() => user = u);
//       print("jljhsdkjsldhldsddjfdsfhsdfdsflhdsfsd${user?.userId.toString()}");
//       context.read<CartProvider>().setUserId(u.userId.toString());
//     }
//   }

//   // ── Polling ───────────────────────────────────────────────────────────────
//   void _startPolling() {
//     _pollingTimer?.cancel();
//     if (user == null) return;
//     _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
//       if (!mounted) return;
//       if (!AppLifecycleService.instance.isAppInForeground) return;
//       if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;

//       final cp = context.read<CartProvider>();
//       await cp.loadCart(user?.userId.toString());

//       if (mounted) _syncCouponFromProvider(cp);
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
//   void _openCouponPicker() {
//     if (user == null) {
//       _snack('Please log in to apply coupons', Colors.red);
//       return;
//     }
//     showCouponPickerModal(
//       context: context,
//       userId: user!.userId.toString(),
//       onCouponApplied: ({required String couponId, required String couponCode}) {
//         setState(() {
//           _appliedCouponId = couponId;
//           _appliedCouponCode = couponCode;
//         });
//         context.read<CartProvider>().loadCart(user?.userId.toString());
//         _snack('Coupon applied! 🎉', Colors.green);
//       },
//     );
//   }

//   // ── Remove coupon ─────────────────────────────────────────────────────────
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
//       Navigator.push(
//           context, MaterialPageRoute(builder: (_) => const CheckoutScreen()));
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

//   // ── BUILD ─────────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     super.build(context); // required by AutomaticKeepAliveClientMixin

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
//             // Keep local coupon in sync whenever provider changes
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               if (mounted) _syncCouponFromProvider(cp);
//             });

//             // ── LOADING STATE ──────────────────────────────────────────────
//             // Only show skeleton when:
//             //   • provider is actively loading AND
//             //   • there is no existing data to display
//             // This prevents the flicker on tab switch because cp.hasItems
//             // stays true while a background refresh runs.
//             if (cp.isLoading && !cp.hasItems) {
//               return _buildSkeletonLoading(theme, cs, isMobile, hPad, maxW);
//             }

//             // ── ERROR STATE ────────────────────────────────────────────────
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
//                     onPressed: () {
//                       _hasInitialized = false; // allow retry
//                       _initializeCart();
//                     },
//                     style: ElevatedButton.styleFrom(
//                         backgroundColor: cs.primary,
//                         foregroundColor: cs.onPrimary),
//                     child: const Text('Retry'),
//                   ),
//                 ]),
//               );
//             }

//             // ── EMPTY STATE ────────────────────────────────────────────────
//             if (!cp.hasItems) {
//               return EmptyCartWidget(theme: theme, colorScheme: cs);
//             }

//             // ── CART WITH ITEMS ────────────────────────────────────────────
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

//                           if (!cp.isVendorActive) _vendorBanner(theme, cs),
//                           if (cp.hasInactiveProducts && cp.isVendorActive)
//                             _inactiveBanner(cp, theme, cs),

//                           const SizedBox(height: 10),

//                           if (isMobile) ...[
//                             _sectionCard(
//                                 theme, cs, _buildCartList(cp, theme, cs)),
//                             const SizedBox(height: 20),
//                             _buildCouponBar(theme, cs),
//                             const SizedBox(height: 10),
//                             _sectionCard(
//                                 theme,
//                                 cs,
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
//                                         _sectionCard(
//                                             theme,
//                                             cs,
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

//   // ── SKELETON LOADING UI ───────────────────────────────────────────────────
//   Widget _buildSkeletonLoading(ThemeData theme, ColorScheme cs, bool isMobile,
//       double hPad, double maxW) {
//     return SingleChildScrollView(
//       physics: const NeverScrollableScrollPhysics(),
//       child: Center(
//         child: ConstrainedBox(
//           constraints: BoxConstraints(maxWidth: maxW),
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header skeleton
//                 Row(children: [
//                   Container(
//                     width: 50,
//                     height: 50,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[300],
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                   const SizedBox(width: 20),
//                   Container(
//                     width: 120,
//                     height: 32,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[300],
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                 ]),
//                 const SizedBox(height: 20),
//                 if (isMobile) ...[
//                   _buildCartItemsSkeleton(theme),
//                   const SizedBox(height: 20),
//                   _buildCouponSkeleton(theme, cs),
//                   const SizedBox(height: 10),
//                   _buildSummarySkeleton(theme, cs),
//                   const SizedBox(height: 20),
//                   _buildCheckoutButtonSkeleton(theme, cs),
//                 ] else ...[
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(
//                         flex: 3,
//                         child: Column(children: [
//                           _buildCartItemsSkeleton(theme),
//                           const SizedBox(height: 16),
//                           _buildCouponSkeleton(theme, cs),
//                         ]),
//                       ),
//                       const SizedBox(width: 24),
//                       Expanded(
//                         flex: 2,
//                         child: Column(children: [
//                           _buildSummarySkeleton(theme, cs),
//                           const SizedBox(height: 14),
//                           _buildCheckoutButtonSkeleton(theme, cs),
//                         ]),
//                       ),
//                     ],
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCartItemsSkeleton(ThemeData theme) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: theme.cardColor,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: Colors.grey[300]!),
//       ),
//       child: Column(
//         children: List.generate(
//           3,
//           (index) => Padding(
//             padding: const EdgeInsets.only(bottom: 12),
//             child: Row(children: [
//               Container(
//                 width: 60,
//                 height: 60,
//                 decoration: BoxDecoration(
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.circular(8)),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _shimmerBox(150, 16),
//                       const SizedBox(height: 8),
//                       _shimmerBox(100, 14),
//                       const SizedBox(height: 8),
//                       _shimmerBox(80, 16),
//                     ]),
//               ),
//               Column(children: [
//                 Row(children: [
//                   _shimmerCircle(32),
//                   const SizedBox(width: 8),
//                   _shimmerBox(28, 20),
//                   const SizedBox(width: 8),
//                   _shimmerCircle(32),
//                 ]),
//                 const SizedBox(height: 8),
//                 _shimmerCircle(32),
//               ]),
//             ]),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCouponSkeleton(ThemeData theme, ColorScheme cs) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       decoration: BoxDecoration(
//         color: theme.cardColor,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: Colors.grey[300]!),
//       ),
//       child: Row(children: [
//         _shimmerBox(42, 42, radius: 10),
//         const SizedBox(width: 12),
//         Expanded(child: _shimmerBox(double.infinity, 20)),
//         const SizedBox(width: 12),
//         _shimmerBox(80, 36, radius: 10),
//       ]),
//     );
//   }

//   Widget _buildSummarySkeleton(ThemeData theme, ColorScheme cs) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: theme.cardColor,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: Colors.grey[300]!),
//       ),
//       child: Column(
//         children: List.generate(
//           5,
//           (index) => Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   _shimmerBox(100, 16),
//                   _shimmerBox(60, 16),
//                 ]),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCheckoutButtonSkeleton(ThemeData theme, ColorScheme cs) {
//     return _shimmerBox(double.infinity, 56, radius: 12);
//   }

//   // Small helpers to reduce repetition in skeletons
//   Widget _shimmerBox(double w, double h, {double radius = 4}) => Container(
//         width: w,
//         height: h,
//         decoration: BoxDecoration(
//             color: Colors.grey[300],
//             borderRadius: BorderRadius.circular(radius)),
//       );

//   Widget _shimmerCircle(double size) => Container(
//         width: size,
//         height: size,
//         decoration:
//             BoxDecoration(color: Colors.grey[300], shape: BoxShape.circle),
//       );

//   // ── Coupon bar ────────────────────────────────────────────────────────────
//   Widget _buildCouponBar(ThemeData theme, ColorScheme cs) {
//     final hasCoupon = _appliedCouponId != null && _appliedCouponCode != null;

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
//           child:
//               Icon(Icons.local_offer_outlined, color: cs.primary, size: 22),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: hasCoupon
//               ? Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('Coupon Applied! 🎉',
//                         style: theme.textTheme.bodyMedium?.copyWith(
//                             fontWeight: FontWeight.w700,
//                             color: Colors.green.shade700)),
//                     const SizedBox(height: 2),
//                     Text(_appliedCouponCode ?? '',
//                         style: theme.textTheme.bodySmall?.copyWith(
//                             color: cs.onSurface.withOpacity(0.55),
//                             letterSpacing: 1.2,
//                             fontWeight: FontWeight.w600)),
//                   ],
//                 )
//               : Text('Have a coupon code?',
//                   style: theme.textTheme.bodyMedium
//                       ?.copyWith(fontWeight: FontWeight.w600)),
//         ),
//         if (hasCoupon)
//           _isRemovingCoupon
//               ? SizedBox(
//                   width: 20,
//                   height: 20,
//                   child: CircularProgressIndicator(
//                       strokeWidth: 2, color: cs.error))
//               : GestureDetector(
//                   onTap: _removeCoupon,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 12, vertical: 8),
//                     decoration: BoxDecoration(
//                       color: cs.errorContainer,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text('Remove',
//                         style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.w700,
//                             color: cs.onErrorContainer)),
//                   ),
//                 )
//         else
//           GestureDetector(
//             onTap: _openCouponPicker,
//             child: Container(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
//               decoration: BoxDecoration(
//                 color: cs.primary,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Text('View Coupons',
//                   style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w700,
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
//     final disabled =
//         !cp.hasItems || !cp.isVendorActive || cp.hasInactiveProducts;
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
//             style: theme.textTheme.titleMedium?.copyWith(
//                 color: cs.onPrimary, fontWeight: FontWeight.bold)),
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
//               child: Text('This restaurant is currently closed.',
//                   style: theme.textTheme.bodyMedium
//                       ?.copyWith(color: cs.onErrorContainer))),
//         ]),
//       );

//   Widget _inactiveBanner(
//           CartProvider cp, ThemeData theme, ColorScheme cs) =>
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
//         child:
//             Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//           Icon(Icons.shopping_cart_outlined,
//               size: iconSize,
//               color: colorScheme.onSurface.withOpacity(0.5)),
//           const SizedBox(height: 20),
//           Text('Your cart is empty',
//               style: theme.textTheme.titleLarge
//                   ?.copyWith(fontWeight: FontWeight.bold)),
//           const SizedBox(height: 10),
//           Text('Add some delicious items to your cart',
//               style: theme.textTheme.bodyMedium?.copyWith(
//                   color: colorScheme.onSurface.withOpacity(0.7)),
//               textAlign: TextAlign.center),
//           const SizedBox(height: 30),
//         ]),
//       ),
//     );
//   }
// }

// // ──────────────────────────────────────────────────────────────────────────
// //  CartItemWidget
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
//               width: 60,
//               height: 60,
//               fit: BoxFit.cover,
//               loadingBuilder: (_, child, prog) => prog == null
//                   ? child
//                   : Container(
//                       width: 60,
//                       height: 60,
//                       color: colorScheme.surfaceVariant,
//                       child: Center(
//                           child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               color: colorScheme.primary))),
//               errorBuilder: (_, __, ___) => Container(
//                   width: 60,
//                   height: 60,
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
//                             color:
//                                 colorScheme.onSurface.withOpacity(0.7))),
//                   if (cartProduct.addOn.plateitems > 0) ...[
//                     const SizedBox(height: 2),
//                     Text('Plates: ${cartProduct.addOn.plateitems}',
//                         style: theme.textTheme.bodySmall?.copyWith(
//                             color:
//                                 colorScheme.onSurface.withOpacity(0.7))),
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
//           width: 32,
//           height: 32,
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

























// lib/views/Cart/cart_screen.dart

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:veegify/helper/storage_helper.dart';
import 'package:veegify/model/CartModel/cart_model.dart';
import 'package:veegify/model/user_model.dart';
import 'package:veegify/provider/CartProvider/cart_provider.dart';
import 'package:veegify/views/Booking/checkout_screen.dart';
import 'package:veegify/views/Booking/checkout_screen_web.dart';
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

class _CartScreenState extends State<CartScreen> with AutomaticKeepAliveClientMixin {
  User? user;
  Timer? _pollingTimer;
  bool _vendorInactiveHandled = false;
  bool _productInactiveHandled = false;

  // Track whether we've done the first load ever
  bool _hasInitialized = false;

  // Store previous cart state to detect changes
  CartModel? _previousCart;

  // ── Coupon local state ────────────────────
  String? _appliedCouponId;
  String? _appliedCouponCode;
  bool _isRemovingCoupon = false;

  // Keep the widget alive across tab switches so data is never lost
  @override
  bool get wantKeepAlive => true;

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

  // ── Init ─────────────────────────────────────────────────────────────────
  // Called once on first build. On subsequent tab visits the widget is kept
  // alive (wantKeepAlive = true) so this is NOT re-called — no more flicker.
  Future<void> _initializeCart() async {
    if (_hasInitialized) return; // guard against double-init
    _hasInitialized = true;

    await _loadUser();

    final cp = context.read<CartProvider>();

    // Only show a full load if the provider has no data yet.
    // If provider already has items (e.g. loaded from navbar), we just sync
    // coupon state and skip the skeleton.
    if (!cp.hasItems) {
      await cp.loadCart(user?.userId.toString());
    }

    // Store initial cart state
    _previousCart = cp.cart;
    
    _syncCouponFromProvider(cp);
    await _handleStatusChanges(cp);
    _startPolling();
  }

  // Sync local coupon vars from provider (no setState if nothing changed)
  void _syncCouponFromProvider(CartProvider cp) {
    final newId = cp.appliedCouponId;
    final newCode = cp.appliedCouponCode;
    if (_appliedCouponId != newId || _appliedCouponCode != newCode) {
      if (mounted) {
        setState(() {
          _appliedCouponId = newId;
          _appliedCouponCode = newCode;
        });
      }
    }
  }

  Future<void> _loadUser() async {
    final u = UserPreferences.getUser();
    if (u != null && mounted) {
      setState(() => user = u);
      debugPrint("User loaded: ${user?.userId.toString()}");
      context.read<CartProvider>().setUserId(u.userId.toString());
    }
  }

  // ── Polling with Silent Updates ───────────────────────────────────────────
  void _startPolling() {
    _pollingTimer?.cancel();
    if (user == null) return;
    
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (!mounted) return;
      
      // Don't poll if app is in background
      if (!AppLifecycleService.instance.isAppInForeground) return;
      
      // Don't poll if this screen isn't visible
      if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;

      final cp = context.read<CartProvider>();
      
      // Store current cart before refresh
      final beforeCart = cp.cart;
      
      // SILENT REFRESH - this will NOT show loading indicators
      await cp.loadCart(user?.userId.toString());
      
      if (!mounted) return;
      
      // After refresh, check if cart changed
      final afterCart = cp.cart;
      
      // Update local coupon state silently
      _syncCouponFromProvider(cp);
      
      // Handle status changes if needed (vendor inactive, inactive products)
      if (_shouldHandleStatusChanges(beforeCart, afterCart)) {
        await _handleStatusChanges(cp);
      }
      
      // If cart changed and we have items, we might want to show a subtle
      // indication that something updated, but NOT a full UI flicker
      if (_previousCart != afterCart && cp.hasItems) {
        _previousCart = afterCart;
        // Optional: Show a very subtle "Updated" message that fades quickly
        // Uncomment if you want this:
        // _showSubtleUpdateIndicator();
      }
    });
  }

  // Helper to determine if we need to handle status changes
  bool _shouldHandleStatusChanges(CartModel? before, CartModel? after) {
    if (before == null && after == null) return false;
    if (before == null || after == null) return true;
    
    // Check vendor status change
    final beforeVendorActive = before.products.every((p) => p.isVendorActive);
    final afterVendorActive = after.products.every((p) => p.isVendorActive);
    
    if (beforeVendorActive != afterVendorActive) return true;
    
    // Check inactive products change
    final beforeHasInactive = before.products.any((p) => !p.isProductActive);
    final afterHasInactive = after.products.any((p) => !p.isProductActive);
    
    return beforeHasInactive != afterHasInactive;
  }

  // Optional subtle update indicator (uncomment if you want it)
  // void _showSubtleUpdateIndicator() {
  //   if (!mounted) return;
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: const Text('Cart updated'),
  //       backgroundColor: Colors.green.withOpacity(0.7),
  //       behavior: SnackBarBehavior.floating,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //       duration: const Duration(milliseconds: 800),
  //       margin: const EdgeInsets.all(16),
  //     ),
  //   );
  // }

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
        context.read<CartProvider>().loadCart(user?.userId.toString());
        _snack('Coupon applied! 🎉', Colors.green);
      },
    );
  }

  // ── Remove coupon ─────────────────────────────────────────────────────────
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
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const CheckoutScreen()));
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

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    super.build(context); // required by AutomaticKeepAliveClientMixin

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
            // Keep local coupon in sync whenever provider changes
            // Use a microtask to avoid setState during build
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _syncCouponFromProvider(cp);
            });

            // ── LOADING STATE (FIRST LOAD ONLY) ─────────────────────────────
            // Only show skeleton when:
            //   • provider is actively loading AND
            //   • there is no existing data to display
            // This prevents the flicker on tab switch because cp.hasItems
            // stays true while a background refresh runs.
            // if (cp.isLoading && !cp.hasItems) {
            //   return _buildSkeletonLoading(theme, cs, isMobile, hPad, maxW);
            // }

            // ── ERROR STATE ────────────────────────────────────────────────
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
                    onPressed: () {
                      _hasInitialized = false; // allow retry
                      _initializeCart();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary),
                    child: const Text('Retry'),
                  ),
                ]),
              );
            }

            // ── EMPTY STATE ────────────────────────────────────────────────
            if (!cp.hasItems) {
              return EmptyCartWidget(theme: theme, colorScheme: cs);
            }

            // ── CART WITH ITEMS ────────────────────────────────────────────
            // Show a subtle indicator if refreshing in background (optional)
            final showRefreshIndicator = cp.isRefreshing;
            
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
                          // Optional subtle refresh indicator
                          if (showRefreshIndicator)
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 12),
                              decoration: BoxDecoration(
                                color: cs.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: cs.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Updating...',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: cs.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          
                          _buildHeader(theme, cs),
                          const SizedBox(height: 20),

                          if (!cp.isVendorActive) _vendorBanner(theme, cs),
                          if (cp.hasInactiveProducts && cp.isVendorActive)
                            _inactiveBanner(cp, theme, cs),

                          const SizedBox(height: 10),

                          if (isMobile) ...[
                            _sectionCard(
                                theme, cs, _buildCartList(cp, theme, cs)),
                            const SizedBox(height: 20),
                            _buildCouponBar(theme, cs),
                            const SizedBox(height: 10),
                            _sectionCard(
                                theme,
                                cs,
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
                                        _sectionCard(
                                            theme,
                                            cs,
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

  // ── SKELETON LOADING UI ───────────────────────────────────────────────────
  Widget _buildSkeletonLoading(ThemeData theme, ColorScheme cs, bool isMobile,
      double hPad, double maxW) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header skeleton
                Row(children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Container(
                    width: 120,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ]),
                const SizedBox(height: 20),
                if (isMobile) ...[
                  _buildCartItemsSkeleton(theme),
                  const SizedBox(height: 20),
                  _buildCouponSkeleton(theme, cs),
                  const SizedBox(height: 10),
                  _buildSummarySkeleton(theme, cs),
                  const SizedBox(height: 20),
                  _buildCheckoutButtonSkeleton(theme, cs),
                ] else ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(children: [
                          _buildCartItemsSkeleton(theme),
                          const SizedBox(height: 16),
                          _buildCouponSkeleton(theme, cs),
                        ]),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 2,
                        child: Column(children: [
                          _buildSummarySkeleton(theme, cs),
                          const SizedBox(height: 14),
                          _buildCheckoutButtonSkeleton(theme, cs),
                        ]),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCartItemsSkeleton(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _shimmerBox(150, 16),
                      const SizedBox(height: 8),
                      _shimmerBox(100, 14),
                      const SizedBox(height: 8),
                      _shimmerBox(80, 16),
                    ]),
              ),
              Column(children: [
                Row(children: [
                  _shimmerCircle(32),
                  const SizedBox(width: 8),
                  _shimmerBox(28, 20),
                  const SizedBox(width: 8),
                  _shimmerCircle(32),
                ]),
                const SizedBox(height: 8),
                _shimmerCircle(32),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildCouponSkeleton(ThemeData theme, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(children: [
        _shimmerBox(42, 42, radius: 10),
        const SizedBox(width: 12),
        Expanded(child: _shimmerBox(double.infinity, 20)),
        const SizedBox(width: 12),
        _shimmerBox(80, 36, radius: 10),
      ]),
    );
  }

  Widget _buildSummarySkeleton(ThemeData theme, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: List.generate(
          5,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _shimmerBox(100, 16),
                  _shimmerBox(60, 16),
                ]),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckoutButtonSkeleton(ThemeData theme, ColorScheme cs) {
    return _shimmerBox(double.infinity, 56, radius: 12);
  }

  // Small helpers to reduce repetition in skeletons
  Widget _shimmerBox(double w, double h, {double radius = 4}) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(radius)),
      );

  Widget _shimmerCircle(double size) => Container(
        width: size,
        height: size,
        decoration:
            BoxDecoration(color: Colors.grey[300], shape: BoxShape.circle),
      );

  // ── Coupon bar ────────────────────────────────────────────────────────────
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
          child:
              Icon(Icons.local_offer_outlined, color: cs.primary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: hasCoupon
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                  ],
                )
              : Text('Have a coupon code?',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
        ),
        if (hasCoupon)
          _isRemovingCoupon
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: cs.error))
              : GestureDetector(
                  onTap: _removeCoupon,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: cs.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Remove',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: cs.onErrorContainer)),
                  ),
                )
        else
          GestureDetector(
            onTap: _openCouponPicker,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('View Coupons',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
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
        !cp.hasItems || !cp.isVendorActive || cp.hasInactiveProducts;
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
            style: theme.textTheme.titleMedium?.copyWith(
                color: cs.onPrimary, fontWeight: FontWeight.bold)),
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
              child: Text('This restaurant is currently closed.',
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
//  EmptyCartWidget
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
        child:
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.shopping_cart_outlined,
              size: iconSize,
              color: colorScheme.onSurface.withOpacity(0.5)),
          const SizedBox(height: 20),
          Text('Your cart is empty',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('Add some delicious items to your cart',
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7)),
              textAlign: TextAlign.center),
          const SizedBox(height: 30),
        ]),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
//  CartItemWidget
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
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, prog) => prog == null
                  ? child
                  : Container(
                      width: 60,
                      height: 60,
                      color: colorScheme.surfaceVariant,
                      child: Center(
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.primary))),
              errorBuilder: (_, __, ___) => Container(
                  width: 60,
                  height: 60,
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
                            color:
                                colorScheme.onSurface.withOpacity(0.7))),
                  if (cartProduct.addOn.plateitems > 0) ...[
                    const SizedBox(height: 2),
                    Text('Plates: ${cartProduct.addOn.plateitems}',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                colorScheme.onSurface.withOpacity(0.7))),
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
          width: 32,
          height: 32,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          child: Icon(icon, size: 18, color: iconColor),
        ),
      );
}

// ──────────────────────────────────────────────────────────────────────────
//  RowItem
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
//  _StickySummaryCard
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