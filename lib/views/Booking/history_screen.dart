
// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:veegify/helper/storage_helper.dart';
// import 'package:veegify/model/previous_order.dart';
// import 'package:veegify/model/user_model.dart';
// import 'package:veegify/provider/AuthProvider/auth_provider.dart';
// import 'package:veegify/provider/Credential/credential_provider.dart';
// import 'package:veegify/utils/previous_order.dart';
// import 'package:veegify/views/ProfileScreen/help_screen.dart';
// import 'package:veegify/views/Booking/booking_screen.dart';
// import 'package:veegify/views/address/address_list.dart';
// import 'package:veegify/views/home/invoice_screen.dart';
// import 'package:veegify/views/Navbar/navbar_screen.dart';
// import 'package:veegify/views/ProfileScreen/refer_earn_screen.dart';
// import 'package:veegify/widgets/bottom_navbar.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;

// // ↓↓↓ INVOICE RELATED ↓↓↓
// // import 'package:printing/printing.dart';
// // import 'package:pdf/pdf.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:open_filex/open_filex.dart';
// // ↑↑↑ INVOICE RELATED ↑↑↑

// import 'package:veegify/utils/responsive.dart'; // ✅ responsive util

// class HystoryScreenWithController extends StatelessWidget {
//   final ScrollController scrollController;

//   const HystoryScreenWithController({
//     super.key,
//     required this.scrollController,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return HystoryScreen(scrollController: scrollController);
//   }
// }

// class HystoryScreen extends StatefulWidget {
//   final ScrollController? scrollController;

//   const HystoryScreen({super.key, this.scrollController});

//   @override
//   State<HystoryScreen> createState() => _HystoryScreenState();
// }

// class _HystoryScreenState extends State<HystoryScreen> {
//   User? user;
//   String? imageUrl;
//   bool _loading = true;
//   String? _error;
//   Object? _lastError;

//   // ✅ typed Order list
//   List<Order> _orders = [];

//   final Map<String, bool> _favorites = {}; // Track favorites by product ID

//   static const String _apiHost = "https://api.vegiffyy.com";

//   @override
//   void initState() {
//     super.initState();
//     _initializeData();
//   }

//   Future<void> _initializeData() async {
//     try {
//       await _loadUserId();
//       await _fetchUserProfile();
//       await _fetchPreviousOrders();
//     } catch (e, st) {
//       debugPrint('Initialization error: $e\n$st');
//       setState(() {
//         _lastError = e;
//         _error = e.toString();
//       });
//     } finally {
//       setState(() {
//         _loading = false;
//       });
//     }
//   }

//   Future<void> _loadUserId() async {
//     final userData = UserPreferences.getUser();
//     if (userData != null) {
//       setState(() {
//         user = userData;
//       });
//     }
//   }

//   Future<void> _fetchUserProfile() async {
//     if (user == null) return;
//     try {
//       final url = Uri.parse("$_apiHost/api/usersprofile/${user!.userId}");
//       debugPrint("Profile URL: $url");
//       final response = await http.get(url);
//       debugPrint("Profile Response : ${response.body}");
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final userData = data['user'];

//         setState(() {
//           imageUrl = userData['profileImg'] ?? '';
//           user = User(
//             userId: userData['_id'],
//             fullName: userData['fullName'] ?? '',
//             email: userData['email'] ?? '',
//             phoneNumber: userData['phoneNumber'] ?? '',
//             profileImg: userData['profileImg'] ?? '',
//           );
//         });

//         debugPrint("✅ Profile fetched successfully");
//       } else {
//         debugPrint("❌ Failed to fetch profile: ${response.statusCode}");
//       }
//     } catch (e, st) {
//       debugPrint("Error fetching profile: $e\n$st");
//       setState(() {
//         _lastError = e;
//         _error = e.toString();
//       });
//     }
//   }

//   Future<void> _fetchPreviousOrders() async {
//     if (user == null) {
//       debugPrint("User is null; skipping previous orders fetch.");
//       return;
//     }

//     setState(() {
//       _loading = true;
//       _error = null;
//       _lastError = null;
//     });

//     try {
//       final url =
//           Uri.parse("$_apiHost/api/userpreviousorders/${user!.userId}");
//       final response = await http.get(url);

//       debugPrint("Orders response: ${response.statusCode} -> ${response.body}");

//       if (response.statusCode == 200) {
//         final List<Order> orders = ordersFromApiResponse(response.body);

//         setState(() {
//           _orders = orders;
//           if (_orders.isEmpty) {
//             _error = "No orders found";
//           }
//         });
//       } else {
//         setState(() {
//           _orders = [];
//           _error = "Failed to fetch orders (${response.statusCode})";
//         });
//       }
//     } on SocketException catch (e) {
//       debugPrint("SocketException fetching previous orders: $e");
//       setState(() {
//         _orders = [];
//         _lastError = e;
//         _error = "Network error: Please check your internet connection.";
//       });
//     } catch (e, st) {
//       debugPrint("Error fetching previous orders: $e\n$st");
//       setState(() {
//         _orders = [];
//         _lastError = e;
//         _error = "Error fetching orders: $e";
//       });
//     } finally {
//       setState(() {
//         _loading = false;
//       });
//     }
//   }

//   void _toggleFavorite(String productId) {
//     setState(() {
//       _favorites[productId] = !(_favorites[productId] ?? false);
//     });
//     // TODO: call API for favorite/unfavorite if needed
//   }

//   void _viewOrderDetails(Order order) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Theme.of(context).cardColor,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => _buildOrderDetailSheet(order),
//     );
//   }

//   Widget _buildOrderDetailSheet(Order order) {
//     final theme = Theme.of(context);
//     final products = order.products;

//     final subTotal = order.subTotal;
//     final gstAmount = order.gstAmount ?? 0;
//     final platformCharge = order.platformCharge ?? 0;
//     final deliveryCharge = order.deliveryCharge;
//         final packingCharge = order.packingCharges;
//                 final deliveryGst = order.gstOnDelivery;


//     final couponDiscount = order.couponDiscount;
//     final totalPayable = order.totalPayable;

//     Future<void> openWhatsApp(String phoneNumber,
//         {String message = ""}) async {
//       // Remove spaces and ensure only digits
//       String cleanedNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

//       // If number is missing country code, add +91 by default
//       if (!cleanedNumber.startsWith("91") && cleanedNumber.length == 10) {
//         cleanedNumber = "91$cleanedNumber";
//       }

//       final String encodedMessage = Uri.encodeComponent(message);
//       final String url = "https://wa.me/$cleanedNumber?text=$encodedMessage";

//       final Uri uri = Uri.parse(url);

//       if (await canLaunchUrl(uri)) {
//         await launchUrl(uri, mode: LaunchMode.externalApplication);
//       } else {
//         throw "Could not launch WhatsApp";
//       }
//     }

//     final isMobile = Responsive.isMobile(context);
//     final isTablet = Responsive.isTablet(context);
//     final isDesktop = Responsive.isDesktop(context);

//     final double maxWidth =
//         isDesktop ? 520 : (isTablet ? 480 : double.infinity);

//     return Center(
//       child: ConstrainedBox(
//         constraints: BoxConstraints(
//           maxWidth: maxWidth,
//           maxHeight: MediaQuery.of(context).size.height * 0.85,
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: Container(
//                   width: 40,
//                   height: 4,
//                   decoration: BoxDecoration(
//                     color: theme.colorScheme.onSurface.withOpacity(0.3),
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),

//               Text(
//                 'Order Items',
//                 style: theme.textTheme.titleLarge?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // SCROLLABLE CONTENT
//               Expanded(
//                 child: SingleChildScrollView(
//                   physics: const BouncingScrollPhysics(),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       ...products.map((product) {
//                         final price = product.price;
//                         final quantity = product.quantity;
//                         final lineTotal = price * quantity;

//                         return Container(
//                           margin: const EdgeInsets.only(bottom: 12),
//                           padding: const EdgeInsets.all(16),
//                           decoration: BoxDecoration(
//                             color:
//                                 theme.colorScheme.surface.withOpacity(0.5),
//                             borderRadius: BorderRadius.circular(16),
//                             border: Border.all(
//                               color: theme.dividerColor.withOpacity(0.3),
//                             ),
//                           ),
//                           child: Row(
//                             children: [
//                               // IMAGE
//                               Container(
//                                 width: 60,
//                                 height: 60,
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(12),
//                                   image: DecorationImage(
//                                     image: _normalizeImageUrl(
//                                                 product.image?.toString())
//                                             .isNotEmpty
//                                         ? NetworkImage(_normalizeImageUrl(
//                                             product.image?.toString()))
//                                         : const AssetImage(
//                                                 'assets/placeholder.png')
//                                             as ImageProvider,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 12),

//                               // INFO
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment:
//                                       CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       product.name,
//                                       style: theme
//                                           .textTheme.bodyMedium
//                                           ?.copyWith(
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       '${product.quantity} x ₹${price.toStringAsFixed(2)}',
//                                       style: theme
//                                           .textTheme.bodySmall
//                                           ?.copyWith(
//                                         color: theme
//                                             .colorScheme.onSurface
//                                             .withOpacity(0.6),
//                                       ),
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       'Total: ₹${lineTotal.toStringAsFixed(2)}',
//                                       style: theme
//                                           .textTheme.bodySmall
//                                           ?.copyWith(
//                                         fontWeight: FontWeight.w600,
//                                         color: theme
//                                             .colorScheme.primary,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       }).toList(),

//                       const SizedBox(height: 16),

//                       // ORDER SUMMARY
//                       Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: theme.colorScheme.primary
//                               .withOpacity(0.04),
//                           borderRadius: BorderRadius.circular(16),
//                           border: Border.all(
//                             color: theme.colorScheme.primary
//                                 .withOpacity(0.3),
//                           ),
//                         ),
//                         child: Column(
//                           children: [
//                             _summaryRow('Items Total', subTotal, theme),
//                             _summaryRow('GST', gstAmount, theme),
//                             _summaryRow(
//                                 'Platform Charge', platformCharge, theme),
//                             _summaryRow(
//                                 'Delivery Charge', deliveryCharge, theme),
//                                                             _summaryRow(
//                                 'Packing Charge', packingCharge, theme),
//                                                             _summaryRow(
//                                 'Delivery Gst Charge', deliveryGst, theme),
//                             if (couponDiscount > 0)
//                               _summaryRow(
//                                 'Coupon Discount',
//                                 -couponDiscount,
//                                 theme,
//                                 isDiscount: true,
//                               ),
//                             const Divider(height: 18),
//                             _summaryRow(
//                               'Total Payable',
//                               totalPayable,
//                               theme,
//                               isTotal: true,
//                             ),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(height: 20),
//                     ],
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 12),

//               // 🚀 WHATSAPP BUTTON
//               GestureDetector(
//      onTap: () {
//     final supportPhone = context.read<CredentialProvider>().getWhatsappByType('user');
    
//     if (supportPhone != null && supportPhone.isNotEmpty) {
//       final orderIdText = order.id ?? "N/A";
//       final message =
//           "Hello Vegiffy Support,\n\nI need help with my order.\nOrder ID: $orderIdText\n\nPlease assist me.";

//       openWhatsApp(supportPhone, message: message);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Support contact not available'),
//           backgroundColor: Theme.of(context).colorScheme.error,
//         ),
//       );
//     }
//   },
//                 child: Container(
//                   width: double.infinity,
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 14),
//                   decoration: BoxDecoration(
//                     color: Colors.green.shade600,
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Image.asset(
//                         'assets/images/wattsapp.png',
//                         width: 22,
//                         height: 22,
//                       ),
//                       const SizedBox(width: 8),
//                       const Text(
//                         "Contact Support on WhatsApp",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 15,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 8),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _summaryRow(
//     String label,
//     double amount,
//     ThemeData theme, {
//     bool isDiscount = false,
//     bool isTotal = false,
//   }) {
//     final color = isTotal
//         ? theme.colorScheme.primary
//         : isDiscount
//             ? Colors.red
//             : theme.colorScheme.onSurface.withOpacity(0.8);

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: theme.textTheme.bodySmall?.copyWith(
//               fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
//             ),
//           ),
//           Text(
//             '${isDiscount ? '-' : ''}₹${amount.abs().toStringAsFixed(2)}',
//             style: theme.textTheme.bodySmall?.copyWith(
//               fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _handleBackButton() {
//     Navigator.of(context).pushAndRemoveUntil(
//       MaterialPageRoute(
//         builder: (context) => const NavbarScreen(),
//       ),
//       (route) => false,
//     );

//     Provider.of<BottomNavbarProvider>(context, listen: false).setIndex(0);
//   }

//   String _normalizeImageUrl(String? raw) {
//     if (raw == null) return '';
//     final s = raw.trim();
//     if (s.isEmpty) return '';
//     if (s.startsWith('http://') || s.startsWith('https://')) return s;
//     if (s.startsWith('/')) {
//       return '$_apiHost$s';
//     } else {
//       return '$_apiHost/$s';
//     }
//   }

//   // ---------- INVOICE DOWNLOAD USING Order MODEL ----------

//   Future<void> _downloadInvoice(Order orderModel) async {
//     final theme = Theme.of(context);

//     try {
//       // 1) Build Veegify HTML
//       final htmlContent = buildInvoiceHtml(orderModel);
//       debugPrint("Invoice HTML: $htmlContent");

//       // await Printing.layoutPdf(
//       //   onLayout: (PdfPageFormat format) async {
//       //     final pdfBytes = await Printing.convertHtml(
//       //       format: format,
//       //       html: htmlContent,
//       //     );
//       //     return pdfBytes;
//       //   },
//       // );
//     } catch (e, st) {
//       debugPrint('Invoice error: $e\n$st');
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to download invoice: $e'),
//           backgroundColor: theme.colorScheme.error,
//         ),
//       );
//     }
//   }

//   Widget _buildOrderCard(Order order) {
//     final theme = Theme.of(context);
//     final isDarkMode = theme.brightness == Brightness.dark;

//     final products = order.products;
//     final mainProduct = products.isNotEmpty ? products.first : null;
//     final rawImageUrl =
//         mainProduct != null ? (mainProduct.image ?? '') : '';
//     final imageUrl = _normalizeImageUrl(rawImageUrl.toString());
//     final name = mainProduct != null ? mainProduct.name : 'Item';
//     final price = mainProduct != null ? mainProduct.price : 0.0;

//     final restaurantName = order.restaurant.restaurantName;

//     final orderStatusRaw = order.orderStatus;
//     final deliveryStatusRaw = order.deliveryStatus;
//     final statusLower = orderStatusRaw.toLowerCase();
//     final deliveryLower = deliveryStatusRaw.toLowerCase();

//     final isDelivered = statusLower.contains('delivered') ||
//         statusLower.contains('completed') ||
//         deliveryLower.contains('delivered');

//     final chipText = isDelivered
//         ? 'Delivered'
//         : (deliveryStatusRaw.isNotEmpty
//             ? deliveryStatusRaw
//             : orderStatusRaw);

//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       decoration: BoxDecoration(
//         color: theme.cardColor,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: theme.dividerColor.withOpacity(0.3),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color:
//                 Colors.black.withOpacity(isDarkMode ? 0.1 : 0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             // Left side text content
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     name,
//                     style: theme.textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     '₹${price.toStringAsFixed(2)}',
//                     style: theme.textTheme.bodyLarge?.copyWith(
//                       fontWeight: FontWeight.w600,
//                       color: theme.colorScheme.primary,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   if (restaurantName.isNotEmpty) ...[
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.restaurant,
//                           size: 14,
//                           color: theme.colorScheme.onSurface
//                               .withOpacity(0.6),
//                         ),
//                         const SizedBox(width: 4),
//                         Expanded(
//                           child: Text(
//                             restaurantName,
//                             style: theme.textTheme.bodySmall?.copyWith(
//                               color: theme.colorScheme.onSurface
//                                   .withOpacity(0.6),
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 6),
//                   ],
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: isDelivered
//                           ? Colors.green.withOpacity(0.08)
//                           : Colors.orange.withOpacity(0.08),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       chipText,
//                       style: TextStyle(
//                         color: isDelivered ? Colors.green : Colors.orange,
//                         fontWeight: FontWeight.w600,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 12),

//                   Row(
//                     children: [
//                       // View items button
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () => _viewOrderDetails(order),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: theme.colorScheme.primary,
//                             foregroundColor:
//                                 theme.colorScheme.onPrimary,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             padding:
//                                 const EdgeInsets.symmetric(vertical: 8),
//                           ),
//                           child: Text(
//                             'View Items',
//                             style:
//                                 theme.textTheme.bodyMedium?.copyWith(
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ),

//                       // Invoice button (only if delivered)
//                       if (isDelivered) ...[
//                         const SizedBox(width: 8),
//                         OutlinedButton.icon(
//                           onPressed: () => _downloadInvoice(order),
//                           style: OutlinedButton.styleFrom(
//                             side: BorderSide(
//                               color: theme.colorScheme.primary,
//                             ),
//                             foregroundColor: theme.colorScheme.primary,
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 10,
//                               vertical: 8,
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           icon: const Icon(
//                             Icons.download_rounded,
//                             size: 18,
//                           ),
//                           label: Text(
//                             'Invoice',
//                             style: theme.textTheme.bodySmall?.copyWith(
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(width: 16),

//             // Right side image
//             Container(
//               width: 120,
//               height: 140,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(12),
//                 image: DecorationImage(
//                   image: imageUrl.isNotEmpty
//                       ? NetworkImage(imageUrl)
//                       : const AssetImage('assets/placeholder.png')
//                           as ImageProvider,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBody() {
//     final theme = Theme.of(context);

//     if (_loading) {
//       return Center(
//         child: CircularProgressIndicator(
//           valueColor:
//               AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
//         ),
//       );
//     }

//     if (_error != null) {
//       return Center(
//         child:
//             _buildNetworkErrorWidget(_lastError ?? _error!, _fetchPreviousOrders),
//       );
//     }

//     if (_orders.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.receipt_long,
//               size: 80,
//               color: theme.colorScheme.onSurface.withOpacity(0.3),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'No previous orders',
//               style: theme.textTheme.titleMedium?.copyWith(
//                 color: theme.colorScheme.onSurface.withOpacity(0.5),
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     final isMobile = Responsive.isMobile(context);
//     final isTablet = Responsive.isTablet(context);
//     final isDesktop = Responsive.isDesktop(context);

//     final double maxWidth =
//         isDesktop ? 900 : (isTablet ? 700 : double.infinity);

//     return Center(
//       child: ConstrainedBox(
//         constraints: BoxConstraints(maxWidth: maxWidth),
//         child: ListView.builder(
//           controller: widget.scrollController,
//           padding: EdgeInsets.fromLTRB(
//             16,
//             16,
//             16,
//             isMobile ? 80 : 32,
//           ),
//           itemCount: _orders.length,
//           itemBuilder: (context, index) {
//             final order = _orders[index];
//             return _buildOrderCard(order);
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildNetworkErrorWidget(Object error, VoidCallback onRetry) {
//     final theme = Theme.of(context);
//     final isNetwork = error is SocketException ||
//         (error is HttpException) ||
//         error.toString().toLowerCase().contains('socket') ||
//         error
//             .toString()
//             .toLowerCase()
//             .contains('failed host lookup') ||
//         error.toString().toLowerCase().contains('network');

//     return Container(
//       padding: const EdgeInsets.all(20),
//       margin: const EdgeInsets.symmetric(horizontal: 20),
//       decoration: BoxDecoration(
//         color: theme.cardColor,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             isNetwork ? Icons.wifi_off : Icons.folder_off,
//             size: 64,
//             color: theme.colorScheme.onSurface.withOpacity(0.3),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             isNetwork ? "No Internet Connection" : "",
//             style: theme.textTheme.titleMedium?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             isNetwork
//                 ? "Please check your internet connection and try again."
//                 : error.toString(),
//             textAlign: TextAlign.center,
//             style: theme.textTheme.bodyMedium?.copyWith(
//               color:
//                   theme.colorScheme.onSurface.withOpacity(0.6),
//             ),
//           ),
//           // If you want retry / close buttons, you already have them commented.
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       appBar: AppBar(
//         title: Text(
//           'Previous Orders',
//           style: theme.textTheme.titleLarge?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back,
//             color: theme.colorScheme.onSurface,
//           ),
//           onPressed: _handleBackButton,
//         ),
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//       ),
//       body: SafeArea(child: _buildBody()),
//     );
//   }
// }

























import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:veegify/helper/storage_helper.dart';
import 'package:veegify/model/previous_order.dart';
import 'package:veegify/model/user_model.dart';
import 'package:veegify/provider/AuthProvider/auth_provider.dart';
import 'package:veegify/provider/Credential/credential_provider.dart';
import 'package:veegify/utils/previous_order.dart';
import 'package:veegify/views/ProfileScreen/help_screen.dart';
import 'package:veegify/views/Booking/booking_screen.dart';
import 'package:veegify/views/address/address_list.dart';
import 'package:veegify/views/home/invoice_screen.dart';
import 'package:veegify/views/Navbar/navbar_screen.dart';
import 'package:veegify/views/ProfileScreen/refer_earn_screen.dart';
import 'package:veegify/widgets/bottom_navbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

// ↓↓↓ INVOICE RELATED ↓↓↓
// import 'package:printing/printing.dart';
// import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
// ↑↑↑ INVOICE RELATED ↑↑↑

import 'package:veegify/utils/responsive.dart'; // ✅ responsive util

class HystoryScreenWithController extends StatelessWidget {
  final ScrollController scrollController;

  const HystoryScreenWithController({
    super.key,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return HystoryScreen(scrollController: scrollController);
  }
}

class HystoryScreen extends StatefulWidget {
  final ScrollController? scrollController;

  const HystoryScreen({super.key, this.scrollController});

  @override
  State<HystoryScreen> createState() => _HystoryScreenState();
}

class _HystoryScreenState extends State<HystoryScreen> {
  User? user;
  String? imageUrl;
  bool _loading = true;
  String? _error;
  Object? _lastError;

  // ✅ typed Order list
  List<Order> _orders = [];

  final Map<String, bool> _favorites = {}; // Track favorites by product ID

  static const String _apiHost = "https://api.vegiffyy.com";

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await _loadUserId();
      await _fetchUserProfile();
      await _fetchPreviousOrders();
    } catch (e, st) {
      debugPrint('Initialization error: $e\n$st');
      setState(() {
        _lastError = e;
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _loadUserId() async {
    final userData = UserPreferences.getUser();
    if (userData != null) {
      setState(() {
        user = userData;
      });
    }
  }

  Future<void> _fetchUserProfile() async {
    if (user == null) return;
    try {
      final url = Uri.parse("$_apiHost/api/usersprofile/${user!.userId}");
      debugPrint("Profile URL: $url");
      final response = await http.get(url);
      debugPrint("Profile Response : ${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userData = data['user'];

        setState(() {
          imageUrl = userData['profileImg'] ?? '';
          user = User(
            userId: userData['_id'],
            fullName: userData['fullName'] ?? '',
            email: userData['email'] ?? '',
            phoneNumber: userData['phoneNumber'] ?? '',
            profileImg: userData['profileImg'] ?? '',
          );
        });

        debugPrint("✅ Profile fetched successfully");
      } else {
        debugPrint("❌ Failed to fetch profile: ${response.statusCode}");
      }
    } catch (e, st) {
      debugPrint("Error fetching profile: $e\n$st");
      setState(() {
        _lastError = e;
        _error = e.toString();
      });
    }
  }

  Future<void> _fetchPreviousOrders() async {
    if (user == null) {
      debugPrint("User is null; skipping previous orders fetch.");
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _lastError = null;
    });

    try {
      final url =
          Uri.parse("$_apiHost/api/userpreviousorders/${user!.userId}");
      final response = await http.get(url);

      debugPrint("Orders response: ${response.statusCode} -> ${response.body}");

      if (response.statusCode == 200) {
        final List<Order> orders = ordersFromApiResponse(response.body);

        setState(() {
          _orders = orders;
          if (_orders.isEmpty) {
            _error = "No orders found";
          }
        });
      } else {
        setState(() {
          _orders = [];
          _error = "Failed to fetch orders (${response.statusCode})";
        });
      }
    } on SocketException catch (e) {
      debugPrint("SocketException fetching previous orders: $e");
      setState(() {
        _orders = [];
        _lastError = e;
        _error = "Network error: Please check your internet connection.";
      });
    } catch (e, st) {
      debugPrint("Error fetching previous orders: $e\n$st");
      setState(() {
        _orders = [];
        _lastError = e;
        _error = "Error fetching orders: $e";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _toggleFavorite(String productId) {
    setState(() {
      _favorites[productId] = !(_favorites[productId] ?? false);
    });
    // TODO: call API for favorite/unfavorite if needed
  }

  void _viewOrderDetails(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildOrderDetailSheet(order),
    );
  }

  Widget _buildOrderDetailSheet(Order order) {
    final theme = Theme.of(context);
    final products = order.products;

    final subTotal = order.subTotal;
    final gstAmount = order.gstAmount ?? 0;
    final platformCharge = order.platformCharge ?? 0;
    final deliveryCharge = order.deliveryCharge;
    final packingCharge = order.packingCharges;
    final deliveryGst = order.gstOnDelivery;

    final couponDiscount = order.couponDiscount;
    final totalPayable = order.totalPayable;

    Future<void> openWhatsApp(String phoneNumber,
        {String message = ""}) async {
      // Remove spaces and ensure only digits
      String cleanedNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');

      // If number is missing country code, add +91 by default
      if (!cleanedNumber.startsWith("91") && cleanedNumber.length == 10) {
        cleanedNumber = "91$cleanedNumber";
      }

      final String encodedMessage = Uri.encodeComponent(message);
      final String url = "https://wa.me/$cleanedNumber?text=$encodedMessage";

      final Uri uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw "Could not launch WhatsApp";
      }
    }

    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final isDesktop = Responsive.isDesktop(context);

    final double maxWidth =
        isDesktop ? 520 : (isTablet ? 480 : double.infinity);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Order Items',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // SCROLLABLE CONTENT
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...products.map((product) {
                        final price = product.price;
                        final quantity = product.quantity;
                        final lineTotal = price * quantity;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                theme.colorScheme.surface.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.dividerColor.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              // IMAGE
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: _normalizeImageUrl(
                                                product.image?.toString())
                                            .isNotEmpty
                                        ? NetworkImage(_normalizeImageUrl(
                                            product.image?.toString()))
                                        : const AssetImage(
                                                'assets/placeholder.png')
                                            as ImageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // INFO
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: theme
                                          .textTheme.bodyMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${product.quantity} x ₹${price.toStringAsFixed(2)}',
                                      style: theme
                                          .textTheme.bodySmall
                                          ?.copyWith(
                                        color: theme
                                            .colorScheme.onSurface
                                            .withOpacity(0.6),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Total: ₹${lineTotal.toStringAsFixed(2)}',
                                      style: theme
                                          .textTheme.bodySmall
                                          ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: theme
                                            .colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),

                      const SizedBox(height: 16),

                      // ORDER SUMMARY
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary
                              .withOpacity(0.04),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.primary
                                .withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            _summaryRow('Items Total', subTotal, theme),
                            _summaryRow('GST', gstAmount, theme),
                            _summaryRow(
                                'Platform Charge', platformCharge, theme),
                            _summaryRow(
                                'Delivery Charge', deliveryCharge, theme),
                            _summaryRow(
                                'Packing Charge', packingCharge, theme),
                            _summaryRow(
                                'Delivery Gst Charge', deliveryGst, theme),
                            if (couponDiscount > 0)
                              _summaryRow(
                                'Coupon Discount',
                                -couponDiscount,
                                theme,
                                isDiscount: true,
                              ),
                            const Divider(height: 18),
                            _summaryRow(
                              'Total Payable',
                              totalPayable,
                              theme,
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 🚀 WHATSAPP BUTTON
              GestureDetector(
                onTap: () {
                  final supportPhone = context.read<CredentialProvider>().getWhatsappByType('user');
                  
                  if (supportPhone != null && supportPhone.isNotEmpty) {
                    final orderIdText = order.id ?? "N/A";
                    final message =
                        "Hello Vegiffy Support,\n\nI need help with my order.\nOrder ID: $orderIdText\n\nPlease assist me.";

                    openWhatsApp(supportPhone, message: message);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Support contact not available'),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/wattsapp.png',
                        width: 22,
                        height: 22,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Contact Support on WhatsApp",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(
    String label,
    double amount,
    ThemeData theme, {
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    final color = isTotal
        ? theme.colorScheme.primary
        : isDiscount
            ? Colors.red
            : theme.colorScheme.onSurface.withOpacity(0.8);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          Text(
            '${isDiscount ? '-' : ''}₹${amount.abs().toStringAsFixed(2)}',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _handleBackButton() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const NavbarScreen(),
      ),
      (route) => false,
    );

    Provider.of<BottomNavbarProvider>(context, listen: false).setIndex(0);
  }

  String _normalizeImageUrl(String? raw) {
    if (raw == null) return '';
    final s = raw.trim();
    if (s.isEmpty) return '';
    if (s.startsWith('http://') || s.startsWith('https://')) return s;
    if (s.startsWith('/')) {
      return '$_apiHost$s';
    } else {
      return '$_apiHost/$s';
    }
  }

  // ---------- INVOICE DOWNLOAD USING Order MODEL ----------

  Future<void> _downloadInvoice(Order orderModel) async {
    final theme = Theme.of(context);

    try {
      // 1) Build Veegify HTML
      final htmlContent = buildInvoiceHtml(orderModel);
      debugPrint("Invoice HTML: $htmlContent");

      // await Printing.layoutPdf(
      //   onLayout: (PdfPageFormat format) async {
      //     final pdfBytes = await Printing.convertHtml(
      //       format: format,
      //       html: htmlContent,
      //     );
      //     return pdfBytes;
      //   },
      // );
    } catch (e, st) {
      debugPrint('Invoice error: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download invoice: $e'),
          backgroundColor: theme.colorScheme.error,
        ),
      );
    }
  }

  Widget _buildBody() {
    final theme = Theme.of(context);
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final isDesktop = Responsive.isDesktop(context);

    if (_loading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor:
              AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: _buildNetworkErrorWidget(_lastError ?? _error!, _fetchPreviousOrders),
      );
    }

    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: isDesktop ? 100 : 80,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No previous orders',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                fontSize: isDesktop ? 20 : 16,
              ),
            ),
            if (isDesktop) ...[
              const SizedBox(height: 8),
              Text(
                'Your order history will appear here',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
            ],
          ],
        ),
      );
    }

    final double maxWidth = isDesktop ? 1200 : (isTablet ? 900 : double.infinity);
    final double horizontalPadding = isDesktop ? 32 : (isTablet ? 24 : 16);

    return RefreshIndicator(
      onRefresh: _fetchPreviousOrders,
      color: theme.colorScheme.primary,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: CustomScrollView(
            controller: widget.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Header for web
              if (isDesktop) ...[
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(horizontalPadding, 24, horizontalPadding, 16),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.history,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order History',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_orders.length} ${_orders.length == 1 ? 'order' : 'orders'} placed',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _fetchPreviousOrders,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Orders grid/list
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  isDesktop ? 8 : 16,
                  horizontalPadding,
                  isMobile ? 80 : 32,
                ),
                sliver: isDesktop
                    ? SliverGrid(
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 500,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 1.2,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final order = _orders[index];
                            return _buildOrderCardWeb(order);
                          },
                          childCount: _orders.length,
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final order = _orders[index];
                            return _buildOrderCard(order);
                          },
                          childCount: _orders.length,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Mobile/Tablet Order Card (existing)
  Widget _buildOrderCard(Order order) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final products = order.products;
    final mainProduct = products.isNotEmpty ? products.first : null;
    final rawImageUrl =
        mainProduct != null ? (mainProduct.image ?? '') : '';
    final imageUrl = _normalizeImageUrl(rawImageUrl.toString());
    final name = mainProduct != null ? mainProduct.name : 'Item';
    final price = mainProduct != null ? mainProduct.price : 0.0;

    final restaurantName = order.restaurant.restaurantName;

    final orderStatusRaw = order.orderStatus;
    final deliveryStatusRaw = order.deliveryStatus;
    final statusLower = orderStatusRaw.toLowerCase();
    final deliveryLower = deliveryStatusRaw.toLowerCase();

    final isDelivered = statusLower.contains('delivered') ||
        statusLower.contains('completed') ||
        deliveryLower.contains('delivered');

    final chipText = isDelivered
        ? 'Delivered'
        : (deliveryStatusRaw.isNotEmpty
            ? deliveryStatusRaw
            : orderStatusRaw);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.1 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Left side text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₹${price.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (restaurantName.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.restaurant,
                          size: 14,
                          color: theme.colorScheme.onSurface
                              .withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            restaurantName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withOpacity(0.6),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDelivered
                          ? Colors.green.withOpacity(0.08)
                          : Colors.orange.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      chipText,
                      style: TextStyle(
                        color: isDelivered ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      // View items button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _viewOrderDetails(order),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor:
                                theme.colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding:
                                const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: Text(
                            'View Items',
                            style:
                                theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      // Invoice button (only if delivered)
                      if (isDelivered) ...[
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () => _downloadInvoice(order),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: theme.colorScheme.primary,
                            ),
                            foregroundColor: theme.colorScheme.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(
                            Icons.download_rounded,
                            size: 18,
                          ),
                          label: Text(
                            'Invoice',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Right side image
            Container(
              width: 100,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: imageUrl.isNotEmpty
                      ? NetworkImage(imageUrl)
                      : const AssetImage('assets/placeholder.png')
                          as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Web Professional Order Card
  Widget _buildOrderCardWeb(Order order) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final products = order.products;
    final mainProduct = products.isNotEmpty ? products.first : null;
    final rawImageUrl =
        mainProduct != null ? (mainProduct.image ?? '') : '';
    final imageUrl = _normalizeImageUrl(rawImageUrl.toString());
    final name = mainProduct != null ? mainProduct.name : 'Item';
    final price = mainProduct != null ? mainProduct.price : 0.0;

    final restaurantName = order.restaurant.restaurantName;
    final orderDate = order.createdAt ?? DateTime.now();
    final formattedDate = '${orderDate.day}/${orderDate.month}/${orderDate.year}';

    final orderStatusRaw = order.orderStatus;
    final deliveryStatusRaw = order.deliveryStatus;
    final statusLower = orderStatusRaw.toLowerCase();
    final deliveryLower = deliveryStatusRaw.toLowerCase();

    final isDelivered = statusLower.contains('delivered') ||
        statusLower.contains('completed') ||
        deliveryLower.contains('delivered');

    final chipText = isDelivered
        ? 'Delivered'
        : (deliveryStatusRaw.isNotEmpty
            ? deliveryStatusRaw
            : orderStatusRaw);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: theme.dividerColor.withOpacity(0.2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with date and status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.receipt_outlined,
                      color: theme.colorScheme.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.id?.substring(0,5)}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formattedDate,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDelivered
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isDelivered ? Icons.check_circle : Icons.pending,
                          size: 14,
                          color: isDelivered ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          chipText,
                          style: TextStyle(
                            color: isDelivered ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Product info row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: theme.colorScheme.surface,
                          child: Icon(
                            Icons.image_not_supported,
                            color: theme.colorScheme.onSurface.withOpacity(0.3),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Product details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (restaurantName.isNotEmpty) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.store,
                                size: 14,
                                color: theme.colorScheme.onSurface.withOpacity(0.5),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                restaurantName,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          '₹${price.toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Total and actions
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      Text(
                        '₹${order.totalPayable.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _viewOrderDetails(order),
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('View Details'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (isDelivered)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _downloadInvoice(order),
                        icon: const Icon(Icons.download, size: 18),
                        label: const Text('Invoice'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final supportPhone = context.read<CredentialProvider>().getWhatsappByType('user');
                          if (supportPhone != null) {
                            final message = "Hello, I need help with my order #${order.id}";
                            launchUrl(Uri.parse("https://wa.me/$supportPhone?text=${Uri.encodeComponent(message)}"));
                          }
                        },
                        icon: Image.asset(
                          'assets/images/wattsapp.png',
                          width: 18,
                          height: 18,
                        ),
                        label: const Text('Support'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkErrorWidget(Object error, VoidCallback onRetry) {
    final theme = Theme.of(context);
    final isNetwork = error is SocketException ||
        (error is HttpException) ||
        error.toString().toLowerCase().contains('socket') ||
        error.toString().toLowerCase().contains('failed host lookup') ||
        error.toString().toLowerCase().contains('network');
    final isDesktop = Responsive.isDesktop(context);

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isNetwork ? Icons.wifi_off : Icons.folder_off,
            size: isDesktop ? 80 : 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            isNetwork ? "No Internet Connection" : "",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isDesktop ? 20 : 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isNetwork
                ? "Please check your internet connection and try again."
                : error.toString(),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontSize: isDesktop ? 16 : 14,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 24 : 20,
                    vertical: isDesktop ? 14 : 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          isDesktop ? 'Order History' : 'Previous Orders',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: _handleBackButton,
        ),
        elevation: isDesktop ? 1 : 0,
        backgroundColor: isDesktop ? theme.cardColor : Colors.transparent,
        centerTitle: isDesktop,
      ),
      body: SafeArea(child: _buildBody()),
    );
  }
}