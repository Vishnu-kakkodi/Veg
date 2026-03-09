
// lib/screens/booking_screen.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:veegify/model/order.dart';
import 'package:veegify/provider/BookingProvider/booking_provider.dart';
import 'package:http/http.dart' as http;
import 'package:veegify/services/pdf_download_service.dart';
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

  // Future<void> _downloadInvoice(Order order) async {
  //   final theme = Theme.of(context);

  //   try {
  //     final htmlContent = buildInvoiceHtml(order);

  //     if (kIsWeb) {
  //       // 🌐 WEB: generate PDF and download
  //       // openInvoiceHtml(htmlContent);
  //       return;
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




  // In booking_screen.dart - replace the _downloadInvoice method

Future<void> _downloadInvoice(Order order) async {
  await PdfDownloadService.downloadInvoice(
    context: context,
    invoiceUrl: order.invoice,
    orderId: order.id,
  );
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