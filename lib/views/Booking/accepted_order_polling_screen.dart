
// // lib/screens/accepted_order_polling_screen.dart
// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:lottie/lottie.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:veegify/helper/storage_helper.dart';
// import 'package:veegify/views/Booking/chat_screen.dart';
// import 'package:veegify/views/Tracker/tracking_screen_osm.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class AcceptedOrderPollingScreen extends StatefulWidget {
//   final String? userId;
//   final String? orderId;

//   const AcceptedOrderPollingScreen({
//     Key? key,
//     this.userId,
//     this.orderId,
//   }) : super(key: key);

//   @override
//   State<AcceptedOrderPollingScreen> createState() =>
//       _AcceptedOrderPollingScreenState();
// }

// class _AcceptedOrderPollingScreenState
//     extends State<AcceptedOrderPollingScreen> with SingleTickerProviderStateMixin {
//   static const _pollInterval = Duration(seconds: 5);
//   Timer? _pollTimer;
//   bool _loading = true;
//   bool _hasOrder = false;
//   bool _hasRider = false;
//   AcceptedOrder? _order;

//   late final AnimationController _hourglassController;
//   late final Animation<double> _hourglassAnimation;
//   String? userId;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserId();

//     _hourglassController =
//         AnimationController(vsync: this, duration: const Duration(seconds: 1));
//     _hourglassAnimation =
//         Tween<double>(begin: 0.0, end: 1.0).animate(_hourglassController);
//     _hourglassController.repeat();

//     _startPolling();
//   }

//   Future<void> _loadUserId() async {
//     final user = UserPreferences.getUser();
//     if (user != null && mounted) {
//       setState(() {
//         userId = user.userId;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _pollTimer?.cancel();
//     _hourglassController.dispose();
//     super.dispose();
//   }

//   void _startPolling() async {
//     await _fetchAcceptedOrder();

//     if (!_hasRider) {
//       _pollTimer = Timer.periodic(_pollInterval, (t) async {
//         if (_hasRider) {
//           t.cancel();
//           return;
//         }
//         await _fetchAcceptedOrder();
//       });
//     }
//   }

//   Future<void> _fetchAcceptedOrder() async {
//     if (!mounted) return;
//     setState(() {
//       _loading = true;
//     });

//     try {
//       Uri url;

//       if (widget.orderId != null && widget.userId != null) {
//         url = Uri.parse(
//           'https://api.vegiffyy.com/api/acceptedorders/${widget.userId}/${widget.orderId}',
//         );
//       } else {
//         url = Uri.parse(
//           'https://api.vegiffyy.com/api/acceptedorders/${widget.userId ?? ''}',
//         );
//       }

//       final resp = await http.get(url).timeout(const Duration(seconds: 10));

//       if (resp.statusCode == 200) {
//         final jsonBody = json.decode(resp.body);

//         final success = jsonBody['success'] ?? false;
//         final data = jsonBody['data'];

//         if (success != true || data == null) {
//           if (!mounted) return;
//           setState(() {
//             _loading = false;
//             _hasOrder = false;
//             _hasRider = false;
//             _order = null;
//           });
//           return;
//         }

//         Map<String, dynamic>? parsed;
//         if (data is List && data.isNotEmpty) {
//           parsed = data.first as Map<String, dynamic>;
//         } else if (data is Map<String, dynamic>) {
//           parsed = data;
//         } else {
//           if (!mounted) return;
//           setState(() {
//             _loading = false;
//             _hasOrder = false;
//             _hasRider = false;
//             _order = null;
//           });
//           return;
//         }

//         final order = AcceptedOrder.fromJson(parsed);
//         final riderPresent = order.riderDetails != null;

//         if (!mounted) return;
//         setState(() {
//           _order = order;
//           _hasOrder = true;
//           _hasRider = riderPresent;
//           _loading = false;
//         });

//         if (riderPresent) {
//           _pollTimer?.cancel();
//           _hourglassController.stop();
//         }
//       } else {
//         if (!mounted) return;
//         setState(() {
//           _loading = false;
//           _hasOrder = false;
//           _hasRider = false;
//           _order = null;
//         });
//       }
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _loading = false;
//       });
//     }
//   }

//   Future<void> _launchPhone(String phone) async {
//     final uri = Uri.parse('tel:$phone');
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Cannot call $phone'),
//           backgroundColor: Theme.of(context).colorScheme.error,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//       );
//     }
//   }

//   /// --- UI BUILD HELPERS ---

//   /// Main card area
//   Widget _buildCardContent() {
//     if (!_hasOrder || _order == null) {
//       // 👉 No data from backend: show Lottie instead of Order Form
//       return _noOrderAnimation();
//     } else {
//       return _acceptedOrderCard(_order!);
//     }
//   }

//   /// Lottie animation when order not accepted / no data yet
//   Widget _noOrderAnimation() {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
//       child: Column(
//         children: [
//           SizedBox(
//             height: 220,
//             child: Lottie.asset(
//               'assets/lottie/food_preparing.json', // 🔁 replace with your file path
//               repeat: true,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'We are preparing your order',
//             style: theme.textTheme.titleMedium?.copyWith(
//               fontWeight: FontWeight.bold,
//               color: colorScheme.onBackground,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Once a Vegiffy Green Partner accepts your order,\n'
//             'you will see all the order details here.',
//             style: theme.textTheme.bodyMedium?.copyWith(
//               color: colorScheme.onSurface.withOpacity(0.7),
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _acceptedOrderCard(AcceptedOrder order) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     return Card(
//       elevation: 6,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       color: theme.cardColor,
//       child: Padding(
//         padding: const EdgeInsets.all(14),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Container(
//                 padding: const EdgeInsets.all(6),
//                 decoration: BoxDecoration(
//                   color: colorScheme.primary.withOpacity(0.1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(Icons.check, color: colorScheme.primary, size: 20),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Vegiffy Green Partner Accepted',
//                       style: theme.textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     Row(children: [
//                       Icon(Icons.store, size: 16, color: colorScheme.primary),
//                       const SizedBox(width: 6),
//                       Expanded(
//                         child: Text(
//                           order.restaurantName ?? 'Unknown',
//                           style: theme.textTheme.bodyMedium,
//                         ),
//                       ),
//                     ]),
//                     const SizedBox(height: 6),
//                     Row(children: [
//                       Icon(
//                         Icons.location_on,
//                         size: 14,
//                         color: colorScheme.onSurface.withOpacity(0.6),
//                       ),
//                       const SizedBox(width: 6),
//                       Expanded(
//                         child: Text(
//                           order.restaurantLocation ?? '',
//                           style: theme.textTheme.bodySmall?.copyWith(
//                             color: colorScheme.onSurface.withOpacity(0.7),
//                           ),
//                         ),
//                       ),
//                     ]),
//                   ],
//                 ),
//               ),
//             ]),
//             const SizedBox(height: 12),
//             Divider(color: colorScheme.outline.withOpacity(0.3)),
//             const SizedBox(height: 8),
//             Text(
//               'Order Details',
//               style: theme.textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             _detailRow(
//               'Total Items',
//               order.orderDetails?.totalItems?.toString() ?? '0',
//               theme,
//               colorScheme,
//             ),
//             _detailRow('Sub Total', order.orderDetails?.subTotal ?? '₹0', theme,
//                 colorScheme),
//             _detailRow(
//               'Delivery charge',
//               order.orderDetails?.deliveryCharge ?? '₹0',
//               theme,
//               colorScheme,
//             ),
//                         _detailRow(
//               'Delivery Gst',
//               order.orderDetails?.gstDelivery ?? '₹0',
//               theme,
//               colorScheme,
//             ),
//                         _detailRow(
//               'Platform charge',
//               order.orderDetails?.platform ?? '₹0',
//               theme,
//               colorScheme,
//             ),
//                                     _detailRow(
//               'Packing charge',
//               order.orderDetails?.packing ?? '₹0',
//               theme,
//               colorScheme,
//             ),
//                                     _detailRow(
//               'Gst charge',
//               order.orderDetails?.gst ?? '₹0',
//               theme,
//               colorScheme,
//             ),
//             const SizedBox(height: 10),
//             Divider(color: colorScheme.outline.withOpacity(0.3)),
//             const SizedBox(height: 8),
//             Text(
//               'Total Payable',
//               style: theme.textTheme.titleMedium?.copyWith(
//                 color: colorScheme.primary,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               order.orderDetails?.totalPayable ?? '₹0',
//               style: theme.textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _detailRow(
//     String title,
//     String value,
//     ThemeData theme,
//     ColorScheme colorScheme,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(children: [
//         Expanded(
//           child: Text(
//             title,
//             style: theme.textTheme.bodyMedium?.copyWith(
//               color: colorScheme.onSurface.withOpacity(0.7),
//             ),
//           ),
//         ),
//         Text(
//           value,
//           style: theme.textTheme.bodyMedium?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ]),
//     );
//   }

//   Widget _bottomPill() {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     final waitingText = _hasRider ? 'Contact rider' : 'Waiting response';
//     final pillColor = _hasRider
//         ? colorScheme.primary.withOpacity(0.1)
//         : colorScheme.secondaryContainer;

//     return Align(
//       alignment: Alignment.bottomCenter,
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
//         child: Container(
//           decoration: BoxDecoration(
//             color: pillColor,
//             borderRadius: BorderRadius.circular(30),
//             boxShadow: [
//               BoxShadow(
//                 color:
//                     const Color.fromARGB(255, 186, 186, 186).withOpacity(0.5),
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//           child: Row(mainAxisSize: MainAxisSize.min, children: [
//             CircleAvatar(
//               radius: 16,
//               backgroundColor: theme.cardColor,
//               child: Icon(
//                 Icons.person_outline,
//                 color: colorScheme.onSurface,
//                 size: 18,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Text(
//               waitingText,
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(width: 12),
//             if (!_hasRider)
//               RotationTransition(
//                 turns: _hourglassAnimation,
//                 child: Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: colorScheme.secondaryContainer,
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     Icons.hourglass_bottom,
//                     color: colorScheme.onSecondaryContainer,
//                   ),
//                 ),
//               )
//             else
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: colorScheme.primary.withOpacity(0.1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   Icons.done_all,
//                   color: colorScheme.primary,
//                 ),
//               ),
//           ]),
//         ),
//       ),
//     );
//   }

//   Widget _deliveryFlowWidget(AcceptedOrder order) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
//       child: Card(
//         elevation: 4,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         color: theme.cardColor,
//         child: Padding(
//           padding: const EdgeInsets.all(14),
//           child: Column(children: [
//             Row(children: [
//               Column(children: [
//                 Icon(Icons.store, size: 22, color: colorScheme.primary),
//               ]),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       order.deliveryFlow?.restaurant?.name ?? '',
//                       style: theme.textTheme.bodyMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(
//                       order.deliveryFlow?.restaurant?.time ?? '',
//                       style: theme.textTheme.bodySmall?.copyWith(
//                         color: colorScheme.onSurface.withOpacity(0.6),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // if (order.deliveryFlow?.restaurant != null)
//               //   const SizedBox(width: 8),
//               // Text(
//               //   '5mins',
//               //   style: theme.textTheme.bodyMedium?.copyWith(
//               //     color: colorScheme.error,
//               //     fontWeight: FontWeight.bold,
//               //   ),
//               // ),
//             ]),
//             const SizedBox(height: 12),
//             Row(children: [
//               Column(children: [
//                 Icon(Icons.location_on, size: 22, color: colorScheme.primary),
//               ]),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'You - ${order.deliveryFlow?.user?.address?.street ?? order.deliveryFlow?.user?.address ?? ''}',
//                       style: theme.textTheme.bodyMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(
//                       order.deliveryFlow?.user?.time ?? '',
//                       style: theme.textTheme.bodySmall?.copyWith(
//                         color: colorScheme.onSurface.withOpacity(0.6),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ]),
//             const SizedBox(height: 12),
//             if (order.riderDetails != null)
//               Divider(color: colorScheme.outline.withOpacity(0.3)),
//             if (order.riderDetails != null)
//               Row(children: [
//                 CircleAvatar(
//                   radius: 22,
//                   backgroundColor: colorScheme.surfaceVariant,
//                   backgroundImage: order.riderDetails?.image != null
//                       ? NetworkImage(order.riderDetails!.image!)
//                       : null,
//                   child: order.riderDetails?.image == null
//                       ? Icon(Icons.person,
//                           color: colorScheme.onSurfaceVariant)
//                       : null,
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         order.riderDetails?.name ?? '',
//                         style: theme.textTheme.bodyMedium?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Text(
//                         'Delivery • ${order.riderDetails?.contact ?? ''}',
//                         style: theme.textTheme.bodySmall?.copyWith(
//                           color: colorScheme.onSurface.withOpacity(0.6),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => TrackingScreenGoogle(
//                           deliveryBoyId: '${order.riderDetails?.id.toString()}',
//                           userId: '$userId',
//                           initialCenter: LatLng(
//                             order.deliveryFlow?.user?.address?.location
//                                     ?.coordinates?[1] ??
//                                 0.0,
//                             order.deliveryFlow?.user?.address?.location
//                                     ?.coordinates?[0] ??
//                                 0.0,
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                   child: CircleAvatar(
//                     radius: 20,
//                     backgroundColor: colorScheme.primary.withOpacity(0.1),
//                     child: Icon(
//                       Icons.location_on_outlined,
//                       color: colorScheme.primary,
//                       size: 20,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => ChatScreen(
//                           deliveryBoyId:
//                               order.riderDetails?.id?.toString() ?? "",
//                           userId: widget.userId.toString(),
//                           title: 'Chat with Rider',
//                         ),
//                       ),
//                     );
//                   },
//                   child: CircleAvatar(
//                     radius: 20,
//                     backgroundColor: colorScheme.primary.withOpacity(0.1),
//                     child: Icon(
//                       Icons.chat,
//                       color: colorScheme.primary,
//                       size: 20,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 GestureDetector(
//                   onTap: () {
//                     final phone = order.riderDetails?.contact ?? '';
//                     if (phone.isNotEmpty) {
//                       _launchPhone(phone);
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: const Text('No phone number'),
//                           backgroundColor: colorScheme.error,
//                           behavior: SnackBarBehavior.floating,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       );
//                     }
//                   },
//                   child: CircleAvatar(
//                     radius: 20,
//                     backgroundColor: colorScheme.primary.withOpacity(0.1),
//                     child: Icon(
//                       Icons.call,
//                       color: colorScheme.primary,
//                       size: 20,
//                     ),
//                   ),
//                 ),
//               ])
//             else
//               const SizedBox(),
//           ]),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     return Scaffold(
//       body: Stack(
//         children: [
//           // Background
//           // Positioned.fill(
//           //   child: Image.asset(
//           //     'assets/images/map_placeholder.png',
//           //     fit: BoxFit.cover,
//           //   ),
//           // ),
//           Positioned.fill(
//             child: Container(
//               color: colorScheme.background.withOpacity(0.18),
//             ),
//           ),

//           // Scrollable content
//           SafeArea(
//             child: SingleChildScrollView(
//               physics: const BouncingScrollPhysics(),
//               child: Padding(
//                 padding: const EdgeInsets.only(bottom: 120),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 8),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 8),
//                       child: Row(
//                         children: [
//                           // Back button (if you want to enable)
//                           // IconButton(
//                           //   icon: Icon(
//                           //     Icons.arrow_back_ios_new,
//                           //     color: colorScheme.onBackground,
//                           //   ),
//                           //   onPressed: () => Navigator.of(context).maybePop(),
//                           // ),
//                           const Spacer(),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 40),
//                     _buildCardContent(),
//                     const SizedBox(height: 8),
//                     if (_hasOrder && _order != null)
//                       _deliveryFlowWidget(_order!),
//                     if (!_hasOrder)
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 28.0, vertical: 6),
//                         child: Column(
//                           children: [
//                             const SizedBox(height: 8),
//                             Text(
//                               'We are waiting for the vendor to confirm pickup. '
//                               'We will update this screen as soon as it happens.',
//                               textAlign: TextAlign.center,
//                               style: theme.textTheme.bodyMedium?.copyWith(
//                                 color: colorScheme.onSurface.withOpacity(0.6),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     const SizedBox(height: 20),
//                               _bottomPill(),

//                   ],
//                 ),
//               ),
//             ),
//           ),

//           // Bottom pill (fixed)

//           // Loader overlay when no order yet
//           // if (_loading && !_hasOrder)
//           //   Center(
//           //     child: SizedBox(
//           //       width: 48,
//           //       height: 48,
//           //       child: CircularProgressIndicator(
//           //         color: colorScheme.primary,
//           //       ),
//           //     ),
//           //   ),
//         ],
//       ),
//     );
//   }
// }

// /// MODELS

// class AcceptedOrder {
//   final String? orderId;
//   final String? message;
//   final String? restaurantName;
//   final String? restaurantLocation;
//   final OrderDetails? orderDetails;
//   final DeliveryFlow? deliveryFlow;
//   final RiderDetails? riderDetails;

//   AcceptedOrder({
//     this.orderId,
//     this.message,
//     this.restaurantName,
//     this.restaurantLocation,
//     this.orderDetails,
//     this.deliveryFlow,
//     this.riderDetails,
//   });

//   factory AcceptedOrder.fromJson(Map<String, dynamic> json) {
//     RiderDetails? rider;
//     if (json['riderDetails'] != null &&
//         json['riderDetails'] is Map<String, dynamic>) {
//       rider =
//           RiderDetails.fromJson(json['riderDetails'] as Map<String, dynamic>);
//     }

//     return AcceptedOrder(
//       orderId: json['orderId']?.toString(),
//       message: json['message'] as String?,
//       restaurantName: json['restaurantName'] as String?,
//       restaurantLocation: json['restaurantLocation'] as String?,
//       orderDetails: json['orderDetails'] != null
//           ? OrderDetails.fromJson(json['orderDetails'] as Map<String, dynamic>)
//           : null,
//       deliveryFlow: json['deliveryFlow'] != null
//           ? DeliveryFlow.fromJson(json['deliveryFlow'] as Map<String, dynamic>)
//           : null,
//       riderDetails: rider,
//     );
//   }
// }

// class OrderDetails {
//   final int? totalItems;
//   final String? subTotal;
//   final String? deliveryCharge;
//   final String? totalPayable;
//     final String? gst;
//   final String? gstDelivery;
//   final String? platform;

//   final String? packing;


//   OrderDetails({
//     this.totalItems,
//     this.subTotal,
//     this.deliveryCharge,
//     this.totalPayable,
//       this.gst,

//   this.gstDelivery,

//   this.platform,
//     this.packing,


//   });

//   factory OrderDetails.fromJson(Map<String, dynamic> json) {
//     return OrderDetails(
//       totalItems: json['totalItems'] is int
//           ? json['totalItems'] as int
//           : int.tryParse('${json['totalItems'] ?? 0}'),
//       subTotal: json['subTotal']?.toString(),
//       deliveryCharge: json['deliveryCharge']?.toString(),
//       totalPayable: json['totalPayable']?.toString(),
//             gst: json['gstCharges']?.toString(),
//                   gstDelivery: json['gstOnDelivery']?.toString(),
//                         packing: json['packingCharges']?.toString(),
//                               platform: json['platformCharge']?.toString(),
//     );
//   }
// }

// class DeliveryFlow {
//   final FlowEndpoint? restaurant;
//   final FlowEndpoint? user;

//   DeliveryFlow({this.restaurant, this.user});

//   factory DeliveryFlow.fromJson(Map<String, dynamic> json) {
//     return DeliveryFlow(
//       restaurant: json['restaurant'] != null
//           ? FlowEndpoint.fromJson(json['restaurant'] as Map<String, dynamic>)
//           : null,
//       user: json['user'] != null
//           ? FlowEndpoint.fromJson(json['user'] as Map<String, dynamic>)
//           : null,
//     );
//   }
// }

// class FlowEndpoint {
//   final String? name;
//   final String? time;
//   final UserAddress? address;

//   FlowEndpoint({this.name, this.time, this.address});

//   factory FlowEndpoint.fromJson(Map<String, dynamic> json) {
//     return FlowEndpoint(
//       name: json['name'] as String?,
//       time: json['time'] as String?,
//       address: UserAddress.fromJson(json['address'] as Map<String, dynamic>?),
//     );
//   }
// }

// class UserAddress {
//   final LocationPoint? location;
//   final String? street;
//   final String? city;
//   final String? state;
//   final String? country;
//   final String? postalCode;
//   final String? addressType;

//   UserAddress({
//     this.location,
//     this.street,
//     this.city,
//     this.state,
//     this.country,
//     this.postalCode,
//     this.addressType,
//   });

//   factory UserAddress.fromJson(Map<String, dynamic>? json) {
//     if (json == null) return UserAddress();
//     return UserAddress(
//       location: LocationPoint.fromJson(json['location'] as Map<String, dynamic>?),
//       street: json['street'] as String?,
//       city: json['city'] as String?,
//       state: json['state'] as String?,
//       country: json['country'] as String?,
//       postalCode: json['postalCode'] as String?,
//       addressType: json['addressType'] as String?,
//     );
//   }
// }

// class LocationPoint {
//   final String? type;
//   final List<double>? coordinates;

//   LocationPoint({this.type, this.coordinates});

//   factory LocationPoint.fromJson(Map<String, dynamic>? json) {
//     if (json == null) return LocationPoint();
//     return LocationPoint(
//       type: json['type'] as String?,
//       coordinates: (json['coordinates'] as List?)
//               ?.map((e) => (e as num).toDouble())
//               .toList() ??
//           [],
//     );
//   }
// }

// class RiderDetails {
//   final String? id;
//   final String? name;
//   final String? contact;
//   final String? image;

//   RiderDetails({this.id, this.name, this.contact, this.image});

//   factory RiderDetails.fromJson(Map<String, dynamic> json) {
//     return RiderDetails(
//       id: json['id']?.toString(),
//       name: json['name'] as String?,
//       contact: json['contact'] as String?,
//       image: json['profileImage'] as String?,
//     );
//   }
// }






















// lib/screens/accepted_order_polling_screen.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:veegify/helper/storage_helper.dart';
import 'package:veegify/views/Booking/chat_screen.dart';
import 'package:veegify/views/Tracker/tracking_screen_osm.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AcceptedOrderPollingScreen extends StatefulWidget {
  final String? userId;
  final String? orderId;

  const AcceptedOrderPollingScreen({
    Key? key,
    this.userId,
    this.orderId,
  }) : super(key: key);

  @override
  State<AcceptedOrderPollingScreen> createState() =>
      _AcceptedOrderPollingScreenState();
}

class _AcceptedOrderPollingScreenState
    extends State<AcceptedOrderPollingScreen> with SingleTickerProviderStateMixin {
  static const _pollInterval = Duration(seconds: 5);
  Timer? _pollTimer;
  bool _isFirstLoad = true;
  bool _hasOrder = false;
  bool _hasRider = false;
  AcceptedOrder? _order;

  late final AnimationController _hourglassController;
  late final Animation<double> _hourglassAnimation;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();

    _hourglassController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _hourglassAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_hourglassController);
    _hourglassController.repeat();

    _startPolling();
  }

  Future<void> _loadUserId() async {
    final user = UserPreferences.getUser();
    if (user != null && mounted) {
      setState(() {
        userId = user.userId;
      });
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _hourglassController.dispose();
    super.dispose();
  }

  void _startPolling() async {
    await _fetchAcceptedOrder(isInitialLoad: true);

    if (!_hasRider) {
      _pollTimer = Timer.periodic(_pollInterval, (t) async {
        if (_hasRider) {
          t.cancel();
          return;
        }
        await _fetchAcceptedOrder(isInitialLoad: false);
      });
    }
  }

  Future<void> _fetchAcceptedOrder({bool isInitialLoad = false}) async {
    if (!mounted) return;
    
    // Only show loading on first load, not on polling
    if (isInitialLoad) {
      setState(() {
        _isFirstLoad = true;
      });
    }

    try {
      Uri url;

      if (widget.orderId != null && widget.userId != null) {
        url = Uri.parse(
          'https://api.vegiffyy.com/api/acceptedorders/${widget.userId}/${widget.orderId}',
        );
      } else {
        url = Uri.parse(
          'https://api.vegiffyy.com/api/acceptedorders/${widget.userId ?? ''}',
        );
      }

      final resp = await http.get(url).timeout(const Duration(seconds: 10));

      if (resp.statusCode == 200) {
        final jsonBody = json.decode(resp.body);

        final success = jsonBody['success'] ?? false;
        final data = jsonBody['data'];

        if (success != true || data == null) {
          if (!mounted) return;
          setState(() {
            _isFirstLoad = false;
            _hasOrder = false;
            _hasRider = false;
            _order = null;
          });
          return;
        }

        Map<String, dynamic>? parsed;
        if (data is List && data.isNotEmpty) {
          parsed = data.first as Map<String, dynamic>;
        } else if (data is Map<String, dynamic>) {
          parsed = data;
        } else {
          if (!mounted) return;
          setState(() {
            _isFirstLoad = false;
            _hasOrder = false;
            _hasRider = false;
            _order = null;
          });
          return;
        }

        final order = AcceptedOrder.fromJson(parsed);
        final riderPresent = order.riderDetails != null;

        if (!mounted) return;
        setState(() {
          _order = order;
          _hasOrder = true;
          _hasRider = riderPresent;
          _isFirstLoad = false;
        });

        if (riderPresent) {
          _pollTimer?.cancel();
          _hourglassController.stop();
        }
      } else {
        if (!mounted) return;
        setState(() {
          _isFirstLoad = false;
          _hasOrder = false;
          _hasRider = false;
          _order = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isFirstLoad = false;
      });
    }
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot call $phone'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  /// --- UI BUILD HELPERS ---

  /// Main card area
  Widget _buildCardContent() {
    if (_isFirstLoad) {
      return _buildLoadingSkeleton();
    }
    
    if (!_hasOrder || _order == null) {
      return _noOrderAnimation();
    } else {
      return _acceptedOrderCard(_order!);
    }
  }

  /// Loading skeleton for better UX
  Widget _buildLoadingSkeleton() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isWeb = kIsWeb;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isWeb ? 32 : 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: isWeb ? 80 : 60,
              height: isWeb ? 80 : 60,
              child: CircularProgressIndicator(
                strokeWidth: isWeb ? 4 : 3,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading order details...',
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: isWeb ? 18 : 16,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Lottie animation when order not accepted / no data yet
Widget _noOrderAnimation() {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final isWeb = kIsWeb;
  final screenWidth = MediaQuery.of(context).size.width;

  // Responsive sizing
  final double lottieHeight = isWeb 
      ? (screenWidth > 1200 ? 200 : 200) 
      : 220;
  final double horizontalPadding = isWeb ? (screenWidth > 1200 ? 80 : 48) : 24.0;
  final double titleFontSize = isWeb ? (screenWidth > 1200 ? 28 : 24) : 18;
  final double bodyFontSize = isWeb ? (screenWidth > 1200 ? 18 : 16) : 14;

  return Container(
    width: double.infinity,
    // 👇 REDUCE THIS VERTICAL PADDING
    padding: EdgeInsets.symmetric(
      horizontal: horizontalPadding, 
      vertical: isWeb ? 16 : 8,  // ← Changed from 32/16 to 16/8
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: lottieHeight,
          width: lottieHeight,
          child: Lottie.asset(
            'assets/lottie/food_preparing.json',
            repeat: true,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: lottieHeight,
                width: lottieHeight,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.restaurant_menu,
                  size: lottieHeight * 0.4,
                  color: Colors.grey.shade400,
                ),
              );
            },
          ),
        ),
        // 👇 REDUCE THIS SPACING
        const SizedBox(height: 16),  // ← Changed from 32 to 16
        
        Text(
          'Finding a Vegiffy Partner',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: titleFontSize,
            color: colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        // 👇 REDUCE THIS SPACING
        const SizedBox(height: 8),  // ← Changed from 16 to 8
        
        Text(
          'We are looking for a Vegiffy Green Partner near you\nto accept your order. This usually takes just a few minutes.',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: bodyFontSize,
            color: colorScheme.onSurface.withOpacity(0.7),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        if (isWeb) ...[
          // 👇 REDUCE THIS SPACING
          const SizedBox(height: 16),  // ← Changed from 24 to 16
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildWaitingIndicator(colorScheme),
            ],
          ),
        ],
      ],
    ),
  );
}

  Widget _buildWaitingIndicator(ColorScheme colorScheme) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: colorScheme.primary,
      ),
    );
  }

  Widget _acceptedOrderCard(AcceptedOrder order) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive padding and margins
    final double cardMargin = isWeb 
        ? (screenWidth > 1200 ? 60 : 40) 
        : 16;
    final double cardPadding = isWeb ? (screenWidth > 1200 ? 28 : 24) : 16;
    final double fontSizeTitle = isWeb ? (screenWidth > 1200 ? 22 : 20) : 16;
    final double fontSizeBody = isWeb ? (screenWidth > 1200 ? 18 : 16) : 14;
    final double fontSizeLarge = isWeb ? (screenWidth > 1200 ? 32 : 28) : 22;

    return Card(
      elevation: isWeb ? 12 : 6,
      shadowColor: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isWeb ? 28 : 16),
      ),
      margin: EdgeInsets.symmetric(horizontal: cardMargin, vertical: isWeb ? 24 : 12),
      color: theme.cardColor,
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success header
            Container(
              padding: EdgeInsets.all(isWeb ? 16 : 12),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isWeb ? 20 : 16),
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
                      Icons.check,
                      color: Colors.white,
                      size: isWeb ? 28 : 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Accepted!',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: fontSizeTitle + 2,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your order has been accepted by a Vegiffy Green Partner',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: fontSizeBody - 1,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Restaurant info
            _buildInfoRow(
              icon: Icons.store,
              title: 'Restaurant',
              subtitle: order.restaurantName ?? 'Unknown',
              location: order.restaurantLocation,
              theme: theme,
              colorScheme: colorScheme,
              isWeb: isWeb,
              fontSizeBody: fontSizeBody,
            ),

            const SizedBox(height: 20),

            // Order details section
            Text(
              'Order Summary',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: fontSizeTitle,
              ),
            ),

            const SizedBox(height: 16),

            // Order details grid for web
            if (isWeb && screenWidth > 900) ...[
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 20,
                mainAxisSpacing: 12,
                children: [
                  _buildDetailCard(
                    'Items',
                    order.orderDetails?.totalItems?.toString() ?? '0',
                    Icons.shopping_bag,
                    theme,
                    colorScheme,
                  ),
                  _buildDetailCard(
                    'Sub Total',
                    order.orderDetails?.subTotal ?? '₹0',
                    Icons.currency_rupee,
                    theme,
                    colorScheme,
                  ),
                  _buildDetailCard(
                    'Delivery',
                    order.orderDetails?.deliveryCharge ?? '₹0',
                    Icons.delivery_dining,
                    theme,
                    colorScheme,
                  ),
                  _buildDetailCard(
                    'GST',
                    order.orderDetails?.gst ?? '₹0',
                    Icons.receipt,
                    theme,
                    colorScheme,
                  ),
                  _buildDetailCard(
                    'Packing',
                    order.orderDetails?.packing ?? '₹0',
                    Icons.inventory,
                    theme,
                    colorScheme,
                  ),
                  _buildDetailCard(
                    'Platform',
                    order.orderDetails?.platform ?? '₹0',
                    Icons.devices,
                    theme,
                    colorScheme,
                  ),
                ],
              ),
            ] else ...[
              // Mobile/tablet list view
              ..._buildDetailList(order, theme, colorScheme, isWeb, fontSizeBody),
            ],

            const SizedBox(height: 20),

            // Total
            Container(
              padding: EdgeInsets.all(isWeb ? 20 : 16),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(isWeb ? 20 : 16),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Payable',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: fontSizeTitle,
                    ),
                  ),
                  Text(
                    order.orderDetails?.totalPayable ?? '₹0',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: fontSizeLarge,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String subtitle,
    String? location,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required bool isWeb,
    required double fontSizeBody,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: colorScheme.primary,
            size: isWeb ? 28 : 22,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: fontSizeBody,
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: fontSizeBody + 2,
                ),
              ),
              if (location != null && location.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: isWeb ? 18 : 14,
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: fontSizeBody - 1,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDetailList(
    AcceptedOrder order,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isWeb,
    double fontSizeBody,
  ) {
    return [
      _buildDetailRow(
        'Total Items',
        order.orderDetails?.totalItems?.toString() ?? '0',
        theme,
        colorScheme,
        isWeb,
        fontSizeBody,
      ),
      _buildDetailRow(
        'Sub Total',
        order.orderDetails?.subTotal ?? '₹0',
        theme,
        colorScheme,
        isWeb,
        fontSizeBody,
      ),
      _buildDetailRow(
        'Delivery Charge',
        order.orderDetails?.deliveryCharge ?? '₹0',
        theme,
        colorScheme,
        isWeb,
        fontSizeBody,
      ),
      _buildDetailRow(
        'Delivery GST',
        order.orderDetails?.gstDelivery ?? '₹0',
        theme,
        colorScheme,
        isWeb,
        fontSizeBody,
      ),
      _buildDetailRow(
        'Platform Charge',
        order.orderDetails?.platform ?? '₹0',
        theme,
        colorScheme,
        isWeb,
        fontSizeBody,
      ),
      _buildDetailRow(
        'Packing Charge',
        order.orderDetails?.packing ?? '₹0',
        theme,
        colorScheme,
        isWeb,
        fontSizeBody,
      ),
      _buildDetailRow(
        'GST',
        order.orderDetails?.gst ?? '₹0',
        theme,
        colorScheme,
        isWeb,
        fontSizeBody,
      ),
    ];
  }

  Widget _buildDetailRow(
    String label,
    String value,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isWeb,
    double fontSizeBody,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: fontSizeBody,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: fontSizeBody,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomPill() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;

    final waitingText = _hasRider ? 'Contact Delivery Partner' : 'Finding';
    final pillColor = _hasRider
        ? colorScheme.primary.withOpacity(0.15)
        : colorScheme.secondaryContainer;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.all(isWeb ? 24 : 16),
        child: Container(
          decoration: BoxDecoration(
            color: pillColor,
            borderRadius: BorderRadius.circular(isWeb ? 60 : 40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: isWeb ? 20 : 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: isWeb ? 2 : 1,
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isWeb ? (screenWidth > 1200 ? 32 : 24) : 20,
            vertical: isWeb ? 16 : 12,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(isWeb ? 4 : 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: isWeb ? 22 : 18,
                  backgroundColor: theme.cardColor,
                  child: Icon(
                    _hasRider ? Icons.person : Icons.hourglass_empty,
                    color: colorScheme.primary,
                    size: isWeb ? 26 : 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _hasRider ? 'Partner Assigned' : 'Finding Partner',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: isWeb ? 13 : 11,
                      color: colorScheme.onSurface.withOpacity(0.6),
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    waitingText,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: isWeb ? 18 : 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              if (!_hasRider)
                RotationTransition(
                  turns: _hourglassAnimation,
                  child: Container(
                    padding: EdgeInsets.all(isWeb ? 12 : 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.hourglass_bottom,
                      color: colorScheme.primary,
                      size: isWeb ? 24 : 18,
                    ),
                  ),
                )
              else
                Container(
                  padding: EdgeInsets.all(isWeb ? 10 : 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green.shade600,
                    size: isWeb ? 28 : 22,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _deliveryFlowWidget(AcceptedOrder order) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive sizing
    final double horizontalPadding = isWeb 
        ? (screenWidth > 1200 ? 60 : 40) 
        : 16;
    final double cardPadding = isWeb ? (screenWidth > 1200 ? 28 : 24) : 16;
    final double fontSizeTitle = isWeb ? (screenWidth > 1200 ? 20 : 18) : 15;
    final double fontSizeBody = isWeb ? (screenWidth > 1200 ? 18 : 16) : 14;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: isWeb ? 20 : 12),
      child: Card(
        elevation: isWeb ? 8 : 4,
        shadowColor: Colors.black.withOpacity(0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isWeb ? 28 : 16),
        ),
        color: theme.cardColor,
        child: Padding(
          padding: EdgeInsets.all(cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delivery Progress',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: fontSizeTitle + 4,
                  color: colorScheme.primary,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Timeline
              _buildTimelineStep(
                isCompleted: true,
                title: 'Order Accepted',
                subtitle: 'Restaurant confirmed your order',
                icon: Icons.check_circle,
                theme: theme,
                colorScheme: colorScheme,
                isWeb: isWeb,
                fontSizeBody: fontSizeBody,
              ),
              
              _buildTimelineStep(
                isCompleted: order.riderDetails != null,
                title: 'Partner Assigned',
                subtitle: order.riderDetails != null 
                    ? '${order.riderDetails?.name} is on the way' 
                    : 'Finding a delivery partner',
                icon: Icons.delivery_dining,
                theme: theme,
                colorScheme: colorScheme,
                isWeb: isWeb,
                fontSizeBody: fontSizeBody,
              ),
              
              _buildTimelineStep(
                isCompleted: false,
                title: 'Out for Delivery',
                subtitle: 'Partner will pick up your order soon',
                icon: Icons.directions_bike,
                theme: theme,
                colorScheme: colorScheme,
                isWeb: isWeb,
                fontSizeBody: fontSizeBody,
                isLast: true,
              ),
              
              const SizedBox(height: 24),
              
              if (order.riderDetails != null) ...[
                const Divider(),
                const SizedBox(height: 16),
                
                // Rider section
                Text(
                  'Your Delivery Partner',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: fontSizeTitle,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Container(
                  padding: EdgeInsets.all(isWeb ? 20 : 16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(isWeb ? 20 : 16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: isWeb ? 36 : 28,
                        backgroundColor: colorScheme.primary.withOpacity(0.1),
                        backgroundImage: order.riderDetails?.image != null
                            ? NetworkImage(order.riderDetails!.image!)
                            : null,
                        child: order.riderDetails?.image == null
                            ? Icon(
                                Icons.person,
                                size: isWeb ? 36 : 28,
                                color: colorScheme.primary,
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.riderDetails?.name ?? 'Delivery Partner',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: fontSizeTitle,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              order.riderDetails?.contact ?? 'Contact not available',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: fontSizeBody,
                                color: colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Action buttons
                      if (isWeb) ...[
                        const SizedBox(width: 16),
                        _buildActionButton(
                          icon: Icons.location_on_outlined,
                          label: 'Track',
                          onTap: _navigateToTracking(order),
                          theme: theme,
                          colorScheme: colorScheme,
                          isLarge: screenWidth > 1200,
                        ),
                        const SizedBox(width: 12),
                        _buildActionButton(
                          icon: Icons.chat,
                          label: 'Chat',
                          onTap: _navigateToChat(order),
                          theme: theme,
                          colorScheme: colorScheme,
                          isLarge: screenWidth > 1200,
                        ),
                        const SizedBox(width: 12),
                        _buildActionButton(
                          icon: Icons.call,
                          label: 'Call',
                          onTap: () => _launchPhone(order.riderDetails?.contact ?? ''),
                          theme: theme,
                          colorScheme: colorScheme,
                          isLarge: screenWidth > 1200,
                        ),
                      ] else ...[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildActionIcon(
                              Icons.location_on_outlined,
                              _navigateToTracking(order),
                              colorScheme,
                            ),
                            const SizedBox(width: 8),
                            _buildActionIcon(
                              Icons.chat,
                              _navigateToChat(order),
                              colorScheme,
                            ),
                            const SizedBox(width: 8),
                            _buildActionIcon(
                              Icons.call,
                              () => _launchPhone(order.riderDetails?.contact ?? ''),
                              colorScheme,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  VoidCallback _navigateToTracking(AcceptedOrder order) {
    return () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TrackingScreenGoogle(
            deliveryBoyId: '${order.riderDetails?.id.toString()}',
            userId: '$userId',
            initialCenter: LatLng(
              order.deliveryFlow?.user?.address?.location
                      ?.coordinates?[1] ??
                  0.0,
              order.deliveryFlow?.user?.address?.location
                      ?.coordinates?[0] ??
                  0.0,
            ),
          ),
        ),
      );
    };
  }

  VoidCallback _navigateToChat(AcceptedOrder order) {
    return () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            deliveryBoyId: order.riderDetails?.id?.toString() ?? "",
            userId: widget.userId.toString(),
            title: 'Chat with Rider',
          ),
        ),
      );
    };
  }

  Widget _buildTimelineStep({
    required bool isCompleted,
    required String title,
    required String subtitle,
    required IconData icon,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required bool isWeb,
    required double fontSizeBody,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: isWeb ? 48 : 40,
              height: isWeb ? 48 : 40,
              decoration: BoxDecoration(
                color: isCompleted 
                    ? colorScheme.primary 
                    : colorScheme.surfaceVariant,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted 
                      ? Colors.transparent 
                      : colorScheme.outline.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                isCompleted ? Icons.check : icon,
                color: isCompleted 
                    ? Colors.white 
                    : colorScheme.onSurfaceVariant,
                size: isWeb ? 24 : 20,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: isWeb ? 50 : 40,
                color: isCompleted 
                    ? colorScheme.primary.withOpacity(0.3)
                    : colorScheme.outline.withOpacity(0.2),
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : (isWeb ? 24 : 16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: fontSizeBody + 2,
                    color: isCompleted 
                        ? colorScheme.primary 
                        : colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: fontSizeBody,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionIcon(IconData icon, VoidCallback onTap, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: colorScheme.primary,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ThemeData theme,
    required ColorScheme colorScheme,
    bool isLarge = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isLarge ? 20 : 16,
          vertical: isLarge ? 12 : 10,
        ),
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: isLarge ? 22 : 18, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: isLarge ? 16 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isWeb = kIsWeb;
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        // decoration: isWeb
        //     ? BoxDecoration(
        //         gradient: LinearGradient(
        //           begin: Alignment.topCenter,
        //           end: Alignment.bottomCenter,
        //           colors: [
        //             colorScheme.primary.withOpacity(0.05),
        //             colorScheme.background,
        //             colorScheme.background,
        //           ],
        //         ),
        //       )
        //     : null,
        child: Stack(
          children: [
            // Scrollable content
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: isWeb ? 120 : 100,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Padding(
                                padding: EdgeInsets.all(isWeb ? 24 : 16),
                                child: Row(
                                  children: [
                                    if (!isWeb)
                                      IconButton(
                                        icon: Icon(
                                          Icons.arrow_back_ios_new,
                                          color: colorScheme.onBackground,
                                        ),
                                        onPressed: () => Navigator.of(context).maybePop(),
                                      ),
                                    if (isWeb) ...[
                                      Text(
                                        'Order Status',
                                        style: theme.textTheme.headlineMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colorScheme.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        child: Text(
                                          'Order #${widget.orderId?.substring(0, 8) ?? 'N/A'}',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              
                              // Main content
                              _buildCardContent(),
                              
                              // Delivery flow if order exists
                              if (_hasOrder && _order != null && !_isFirstLoad)
                                _deliveryFlowWidget(_order!),
                              
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom pill (fixed at bottom)
            _bottomPill(),
          ],
        ),
      ),
    );
  }
}

// MODELS (unchanged - keep as they were)
class AcceptedOrder {
  final String? orderId;
  final String? message;
  final String? restaurantName;
  final String? restaurantLocation;
  final OrderDetails? orderDetails;
  final DeliveryFlow? deliveryFlow;
  final RiderDetails? riderDetails;

  AcceptedOrder({
    this.orderId,
    this.message,
    this.restaurantName,
    this.restaurantLocation,
    this.orderDetails,
    this.deliveryFlow,
    this.riderDetails,
  });

  factory AcceptedOrder.fromJson(Map<String, dynamic> json) {
    RiderDetails? rider;
    if (json['riderDetails'] != null &&
        json['riderDetails'] is Map<String, dynamic>) {
      rider =
          RiderDetails.fromJson(json['riderDetails'] as Map<String, dynamic>);
    }

    return AcceptedOrder(
      orderId: json['orderId']?.toString(),
      message: json['message'] as String?,
      restaurantName: json['restaurantName'] as String?,
      restaurantLocation: json['restaurantLocation'] as String?,
      orderDetails: json['orderDetails'] != null
          ? OrderDetails.fromJson(json['orderDetails'] as Map<String, dynamic>)
          : null,
      deliveryFlow: json['deliveryFlow'] != null
          ? DeliveryFlow.fromJson(json['deliveryFlow'] as Map<String, dynamic>)
          : null,
      riderDetails: rider,
    );
  }
}

class OrderDetails {
  final int? totalItems;
  final String? subTotal;
  final String? deliveryCharge;
  final String? totalPayable;
  final String? gst;
  final String? gstDelivery;
  final String? platform;
  final String? packing;

  OrderDetails({
    this.totalItems,
    this.subTotal,
    this.deliveryCharge,
    this.totalPayable,
    this.gst,
    this.gstDelivery,
    this.platform,
    this.packing,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    return OrderDetails(
      totalItems: json['totalItems'] is int
          ? json['totalItems'] as int
          : int.tryParse('${json['totalItems'] ?? 0}'),
      subTotal: json['subTotal']?.toString(),
      deliveryCharge: json['deliveryCharge']?.toString(),
      totalPayable: json['totalPayable']?.toString(),
      gst: json['gstCharges']?.toString(),
      gstDelivery: json['gstOnDelivery']?.toString(),
      packing: json['packingCharges']?.toString(),
      platform: json['platformCharge']?.toString(),
    );
  }
}

class DeliveryFlow {
  final FlowEndpoint? restaurant;
  final FlowEndpoint? user;

  DeliveryFlow({this.restaurant, this.user});

  factory DeliveryFlow.fromJson(Map<String, dynamic> json) {
    return DeliveryFlow(
      restaurant: json['restaurant'] != null
          ? FlowEndpoint.fromJson(json['restaurant'] as Map<String, dynamic>)
          : null,
      user: json['user'] != null
          ? FlowEndpoint.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}

class FlowEndpoint {
  final String? name;
  final String? time;
  final UserAddress? address;

  FlowEndpoint({this.name, this.time, this.address});

  factory FlowEndpoint.fromJson(Map<String, dynamic> json) {
    return FlowEndpoint(
      name: json['name'] as String?,
      time: json['time'] as String?,
      address: UserAddress.fromJson(json['address'] as Map<String, dynamic>?),
    );
  }
}

class UserAddress {
  final LocationPoint? location;
  final String? street;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final String? addressType;

  UserAddress({
    this.location,
    this.street,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.addressType,
  });

  factory UserAddress.fromJson(Map<String, dynamic>? json) {
    if (json == null) return UserAddress();
    return UserAddress(
      location: LocationPoint.fromJson(json['location'] as Map<String, dynamic>?),
      street: json['street'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      postalCode: json['postalCode'] as String?,
      addressType: json['addressType'] as String?,
    );
  }
}

class LocationPoint {
  final String? type;
  final List<double>? coordinates;

  LocationPoint({this.type, this.coordinates});

  factory LocationPoint.fromJson(Map<String, dynamic>? json) {
    if (json == null) return LocationPoint();
    return LocationPoint(
      type: json['type'] as String?,
      coordinates: (json['coordinates'] as List?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
    );
  }
}

class RiderDetails {
  final String? id;
  final String? name;
  final String? contact;
  final String? image;

  RiderDetails({this.id, this.name, this.contact, this.image});

  factory RiderDetails.fromJson(Map<String, dynamic> json) {
    return RiderDetails(
      id: json['id']?.toString(),
      name: json['name'] as String?,
      contact: json['contact'] as String?,
      image: json['profileImage'] as String?,
    );
  }
}