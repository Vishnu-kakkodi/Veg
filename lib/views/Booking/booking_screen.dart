// // lib/screens/booking_screen.dart
// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
// import 'package:veegify/model/order.dart';
// import 'package:veegify/provider/BookingProvider/booking_provider.dart';
// import 'package:http/http.dart' as http;
// import 'package:veegify/utils/web_invoice.dart';
// import 'package:veegify/views/Booking/accepted_order_polling_screen.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:open_filex/open_filex.dart';
// import 'package:veegify/utils/invoice_html_builder.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:flutter/foundation.dart';


// class BookingScreen extends StatefulWidget {
//   final String? userId;

//   const BookingScreen({super.key, required this.userId});

//   @override
//   State<BookingScreen> createState() => _BookingScreenState();
// }

// class _BookingScreenState extends State<BookingScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   late OrderProvider _orderProvider;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _orderProvider = Provider.of<OrderProvider>(context, listen: false);
//       _orderProvider.loadAllOrders(widget.userId.toString());
//     });
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

// Future<void> _downloadInvoice(Order order) async {
//   final theme = Theme.of(context);

//   try {
//     final htmlContent = buildInvoiceHtml(order);

//     if (kIsWeb) {
//       // 🌐 WEB: generate PDF and download
//   // openInvoiceHtml(htmlContent);
//   return;
//     } else {
//       // 📱 MOBILE: print / preview
//       // await Printing.layoutPdf(
//       //   onLayout: (PdfPageFormat format) async {
//       //     return Printing.convertHtml(
//       //       format: format,
//       //       html: htmlContent,
//       //     );
//       //   },
//       // );
//     }
//   } catch (e, st) {
//     debugPrint('Invoice error: $e\n$st');
//     if (!mounted) return;

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Failed to generate invoice'),
//         backgroundColor: theme.colorScheme.error,
//       ),
//     );
//   }
// }




//   Widget _buildList(List<Order> items) {
//     double maxWidth = MediaQuery.of(context).size.width >= 1200
//         ? 1000
//         : double.infinity;
//     double padding = MediaQuery.of(context).size.width >= 1200 ? 24 : 16;

//     if (items.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.receipt_long,
//               size: 80,
//               color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'No orders found',
//               style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                 color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return Center(
//       child: ConstrainedBox(
//         constraints: BoxConstraints(maxWidth: maxWidth),
//         child: ListView.separated(
//           padding: EdgeInsets.all(padding),
//           itemCount: items.length,
//           separatorBuilder: (_, __) => const SizedBox(height: 16),
//           itemBuilder: (context, index) {
//             final order = items[index];
//             return _buildModernBookingCard(order);
//           },
//         ),
//       ),
//     );
//   }


// Widget _buildModernBookingCard(Order order) {
//   final theme = Theme.of(context);
//   final isDarkMode = theme.brightness == Brightness.dark;
//   final screenWidth = MediaQuery.of(context).size.width;
//   final isWeb = screenWidth > 600; // Tablet/Web threshold
  
//   final firstProduct = order.products.isNotEmpty ? order.products.first : null;
//   final status = order.orderStatus.toLowerCase();

//   // Status colors with theme compatibility
//   Color statusColor;
//   Color statusBgColor;
//   IconData statusIcon;

//   switch (status) {
//     case 'pending':
//       statusColor = Colors.orange;
//       statusBgColor = Colors.orange.withOpacity(0.1);
//       statusIcon = Icons.access_time;
//       break;
//     case 'accepted':
//     case 'rider accepted':
//     case 'picked':
//       statusColor = Colors.blue;
//       statusBgColor = Colors.blue.withOpacity(0.1);
//       statusIcon = Icons.check_circle;
//       break;
//     case 'completed':
//     case 'delivered':
//       statusColor = Colors.green;
//       statusBgColor = Colors.green.withOpacity(0.1);
//       statusIcon = Icons.done_all;
//       break;
//     case 'cancelled':
//       statusColor = Colors.red;
//       statusBgColor = Colors.red.withOpacity(0.1);
//       statusIcon = Icons.cancel;
//       break;
//     default:
//       statusColor = Colors.grey;
//       statusBgColor = Colors.grey.withOpacity(0.1);
//       statusIcon = Icons.help;
//   }

//   final isCompletedOrDelivered = status == 'completed' || status == 'delivered';

//   return Container(
//     constraints: isWeb ? const BoxConstraints(maxWidth: 800) : null,
//     margin: isWeb ? const EdgeInsets.symmetric(horizontal: 16) : null,
//     decoration: BoxDecoration(
//       color: theme.cardColor,
//       borderRadius: BorderRadius.circular(20),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.08),
//           blurRadius: 12,
//           offset: const Offset(0, 4),
//         ),
//       ],
//     ),
//     child: Padding(
//       padding: EdgeInsets.all(isWeb ? 24 : 20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header with Restaurant Info
//           isWeb ? _buildWebHeader(theme, firstProduct, order, statusColor, statusBgColor, statusIcon)
//                 : _buildMobileHeader(theme, firstProduct, order, statusColor, statusBgColor, statusIcon),

//           SizedBox(height: isWeb ? 20 : 16),

//           // Order Items Preview
//           if (order.products.isNotEmpty) ...[
//             isWeb ? _buildWebOrderItems(theme, order)
//                   : _buildMobileOrderItems(theme, order),
//             SizedBox(height: isWeb ? 20 : 16),
//           ],

//           // Order Summary and Actions - Web Layout
//           if (isWeb)
//             _buildWebSummaryAndActions(theme, order, isCompletedOrDelivered, status)
//           else
//             // Mobile Layout
//             _buildMobileSummaryAndActions(theme, order, isCompletedOrDelivered, status),
//         ],
//       ),
//     ),
//   );
// }

// // Mobile Header
// Widget _buildMobileHeader(ThemeData theme, dynamic firstProduct, Order order, 
//     Color statusColor, Color statusBgColor, IconData statusIcon) {
//   return Row(
//     children: [
//       Container(
//         width: 50,
//         height: 50,
//         decoration: BoxDecoration(
//           color: theme.colorScheme.primary.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: firstProduct?.image != null
//             ? ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: Image.network(
//                   firstProduct!.image!,
//                   width: 50,
//                   height: 50,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) {
//                     return Icon(
//                       Icons.restaurant,
//                       color: theme.colorScheme.primary,
//                       size: 24,
//                     );
//                   },
//                 ),
//               )
//             : Icon(
//                 Icons.restaurant,
//                 color: theme.colorScheme.primary,
//                 size: 24,
//               ),
//       ),
//       const SizedBox(width: 12),
//       Expanded(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               order.restaurant.restaurantName,
//               style: theme.textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//             const SizedBox(height: 4),
//             Text(
//               order.restaurant.locationName,
//               style: theme.textTheme.bodySmall?.copyWith(
//                 color: theme.colorScheme.onSurface.withOpacity(0.6),
//               ),
//             ),
//           ],
//         ),
//       ),
//       Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//         decoration: BoxDecoration(
//           color: statusBgColor,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(statusIcon, size: 14, color: statusColor),
//             const SizedBox(width: 6),
//             Text(
//               order.orderStatus,
//               style: TextStyle(
//                 color: statusColor,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 12,
//               ),
//             ),
//           ],
//         ),
//       ),
//     ],
//   );
// }

// // Web Header
// Widget _buildWebHeader(ThemeData theme, dynamic firstProduct, Order order,
//     Color statusColor, Color statusBgColor, IconData statusIcon) {
//   return Row(
//     children: [
//       Container(
//         width: 70,
//         height: 70,
//         decoration: BoxDecoration(
//           color: theme.colorScheme.primary.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: firstProduct?.image != null
//             ? ClipRRect(
//                 borderRadius: BorderRadius.circular(16),
//                 child: Image.network(
//                   firstProduct!.image!,
//                   width: 70,
//                   height: 70,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) {
//                     return Icon(
//                       Icons.restaurant,
//                       color: theme.colorScheme.primary,
//                       size: 32,
//                     );
//                   },
//                 ),
//               )
//             : Icon(
//                 Icons.restaurant,
//                 color: theme.colorScheme.primary,
//                 size: 32,
//               ),
//       ),
//       const SizedBox(width: 20),
//       Expanded(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               order.restaurant.restaurantName,
//               style: theme.textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//             const SizedBox(height: 6),
//             Row(
//               children: [
//                 Icon(
//                   Icons.location_on_outlined,
//                   size: 16,
//                   color: theme.colorScheme.onSurface.withOpacity(0.6),
//                 ),
//                 const SizedBox(width: 4),
//                 Text(
//                   order.restaurant.locationName,
//                   style: theme.textTheme.bodyMedium?.copyWith(
//                     color: theme.colorScheme.onSurface.withOpacity(0.6),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//       Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: BoxDecoration(
//           color: statusBgColor,
//           borderRadius: BorderRadius.circular(24),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(statusIcon, size: 18, color: statusColor),
//             const SizedBox(width: 8),
//             Text(
//               order.orderStatus,
//               style: TextStyle(
//                 color: statusColor,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       ),
//     ],
//   );
// }

// // Mobile Order Items
// Widget _buildMobileOrderItems(ThemeData theme, Order order) {
//   return Container(
//     padding: const EdgeInsets.all(12),
//     decoration: BoxDecoration(
//       color: theme.colorScheme.surface.withOpacity(0.5),
//       borderRadius: BorderRadius.circular(12),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Order Items',
//           style: theme.textTheme.bodyMedium?.copyWith(
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         const SizedBox(height: 8),
//         ...order.products.take(2).map(
//           (product) => Padding(
//             padding: const EdgeInsets.symmetric(vertical: 4),
//             child: Row(
//               children: [
//                 Container(
//                   width: 4,
//                   height: 4,
//                   decoration: BoxDecoration(
//                     color: theme.colorScheme.primary,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     '${product.quantity}x ${product.name}',
//                     style: theme.textTheme.bodySmall,
//                   ),
//                 ),
//                 Text(
//                   '₹${(product.quantity * product.basePrice).toStringAsFixed(2)}',
//                   style: theme.textTheme.bodySmall?.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         if (order.products.length > 2)
//           Padding(
//             padding: const EdgeInsets.only(top: 4),
//             child: Text(
//               '+ ${order.products.length - 2} more items',
//               style: theme.textTheme.bodySmall?.copyWith(
//                 color: theme.colorScheme.onSurface.withOpacity(0.6),
//                 fontStyle: FontStyle.italic,
//               ),
//             ),
//           ),
//       ],
//     ),
//   );
// }

// // Web Order Items
// Widget _buildWebOrderItems(ThemeData theme, Order order) {
//   return Container(
//     padding: const EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       color: theme.colorScheme.surface.withOpacity(0.5),
//       borderRadius: BorderRadius.circular(16),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Order Items',
//           style: theme.textTheme.titleSmall?.copyWith(
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         const SizedBox(height: 12),
//         ...order.products.take(3).map(
//           (product) => Padding(
//             padding: const EdgeInsets.symmetric(vertical: 6),
//             child: Row(
//               children: [
//                 Container(
//                   width: 6,
//                   height: 6,
//                   decoration: BoxDecoration(
//                     color: theme.colorScheme.primary,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   flex: 3,
//                   child: Text(
//                     product.name,
//                     style: theme.textTheme.bodyMedium,
//                   ),
//                 ),
//                 Expanded(
//                   child: Text(
//                     'Qty: ${product.quantity}',
//                     style: theme.textTheme.bodyMedium?.copyWith(
//                       color: theme.colorScheme.onSurface.withOpacity(0.7),
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//                 Expanded(
//                   child: Text(
//                     '₹${(product.quantity * product.basePrice).toStringAsFixed(2)}',
//                     style: theme.textTheme.bodyMedium?.copyWith(
//                       fontWeight: FontWeight.w600,
//                     ),
//                     textAlign: TextAlign.right,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         if (order.products.length > 3)
//           Padding(
//             padding: const EdgeInsets.only(top: 8),
//             child: Text(
//               '+ ${order.products.length - 3} more items',
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 color: theme.colorScheme.onSurface.withOpacity(0.6),
//                 fontStyle: FontStyle.italic,
//               ),
//             ),
//           ),
//       ],
//     ),
//   );
// }

// // Mobile Summary and Actions
// Widget _buildMobileSummaryAndActions(ThemeData theme, Order order,
//     bool isCompletedOrDelivered, String status) {
//   return Column(
//     children: [
//       // Order Summary
//       Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               theme.colorScheme.primary.withOpacity(0.05),
//               theme.colorScheme.primary.withOpacity(0.1),
//             ],
//           ),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: theme.colorScheme.primary.withOpacity(0.2),
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Total Amount',
//                   style: theme.textTheme.bodySmall?.copyWith(
//                     color: theme.colorScheme.onSurface.withOpacity(0.7),
//                   ),
//                 ),
//                 Text(
//                   '₹${order.totalPayable.toStringAsFixed(2)}',
//                   style: theme.textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: theme.colorScheme.primary,
//                   ),
//                 ),
//               ],
//             ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text(
//                   '${order.totalItems} items',
//                   style: theme.textTheme.bodySmall?.copyWith(
//                     color: theme.colorScheme.onSurface.withOpacity(0.7),
//                   ),
//                 ),
//                 Text(
//                   order.createdAt == null
//                       ? 'N/A'
//                       : DateFormat('MMM dd, hh:mm a')
//                           .format(order.createdAt!.toLocal()),
//                   style: theme.textTheme.bodySmall?.copyWith(
//                     color: theme.colorScheme.onSurface.withOpacity(0.6),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//       const SizedBox(height: 16),
//       // Action Buttons
//       Row(
//         children: [
//           if (isCompletedOrDelivered) ...[
//             IconButton(
//               onPressed: () => _downloadInvoice(order),
//               tooltip: 'Download Invoice',
//               style: IconButton.styleFrom(
//                 backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
//                 foregroundColor: theme.colorScheme.primary,
//               ),
//               icon: const Icon(Icons.download_rounded),
//             ),
//             const SizedBox(width: 8),
//           ],
//           Expanded(
//             child: ElevatedButton(
//               onPressed: () => _handleViewDetails(order, status),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: theme.colorScheme.primary,
//                 foregroundColor: theme.colorScheme.onPrimary,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.remove_red_eye_outlined, size: 20),
//                   const SizedBox(width: 8),
//                   Text(
//                     'View Details',
//                     style: theme.textTheme.bodyMedium?.copyWith(
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           if (isCompletedOrDelivered) ...[
//             const SizedBox(width: 12),
//             ElevatedButton(
//               onPressed: () => _showReviewDialog(order),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.amber,
//                 foregroundColor: Colors.black,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 12,
//                   horizontal: 16,
//                 ),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Icon(Icons.star, size: 20),
//                   const SizedBox(width: 4),
//                   Text(
//                     'Review',
//                     style: theme.textTheme.bodyMedium?.copyWith(
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ],
//       ),
//     ],
//   );
// }

// // Web Summary and Actions
// Widget _buildWebSummaryAndActions(ThemeData theme, Order order,
//     bool isCompletedOrDelivered, String status) {
//   return Row(
//     children: [
//       // Order Summary - Takes more space on web
//       Expanded(
//         flex: 2,
//         child: Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 theme.colorScheme.primary.withOpacity(0.05),
//                 theme.colorScheme.primary.withOpacity(0.1),
//               ],
//             ),
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(
//               color: theme.colorScheme.primary.withOpacity(0.2),
//             ),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Total Amount',
//                     style: theme.textTheme.bodyMedium?.copyWith(
//                       color: theme.colorScheme.onSurface.withOpacity(0.7),
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     '₹${order.totalPayable.toStringAsFixed(2)}',
//                     style: theme.textTheme.headlineSmall?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: theme.colorScheme.primary,
//                     ),
//                   ),
//                 ],
//               ),
//               Column(
//                 children: [
//                   Text(
//                     'Total Items',
//                     style: theme.textTheme.bodyMedium?.copyWith(
//                       color: theme.colorScheme.onSurface.withOpacity(0.7),
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     '${order.totalItems}',
//                     style: theme.textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text(
//                     'Order Date',
//                     style: theme.textTheme.bodyMedium?.copyWith(
//                       color: theme.colorScheme.onSurface.withOpacity(0.7),
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     order.createdAt == null
//                         ? 'N/A'
//                         : DateFormat('MMM dd, hh:mm a')
//                             .format(order.createdAt!.toLocal()),
//                     style: theme.textTheme.bodyMedium?.copyWith(
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//       const SizedBox(width: 16),
//       // Action Buttons
//       Expanded(
//         child: Row(
//           children: [
//             if (isCompletedOrDelivered)
//               Expanded(
//                 child: ElevatedButton.icon(
//                   onPressed: () => _downloadInvoice(order),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
//                     foregroundColor: theme.colorScheme.primary,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                   ),
//                   icon: const Icon(Icons.download_rounded, size: 20),
//                   label: const Text('Invoice'),
//                 ),
//               ),
//             if (isCompletedOrDelivered) const SizedBox(width: 12),
//             Expanded(
//               flex: isCompletedOrDelivered ? 1 : 2,
//               child: ElevatedButton.icon(
//                 onPressed: () => _handleViewDetails(order, status),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: theme.colorScheme.primary,
//                   foregroundColor: theme.colorScheme.onPrimary,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                 ),
//                 icon: const Icon(Icons.remove_red_eye_outlined, size: 20),
//                 label: const Text('View Details'),
//               ),
//             ),
//             if (isCompletedOrDelivered) ...[
//               const SizedBox(width: 12),
//               Expanded(
//                 child: ElevatedButton.icon(
//                   onPressed: () => _showReviewDialog(order),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.amber,
//                     foregroundColor: Colors.black,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                   ),
//                   icon: const Icon(Icons.star, size: 20),
//                   label: const Text('Review'),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     ],
//   );
// }

// // Helper method for view details
// void _handleViewDetails(Order order, String status) {
//   if (status == 'pending' ||
//       status == 'rider accepted' ||
//       status == 'accepted' ||
//       status == 'picked') {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => AcceptedOrderPollingScreen(
//           userId: order.userId,
//           orderId: order.id,
//         ),
//       ),
//     );
//   } else {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Theme.of(context).cardColor,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(
//           top: Radius.circular(20),
//         ),
//       ),
//       builder: (_) => _buildOrderDetailSheet(order),
//     );
//   }
// }





//   void _showReviewDialog(Order order) {
//     showDialog(
//       context: context,
//       builder: (context) => ReviewDialog(
//         order: order,
//         userId: widget.userId!,
//         onReviewSubmitted: () {
//           _orderProvider.loadAllOrders(widget.userId.toString());
//         },
//       ),
//     );
//   }

//   Widget _buildOrderDetailSheet(Order order) {
//     final theme = Theme.of(context);

//     return Padding(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Center(
//             child: Container(
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: theme.colorScheme.onSurface.withOpacity(0.3),
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           Text(
//             'Order Details',
//             style: theme.textTheme.titleLarge?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 16),

//           // Make the content scrollable
//           Expanded(
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildDetailRow('Order ID', order.id, theme),
//                   _buildDetailRow(
//                     'Restaurant',
//                     order.restaurant.restaurantName,
//                     theme,
//                   ),
//                   _buildDetailRow(
//                     'Address',
//                     '${order.deliveryAddress.street}, ${order.deliveryAddress.city}',
//                     theme,
//                   ),
//                   _buildDetailRow(
//                     'Payment',
//                     '${order.paymentMethod} • ${order.paymentStatus}',
//                     theme,
//                   ),
//                   _buildDetailRow(
//                     'Total',
//                     '₹${order.totalPayable.toStringAsFixed(2)}',
//                     theme,
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Items Ordered',
//                     style: theme.textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   ...order.products.map(
//                     (p) => Container(
//                       margin: const EdgeInsets.only(bottom: 8),
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: theme.colorScheme.surface.withOpacity(0.5),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   p.name,
//                                   style: theme.textTheme.bodyMedium?.copyWith(
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                                 Text(
//                                   '${p.quantity} x ₹${p.basePrice.toStringAsFixed(2)}',
//                                   style: theme.textTheme.bodySmall?.copyWith(
//                                     color: theme.colorScheme.onSurface
//                                         .withOpacity(0.6),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Text(
//                             '₹${(p.quantity * p.basePrice).toStringAsFixed(2)}',
//                             style: theme.textTheme.bodyLarge?.copyWith(
//                               fontWeight: FontWeight.bold,
//                               color: theme.colorScheme.primary,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value, ThemeData theme) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 100,
//             child: Text(
//               label,
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 fontWeight: FontWeight.w600,
//                 color: theme.colorScheme.onSurface.withOpacity(0.7),
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final provider = Provider.of<OrderProvider>(context);
//     final isLoading = provider.state == OrdersState.loading;
//     final error = provider.error;
//         final screenWidth = MediaQuery.of(context).size.width;
//     final isWebLayout = screenWidth > 600;
//     final maxWidth = isWebLayout ? 1200.0 : double.infinity;
//     final contentPadding = isWebLayout ? 40.0 : 16.0;

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           icon: Icon(Icons.arrow_back_ios, color: theme.colorScheme.onSurface),
//         ),
//         centerTitle: true,
//         title: Text(
//           "My Orders",
//           style: theme.textTheme.titleLarge?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         elevation: 0,
//         backgroundColor: Colors.transparent,

//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(80),
//           child: Center(
//             child: ConstrainedBox(
//               constraints: BoxConstraints(
//                 maxWidth: MediaQuery.of(context).size.width >= 1200
//                     ? 1000
//                     : double.infinity,
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 child: TabBar(
//                   controller: _tabController,
//                   isScrollable: true,
//                   indicator: BoxDecoration(
//                     color: theme.colorScheme.primary,
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: theme.colorScheme.primary.withOpacity(0.3),
//                         blurRadius: 8,
//                         offset: const Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   indicatorSize: TabBarIndicatorSize.tab,
//                   indicatorColor: Colors.transparent,
//                   overlayColor: MaterialStateProperty.all(Colors.transparent),
//                   dividerColor: Colors.transparent,
//                   labelColor: theme.colorScheme.onPrimary,
//                   unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(
//                     0.7,
//                   ),
//                   labelPadding: const EdgeInsets.symmetric(horizontal: 12),
//                   tabs: [
//                     _buildTabItem(
//                       "Today",
//                       Icons.calendar_today,
//                       _tabController.index == 0,
//                       theme,
//                     ),
//                     _buildTabItem(
//                       "All Orders",
//                       Icons.receipt_long,
//                       _tabController.index == 1,
//                       theme,
//                     ),
//                     _buildTabItem(
//                       "Cancelled",
//                       Icons.cancel,
//                       _tabController.index == 2,
//                       theme,
//                     ),
//                   ],
//                   onTap: (i) => setState(() {}),
//                 ),
//               ),
//             ),
//           ),
//         ),

//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : error != null
//           ? Center(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(
//                     Icons.error_outline,
//                     size: 64,
//                     color: theme.colorScheme.error,
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Error loading orders',
//                     style: theme.textTheme.titleMedium?.copyWith(
//                       color: theme.colorScheme.error,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     error,
//                     textAlign: TextAlign.center,
//                     style: theme.textTheme.bodyMedium?.copyWith(
//                       color: theme.colorScheme.onSurface.withOpacity(0.6),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   ElevatedButton(
//                     onPressed: () =>
//                         provider.loadAllOrders(widget.userId.toString()),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: theme.colorScheme.primary,
//                       foregroundColor: theme.colorScheme.onPrimary,
//                     ),
//                     child: const Text('Try Again'),
//                   ),
//                 ],
//               ),
//             )
//           : TabBarView(
//               controller: _tabController,
//               children: [
//                 RefreshIndicator(
//                   onRefresh: () =>
//                       provider.loadAllOrders(widget.userId.toString()),
//                   child: _buildList(provider.todayOrders),
//                 ),
//                 RefreshIndicator(
//                   onRefresh: () =>
//                       provider.loadAllOrders(widget.userId.toString()),
//                   child: _buildList(provider.orders),
//                 ),
//                 RefreshIndicator(
//                   onRefresh: () =>
//                       provider.loadAllOrders(widget.userId.toString()),
//                   child: _buildList(provider.cancelledOrders),
//                 ),
//               ],
//             ),
//     );
//   }

//   Widget _buildTabItem(
//     String text,
//     IconData icon,
//     bool isSelected,
//     ThemeData theme,
//   ) {
//     return Tab(
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//         decoration: BoxDecoration(
//           color: isSelected ? theme.colorScheme.primary : theme.cardColor,
//           borderRadius: BorderRadius.circular(12),
//           border: isSelected ? null : Border.all(color: theme.dividerColor),
//           boxShadow: isSelected
//               ? [
//                   BoxShadow(
//                     color: theme.colorScheme.primary.withOpacity(0.3),
//                     blurRadius: 8,
//                     offset: const Offset(0, 3),
//                   ),
//                 ]
//               : [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 3,
//                     offset: const Offset(0, 1),
//                   ),
//                 ],
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               icon,
//               size: 18,
//               color: isSelected
//                   ? theme.colorScheme.onPrimary
//                   : theme.colorScheme.onSurface.withOpacity(0.7),
//             ),
//             const SizedBox(width: 8),
//             Text(
//               text,
//               style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 14,
//                 color: isSelected
//                     ? theme.colorScheme.onPrimary
//                     : theme.colorScheme.onSurface.withOpacity(0.7),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class ReviewDialog extends StatefulWidget {
//   final Order order;
//   final String userId;
//   final VoidCallback onReviewSubmitted;

//   /// Optional existing restaurant review info (for edit/delete use later).
//   final String? existingRestaurantReviewId;
//   final int? existingRestaurantRating;
//   final String? existingRestaurantComment;

//   const ReviewDialog({
//     super.key,
//     required this.order,
//     required this.userId,
//     required this.onReviewSubmitted,
//     this.existingRestaurantReviewId,
//     this.existingRestaurantRating,
//     this.existingRestaurantComment,
//   });

//   @override
//   State<ReviewDialog> createState() => _ReviewDialogState();
// }

// class _ReviewDialogState extends State<ReviewDialog> {
//   // Product review state (multi-product, your original logic)
//   final Map<String, Map<String, dynamic>> _selectedProducts = {};
//   bool _isSubmitting = false;

//   // Restaurant review state
//   int _restaurantRating = 0;
//   final TextEditingController _restaurantReviewController =
//       TextEditingController();
//   bool _isRestaurantSubmitting = false;
//   String? _restaurantReviewId; // if set => edit/delete

//   @override
//   void initState() {
//     super.initState();

//     // Initialize all products as unselected
//     for (final product in widget.order.products) {
//       _selectedProducts[product.id] = {
//         'selected': false,
//         'rating': 0,
//         'review': '',
//         'product': product,
//         'isSubmitting': false,
//       };
//     }

//     // Initialize restaurant review if existing
//     _restaurantReviewId = widget.existingRestaurantReviewId;
//     _restaurantRating = widget.existingRestaurantRating ?? 0;
//     _restaurantReviewController.text = widget.existingRestaurantComment ?? '';
//   }

//   // ---------- RESTAURANT REVIEW API CALLS ----------

//   Future<void> _submitRestaurantReview() async {
//     if (_restaurantRating == 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('Please rate the restaurant'),
//           backgroundColor: Theme.of(context).colorScheme.error,
//         ),
//       );
//       return;
//     }

//     setState(() {
//       _isRestaurantSubmitting = true;
//     });

//     try {
//       // Adjust this if your Order model exposes restaurantId differently
//       final restaurantId = widget.order.restaurant.id;

//       final uri = _restaurantReviewId == null
//           ? Uri.parse('https://api.vegiffyy.com/api/addrestureview')
//           : Uri.parse('https://api.vegiffyy.com/api/editrestureview');

//       final payload = {
//         "restaurantId": restaurantId,
//         "userId": widget.userId,
//         "stars": _restaurantRating,
//         "comment": _restaurantReviewController.text.trim(),
//         if (_restaurantReviewId != null) "reviewId": _restaurantReviewId,
//       };

//       final response = await (_restaurantReviewId == null
//           ? http.post(
//               uri,
//               headers: {'Content-Type': 'application/json'},
//               body: json.encode(payload),
//             )
//           : http.put(
//               uri,
//               headers: {'Content-Type': 'application/json'},
//               body: json.encode(payload),
//             ));

//       if (response.statusCode == 200) {
//         // Optionally, parse and update _restaurantReviewId from response if backend returns it.
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               _restaurantReviewId == null
//                   ? 'Restaurant review added successfully!'
//                   : 'Restaurant review updated successfully!',
//             ),
//             backgroundColor: Colors.green,
//           ),
//         );
//       } else {
//         throw Exception('Failed to submit restaurant review');
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error submitting restaurant review: $e'),
//             backgroundColor: Theme.of(context).colorScheme.error,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isRestaurantSubmitting = false;
//         });
//       }
//     }
//   }

//   Future<void> _deleteRestaurantReview() async {
//     if (_restaurantReviewId == null) return;

//     setState(() {
//       _isRestaurantSubmitting = true;
//     });

//     try {
//       final restaurantId = widget.order.restaurant.id;

//       final uri = Uri.parse('https://api.vegiffyy.com/api/deleterestureview');

//       final payload = {
//         "restaurantId": restaurantId,
//         "userId": widget.userId,
//         "reviewId": _restaurantReviewId,
//       };

//       final response = await http.delete(
//         uri,
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode(payload),
//       );

//       if (response.statusCode == 200) {
//         setState(() {
//           _restaurantReviewId = null;
//           _restaurantRating = 0;
//           _restaurantReviewController.clear();
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Restaurant review deleted'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       } else {
//         throw Exception('Failed to delete restaurant review');
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error deleting restaurant review: $e'),
//             backgroundColor: Theme.of(context).colorScheme.error,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isRestaurantSubmitting = false;
//         });
//       }
//     }
//   }

//   // ---------- PRODUCT REVIEWS (YOUR ORIGINAL MULTI-PRODUCT LOGIC) ----------

//   Future<void> _submitReviews() async {
//     // Check if at least one product is selected and rated
//     final selectedProducts = _selectedProducts.entries
//         .where((entry) => entry.value['selected'] == true)
//         .toList();

//     print("----- Selected Products -----");
//     for (final entry in selectedProducts) {
//       final product = entry.value['product'] as OrderProduct;
//       final rating = entry.value['rating'];
//       final review = entry.value['review'];

//       print("Product ID: ${product.recommendedId}");
//       print("Product Name: ${product.name}");
//       print("Rating: $rating");
//       print("Review: $review");
//       print("-----------------------------");
//     }

//     if (selectedProducts.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('Please select at least one product to review'),
//           backgroundColor: Theme.of(context).colorScheme.error,
//         ),
//       );
//       return;
//     }

//     // Check if all selected products have ratings
//     for (final entry in selectedProducts) {
//       if (entry.value['rating'] == 0) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Please rate ${entry.value['product'].name}'),
//             backgroundColor: Theme.of(context).colorScheme.error,
//           ),
//         );
//         return;
//       }
//     }

//     setState(() {
//       _isSubmitting = true;
//     });

//     bool allSuccessful = true;
//     int successfulCount = 0;

//     // Submit reviews for all selected products with separate API calls
//     for (final entry in selectedProducts) {
//       final product = entry.value['product'] as OrderProduct;
//       final rating = entry.value['rating'] as int;
//       final review = entry.value['review'] as String;

//       // Update individual product submitting state
//       setState(() {
//         _selectedProducts[product.id]?['isSubmitting'] = true;
//       });

//       try {
//         print("ProductId:${product.recommendedId}, UserId:${widget.userId}");

//         final response = await http.post(
//           Uri.parse('https://api.vegiffyy.com/api/addreview'),
//           headers: {'Content-Type': 'application/json'},
//           body: json.encode({
//             "productId": product.recommendedId,
//             "userId": widget.userId,
//             "stars": rating,
//             "comment": review.trim(),
//           }),
//         );

//         print("Product review response: ${response.body}");

//         if (response.statusCode == 200) {
//           successfulCount++;
//           // Mark as submitted
//           setState(() {
//             _selectedProducts[product.id]?['selected'] = false;
//           });
//         } else {
//           allSuccessful = false;
//           throw Exception('Failed to submit review for ${product.name}');
//         }
//       } catch (e) {
//         allSuccessful = false;
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Error submitting review for ${product.name}: $e'),
//               backgroundColor: Theme.of(context).colorScheme.error,
//             ),
//           );
//         }
//       } finally {
//         if (mounted) {
//           setState(() {
//             _selectedProducts[product.id]?['isSubmitting'] = false;
//           });
//         }
//       }
//     }

//     setState(() {
//       _isSubmitting = false;
//     });

//     if (mounted) {
//       if (allSuccessful) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               '$successfulCount review${successfulCount > 1 ? 's' : ''} submitted successfully!',
//             ),
//             backgroundColor: Colors.green,
//           ),
//         );
//         widget.onReviewSubmitted();
//         Navigator.of(context).pop();
//       } else if (successfulCount > 0) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               '$successfulCount review${successfulCount > 1 ? 's' : ''} submitted, but some failed',
//             ),
//             backgroundColor: Colors.orange,
//           ),
//         );
//         // Don't close the dialog if some failed, let user retry
//       }
//     }
//   }

//   void _toggleProductSelection(String productId) {
//     setState(() {
//       final current = _selectedProducts[productId]?['selected'] == true;
//       _selectedProducts[productId]?['selected'] = !current;
//     });
//   }

//   void _updateProductRating(String productId, int rating) {
//     setState(() {
//       _selectedProducts[productId]?['rating'] = rating;
//     });
//   }

//   void _updateProductReview(String productId, String review) {
//     setState(() {
//       _selectedProducts[productId]?['review'] = review;
//     });
//   }

//   bool get _hasSelectedProducts {
//     return _selectedProducts.entries.any(
//       (entry) => entry.value['selected'] == true,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isWeb = screenWidth > 600;
    
//     final selectedCount = _selectedProducts.entries
//         .where((entry) => entry.value['selected'] == true)
//         .length;

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () => Navigator.of(context).pop(),
//           icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
//         ),
//         title: Text(
//           'Rate Your Order',
//           style: theme.textTheme.titleLarge?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         actions: [
//           if (_hasSelectedProducts)
//             Padding(
//               padding: EdgeInsets.only(right: isWeb ? 24 : 16),
//               child: Center(
//                 child: Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: isWeb ? 16 : 12,
//                     vertical: isWeb ? 8 : 6,
//                   ),
//                   decoration: BoxDecoration(
//                     color: theme.colorScheme.primary.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     '$selectedCount selected',
//                     style: theme.textTheme.bodyMedium?.copyWith(
//                       color: theme.colorScheme.primary,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//       body: Center(
//         child: Container(
//           constraints: isWeb ? const BoxConstraints(maxWidth: 900) : null,
//           child: Column(
//             children: [
//               // Order Info Card
//               Container(
//                 width: double.infinity,
//                 padding: EdgeInsets.all(isWeb ? 20 : 16),
//                 decoration: BoxDecoration(
//                   color: theme.cardColor,
//                   border: Border(
//                     bottom: BorderSide(
//                       color: theme.dividerColor.withOpacity(0.3),
//                     ),
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     Container(
//                       width: isWeb ? 60 : 50,
//                       height: isWeb ? 60 : 50,
//                       decoration: BoxDecoration(
//                         color: theme.colorScheme.primary.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(isWeb ? 14 : 12),
//                       ),
//                       child: widget.order.products.isNotEmpty &&
//                               widget.order.products.first.image != null
//                           ? ClipRRect(
//                               borderRadius: BorderRadius.circular(
//                                 isWeb ? 14 : 12,
//                               ),
//                               child: Image.network(
//                                 widget.order.products.first.image.toString(),
//                                 fit: BoxFit.cover,
//                               ),
//                             )
//                           : Icon(
//                               Icons.restaurant,
//                               color: theme.colorScheme.primary,
//                               size: isWeb ? 28 : 24,
//                             ),
//                     ),
//                     SizedBox(width: isWeb ? 16 : 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             widget.order.restaurant.restaurantName,
//                             style: (isWeb
//                                     ? theme.textTheme.titleLarge
//                                     : theme.textTheme.titleMedium)
//                                 ?.copyWith(
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             'Order #${widget.order.id.substring(0, 8)}...',
//                             style: theme.textTheme.bodySmall?.copyWith(
//                               color: theme.colorScheme.onSurface.withOpacity(
//                                 0.6,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // Instruction
//               Container(
//                 width: double.infinity,
//                 padding: EdgeInsets.all(isWeb ? 20 : 16),
//                 color: theme.colorScheme.primary.withOpacity(0.05),
//                 child: Text(
//                   'Rate the restaurant and products in this order',
//                   style: (isWeb
//                           ? theme.textTheme.bodyLarge
//                           : theme.textTheme.bodyMedium)
//                       ?.copyWith(
//                     color: theme.colorScheme.primary,
//                     fontWeight: FontWeight.w500,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ),

//               // CONTENT: restaurant review + product list
//               Expanded(
//                 child: isWeb ? _buildWebLayout(theme) : _buildMobileLayout(theme),
//               ),

//               // Submit Button (for product reviews)
//               Container(
//                 width: double.infinity,
//                 padding: EdgeInsets.all(isWeb ? 20 : 16),
//                 decoration: BoxDecoration(
//                   color: theme.cardColor,
//                   border: Border(
//                     top: BorderSide(
//                       color: theme.dividerColor.withOpacity(0.3),
//                     ),
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed: _isSubmitting || !_hasSelectedProducts
//                             ? null
//                             : _submitReviews,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: theme.colorScheme.primary,
//                           foregroundColor: theme.colorScheme.onPrimary,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           padding: EdgeInsets.symmetric(
//                             vertical: isWeb ? 18 : 16,
//                           ),
//                         ),
//                         child: _isSubmitting
//                             ? SizedBox(
//                                 width: isWeb ? 24 : 20,
//                                 height: isWeb ? 24 : 20,
//                                 child: const CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   valueColor: AlwaysStoppedAnimation<Color>(
//                                     Colors.white,
//                                   ),
//                                 ),
//                               )
//                             : Text(
//                                 'Submit ${selectedCount > 0 ? '$selectedCount ' : ''}Review${selectedCount > 1 ? 's' : ''}',
//                                 style: (isWeb
//                                         ? theme.textTheme.titleMedium
//                                         : theme.textTheme.bodyLarge)
//                                     ?.copyWith(
//                                   fontWeight: FontWeight.w600,
//                                   color: theme.colorScheme.onPrimary,
//                                 ),
//                               ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Mobile Layout - Original stacked layout
//   Widget _buildMobileLayout(ThemeData theme) {
//     return ListView(
//       padding: EdgeInsets.zero,
//       children: [
//         _buildRestaurantReviewSection(theme, false),
//         _buildProductsList(theme, false),
//       ],
//     );
//   }

//   // Web Layout - Side by side layout
//   Widget _buildWebLayout(ThemeData theme) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Left side: Restaurant Review (fixed width)
//         SizedBox(
//           width: 400,
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: _buildRestaurantReviewSection(theme, true),
//           ),
//         ),
        
//         // Divider
//         VerticalDivider(
//           width: 1,
//           thickness: 1,
//           color: theme.dividerColor.withOpacity(0.3),
//         ),
        
//         // Right side: Products List (expandable)
//         Expanded(
//           child: _buildProductsList(theme, true),
//         ),
//       ],
//     );
//   }

//   // Restaurant Review Section
//   Widget _buildRestaurantReviewSection(ThemeData theme, bool isWeb) {
//     return Container(
//       margin: EdgeInsets.all(isWeb ? 0 : 12),
//       padding: EdgeInsets.all(isWeb ? 20 : 16),
//       decoration: BoxDecoration(
//         color: theme.cardColor,
//         borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
//         border: Border.all(
//           color: theme.colorScheme.primary.withOpacity(0.4),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.restaurant,
//                 color: theme.colorScheme.primary,
//                 size: isWeb ? 28 : 24,
//               ),
//               SizedBox(width: isWeb ? 12 : 8),
//               Text(
//                 'Restaurant Rating',
//                 style: (isWeb
//                         ? theme.textTheme.titleLarge
//                         : theme.textTheme.titleMedium)
//                     ?.copyWith(
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: isWeb ? 16 : 12),
//           Center(
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: List.generate(5, (index) {
//                 return GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       _restaurantRating = index + 1;
//                     });
//                   },
//                   child: Icon(
//                     index < _restaurantRating
//                         ? Icons.star_rounded
//                         : Icons.star_border_rounded,
//                     color: Colors.amber,
//                     size: isWeb ? 42 : 36,
//                   ),
//                 );
//               }),
//             ),
//           ),
//           SizedBox(height: isWeb ? 12 : 8),
//           Center(
//             child: Text(
//               _restaurantRating == 0
//                   ? 'Tap to rate the restaurant'
//                   : '$_restaurantRating ${_restaurantRating == 1 ? 'star' : 'stars'}',
//               style: (isWeb
//                       ? theme.textTheme.bodyLarge
//                       : theme.textTheme.bodyMedium)
//                   ?.copyWith(
//                 fontWeight: FontWeight.w600,
//                 color: theme.colorScheme.primary,
//               ),
//             ),
//           ),
//           SizedBox(height: isWeb ? 20 : 16),
//           Text(
//             'Your Review for Restaurant (Optional)',
//             style: (isWeb
//                     ? theme.textTheme.bodyLarge
//                     : theme.textTheme.bodyMedium)
//                 ?.copyWith(
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           SizedBox(height: isWeb ? 12 : 8),
//           TextField(
//             controller: _restaurantReviewController,
//             maxLines: isWeb ? 4 : 3,
//             decoration: InputDecoration(
//               hintText: 'Share your experience with the restaurant...',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(color: theme.dividerColor),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(
//                   color: theme.colorScheme.primary,
//                 ),
//               ),
//               contentPadding: EdgeInsets.all(isWeb ? 16 : 12),
//             ),
//           ),
//           SizedBox(height: isWeb ? 16 : 12),
//           Row(
//             children: [
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed:
//                       _isRestaurantSubmitting ? null : _submitRestaurantReview,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: theme.colorScheme.primary,
//                     foregroundColor: theme.colorScheme.onPrimary,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     padding: EdgeInsets.symmetric(
//                       vertical: isWeb ? 16 : 14,
//                     ),
//                   ),
//                   child: _isRestaurantSubmitting
//                       ? SizedBox(
//                           width: isWeb ? 24 : 20,
//                           height: isWeb ? 24 : 20,
//                           child: const CircularProgressIndicator(
//                             strokeWidth: 2,
//                             valueColor: AlwaysStoppedAnimation<Color>(
//                               Colors.white,
//                             ),
//                           ),
//                         )
//                       : Text(
//                           _restaurantReviewId == null
//                               ? 'Submit Restaurant Review'
//                               : 'Update Restaurant Review',
//                           style: (isWeb
//                                   ? theme.textTheme.bodyLarge
//                                   : theme.textTheme.bodyMedium)
//                               ?.copyWith(
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                 ),
//               ),
//               if (_restaurantReviewId != null) ...[
//                 SizedBox(width: isWeb ? 12 : 8),
//                 IconButton(
//                   onPressed:
//                       _isRestaurantSubmitting ? null : _deleteRestaurantReview,
//                   icon: Icon(
//                     Icons.delete_outline,
//                     color: theme.colorScheme.error,
//                     size: isWeb ? 28 : 24,
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // Products List
//   Widget _buildProductsList(ThemeData theme, bool isWeb) {
//     return ListView.builder(
//       physics: isWeb
//           ? const AlwaysScrollableScrollPhysics()
//           : const NeverScrollableScrollPhysics(),
//       shrinkWrap: !isWeb,
//       padding: EdgeInsets.all(isWeb ? 16 : 8),
//       itemCount: widget.order.products.length,
//       itemBuilder: (context, index) {
//         final product = widget.order.products[index];
//         final productData = _selectedProducts[product.id]!;
//         final isSelected = productData['selected'] as bool;
//         final rating = productData['rating'] as int;
//         final review = productData['review'] as String;
//         final isSubmitting = productData['isSubmitting'] as bool;

//         return Container(
//           margin: EdgeInsets.symmetric(
//             vertical: isWeb ? 12 : 8,
//             horizontal: isWeb ? 8 : 0,
//           ),
//           decoration: BoxDecoration(
//             color: theme.cardColor,
//             borderRadius: isWeb ? BorderRadius.circular(16) : null,
//             border: isSelected
//                 ? Border.all(
//                     color: theme.colorScheme.primary,
//                     width: 2,
//                   )
//                 : isWeb
//                     ? Border.all(
//                         color: theme.dividerColor.withOpacity(0.3),
//                       )
//                     : null,
//           ),
//           child: Column(
//             children: [
//               // Product Header with Checkbox
//               ListTile(
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: isWeb ? 20 : 16,
//                   vertical: isWeb ? 8 : 0,
//                 ),
//                 leading: Checkbox(
//                   value: isSelected,
//                   onChanged: (value) {
//                     _toggleProductSelection(product.id);
//                   },
//                   activeColor: theme.colorScheme.primary,
//                 ),
//                 title: Text(
//                   product.name,
//                   style: (isWeb
//                           ? theme.textTheme.titleMedium
//                           : theme.textTheme.bodyLarge)
//                       ?.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 subtitle: Padding(
//                   padding: const EdgeInsets.only(top: 4),
//                   child: Text(
//                     '${product.quantity}x • ₹${(product.quantity * product.basePrice).toStringAsFixed(2)}',
//                     style: (isWeb
//                             ? theme.textTheme.bodyMedium
//                             : theme.textTheme.bodyMedium)
//                         ?.copyWith(
//                       color: theme.colorScheme.onSurface.withOpacity(0.6),
//                     ),
//                   ),
//                 ),
//                 trailing: isSubmitting
//                     ? SizedBox(
//                         width: isWeb ? 24 : 20,
//                         height: isWeb ? 24 : 20,
//                         child: const CircularProgressIndicator(strokeWidth: 2),
//                       )
//                     : null,
//               ),

//               // Rating Section (only show if selected)
//               if (isSelected) ...[
//                 Divider(
//                   height: 1,
//                   color: theme.dividerColor.withOpacity(0.3),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.all(isWeb ? 20 : 16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Star Rating
//                       Text(
//                         'Rate this product',
//                         style: (isWeb
//                                 ? theme.textTheme.bodyLarge
//                                 : theme.textTheme.bodyMedium)
//                             ?.copyWith(
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       SizedBox(height: isWeb ? 16 : 12),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: List.generate(5, (index) {
//                           return GestureDetector(
//                             onTap: () {
//                               _updateProductRating(
//                                 product.id,
//                                 index + 1,
//                               );
//                             },
//                             child: Icon(
//                               index < rating
//                                   ? Icons.star_rounded
//                                   : Icons.star_border_rounded,
//                               color: Colors.amber,
//                               size: isWeb ? 42 : 36,
//                             ),
//                           );
//                         }),
//                       ),
//                       SizedBox(height: isWeb ? 12 : 8),
//                       Center(
//                         child: Text(
//                           rating == 0
//                               ? 'Tap to rate'
//                               : '$rating ${rating == 1 ? 'star' : 'stars'}',
//                           style: (isWeb
//                                   ? theme.textTheme.bodyLarge
//                                   : theme.textTheme.bodyMedium)
//                               ?.copyWith(
//                             fontWeight: FontWeight.w600,
//                             color: theme.colorScheme.primary,
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: isWeb ? 20 : 16),

//                       // Review Text Field
//                       Text(
//                         'Your Review (Optional)',
//                         style: (isWeb
//                                 ? theme.textTheme.bodyLarge
//                                 : theme.textTheme.bodyMedium)
//                             ?.copyWith(
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       SizedBox(height: isWeb ? 12 : 8),
//                       TextField(
//                         onChanged: (value) {
//                           _updateProductReview(product.id, value);
//                         },
//                         maxLines: isWeb ? 4 : 3,
//                         decoration: InputDecoration(
//                           hintText:
//                               'Share your experience with ${product.name}...',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(
//                               color: theme.dividerColor,
//                             ),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide(
//                               color: theme.colorScheme.primary,
//                             ),
//                           ),
//                           contentPadding: EdgeInsets.all(isWeb ? 16 : 12),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         );
//       },
//     );
//   }

//   @override
//   void dispose() {
//     _restaurantReviewController.dispose();
//     super.dispose();
//   }
// }



















// lib/screens/booking_screen.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:veegify/model/order.dart';
import 'package:veegify/provider/BookingProvider/booking_provider.dart';
import 'package:http/http.dart' as http;
import 'package:veegify/utils/web_invoice.dart';
import 'package:veegify/views/Booking/accepted_order_polling_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:veegify/utils/invoice_html_builder.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';
import 'package:veegify/utils/responsive.dart';
import 'package:veegify/views/Booking/review.dart'; // Add responsive utility

class BookingScreen extends StatefulWidget {
  final String? userId;

  const BookingScreen({super.key, required this.userId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late OrderProvider _orderProvider;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _orderProvider = Provider.of<OrderProvider>(context, listen: false);
      _orderProvider.loadAllOrders(widget.userId.toString());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _downloadInvoice(Order order) async {
    final theme = Theme.of(context);

    try {
      final htmlContent = buildInvoiceHtml(order);

      if (kIsWeb) {
        // 🌐 WEB: generate PDF and download
        // openInvoiceHtml(htmlContent);
        return;
      } else {
        // 📱 MOBILE: print / preview
        // await Printing.layoutPdf(
        //   onLayout: (PdfPageFormat format) async {
        //     return Printing.convertHtml(
        //       format: format,
        //       html: htmlContent,
        //     );
        //   },
        // );
      }
    } catch (e, st) {
      debugPrint('Invoice error: $e\n$st');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate invoice'),
          backgroundColor: theme.colorScheme.error,
        ),
      );
    }
  }

Widget _buildList(List<Order> items) {
  final isDesktop = Responsive.isDesktop(context);
  print("isDesktop: $isDesktop");
  final isTablet = Responsive.isTablet(context);
  
  double maxWidth = isDesktop ? 1400 : (isTablet ? 1000 : double.infinity);
  double padding = isDesktop ? 32 : (isTablet ? 24 : 16);

  if (items.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: isDesktop ? 100 : 80,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No orders found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              fontSize: isDesktop ? 20 : 16,
            ),
          ),
          if (isDesktop) ...[
            const SizedBox(height: 8),
            Text(
              'Your order history will appear here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ],
      ),
    );
  }

  return Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: isDesktop
          ? GridView.builder(
              padding: EdgeInsets.all(padding),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85, // Adjusted for better card proportions
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final order = items[index];
                return _buildModernBookingCard(order, isWeb: true);
              },
            )
          : ListView.separated(
              padding: EdgeInsets.all(padding),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final order = items[index];
                return _buildModernBookingCard(order, isWeb: false);
              },
            ),
    ),
  );
}
  Widget _buildModernBookingCard(Order order, {required bool isWeb}) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final firstProduct = order.products.isNotEmpty ? order.products.first : null;
    final status = order.orderStatus.toLowerCase();

    // Status colors with theme compatibility
    Color statusColor;
    Color statusBgColor;
    IconData statusIcon;

    switch (status) {
      case 'pending':
        statusColor = Colors.orange;
        statusBgColor = Colors.orange.withOpacity(0.1);
        statusIcon = Icons.access_time;
        break;
      case 'accepted':
      case 'rider accepted':
      case 'picked':
        statusColor = Colors.blue;
        statusBgColor = Colors.blue.withOpacity(0.1);
        statusIcon = Icons.check_circle;
        break;
      case 'completed':
      case 'delivered':
        statusColor = Colors.green;
        statusBgColor = Colors.green.withOpacity(0.1);
        statusIcon = Icons.done_all;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusBgColor = Colors.red.withOpacity(0.1);
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusBgColor = Colors.grey.withOpacity(0.1);
        statusIcon = Icons.help;
    }

    final isCompletedOrDelivered = status == 'completed' || status == 'delivered';

    return isWeb
        ? _buildWebCard(theme, order, firstProduct, status, statusColor, 
            statusBgColor, statusIcon, isCompletedOrDelivered)
        : _buildMobileCard(theme, order, firstProduct, status, statusColor,
            statusBgColor, statusIcon, isCompletedOrDelivered);
  }

  // Mobile Card (existing layout)
  Widget _buildMobileCard(
    ThemeData theme,
    Order order,
    dynamic firstProduct,
    String status,
    Color statusColor,
    Color statusBgColor,
    IconData statusIcon,
    bool isCompletedOrDelivered,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMobileHeader(theme, firstProduct, order, statusColor, 
                statusBgColor, statusIcon),
            const SizedBox(height: 16),
            _buildMobileOrderItems(theme, order),
            const SizedBox(height: 16),
            _buildMobileSummaryAndActions(theme, order, 
                isCompletedOrDelivered, status),
          ],
        ),
      ),
    );
  }

  // Professional Web Card
// Professional Web Card - FIXED VERSION
// Professional Web Card - COMPACT VERSION
Widget _buildWebCard(
  ThemeData theme,
  Order order,
  dynamic firstProduct,
  String status,
  Color statusColor,
  Color statusBgColor,
  IconData statusIcon,
  bool isCompletedOrDelivered,
) {
  return MouseRegion(
    cursor: SystemMouseCursors.click,
    child: Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        height: 380, // Reduced from 500 to 380
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header with image - Smaller height
            SizedBox(
              height: 100, // Reduced from 140 to 100
              child: Stack(
                children: [
                  // Image Header
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Container(
                      width: double.infinity,
                      height: 100,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                      ),
                      child: firstProduct?.image != null && firstProduct!.image!.isNotEmpty
                          ? Image.network(
                              firstProduct.image!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(
                                    Icons.restaurant,
                                    size: 32, // Reduced from 48
                                    color: theme.colorScheme.primary.withOpacity(0.5),
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Icon(
                                Icons.restaurant,
                                size: 32,
                                color: theme.colorScheme.primary.withOpacity(0.5),
                              ),
                            ),
                    ),
                  ),
                  
                  // Gradient Overlay - Lighter gradient
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            theme.cardColor.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  // Restaurant Info Overlay - Smaller
                  Positioned(
                    bottom: 8, // Reduced from 16
                    left: 8, // Reduced from 16
                    right: 8, // Reduced from 16
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Smaller padding
                          decoration: BoxDecoration(
                            color: theme.cardColor.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12), // Smaller radius
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.store,
                                size: 12, // Reduced from 14
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 2), // Reduced from 4
                              Flexible(
                                child: Text(
                                  order.restaurant.restaurantName,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11, // Smaller font
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8, // Reduced from 12
                            vertical: 4, // Reduced from 6
                          ),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(12), // Smaller radius
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 12, color: statusColor), // Reduced from 14
                              const SizedBox(width: 2), // Reduced from 4
                              Text(
                                order.orderStatus.length > 10 
                                    ? '${order.orderStatus.substring(0, 10)}...' 
                                    : order.orderStatus,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10, // Smaller font
                                ),
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

            // Content - Takes remaining space
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12), // Reduced from 20
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order ID and Date - Compact
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4), // Reduced from 6
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6), // Smaller radius
                          ),
                          child: Icon(
                            Icons.receipt_outlined,
                            size: 12, // Reduced from 14
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 6), // Reduced from 8
                        Expanded(
                          child: Text(
                            'Order #${order.id.length > 6 ? order.id.substring(0, 6) : order.id}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 11, // Smaller font
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          order.createdAt == null
                              ? 'N/A'
                              : DateFormat('dd/MM').format(order.createdAt!.toLocal()), // Shorter format
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 10, // Smaller font
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8), // Reduced from 12

                    // Items Preview - Compact
                    Container(
                      padding: const EdgeInsets.all(8), // Reduced from 12
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8), // Smaller radius
                      ),
                      child: Column(
                        children: [
                          ...order.products.take(2).map(
                            (product) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2), // Reduced from 4
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      product.name,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontSize: 10, // Smaller font
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4), // Reduced from 8
                                  Text(
                                    '${product.quantity}x',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                                      fontSize: 10,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '₹${(product.quantity * product.basePrice).toStringAsFixed(0)}', // No decimals
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (order.products.length > 2)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                '+${order.products.length - 2} more',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  fontSize: 9,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Summary Row - Compact
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8), // Reduced from 12
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                '₹${order.totalPayable.toStringAsFixed(0)}', // No decimals
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                  fontSize: 14, // Smaller font
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Items',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                '${order.totalItems}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Action Buttons - Compact
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _handleViewDetails(order, status),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8), // Smaller radius
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 6), // Smaller padding
                              minimumSize: const Size(double.infinity, 28), // Smaller height
                            ),
                            child: const Text(
                              'Details',
                              style: TextStyle(fontSize: 11), // Smaller font
                            ),
                          ),
                        ),
                        if (isCompletedOrDelivered) ...[
                          const SizedBox(width: 4), // Reduced from 8
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _downloadInvoice(order),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                minimumSize: const Size(double.infinity, 28),
                              ),
                              child: const Text(
                                'Invoice',
                                style: TextStyle(fontSize: 11),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _showReviewDialog(order),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                minimumSize: const Size(double.infinity, 28),
                              ),
                              child: const Text(
                                'Review',
                                style: TextStyle(fontSize: 11),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
  // Mobile Header (unchanged)
  Widget _buildMobileHeader(ThemeData theme, dynamic firstProduct, Order order, 
      Color statusColor, Color statusBgColor, IconData statusIcon) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: firstProduct?.image != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    firstProduct!.image!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.restaurant,
                        color: theme.colorScheme.primary,
                        size: 24,
                      );
                    },
                  ),
                )
              : Icon(
                  Icons.restaurant,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.restaurant.restaurantName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                order.restaurant.locationName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusBgColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(statusIcon, size: 14, color: statusColor),
              const SizedBox(width: 6),
              Text(
                order.orderStatus,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Mobile Order Items (unchanged)
  Widget _buildMobileOrderItems(ThemeData theme, Order order) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Items',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...order.products.take(2).map(
            (product) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${product.quantity}x ${product.name}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  Text(
                    '₹${(product.quantity * product.basePrice).toStringAsFixed(2)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (order.products.length > 2)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '+ ${order.products.length - 2} more items',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Mobile Summary and Actions (unchanged)
  Widget _buildMobileSummaryAndActions(ThemeData theme, Order order,
      bool isCompletedOrDelivered, String status) {
    return Column(
      children: [
        // Order Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withOpacity(0.05),
                theme.colorScheme.primary.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Amount',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    '₹${order.totalPayable.toStringAsFixed(2)}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${order.totalItems} items',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    order.createdAt == null
                        ? 'N/A'
                        : DateFormat('MMM dd, hh:mm a')
                            .format(order.createdAt!.toLocal()),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Action Buttons
        Row(
          children: [
            if (isCompletedOrDelivered) ...[
              IconButton(
                onPressed: () => _downloadInvoice(order),
                tooltip: 'Download Invoice',
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  foregroundColor: theme.colorScheme.primary,
                ),
                icon: const Icon(Icons.download_rounded),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: ElevatedButton(
                onPressed: () => _handleViewDetails(order, status),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.remove_red_eye_outlined, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'View Details',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isCompletedOrDelivered) ...[
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => _showReviewDialog(order),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      'Review',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  void _handleViewDetails(Order order, String status) {
    if (status == 'pending' ||
        status == 'rider accepted' ||
        status == 'accepted' ||
        status == 'picked') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AcceptedOrderPollingScreen(
            userId: order.userId,
            orderId: order.id,
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Theme.of(context).cardColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        builder: (_) => _buildOrderDetailSheet(order),
      );
    }
  }

  void _showReviewDialog(Order order) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: Responsive.isDesktop(context)
            ? const EdgeInsets.symmetric(horizontal: 100, vertical: 40)
            : const EdgeInsets.symmetric(horizontal: 40),
        child: ReviewDialog(
          order: order,
          userId: widget.userId!,
          onReviewSubmitted: () {
            _orderProvider.loadAllOrders(widget.userId.toString());
          },
        ),
      ),
    );
  }

  Widget _buildOrderDetailSheet(Order order) {
    final theme = Theme.of(context);
    final isDesktop = Responsive.isDesktop(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
        maxWidth: isDesktop ? 600 : double.infinity,
      ),
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
            'Order Details',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Make the content scrollable
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Order ID', order.id, theme),
                  _buildDetailRow(
                    'Restaurant',
                    order.restaurant.restaurantName,
                    theme,
                  ),
                  _buildDetailRow(
                    'Address',
                    '${order.deliveryAddress.street}, ${order.deliveryAddress.city}',
                    theme,
                  ),
                  _buildDetailRow(
                    'Payment',
                    '${order.paymentMethod} • ${order.paymentStatus}',
                    theme,
                  ),
                  _buildDetailRow(
                    'Total',
                    '₹${order.totalPayable.toStringAsFixed(2)}',
                    theme,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Items Ordered',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...order.products.map(
                    (p) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${p.quantity} x ₹${p.basePrice.toStringAsFixed(2)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '₹${(p.quantity * p.basePrice).toStringAsFixed(2)}',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<OrderProvider>(context);
    final isLoading = provider.state == OrdersState.loading;
    final error = provider.error;
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, color: theme.colorScheme.onSurface),
        ),
        centerTitle: isDesktop,
        title: Text(
          "My Orders",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isDesktop ? 24 : 20,
          ),
        ),
        elevation: isDesktop ? 1 : 0,
        backgroundColor: isDesktop ? theme.cardColor : Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 1400 : (isTablet ? 1000 : double.infinity),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 32 : 16,
                  vertical: 12,
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicator: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorColor: Colors.transparent,
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  dividerColor: Colors.transparent,
                  labelColor: theme.colorScheme.onPrimary,
                  unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.7),
                  labelPadding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 16 : 12,
                  ),
                  tabs: [
                    _buildTabItem(
                      "Today",
                      Icons.calendar_today,
                      _tabController.index == 0,
                      theme,
                      isDesktop,
                    ),
                    _buildTabItem(
                      "All Orders",
                      Icons.receipt_long,
                      _tabController.index == 1,
                      theme,
                      isDesktop,
                    ),
                    _buildTabItem(
                      "Cancelled",
                      Icons.cancel,
                      _tabController.index == 2,
                      theme,
                      isDesktop,
                    ),
                  ],
                  onTap: (i) => setState(() {}),
                ),
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          : error != null
              ? Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: isDesktop ? 80 : 64,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading orders',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.error,
                            fontSize: isDesktop ? 20 : 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              provider.loadAllOrders(widget.userId.toString()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: EdgeInsets.symmetric(
                              horizontal: isDesktop ? 32 : 24,
                              vertical: isDesktop ? 16 : 12,
                            ),
                          ),
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    RefreshIndicator(
                      onRefresh: () =>
                          provider.loadAllOrders(widget.userId.toString()),
                      child: _buildList(provider.todayOrders),
                    ),
                    RefreshIndicator(
                      onRefresh: () =>
                          provider.loadAllOrders(widget.userId.toString()),
                      child: _buildList(provider.orders),
                    ),
                    RefreshIndicator(
                      onRefresh: () =>
                          provider.loadAllOrders(widget.userId.toString()),
                      child: _buildList(provider.cancelledOrders),
                    ),
                  ],
                ),
    );
  }

  Widget _buildTabItem(
    String text,
    IconData icon,
    bool isSelected,
    ThemeData theme,
    bool isDesktop,
  ) {
    return Tab(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 24 : 20,
          vertical: isDesktop ? 14 : 12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? null : Border.all(color: theme.dividerColor),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isDesktop ? 20 : 18,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: isDesktop ? 15 : 14,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}