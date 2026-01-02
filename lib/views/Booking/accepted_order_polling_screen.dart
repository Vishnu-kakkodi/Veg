
// // lib/screens/accepted_order_polling_screen.dart
// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/widgets.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:veegify/helper/storage_helper.dart';
// import 'package:veegify/views/Booking/chat_screen.dart';
// import 'package:veegify/views/Tracker/tracking_screen_osm.dart'; // add url_launcher in pubspec if you want call feature
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class AcceptedOrderPollingScreen extends StatefulWidget {
//   final String? userId;
//   final String? orderId;
//   const AcceptedOrderPollingScreen({Key? key, this.userId, this.orderId})
//       : super(key: key);

//   @override
//   State<AcceptedOrderPollingScreen> createState() =>
//       _AcceptedOrderPollingScreenState();
// }

// class _AcceptedOrderPollingScreenState extends State<AcceptedOrderPollingScreen>
//     with SingleTickerProviderStateMixin {
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
//             'http://31.97.206.144:5051/api/acceptedorders/${widget.userId}/${widget.orderId}');
//       } else {
//         url = Uri.parse(
//             'http://31.97.206.144:5051/api/acceptedorders/${widget.userId ?? ''}');
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

//   Widget _buildCardContent() {
//     if (!_hasOrder) {
//       return _acceptedOrderCardPlaceholder();
//     } else {
//       return _acceptedOrderCard(_order!);
//     }
//   }

//   Widget _acceptedOrderCardPlaceholder() {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     return Card(
//       elevation: 6,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       color: theme.cardColor,
//       child: Padding(
//         padding: const EdgeInsets.all(14),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Row(children: [
//             Container(
//               padding: const EdgeInsets.all(6),
//               decoration: BoxDecoration(
//                 color: colorScheme.primary.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(Icons.check, color: colorScheme.primary, size: 20),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 'Order From',
//                 style: theme.textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ]),
//           const SizedBox(height: 12),
//           Divider(color: colorScheme.outline.withOpacity(0.3)),
//           const SizedBox(height: 8),
//           Text(
//             'Order Details',
//             style: theme.textTheme.titleMedium?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           _detailRow('Total Items', '---', theme, colorScheme),
//           _detailRow('Sub Total', '---', theme, colorScheme),
//           _detailRow('Delivery charge', '---', theme, colorScheme),
//           const SizedBox(height: 8),
//           Divider(color: colorScheme.outline.withOpacity(0.3)),
//           const SizedBox(height: 8),
//           Text(
//             'Total Payable',
//             style: theme.textTheme.titleMedium?.copyWith(
//               color: colorScheme.primary,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             '---',
//             style: theme.textTheme.titleLarge?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ]),
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
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Container(
//               padding: const EdgeInsets.all(6),
//               decoration: BoxDecoration(
//                 color: colorScheme.primary.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(Icons.check, color: colorScheme.primary, size: 20),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Vegiffyy Green Partner Accepted',
//                     style: theme.textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Row(children: [
//                     Icon(Icons.store, size: 16, color: colorScheme.primary),
//                     const SizedBox(width: 6),
//                     Expanded(
//                       child: Text(
//                         order.restaurantName ?? 'Unknown',
//                         style: theme.textTheme.bodyMedium,
//                       ),
//                     ),
//                   ]),
//                   const SizedBox(height: 6),
//                   Row(children: [
//                     Icon(Icons.location_on,
//                         size: 14,
//                         color: colorScheme.onSurface.withOpacity(0.6)),
//                     const SizedBox(width: 6),
//                     Expanded(
//                       child: Text(
//                         order.restaurantLocation ?? '',
//                         style: theme.textTheme.bodySmall?.copyWith(
//                           color: colorScheme.onSurface.withOpacity(0.7),
//                         ),
//                       ),
//                     ),
//                   ]),
//                 ],
//               ),
//             ),
//           ]),
//           const SizedBox(height: 12),
//           Divider(color: colorScheme.outline.withOpacity(0.3)),
//           const SizedBox(height: 8),
//           Text(
//             'Order Details',
//             style: theme.textTheme.titleMedium?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           _detailRow(
//             'Total Items',
//             order.orderDetails?.totalItems?.toString() ?? '0',
//             theme,
//             colorScheme,
//           ),
//           _detailRow('Sub Total', order.orderDetails?.subTotal ?? '₹0', theme,
//               colorScheme),
//           _detailRow(
//             'Delivery charge',
//             order.orderDetails?.deliveryCharge ?? '₹0',
//             theme,
//             colorScheme,
//           ),
//           const SizedBox(height: 10),
//           Divider(color: colorScheme.outline.withOpacity(0.3)),
//           const SizedBox(height: 8),
//           Text(
//             'Total Payable',
//             style: theme.textTheme.titleMedium?.copyWith(
//               color: colorScheme.primary,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             order.orderDetails?.totalPayable ?? '₹0',
//             style: theme.textTheme.titleLarge?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ]),
//       ),
//     );
//   }

//   Widget _detailRow(
//       String title, String value, ThemeData theme, ColorScheme colorScheme) {
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
//     final pillColor =
//         _hasRider ? colorScheme.primary.withOpacity(0.1) : colorScheme.secondaryContainer;

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
//                 color: const Color.fromARGB(255, 186, 186, 186).withOpacity(0.5),
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
//               if (order.deliveryFlow?.restaurant != null) const SizedBox(width: 8),
//               Text(
//                 '5mins',
//                 style: theme.textTheme.bodyMedium?.copyWith(
//                   color: colorScheme.error,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
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
//                       ? Icon(Icons.person, color: colorScheme.onSurfaceVariant)
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
//           Positioned.fill(
//             child: Image.asset(
//               'assets/images/map_placeholder.png',
//               fit: BoxFit.cover,
//             ),
//           ),
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
//                 // padding bottom so content doesn't go under bottom pill
//                 padding: const EdgeInsets.only(bottom: 120),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 8),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 8),
//                       child: Row(
//                         children: [
//                           // IconButton(
//                           //   icon: Icon(
//                           //     Icons.arrow_back_ios_new,
//                           //     color: colorScheme.onBackground,
//                           //   ),
//                           //   onPressed: () => Navigator.of(context).maybePop(),
//                           // ),
//                                     _bottomPill(),

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
//                               'We are waiting for the vendor to confirm pickup. We will update this screen as soon as it happens.',
//                               textAlign: TextAlign.center,
//                               style: theme.textTheme.bodyMedium?.copyWith(
//                                 color: colorScheme.onSurface.withOpacity(0.6),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     const SizedBox(height: 40),
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           // Bottom pill (fixed)

//           // Loader overlay when no order yet
//           if (_loading && !_hasOrder)
//             Center(
//               child: SizedBox(
//                 width: 48,
//                 height: 48,
//                 child: CircularProgressIndicator(
//                   color: colorScheme.primary,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// /// Models (unchanged - they don't contain UI)
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

//   OrderDetails({
//     this.totalItems,
//     this.subTotal,
//     this.deliveryCharge,
//     this.totalPayable,
//   });

//   factory OrderDetails.fromJson(Map<String, dynamic> json) {
//     return OrderDetails(
//       totalItems: json['totalItems'] is int
//           ? json['totalItems'] as int
//           : int.tryParse('${json['totalItems'] ?? 0}'),
//       subTotal: json['subTotal']?.toString(),
//       deliveryCharge: json['deliveryCharge']?.toString(),
//       totalPayable: json['totalPayable']?.toString(),
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
  bool _loading = true;
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
    await _fetchAcceptedOrder();

    if (!_hasRider) {
      _pollTimer = Timer.periodic(_pollInterval, (t) async {
        if (_hasRider) {
          t.cancel();
          return;
        }
        await _fetchAcceptedOrder();
      });
    }
  }

  Future<void> _fetchAcceptedOrder() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
    });

    try {
      Uri url;

      if (widget.orderId != null && widget.userId != null) {
        url = Uri.parse(
          'http://31.97.206.144:5051/api/acceptedorders/${widget.userId}/${widget.orderId}',
        );
      } else {
        url = Uri.parse(
          'http://31.97.206.144:5051/api/acceptedorders/${widget.userId ?? ''}',
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
            _loading = false;
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
            _loading = false;
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
          _loading = false;
        });

        if (riderPresent) {
          _pollTimer?.cancel();
          _hourglassController.stop();
        }
      } else {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _hasOrder = false;
          _hasRider = false;
          _order = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
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
    if (!_hasOrder || _order == null) {
      // 👉 No data from backend: show Lottie instead of Order Form
      return _noOrderAnimation();
    } else {
      return _acceptedOrderCard(_order!);
    }
  }

  /// Lottie animation when order not accepted / no data yet
  Widget _noOrderAnimation() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: Lottie.asset(
              'assets/lottie/food_preparing.json', // 🔁 replace with your file path
              repeat: true,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'We are preparing your order',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onBackground,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Once a Vegiffy Green Partner accepts your order,\n'
            'you will see all the order details here.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _acceptedOrderCard(AcceptedOrder order) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vegiffy Green Partner Accepted',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(children: [
                      Icon(Icons.store, size: 16, color: colorScheme.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          order.restaurantName ?? 'Unknown',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          order.restaurantLocation ?? '',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Divider(color: colorScheme.outline.withOpacity(0.3)),
            const SizedBox(height: 8),
            Text(
              'Order Details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _detailRow(
              'Total Items',
              order.orderDetails?.totalItems?.toString() ?? '0',
              theme,
              colorScheme,
            ),
            _detailRow('Sub Total', order.orderDetails?.subTotal ?? '₹0', theme,
                colorScheme),
            _detailRow(
              'Delivery charge',
              order.orderDetails?.deliveryCharge ?? '₹0',
              theme,
              colorScheme,
            ),
                        _detailRow(
              'Delivery Gst',
              order.orderDetails?.gstDelivery ?? '₹0',
              theme,
              colorScheme,
            ),
                        _detailRow(
              'Platform charge',
              order.orderDetails?.platform ?? '₹0',
              theme,
              colorScheme,
            ),
                                    _detailRow(
              'Packing charge',
              order.orderDetails?.packing ?? '₹0',
              theme,
              colorScheme,
            ),
                                    _detailRow(
              'Gst charge',
              order.orderDetails?.gst ?? '₹0',
              theme,
              colorScheme,
            ),
            const SizedBox(height: 10),
            Divider(color: colorScheme.outline.withOpacity(0.3)),
            const SizedBox(height: 8),
            Text(
              'Total Payable',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              order.orderDetails?.totalPayable ?? '₹0',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
    String title,
    String value,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ]),
    );
  }

  Widget _bottomPill() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final waitingText = _hasRider ? 'Contact rider' : 'Waiting response';
    final pillColor = _hasRider
        ? colorScheme.primary.withOpacity(0.1)
        : colorScheme.secondaryContainer;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
        child: Container(
          decoration: BoxDecoration(
            color: pillColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color:
                    const Color.fromARGB(255, 186, 186, 186).withOpacity(0.5),
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.cardColor,
              child: Icon(
                Icons.person_outline,
                color: colorScheme.onSurface,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              waitingText,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 12),
            if (!_hasRider)
              RotationTransition(
                turns: _hourglassAnimation,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.hourglass_bottom,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.done_all,
                  color: colorScheme.primary,
                ),
              ),
          ]),
        ),
      ),
    );
  }

  Widget _deliveryFlowWidget(AcceptedOrder order) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: theme.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(children: [
            Row(children: [
              Column(children: [
                Icon(Icons.store, size: 22, color: colorScheme.primary),
              ]),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.deliveryFlow?.restaurant?.name ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      order.deliveryFlow?.restaurant?.time ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              // if (order.deliveryFlow?.restaurant != null)
              //   const SizedBox(width: 8),
              // Text(
              //   '5mins',
              //   style: theme.textTheme.bodyMedium?.copyWith(
              //     color: colorScheme.error,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Column(children: [
                Icon(Icons.location_on, size: 22, color: colorScheme.primary),
              ]),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You - ${order.deliveryFlow?.user?.address?.street ?? order.deliveryFlow?.user?.address ?? ''}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      order.deliveryFlow?.user?.time ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 12),
            if (order.riderDetails != null)
              Divider(color: colorScheme.outline.withOpacity(0.3)),
            if (order.riderDetails != null)
              Row(children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: colorScheme.surfaceVariant,
                  backgroundImage: order.riderDetails?.image != null
                      ? NetworkImage(order.riderDetails!.image!)
                      : null,
                  child: order.riderDetails?.image == null
                      ? Icon(Icons.person,
                          color: colorScheme.onSurfaceVariant)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.riderDetails?.name ?? '',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Delivery • ${order.riderDetails?.contact ?? ''}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
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
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.location_on_outlined,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          deliveryBoyId:
                              order.riderDetails?.id?.toString() ?? "",
                          userId: widget.userId.toString(),
                          title: 'Chat with Rider',
                        ),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.chat,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    final phone = order.riderDetails?.contact ?? '';
                    if (phone.isNotEmpty) {
                      _launchPhone(phone);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('No phone number'),
                          backgroundColor: colorScheme.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.call,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ),
              ])
            else
              const SizedBox(),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          // Positioned.fill(
          //   child: Image.asset(
          //     'assets/images/map_placeholder.png',
          //     fit: BoxFit.cover,
          //   ),
          // ),
          Positioned.fill(
            child: Container(
              color: colorScheme.background.withOpacity(0.18),
            ),
          ),

          // Scrollable content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          // Back button (if you want to enable)
                          // IconButton(
                          //   icon: Icon(
                          //     Icons.arrow_back_ios_new,
                          //     color: colorScheme.onBackground,
                          //   ),
                          //   onPressed: () => Navigator.of(context).maybePop(),
                          // ),
                          const Spacer(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildCardContent(),
                    const SizedBox(height: 8),
                    if (_hasOrder && _order != null)
                      _deliveryFlowWidget(_order!),
                    if (!_hasOrder)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28.0, vertical: 6),
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              'We are waiting for the vendor to confirm pickup. '
                              'We will update this screen as soon as it happens.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                              _bottomPill(),

                  ],
                ),
              ),
            ),
          ),

          // Bottom pill (fixed)

          // Loader overlay when no order yet
          // if (_loading && !_hasOrder)
          //   Center(
          //     child: SizedBox(
          //       width: 48,
          //       height: 48,
          //       child: CircularProgressIndicator(
          //         color: colorScheme.primary,
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }
}

/// MODELS

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
