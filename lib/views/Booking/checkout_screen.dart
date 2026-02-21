// // checkout_screen.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:veegify/helper/storage_helper.dart';
// import 'package:veegify/model/user_model.dart';
// import 'package:veegify/provider/CartProvider/cart_provider.dart';
// import 'package:veegify/model/address_model.dart';
// import 'package:veegify/model/CartModel/cart_model.dart';
// import 'package:veegify/provider/address_provider.dart';
// import 'package:veegify/services/order_service.dart';
// import 'package:veegify/views/PaymentSuccess/payment_success_screen.dart';
// import 'package:veegify/views/address/address_list.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';

// class CheckoutScreen extends StatefulWidget {
//   const CheckoutScreen({super.key});

//   @override
//   State<CheckoutScreen> createState() => _CheckoutScreenState();
// }

// class _CheckoutScreenState extends State<CheckoutScreen> {
//   String? _selectedAddressId;
//   String? _selectedPaymentMethod;
//   bool _isProcessingOrder = false;
//   User? user;
//   late Razorpay _razorpay;

//   @override
//   void initState() {
//     super.initState();
//     _initializeRazorpay();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadUserId();
//       _loadAddresses();
//       _loadCart();
//     });
//   }

//   @override
//   void dispose() {
//     _razorpay.clear();
//     super.dispose();
//   }

//   void _initializeRazorpay() {
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//   }

//   Future<void> _loadUserId() async {
//     final userData = UserPreferences.getUser();
//     if (userData != null) {
//       setState(() {
//         user = userData;
//       });
//       print("User ID: ${user?.userId.toString()}");
//     }
//   }

//   Future<void> _loadAddresses() async {
//     final addressProvider = Provider.of<AddressProvider>(
//       context,
//       listen: false,
//     );
//     await addressProvider.loadAddresses();
//   }

//   Future<void> _loadCart() async {
//     final cartProvider = Provider.of<CartProvider>(context, listen: false);
//     await cartProvider.loadCart(user?.userId.toString());
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

//   bool get _canPlaceOrder {
//     final cartProvider = Provider.of<CartProvider>(context, listen: false);
//     return _selectedAddressId != null &&
//         _selectedPaymentMethod != null &&
//         !_isProcessingOrder &&
//         cartProvider.hasItems;
//   }

//   // Razorpay Payment Handlers
//   void _handlePaymentSuccess(PaymentSuccessResponse response) async {
//     print("Payment Success: ${response.paymentId}");

//     // Payment successful, now create the order with transaction ID
//     await _createOrder(transactionId: response.paymentId);
//   }

//   void _handlePaymentError(PaymentFailureResponse response) {
//     setState(() => _isProcessingOrder = false);

//     _showSnackBar(
//       'Payment Failed: ${"User Close the Payment" ?? "Unknown error"}',
//       Colors.red,
//     );

//     print(
//       "Payment Error: Code: ${response.code}, Message: ${response.message}",
//     );
//   }

//   void _handleExternalWallet(ExternalWalletResponse response) {
//     _showSnackBar(
//       'External Wallet Selected: ${response.walletName}',
//       Colors.blue,
//     );
//   }

//   Future<void> _placeOrder() async {
//     if (!_canPlaceOrder) return;

//     setState(() => _isProcessingOrder = true);

//     try {
//       final cartProvider = Provider.of<CartProvider>(context, listen: false);

//       // Check if payment method is Online
//       if (_selectedPaymentMethod == 'Online') {
//         // Initiate Razorpay payment
//         _initiateRazorpayPayment();
//       } else {
//         // For COD, directly create order without payment
//         await _createOrder(transactionId: null);
//       }
//     } catch (e) {
//       setState(() => _isProcessingOrder = false);
//       _showSnackBar('Error placing order: $e', Colors.red);
//     }
//   }

//   void _initiateRazorpayPayment() {
//     final cartProvider = Provider.of<CartProvider>(context, listen: false);

//     var options = {
//       'key': 'rzp_test_RgqXPvDLbgEIVv', // Replace with your Razorpay key
//       'amount': (cartProvider.totalPayable * 100).toInt(), // Amount in paise
//       'name': 'Vegiffy',
//       'description': 'Order Payment',
//       'retry': {'enabled': true, 'max_count': 1},
//       'send_sms_hash': true,
//       'prefill': {'contact': "6282714883" ?? '', 'email': user?.email ?? ''},
//       'external': {
//         'wallets': ['paytm', 'phonepe', 'gpay'],
//       },
//     };

//     try {
//       _razorpay.open(options);
//     } catch (e) {
//       setState(() => _isProcessingOrder = false);
//       _showSnackBar('Error opening Razorpay: $e', Colors.red);
//     }
//   }

//   Future<void> _createOrder({String? transactionId}) async {
//     try {
//       final cartProvider = Provider.of<CartProvider>(context, listen: false);

//       // Get cart items for order
//       final cartItems = cartProvider.items;

//       print('=== ORDER DETAILS ===');
//       print('Total Items: ${cartProvider.totalItems}');
//       print('Subtotal: ${cartProvider.subtotal}');
//       print('Delivery Charge: ${cartProvider.deliveryCharge}');
//       print('Coupon Discount: ${cartProvider.couponDiscount}');
//       print('Total Payable: ${cartProvider.totalPayable}');
//       print('Selected Address ID: $_selectedAddressId');
//       print('Payment Method: $_selectedPaymentMethod');
//       print('Transaction ID: $transactionId');
//       print('Cart Items:');
//       for (var item in cartItems) {
//         print(
//           '  - ${item.name} (Qty: ${item.quantity}, Price: ${item.totalPrice})',
//         );
//       }

//       // Create order payload
//       final orderData = {
//         "userId": "${user?.userId.toString()}",
//         "paymentMethod": _selectedPaymentMethod,
//         "addressId": _selectedAddressId,
//         "transactionId":
//             transactionId, // Include transaction ID for online payment
//         "items": cartItems
//             .map(
//               (item) => {
//                 "productId": item.id,
//                 "name": item.name,
//                 "quantity": item.quantity,
//                 "price": item.basePrice,
//                 "totalPrice": item.totalPrice,
//                 "variation": item.addOn.variation,
//                 "plateItems": item.addOn.plateitems,
//               },
//             )
//             .toList(),
//         "subtotal": cartProvider.subtotal,
//         "deliveryCharge": cartProvider.deliveryCharge,
//         "couponDiscount": cartProvider.couponDiscount,
//         "totalAmount": cartProvider.totalPayable,
//       };

//       // Call order service
//       final result = await OrderService.createOrder(orderData);

//       if (result['success']) {
//         final orderId = result['data']['data']['_id'];
//         // Clear cart after successful order
//         await cartProvider.clearCart();

//         if (mounted) {
//           setState(() => _isProcessingOrder = false);
//           _showSnackBar('Order placed successfully!', Colors.green);

//           // Navigate to payment success screen
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => PaymentSuccessScreen(
//                 userId: user?.userId.toString(),
//                 orderId: orderId.toString(),
//               ),
//             ),
//           );
//         }
//       } else {
//         if (mounted) {
//           setState(() => _isProcessingOrder = false);
//           _showSnackBar(
//             result['message'] ?? 'Failed to place order',
//             Colors.red,
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => _isProcessingOrder = false);
//         _showSnackBar('Error placing order: $e', Colors.red);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     return PopScope(
//       canPop: !_isProcessingOrder,
//       child: Scaffold(
//         backgroundColor: theme.scaffoldBackgroundColor,
//         appBar: AppBar(
//           centerTitle: true,
//           title: Text(
//             'Checkout',
//             style: theme.textTheme.titleLarge?.copyWith(
//               color: colorScheme.onPrimary,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           backgroundColor: colorScheme.primary,
//           foregroundColor: colorScheme.onPrimary,
//           elevation: 0,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: _isProcessingOrder ? null : () => Navigator.pop(context),
//           ),
//         ),
//         body: Stack(
//           children: [
//             Consumer2<CartProvider, AddressProvider>(
//               builder: (context, cartProvider, addressProvider, child) {
//                 // Show loading if cart or address is loading
//                 if (cartProvider.isLoading || addressProvider.isLoading) {
//                   return Center(
//                     child: CircularProgressIndicator(
//                       color: colorScheme.primary,
//                     ),
//                   );
//                 }

//                 // Show error if cart is empty
//                 if (!cartProvider.hasItems) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           Icons.shopping_cart_outlined,
//                           size: 80,
//                           color: colorScheme.onSurface.withOpacity(0.5),
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'Your cart is empty',
//                           style: theme.textTheme.titleLarge?.copyWith(
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Add items to proceed with checkout',
//                           style: theme.textTheme.bodyMedium?.copyWith(
//                             color: colorScheme.onSurface.withOpacity(0.7),
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         ElevatedButton(
//                           onPressed: () => Navigator.pop(context),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: colorScheme.primary,
//                             foregroundColor: colorScheme.onPrimary,
//                           ),
//                           child: const Text('Go Back'),
//                         ),
//                       ],
//                     ),
//                   );
//                 }

//                 // return SingleChildScrollView(
//                 //   child: Column(
//                 //     children: [
//                 //       // Cart Items Section
//                 //       _buildCartItemsSection(cartProvider, theme, colorScheme),

//                 //       const SizedBox(height: 16),

//                 //       // Delivery Address Section
//                 //       _buildAddressSection(addressProvider, theme, colorScheme),

//                 //       const SizedBox(height: 16),

//                 //       // Payment Method Section
//                 //       _buildPaymentMethodSection(theme, colorScheme),

//                 //       const SizedBox(height: 16),

//                 //       // Price Summary
//                 //       _buildPriceSummary(cartProvider, theme, colorScheme),

//                 //       const SizedBox(height: 20),

//                 //       // Place Order Button
//                 //       _buildPlaceOrderButton(theme, colorScheme),

//                 //       const SizedBox(height: 20),
//                 //     ],
//                 //   ),
//                 // );


//                 return LayoutBuilder(
//   builder: (context, constraints) {
//     final width = constraints.maxWidth;

//     final bool isMobile = width < 800;
//     final bool isTablet = width >= 800 && width < 1200;
//     final bool isDesktop = width >= 1200;

//     final double maxWidth = isDesktop ? 1200 : (isTablet ? 950 : double.infinity);
//     final double horizontalPadding = isDesktop ? 30 : (isTablet ? 20 : 16);

//     return SingleChildScrollView(
//       child: Center(
//         child: ConstrainedBox(
//           constraints: BoxConstraints(maxWidth: maxWidth),
//           child: Padding(
//             padding: EdgeInsets.symmetric(
//               horizontal: horizontalPadding,
//               vertical: 16,
//             ),
//             child: isMobile
//                 ? Column(
//                     children: [
//                       _buildCartItemsSection(cartProvider, theme, colorScheme),
//                       const SizedBox(height: 16),
//                       _buildAddressSection(addressProvider, theme, colorScheme),
//                       const SizedBox(height: 16),
//                       _buildPaymentMethodSection(theme, colorScheme),
//                       const SizedBox(height: 16),
//                       _buildPriceSummary(cartProvider, theme, colorScheme),
//                       const SizedBox(height: 16),
//                       _buildPlaceOrderButton(theme, colorScheme),
//                       const SizedBox(height: 30),
//                     ],
//                   )
//                 : Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // LEFT SIDE (Main content)
//                       Expanded(
//                         flex: 3,
//                         child: Column(
//                           children: [
//                             _buildCartItemsSection(cartProvider, theme, colorScheme),
//                             const SizedBox(height: 16),
//                             _buildAddressSection(addressProvider, theme, colorScheme),
//                             const SizedBox(height: 16),
//                             _buildPaymentMethodSection(theme, colorScheme),
//                             const SizedBox(height: 30),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(width: 20),

//                       // RIGHT SIDE (Summary)
//                       Expanded(
//                         flex: 2,
//                         child: _StickyCheckoutSummary(
//                           child: Column(
//                             children: [
//                               _buildPriceSummary(cartProvider, theme, colorScheme),
//                               const SizedBox(height: 14),
//                               _buildPlaceOrderButton(theme, colorScheme),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//           ),
//         ),
//       ),
//     );
//   },
// );

//               },
//             ),

//             // Processing overlay
//             if (_isProcessingOrder)
//               Container(
//                 color: Colors.black.withOpacity(0.7),
//                 child: Center(
//                   child: Container(
//                     padding: const EdgeInsets.all(24),
//                     margin: const EdgeInsets.symmetric(horizontal: 40),
//                     decoration: BoxDecoration(
//                       color: theme.cardColor,
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         CircularProgressIndicator(
//                           valueColor: AlwaysStoppedAnimation<Color>(
//                             colorScheme.primary,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           _selectedPaymentMethod == 'Online'
//                               ? 'Processing Payment...'
//                               : 'Processing Order...',
//                           style: theme.textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           _selectedPaymentMethod == 'Online'
//                               ? 'Please complete the payment'
//                               : 'Please wait while we confirm your order',
//                           style: theme.textTheme.bodyMedium?.copyWith(
//                             color: colorScheme.primary,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCartItemsSection(
//     CartProvider cartProvider,
//     ThemeData theme,
//     ColorScheme colorScheme,
//   ) {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       padding: const EdgeInsets.all(16),
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
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Order Items',
//                 style: theme.textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 10,
//                   vertical: 4,
//                 ),
//                 decoration: BoxDecoration(
//                   color: colorScheme.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   '${cartProvider.totalItems} items',
//                   style: TextStyle(
//                     color: colorScheme.primary,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           ListView.separated(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: cartProvider.items.length,
//             separatorBuilder: (_, __) => Divider(
//               height: 20,
//               color: colorScheme.outline.withOpacity(0.2),
//             ),
//             itemBuilder: (context, index) {
//               final item = cartProvider.items[index];
//               return _buildCartItemTile(item, theme, colorScheme);
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCartItemTile(
//     CartProduct item,
//     ThemeData theme,
//     ColorScheme colorScheme,
//   ) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         ClipRRect(
//           borderRadius: BorderRadius.circular(8),
//           child: Image.network(
//             item.image,
//             width: 60,
//             height: 60,
//             fit: BoxFit.cover,
//             errorBuilder: (_, __, ___) => Container(
//               width: 60,
//               height: 60,
//               color: colorScheme.surfaceVariant,
//               child: Icon(Icons.image, color: colorScheme.onSurfaceVariant),
//             ),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 item.name,
//                 style: theme.textTheme.titleSmall?.copyWith(
//                   fontWeight: FontWeight.w600,
//                 ),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 'Size: ${item.addOn.variation}',
//                 style: theme.textTheme.bodySmall?.copyWith(
//                   color: colorScheme.onSurface.withOpacity(0.7),
//                 ),
//               ),
//               if (item.addOn.plateitems > 0) ...[
//                 Text(
//                   'Plates: ${item.addOn.plateitems}',
//                   style: theme.textTheme.bodySmall?.copyWith(
//                     color: colorScheme.onSurface.withOpacity(0.7),
//                   ),
//                 ),
//               ],
//               const SizedBox(height: 4),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Qty: ${item.quantity}',
//                     style: theme.textTheme.bodyMedium?.copyWith(
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   Text(
//                     '₹${item.price.toStringAsFixed(2)}',
//                     style: theme.textTheme.titleSmall?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: colorScheme.primary,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildAddressSection(
//     AddressProvider addressProvider,
//     ThemeData theme,
//     ColorScheme colorScheme,
//   ) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       padding: const EdgeInsets.all(16),
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
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Delivery Address',
//                 style: theme.textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               TextButton.icon(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (_) => AddressList()),
//                   );
//                 },
//                 icon: Icon(Icons.add, size: 18, color: colorScheme.primary),
//                 label: Text(
//                   'Add New',
//                   style: TextStyle(color: colorScheme.primary),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           if (addressProvider.addresses.isEmpty)
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: colorScheme.errorContainer.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.info_outline, color: colorScheme.error),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'No addresses found. Please add a delivery address.',
//                       style: TextStyle(color: colorScheme.error),
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           else
//             ListView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: addressProvider.addresses.length,
//               itemBuilder: (context, index) {
//                 final address = addressProvider.addresses[index];
//                 final isSelected = _selectedAddressId == address.id;

//                 return GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       _selectedAddressId = address.id;
//                     });
//                   },
//                   child: Container(
//                     margin: const EdgeInsets.only(bottom: 12),
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: isSelected
//                           ? colorScheme.primary.withOpacity(0.1)
//                           : colorScheme.surfaceVariant,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(
//                         color: isSelected
//                             ? colorScheme.primary
//                             : colorScheme.outline.withOpacity(0.3),
//                         width: isSelected ? 2 : 1,
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(
//                           isSelected
//                               ? Icons.radio_button_checked
//                               : Icons.radio_button_unchecked,
//                           color: isSelected
//                               ? colorScheme.primary
//                               : colorScheme.onSurfaceVariant,
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Container(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 8,
//                                       vertical: 4,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: colorScheme.primary,
//                                       borderRadius: BorderRadius.circular(4),
//                                     ),
//                                     child: Text(
//                                       address.addressType,
//                                       style: TextStyle(
//                                         color: colorScheme.onPrimary,
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 address.fullAddress ?? address.formattedAddress,
//                                 style: theme.textTheme.bodyMedium,
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPaymentMethodSection(ThemeData theme, ColorScheme colorScheme) {
//     final paymentMethods = [
//       {
//         'title': 'Cash on Delivery',
//         'value': 'COD',
//         'icon': Icons.money_outlined,
//         'description': 'Pay when you receive',
//       },
//       {
//         'title': 'Online Payment',
//         'value': 'Online',
//         'icon': Icons.payment_outlined,
//         'description': 'UPI, Card, Net Banking',
//       },
//     ];

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       padding: const EdgeInsets.all(16),
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
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Payment Method',
//             style: theme.textTheme.titleMedium?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 12),
//           ...paymentMethods.map((method) {
//             final isSelected = _selectedPaymentMethod == method['value'];

//             return GestureDetector(
//               onTap: () {
//                 setState(() {
//                   _selectedPaymentMethod = method['value'] as String;
//                 });
//               },
//               child: Container(
//                 margin: const EdgeInsets.only(bottom: 12),
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: isSelected
//                       ? colorScheme.primary.withOpacity(0.1)
//                       : colorScheme.surfaceVariant,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(
//                     color: isSelected
//                         ? colorScheme.primary
//                         : colorScheme.outline.withOpacity(0.3),
//                     width: isSelected ? 2 : 1,
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       isSelected
//                           ? Icons.radio_button_checked
//                           : Icons.radio_button_unchecked,
//                       color: isSelected
//                           ? colorScheme.primary
//                           : colorScheme.onSurfaceVariant,
//                     ),
//                     const SizedBox(width: 12),
//                     Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: colorScheme.primary.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Icon(
//                         method['icon'] as IconData,
//                         color: colorScheme.primary,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             method['title'] as String,
//                             style: theme.textTheme.titleSmall?.copyWith(
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           const SizedBox(height: 2),
//                           Text(
//                             method['description'] as String,
//                             style: theme.textTheme.bodySmall?.copyWith(
//                               color: colorScheme.onSurface.withOpacity(0.7),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }).toList(),
//         ],
//       ),
//     );
//   }

//   Widget _buildPriceSummary(
//     CartProvider cartProvider,
//     ThemeData theme,
//     ColorScheme colorScheme,
//   ) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: colorScheme.surfaceVariant,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [
//           _buildPriceRow(
//             'Sub Total',
//             '₹${cartProvider.subtotal.toStringAsFixed(2)}',
//             theme,
//             colorScheme,
//           ),
//           if (cartProvider.couponDiscount > 0)
//             _buildPriceRow(
//               'Coupon Discount',
//               '-₹${cartProvider.couponDiscount.toStringAsFixed(2)}',
//               theme,
//               colorScheme,
//               valueColor: colorScheme.primary,
//             ),
//           _buildPriceRow(
//             'Delivery Charge',
//             '₹${cartProvider.deliveryCharge.toStringAsFixed(2)}',
//             theme,
//             colorScheme,
//           ),
//           _buildPriceRow(
//             'Platform Charge',
//             '₹${cartProvider.platformCharge.toStringAsFixed(2)}',
//             theme,
//             colorScheme,
//           ),
// _buildGstPriceRow(cartProvider, theme, colorScheme),

//           _buildPriceRow(
//             'Packing Charge',
//             '₹${cartProvider.packingCharges.toStringAsFixed(2)}',
//             theme,
//             colorScheme,
//           ),
//           _buildPriceRow(
//             'Your Saving',
//             '₹${cartProvider.amountSavedOnOrder.toStringAsFixed(2)}',
//             theme,
//             colorScheme,
//           ),
//           Divider(height: 20, color: colorScheme.outline.withOpacity(0.3)),
//           _buildPriceRow(
//             'Total Payable',
//             '₹${cartProvider.totalPayable.toStringAsFixed(2)}',
//             theme,
//             colorScheme,
//             valueColor: colorScheme.primary,
//             isBold: true,
//           ),
//         ],
//       ),
//     );
//   }


// //   Widget _buildPriceSummary(
// //   CartProvider cartProvider,
// //   ThemeData theme,
// //   ColorScheme colorScheme,
// // ) {
// //   return Container(
// //     margin: const EdgeInsets.symmetric(horizontal: 16),
// //     padding: const EdgeInsets.all(16),
// //     decoration: BoxDecoration(
// //       color: colorScheme.surfaceVariant,
// //       borderRadius: BorderRadius.circular(12),
// //     ),
// //     child: Column(
// //       children: [
// //         _buildPriceRow(
// //           'Sub Total',
// //           '₹${cartProvider.subtotal.toStringAsFixed(2)}',
// //           theme,
// //           colorScheme,
// //         ),

// //         if (cartProvider.couponDiscount > 0)
// //           _buildPriceRow(
// //             'Coupon Discount',
// //             '-₹${cartProvider.couponDiscount.toStringAsFixed(2)}',
// //             theme,
// //             colorScheme,
// //             valueColor: Colors.green,
// //           ),

// //         _buildPriceRow(
// //           'Delivery Charge',
// //           '₹${cartProvider.deliveryCharge.toStringAsFixed(2)}',
// //           theme,
// //           colorScheme,
// //         ),

// //         _buildPriceRow(
// //           'Platform Charge',
// //           '₹${cartProvider.platformCharge.toStringAsFixed(2)}',
// //           theme,
// //           colorScheme,
// //         ),

// //         /// ✅ SINGLE GST ROW WITH LINK
// //         _buildGstPriceRow(cartProvider, theme, colorScheme),

// //         _buildPriceRow(
// //           'Packing Charge',
// //           '₹${cartProvider.packingCharges.toStringAsFixed(2)}',
// //           theme,
// //           colorScheme,
// //         ),

// //         _buildPriceRow(
// //           'Your Saving',
// //           '₹${cartProvider.amountSavedOnOrder.toStringAsFixed(2)}',
// //           theme,
// //           colorScheme,
// //           valueColor: Colors.green,
// //         ),

// //         Divider(height: 20, color: colorScheme.outline.withOpacity(0.3)),

// //         _buildPriceRow(
// //           'Total Payable',
// //           '₹${cartProvider.totalPayable.toStringAsFixed(2)}',
// //           theme,
// //           colorScheme,
// //           valueColor: colorScheme.primary,
// //           isBold: true,
// //         ),
// //       ],
// //     ),
// //   );
// // }

// Widget _buildGstPriceRow(
//   CartProvider cartProvider,
//   ThemeData theme,
//   ColorScheme colorScheme,
// ) {
//   final totalGst =
//       cartProvider.gstAmount + cartProvider.gstOnDelivery;

//   return Padding(
//     padding: const EdgeInsets.symmetric(vertical: 4),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         GestureDetector(
//           onTap: () => _showGstBreakupModal(cartProvider, theme, colorScheme),
//           child: RichText(
//             text: TextSpan(
//               text: 'GST ',
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 color: colorScheme.onSurface.withOpacity(0.7),
//               ),
//               children: [
//                 TextSpan(
//                   text: '(View breakup)',
//                   style: theme.textTheme.bodyMedium?.copyWith(
//                     color: colorScheme.primary,
//                     decoration: TextDecoration.underline,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         Text(
//           '₹${totalGst.toStringAsFixed(2)}',
//           style: theme.textTheme.bodyMedium?.copyWith(
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ],
//     ),
//   );
// }


// void _showGstBreakupModal(
//   CartProvider cartProvider,
//   ThemeData theme,
//   ColorScheme colorScheme,
// ) {
//   final totalGst =
//       cartProvider.gstAmount + cartProvider.gstOnDelivery;

//   showModalBottomSheet(
//     context: context,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//     ),
//     builder: (_) {
//       return Padding(
//         padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'GST Breakup',
//                   style: theme.textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.close),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 16),

//             _gstRow('Items GST', cartProvider.gstAmount, theme),
//             const SizedBox(height: 12),
//             _gstRow('Delivery GST', cartProvider.gstOnDelivery, theme),

//             const Divider(height: 32),

//             _gstRow('Total GST', totalGst, theme, isBold: true),
//           ],
//         ),
//       );
//     },
//   );
// }


// Widget _gstRow(
//   String label,
//   double value,
//   ThemeData theme, {
//   bool isBold = false,
// }) {
//   return Row(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//       Text(
//         label,
//         style: theme.textTheme.bodyMedium?.copyWith(
//           fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//         ),
//       ),
//       Text(
//         '₹${value.toStringAsFixed(2)}',
//         style: theme.textTheme.bodyMedium?.copyWith(
//           fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
//         ),
//       ),
//     ],
//   );
// }


//   Widget _buildPriceRow(
//     String label,
//     String value,
//     ThemeData theme,
//     ColorScheme colorScheme, {
//     Color? valueColor,
//     bool isBold = false,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: theme.textTheme.bodyMedium?.copyWith(
//               color: colorScheme.onSurface.withOpacity(isBold ? 1 : 0.7),
//               fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//             ),
//           ),
//           Text(
//             value,
//             style: theme.textTheme.bodyMedium?.copyWith(
//               color: valueColor ?? colorScheme.onSurface,
//               fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPlaceOrderButton(ThemeData theme, ColorScheme colorScheme) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: SizedBox(
//         width: double.infinity,
//         child: ElevatedButton(
//           onPressed: _canPlaceOrder ? _placeOrder : null,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: colorScheme.primary,
//             foregroundColor: colorScheme.onPrimary,
//             disabledBackgroundColor: colorScheme.onSurface.withOpacity(0.12),
//             disabledForegroundColor: colorScheme.onSurface.withOpacity(0.38),
//             padding: const EdgeInsets.symmetric(vertical: 16),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//           child: _isProcessingOrder
//               ? Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(
//                         color: colorScheme.onPrimary,
//                         strokeWidth: 2,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       'Processing...',
//                       style: theme.textTheme.titleMedium?.copyWith(
//                         color: colorScheme.onPrimary,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 )
//               : Text(
//                   _canPlaceOrder ? 'Place Order' : 'Select Address & Payment',
//                   style: theme.textTheme.titleMedium?.copyWith(
//                     color: _canPlaceOrder
//                         ? colorScheme.onPrimary
//                         : colorScheme.onSurface.withOpacity(0.6),
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//         ),
//       ),
//     );
//   }
// }



// class _StickyCheckoutSummary extends StatelessWidget {
//   final Widget child;

//   const _StickyCheckoutSummary({required this.child});

//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: Alignment.topCenter,
//       child: child,
//     );
//   }
// }


























// checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veegify/helper/storage_helper.dart';
import 'package:veegify/model/user_model.dart';
import 'package:veegify/provider/CartProvider/cart_provider.dart';
import 'package:veegify/model/address_model.dart';
import 'package:veegify/model/CartModel/cart_model.dart';
import 'package:veegify/provider/address_provider.dart';
import 'package:veegify/services/order_service.dart';
import 'package:veegify/views/PaymentSuccess/payment_success_screen.dart';
import 'package:veegify/views/address/address_list.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:veegify/utils/responsive.dart'; // Add responsive utility

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String? _selectedAddressId;
  String? _selectedPaymentMethod;
  bool _isProcessingOrder = false;
  User? user;
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _initializeRazorpay();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserId();
      _loadAddresses();
      _loadCart();
    });
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> _loadUserId() async {
    final userData = UserPreferences.getUser();
    if (userData != null) {
      setState(() {
        user = userData;
      });
      print("User ID: ${user?.userId.toString()}");
    }
  }

  Future<void> _loadAddresses() async {
    final addressProvider = Provider.of<AddressProvider>(
      context,
      listen: false,
    );
    await addressProvider.loadAddresses();
  }

  Future<void> _loadCart() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    await cartProvider.loadCart(user?.userId.toString());
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (mounted) {
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
  }

  bool get _canPlaceOrder {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    return _selectedAddressId != null &&
        _selectedPaymentMethod != null &&
        !_isProcessingOrder &&
        cartProvider.hasItems;
  }

  // Razorpay Payment Handlers
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print("Payment Success: ${response.paymentId}");

    // Payment successful, now create the order with transaction ID
    await _createOrder(transactionId: response.paymentId);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isProcessingOrder = false);

    _showSnackBar(
      'Payment Failed: ${"User Close the Payment" ?? "Unknown error"}',
      Colors.red,
    );

    print(
      "Payment Error: Code: ${response.code}, Message: ${response.message}",
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _showSnackBar(
      'External Wallet Selected: ${response.walletName}',
      Colors.blue,
    );
  }

  Future<void> _placeOrder() async {
    if (!_canPlaceOrder) return;

    setState(() => _isProcessingOrder = true);

    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      // Check if payment method is Online
      if (_selectedPaymentMethod == 'Online') {
        // Initiate Razorpay payment
        _initiateRazorpayPayment();
      } else {
        // For COD, directly create order without payment
        await _createOrder(transactionId: null);
      }
    } catch (e) {
      setState(() => _isProcessingOrder = false);
      _showSnackBar('Error placing order: $e', Colors.red);
    }
  }

  void _initiateRazorpayPayment() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    var options = {
      'key': 'rzp_test_RgqXPvDLbgEIVv', // Replace with your Razorpay key
      'amount': (cartProvider.totalPayable * 100).toInt(), // Amount in paise
      'name': 'Vegiffy',
      'description': 'Order Payment',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {'contact': "6282714883" ?? '', 'email': user?.email ?? ''},
      'external': {
        'wallets': ['paytm', 'phonepe', 'gpay'],
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() => _isProcessingOrder = false);
      _showSnackBar('Error opening Razorpay: $e', Colors.red);
    }
  }

  Future<void> _createOrder({String? transactionId}) async {
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      // Get cart items for order
      final cartItems = cartProvider.items;

      print('=== ORDER DETAILS ===');
      print('Total Items: ${cartProvider.totalItems}');
      print('Subtotal: ${cartProvider.subtotal}');
      print('Delivery Charge: ${cartProvider.deliveryCharge}');
      print('Coupon Discount: ${cartProvider.couponDiscount}');
      print('Total Payable: ${cartProvider.totalPayable}');
      print('Selected Address ID: $_selectedAddressId');
      print('Payment Method: $_selectedPaymentMethod');
      print('Transaction ID: $transactionId');
      print('Cart Items:');
      for (var item in cartItems) {
        print(
          '  - ${item.name} (Qty: ${item.quantity}, Price: ${item.totalPrice})',
        );
      }

      // Create order payload
      final orderData = {
        "userId": "${user?.userId.toString()}",
        "paymentMethod": _selectedPaymentMethod,
        "addressId": _selectedAddressId,
        "transactionId":
            transactionId, // Include transaction ID for online payment
        "items": cartItems
            .map(
              (item) => {
                "productId": item.id,
                "name": item.name,
                "quantity": item.quantity,
                "price": item.basePrice,
                "totalPrice": item.totalPrice,
                "variation": item.addOn.variation,
                "plateItems": item.addOn.plateitems,
              },
            )
            .toList(),
        "subtotal": cartProvider.subtotal,
        "deliveryCharge": cartProvider.deliveryCharge,
        "couponDiscount": cartProvider.couponDiscount,
        "totalAmount": cartProvider.totalPayable,
      };

      // Call order service
      final result = await OrderService.createOrder(orderData);

      if (result['success']) {
        final orderId = result['data']['data']['_id'];
        // Clear cart after successful order
        await cartProvider.clearCart();

        if (mounted) {
          setState(() => _isProcessingOrder = false);
          _showSnackBar('Order placed successfully!', Colors.green);

          // Navigate to payment success screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentSuccessScreen(
                userId: user?.userId.toString(),
                orderId: orderId.toString(),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() => _isProcessingOrder = false);
          _showSnackBar(
            result['message'] ?? 'Failed to place order',
            Colors.red,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessingOrder = false);
        _showSnackBar('Error placing order: $e', Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);

    return PopScope(
      canPop: !_isProcessingOrder,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          centerTitle: isDesktop,
          title: Text(
            'Checkout',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
              fontSize: isDesktop ? 24 : 20,
            ),
          ),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: isDesktop ? 2 : 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _isProcessingOrder ? null : () => Navigator.pop(context),
          ),
          actions: isDesktop
              ? [
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Center(
                      child: Text(
                        'Secure Checkout',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimary.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ),
                ]
              : null,
        ),
        body: Stack(
          children: [
            Consumer2<CartProvider, AddressProvider>(
              builder: (context, cartProvider, addressProvider, child) {
                // Show loading if cart or address is loading
                if (cartProvider.isLoading || addressProvider.isLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                  );
                }

                // Show error if cart is empty
                if (!cartProvider.hasItems) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: isDesktop ? 100 : 80,
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Your cart is empty',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: isDesktop ? 24 : 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add items to proceed with checkout',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                            fontSize: isDesktop ? 16 : 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: EdgeInsets.symmetric(
                              horizontal: isDesktop ? 32 : 24,
                              vertical: isDesktop ? 16 : 12,
                            ),
                          ),
                          child: Text(
                            'Go Back',
                            style: TextStyle(
                              fontSize: isDesktop ? 16 : 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;

                    final bool isMobile = width < 800;
                    final bool isTablet = width >= 800 && width < 1200;
                    final bool isDesktop = width >= 1200;

                    final double maxWidth = isDesktop ? 1400 : (isTablet ? 1000 : double.infinity);
                    final double horizontalPadding = isDesktop ? 40 : (isTablet ? 24 : 16);
                    final double verticalPadding = isDesktop ? 24 : 16;

                    return SingleChildScrollView(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                              vertical: verticalPadding,
                            ),
                            child: isMobile
                                ? _buildMobileLayout(
                                    cartProvider,
                                    addressProvider,
                                    theme,
                                    colorScheme,
                                  )
                                : _buildDesktopLayout(
                                    cartProvider,
                                    addressProvider,
                                    theme,
                                    colorScheme,
                                  ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            // Processing overlay
            if (_isProcessingOrder)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedPaymentMethod == 'Online'
                              ? 'Processing Payment...'
                              : 'Processing Order...',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedPaymentMethod == 'Online'
                              ? 'Please complete the payment'
                              : 'Please wait while we confirm your order',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Mobile Layout (unchanged)
  Widget _buildMobileLayout(
    CartProvider cartProvider,
    AddressProvider addressProvider,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        _buildCartItemsSection(cartProvider, theme, colorScheme),
        const SizedBox(height: 16),
        _buildAddressSection(addressProvider, theme, colorScheme),
        const SizedBox(height: 16),
        _buildPaymentMethodSection(theme, colorScheme),
        const SizedBox(height: 16),
        _buildPriceSummary(cartProvider, theme, colorScheme),
        const SizedBox(height: 16),
        _buildPlaceOrderButton(theme, colorScheme),
        const SizedBox(height: 30),
      ],
    );
  }

  // Professional Desktop Layout
  Widget _buildDesktopLayout(
    CartProvider cartProvider,
    AddressProvider addressProvider,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LEFT SIDE - Main Content (2/3 width)
        Expanded(
          flex: 1,
          child: Column(
            children: [
              // Order Progress
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _buildProgressStep(1, 'Cart', true, theme, colorScheme),
                    _buildProgressLine(theme, colorScheme),
                    _buildProgressStep(2, 'Checkout', true, theme, colorScheme),
                    _buildProgressLine(theme, colorScheme),
                    _buildProgressStep(3, 'Payment', false, theme, colorScheme),
                  ],
                ),
              ),

              // Cart Items Section
              _buildCartItemsSection(cartProvider, theme, colorScheme),
              const SizedBox(height: 20),

              // Delivery Address Section
              _buildAddressSection(addressProvider, theme, colorScheme),

            ],
          ),
        ),

        const SizedBox(width: 24),

        // RIGHT SIDE - Order Summary (1/3 width)
        Expanded(
          flex: 1,
          child: Column(
            children: [


                            // Payment Method Section
              _buildPaymentMethodSection(theme, colorScheme),
              const SizedBox(height: 20),

              // Sticky Summary Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Summary Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.05),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.receipt_outlined,
                              color: colorScheme.onPrimary,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Order Summary',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Summary Content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildPriceSummary(cartProvider, theme, colorScheme),
                          const SizedBox(height: 20),
                          _buildPlaceOrderButton(theme, colorScheme),

                          // Secure Checkout Note
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lock_outline,
                                size: 14,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '100% Secure Checkout',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),


                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper widget for progress steps
  Widget _buildProgressStep(
    int step,
    String label,
    bool isActive,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive ? colorScheme.primary : colorScheme.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step.toString(),
                style: TextStyle(
                  color: isActive ? colorScheme.onPrimary : colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive ? colorScheme.primary : colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressLine(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: colorScheme.primary.withOpacity(0.3),
    );
  }

  Widget _buildTrustBadge(
    IconData icon,
    String label,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCartItemsSection(
    CartProvider cartProvider,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isDesktop = Responsive.isDesktop(context);

    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order Items',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isDesktop ? 18 : 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${cartProvider.totalItems} items',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: isDesktop ? 14 : 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cartProvider.items.length,
            separatorBuilder: (_, __) => Divider(
              height: 24,
              color: colorScheme.outline.withOpacity(0.2),
            ),
            itemBuilder: (context, index) {
              final item = cartProvider.items[index];
              return _buildCartItemTile(item, theme, colorScheme);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemTile(
    CartProduct item,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isDesktop = Responsive.isDesktop(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            item.image,
            width: isDesktop ? 70 : 60,
            height: isDesktop ? 70 : 60,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: isDesktop ? 70 : 60,
              height: isDesktop ? 70 : 60,
              color: colorScheme.surfaceVariant,
              child: Icon(Icons.image, color: colorScheme.onSurfaceVariant),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: isDesktop ? 16 : 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Size: ${item.addOn.variation}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                  fontSize: isDesktop ? 14 : 12,
                ),
              ),
              if (item.addOn.plateitems > 0) ...[
                Text(
                  'Plates: ${item.addOn.plateitems}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                    fontSize: isDesktop ? 14 : 12,
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Qty: ${item.quantity}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: isDesktop ? 14 : 12,
                    ),
                  ),
                  Text(
                    '₹${item.price.toStringAsFixed(2)}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                      fontSize: isDesktop ? 16 : 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddressSection(
    AddressProvider addressProvider,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isDesktop = Responsive.isDesktop(context);

    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delivery Address',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isDesktop ? 18 : 16,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddressList()),
                  ).then((_) {
                    // Refresh addresses when returning
                    addressProvider.loadAddresses();
                  });
                },
                icon: Icon(Icons.add, size: isDesktop ? 20 : 18, color: colorScheme.primary),
                label: Text(
                  'Add New',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: isDesktop ? 14 : 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (addressProvider.addresses.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: colorScheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No addresses found. Please add a delivery address.',
                      style: TextStyle(
                        color: colorScheme.error,
                        fontSize: isDesktop ? 14 : 12,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: addressProvider.addresses.length,
              itemBuilder: (context, index) {
                final address = addressProvider.addresses[index];
                final isSelected = _selectedAddressId == address.id;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAddressId = address.id;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary.withOpacity(0.1)
                          : colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.outline.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                          size: isDesktop ? 22 : 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      address.addressType,
                                      style: TextStyle(
                                        color: colorScheme.onPrimary,
                                        fontSize: isDesktop ? 12 : 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                address.fullAddress ?? address.formattedAddress,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: isDesktop ? 14 : 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection(ThemeData theme, ColorScheme colorScheme) {
    final isDesktop = Responsive.isDesktop(context);
    
    final paymentMethods = [
      {
        'title': 'Cash on Delivery',
        'value': 'COD',
        'icon': Icons.money_outlined,
        'description': 'Pay when you receive',
      },
      {
        'title': 'Online Payment',
        'value': 'Online',
        'icon': Icons.payment_outlined,
        'description': 'UPI, Card, Net Banking',
      },
    ];

    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isDesktop ? 18 : 16,
            ),
          ),
          const SizedBox(height: 16),
          ...paymentMethods.map((method) {
            final isSelected = _selectedPaymentMethod == method['value'];

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPaymentMethod = method['value'] as String;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary.withOpacity(0.1)
                      : colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.outline.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                      size: isDesktop ? 22 : 20,
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        method['icon'] as IconData,
                        color: colorScheme.primary,
                        size: isDesktop ? 22 : 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            method['title'] as String,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: isDesktop ? 16 : 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            method['description'] as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                              fontSize: isDesktop ? 14 : 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPriceSummary(
    CartProvider cartProvider,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isDesktop = Responsive.isDesktop(context);

    return Container(
      padding: EdgeInsets.all(isDesktop ? 20 : 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
      ),
      child: Column(
        children: [
          _buildPriceRow(
            'Sub Total',
            '₹${cartProvider.subtotal.toStringAsFixed(2)}',
            theme,
            colorScheme,
          ),
          if (cartProvider.couponDiscount > 0)
            _buildPriceRow(
              'Coupon Discount',
              '-₹${cartProvider.couponDiscount.toStringAsFixed(2)}',
              theme,
              colorScheme,
              valueColor: colorScheme.primary,
            ),
          _buildPriceRow(
            'Delivery Charge',
            '₹${cartProvider.deliveryCharge.toStringAsFixed(2)}',
            theme,
            colorScheme,
          ),
          _buildPriceRow(
            'Platform Charge',
            '₹${cartProvider.platformCharge.toStringAsFixed(2)}',
            theme,
            colorScheme,
          ),
          _buildGstPriceRow(cartProvider, theme, colorScheme),
          _buildPriceRow(
            'Packing Charge',
            '₹${cartProvider.packingCharges.toStringAsFixed(2)}',
            theme,
            colorScheme,
          ),
          _buildPriceRow(
            'Your Saving',
            '₹${cartProvider.amountSavedOnOrder.toStringAsFixed(2)}',
            theme,
            colorScheme,
            valueColor: Colors.green,
          ),
          Divider(height: isDesktop ? 24 : 20, color: colorScheme.outline.withOpacity(0.3)),
          _buildPriceRow(
            'Total Payable',
            '₹${cartProvider.totalPayable.toStringAsFixed(2)}',
            theme,
            colorScheme,
            valueColor: colorScheme.primary,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildGstPriceRow(
    CartProvider cartProvider,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isDesktop = Responsive.isDesktop(context);
    final totalGst = cartProvider.gstAmount + cartProvider.gstOnDelivery;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => _showGstBreakupModal(cartProvider, theme, colorScheme),
            child: RichText(
              text: TextSpan(
                text: 'GST ',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                  fontSize: isDesktop ? 14 : 12,
                ),
                children: [
                  TextSpan(
                    text: isDesktop ? '(View breakup)' : '(View)',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w600,
                      fontSize: isDesktop ? 14 : 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Text(
            '₹${totalGst.toStringAsFixed(2)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: isDesktop ? 14 : 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showGstBreakupModal(
    CartProvider cartProvider,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isDesktop = Responsive.isDesktop(context);
    final totalGst = cartProvider.gstAmount + cartProvider.gstOnDelivery;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Container(
          padding: EdgeInsets.fromLTRB(
            isDesktop ? 32 : 20,
            isDesktop ? 24 : 20,
            isDesktop ? 32 : 20,
            isDesktop ? 32 : 30,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'GST Breakup',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isDesktop ? 20 : 18,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _gstRow('Items GST', cartProvider.gstAmount, theme, isDesktop),
              const SizedBox(height: 12),
              _gstRow('Delivery GST', cartProvider.gstOnDelivery, theme, isDesktop),
              const Divider(height: 32),
              _gstRow('Total GST', totalGst, theme, isDesktop, isBold: true),
            ],
          ),
        );
      },
    );
  }

  Widget _gstRow(
    String label,
    double value,
    ThemeData theme,
    bool isDesktop, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isDesktop ? 16 : 14,
          ),
        ),
        Text(
          '₹${value.toStringAsFixed(2)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: isDesktop ? 16 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(
    String label,
    String value,
    ThemeData theme,
    ColorScheme colorScheme, {
    Color? valueColor,
    bool isBold = false,
  }) {
    final isDesktop = Responsive.isDesktop(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(isBold ? 1 : 0.7),
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isDesktop ? 14 : 12,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: valueColor ?? colorScheme.onSurface,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isDesktop ? 14 : 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceOrderButton(ThemeData theme, ColorScheme colorScheme) {
    final isDesktop = Responsive.isDesktop(context);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _canPlaceOrder ? _placeOrder : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.onSurface.withOpacity(0.12),
          disabledForegroundColor: colorScheme.onSurface.withOpacity(0.38),
          padding: EdgeInsets.symmetric(
            vertical: isDesktop ? 18 : 16,
            horizontal: isDesktop ? 24 : 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
          ),
          elevation: isDesktop ? 4 : 0,
        ),
        child: _isProcessingOrder
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: isDesktop ? 24 : 20,
                    height: isDesktop ? 24 : 20,
                    child: CircularProgressIndicator(
                      color: colorScheme.onPrimary,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Processing...',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: isDesktop ? 18 : 16,
                    ),
                  ),
                ],
              )
            : Text(
                _canPlaceOrder ? 'Place Order' : 'Select Address & Payment',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: _canPlaceOrder
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.bold,
                  fontSize: isDesktop ? 18 : 16,
                ),
              ),
      ),
    );
  }
}

class _StickyCheckoutSummary extends StatelessWidget {
  final Widget child;

  const _StickyCheckoutSummary({required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: child,
    );
  }
}