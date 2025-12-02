
// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:veegify/helper/storage_helper.dart';
// import 'package:veegify/model/user_model.dart';
// import 'package:veegify/provider/AuthProvider/auth_provider.dart';
// import 'package:veegify/views/ProfileScreen/help_screen.dart';
// import 'package:veegify/views/Booking/booking_screen.dart';
// import 'package:veegify/views/address/address_list.dart';
// import 'package:veegify/views/home/invoice_screen.dart';
// import 'package:veegify/views/Navbar/navbar_screen.dart';
// import 'package:veegify/views/ProfileScreen/refer_earn_screen.dart';
// import 'package:veegify/widgets/bottom_navbar.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;


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
//   List<dynamic> _orders = [];
//   final Map<String, bool> _favorites = {}; // Track favorites by product ID

//   static const String _apiHost = "http://31.97.206.144:5051";

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
//       print("iiiiiiiiiiiiii$url");
//       final response = await http.get(url);
//       print("Response : ${response.body}");
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
//       final url = Uri.parse("$_apiHost/api/userpreviousorders/${user!.userId}");
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> body = jsonDecode(response.body);
//         if (body['success'] == true && body['data'] is List) {
//           setState(() {
//             _orders = body['data'];
//           });
//         } else {
//           setState(() {
//             _orders = [];
//             _error = "No orders found";
//           });
//         }
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
//     // Here you would typically make an API call to update favorite status
//   }

//   void _viewOrderDetails(Map<String, dynamic> order) {
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

//   Widget _buildOrderDetailSheet(Map<String, dynamic> order) {
//     final theme = Theme.of(context);
//     final products = order['products'] as List<dynamic>? ?? [];
    
//     return Container(
//       constraints: BoxConstraints(
//         maxHeight: MediaQuery.of(context).size.height * 0.85,
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Container(
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: theme.colorScheme.onSurface.withOpacity(0.3),
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Order Items',
//               style: theme.textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
            
//             Expanded(
//               child: SingleChildScrollView(
//                 physics: const BouncingScrollPhysics(),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     ...products.map((product) => Container(
//                       margin: const EdgeInsets.only(bottom: 12),
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: theme.colorScheme.surface.withOpacity(0.5),
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(
//                           color: theme.dividerColor.withOpacity(0.3),
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           // Product Image
//                           Container(
//                             width: 60,
//                             height: 60,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(12),
//                               image: DecorationImage(
//                                 image: _normalizeImageUrl(product['image']?.toString()).isNotEmpty
//                                     ? NetworkImage(_normalizeImageUrl(product['image']?.toString()))
//                                     : const AssetImage('assets/placeholder.png') as ImageProvider,
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
                          
//                           // Product Details
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   product['name'] ?? 'Product',
//                                   style: theme.textTheme.bodyMedium?.copyWith(
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   '${product['quantity']} x ₹${(product['basePrice'] ?? 0).toStringAsFixed(2)}',
//                                   style: theme.textTheme.bodySmall?.copyWith(
//                                     color: theme.colorScheme.onSurface.withOpacity(0.6),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   'Total: ₹${((product['quantity'] ?? 1) * (product['basePrice'] ?? 0)).toStringAsFixed(2)}',
//                                   style: theme.textTheme.bodySmall?.copyWith(
//                                     fontWeight: FontWeight.w600,
//                                     color: theme.colorScheme.primary,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
                          
//                           // Favorite Icon
//                           IconButton(
//                             onPressed: () {
//                               _toggleFavorite(product['_id'] ?? product['id'] ?? '');
//                             },
//                             icon: Icon(
//                               _favorites[product['_id'] ?? product['id'] ?? ''] ?? false
//                                   ? Icons.favorite
//                                   : Icons.favorite_border,
//                               color: Colors.red,
//                               size: 20,
//                             ),
//                           ),
//                         ],
//                       ),
//                     )),
//                     const SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
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

//   Widget _buildOrderCard(Map<String, dynamic> order) {
//     final theme = Theme.of(context);
//     final isDarkMode = theme.brightness == Brightness.dark;
    
//     final products = order['products'] as List<dynamic>? ?? [];
//     final mainProduct = products.isNotEmpty ? products[0] : null;
//     final rawImageUrl = mainProduct != null ? (mainProduct['image'] ?? '') : '';
//     final imageUrl = _normalizeImageUrl(rawImageUrl?.toString());
//     final name = mainProduct != null ? (mainProduct['name'] ?? 'Item') : 'Item';
//     final price = mainProduct != null ? (mainProduct['basePrice'] ?? 0) : 0;
//     final productId = mainProduct != null ? (mainProduct['_id'] ?? mainProduct['id'] ?? '') : '';
//     final restaurantName = order['restaurantId'] != null 
//         ? (order['restaurantId']['restaurantName'] ?? '') 
//         : '';

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: theme.cardColor,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: theme.dividerColor.withOpacity(0.3),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(isDarkMode ? 0.1 : 0.05),
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
//                     '₹$price',
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
//                           color: theme.colorScheme.onSurface.withOpacity(0.6),
//                         ),
//                         const SizedBox(width: 4),
//                         Expanded(
//                           child: Text(
//                             restaurantName,
//                             style: theme.textTheme.bodySmall?.copyWith(
//                               color: theme.colorScheme.onSurface.withOpacity(0.6),
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 6),
//                   ],
//                   // Row(
//                   //   children: [
//                   //     Icon(Icons.star, size: 14, color: Colors.amber),
//                   //     const SizedBox(width: 4),
//                   //     Text('4.2', style: TextStyle(color: Colors.amber[700])),
//                   //     const SizedBox(width: 8),
//                   //     Text(
//                   //       '(${(order['totalItems'] ?? 1)})',
//                   //       style: theme.textTheme.bodySmall?.copyWith(
//                   //         color: theme.colorScheme.onSurface.withOpacity(0.6),
//                   //       ),
//                   //     ),
//                   //   ],
//                   // ),
//                   // const SizedBox(height: 8),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: order['orderStatus'] == 'Completed' 
//                           ? Colors.green.withOpacity(0.1)
//                           : Colors.orange.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       order['orderStatus'] == 'Completed' ? 'Delivered' : (order['deliveryStatus'] ?? ''),
//                       style: TextStyle(
//                         color: order['orderStatus'] == 'Completed' ? Colors.green : Colors.orange,
//                         fontWeight: FontWeight.w600,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: () => _viewOrderDetails(order),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: theme.colorScheme.primary,
//                         foregroundColor: theme.colorScheme.onPrimary,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         padding: const EdgeInsets.symmetric(vertical: 8),
//                       ),
//                       child: Text(
//                         'View Items',
//                         style: theme.textTheme.bodyMedium?.copyWith(
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(width: 16),

//             // Right side image with favorite icon
//             Stack(
//               clipBehavior: Clip.none,
//               children: [
//                 Container(
//                   width: 120,
//                   height: 140,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                     image: DecorationImage(
//                       image: imageUrl.isNotEmpty
//                           ? NetworkImage(imageUrl)
//                           : const AssetImage('assets/placeholder.png') as ImageProvider,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),

//                 // Favorite icon - top right
//                 // if (productId.isNotEmpty)
//                 //   Positioned(
//                 //     top: 8,
//                 //     right: 8,
//                 //     child: Container(
//                 //       decoration: BoxDecoration(
//                 //         color: theme.cardColor,
//                 //         shape: BoxShape.circle,
//                 //         boxShadow: [
//                 //           BoxShadow(
//                 //             color: Colors.black.withOpacity(0.1),
//                 //             blurRadius: 4,
//                 //             offset: const Offset(0, 2),
//                 //           ),
//                 //         ],
//                 //       ),
//                 //       child: IconButton(
//                 //         icon: Icon(
//                 //           _favorites[productId] ?? false
//                 //               ? Icons.favorite
//                 //               : Icons.favorite_border,
//                 //           color: Colors.red,
//                 //           size: 20,
//                 //         ),
//                 //         onPressed: () => _toggleFavorite(productId),
//                 //       ),
//                 //     ),
//                 //   ),
//               ],
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
//           valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
//         ),
//       );
//     }

//     if (_error != null) {
//       return Center(
//         child: _buildNetworkErrorWidget(_lastError ?? _error!, _fetchPreviousOrders),
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

//     return ListView.builder(
//       controller: widget.scrollController,
//       padding: const EdgeInsets.only(top: 16, bottom: 80),
//       itemCount: _orders.length,
//       itemBuilder: (context, index) {
//         final order = _orders[index] as Map<String, dynamic>;
//         return _buildOrderCard(order);
//       },
//     );
//   }

//   Widget _buildNetworkErrorWidget(Object error, VoidCallback onRetry) {
//     final theme = Theme.of(context);
//     final isNetwork = error is SocketException ||
//         (error is HttpException) ||
//         error.toString().toLowerCase().contains('socket') ||
//         error.toString().toLowerCase().contains('failed host lookup') ||
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
//             isNetwork ? Icons.wifi_off : Icons.error_outline,
//             size: 64,
//             color: theme.colorScheme.onSurface.withOpacity(0.3),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             isNetwork ? "No Internet Connection" : "Something went wrong",
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
//               color: theme.colorScheme.onSurface.withOpacity(0.6),
//             ),
//           ),
//           const SizedBox(height: 20),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton(
//                 onPressed: () => onRetry(),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: theme.colorScheme.primary,
//                   foregroundColor: theme.colorScheme.onPrimary,
//                 ),
//                 child: const Text("Retry"),
//               ),
//               const SizedBox(width: 12),
//               OutlinedButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: const Text("Close"),
//               )
//             ],
//           ),
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




















// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:veegify/helper/storage_helper.dart';
// import 'package:veegify/model/user_model.dart';
// import 'package:veegify/provider/AuthProvider/auth_provider.dart';
// import 'package:veegify/views/ProfileScreen/help_screen.dart';
// import 'package:veegify/views/Booking/booking_screen.dart';
// import 'package:veegify/views/address/address_list.dart';
// import 'package:veegify/views/home/invoice_screen.dart';
// import 'package:veegify/views/Navbar/navbar_screen.dart';
// import 'package:veegify/views/ProfileScreen/refer_earn_screen.dart';
// import 'package:veegify/widgets/bottom_navbar.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;

// // ↓↓↓ NEW IMPORTS FOR INVOICE ↓↓↓
// import 'package:printing/printing.dart';
// import 'package:pdf/pdf.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:open_filex/open_filex.dart';
// import 'package:veegify/utils/invoice_html_builder.dart';
// import 'package:veegify/model/order.dart' as veeg_order;
// // ↑↑↑ NEW IMPORTS FOR INVOICE ↑↑↑

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
//   List<dynamic> _orders = [];
//   final Map<String, bool> _favorites = {}; // Track favorites by product ID

//   static const String _apiHost = "http://31.97.206.144:5051";

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
//       print("iiiiiiiiiiiiii$url");
//       final response = await http.get(url);
//       print("Response : ${response.body}");
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
//       final url = Uri.parse("$_apiHost/api/userpreviousorders/${user!.userId}");
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> body = jsonDecode(response.body);
//         if (body['success'] == true && body['data'] is List) {
//           setState(() {
//             _orders = body['data'];
//           });
//         } else {
//           setState(() {
//             _orders = [];
//             _error = "No orders found";
//           });
//         }
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
//     // Here you would typically make an API call to update favorite status
//   }

//   void _viewOrderDetails(Map<String, dynamic> order) {
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

//   double _parseDouble(dynamic value) {
//     if (value == null) return 0;
//     if (value is num) return value.toDouble();
//     return double.tryParse(value.toString()) ?? 0;
//   }

//   double _getProductPrice(Map<String, dynamic> product) {
//     return _parseDouble(product['price'] ?? product['basePrice']);
//   }

//   Widget _buildOrderDetailSheet(Map<String, dynamic> order) {
//     final theme = Theme.of(context);
//     final products = order['products'] as List<dynamic>? ?? [];

//     final subTotal = _parseDouble(order['subTotal']);
//     final gstAmount = _parseDouble(order['gstAmount']);
//     final platformCharge = _parseDouble(order['platformCharge']);
//     final deliveryCharge = _parseDouble(order['deliveryCharge']);
//     final couponDiscount = _parseDouble(order['couponDiscount']);
//     final totalPayable = _parseDouble(order['totalPayable']);

//     return Container(
//       constraints: BoxConstraints(
//         maxHeight: MediaQuery.of(context).size.height * 0.85,
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Container(
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: theme.colorScheme.onSurface.withOpacity(0.3),
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Order Items',
//               style: theme.textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),

//             Expanded(
//               child: SingleChildScrollView(
//                 physics: const BouncingScrollPhysics(),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     ...products.map((product) {
//                       final price = _getProductPrice(product);
//                       final quantity = product['quantity'] ?? 1;
//                       final lineTotal = price * (quantity is num ? quantity.toDouble() : 1);

//                       return Container(
//                         margin: const EdgeInsets.only(bottom: 12),
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: theme.colorScheme.surface.withOpacity(0.5),
//                           borderRadius: BorderRadius.circular(16),
//                           border: Border.all(
//                             color: theme.dividerColor.withOpacity(0.3),
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//                             // Product Image
//                             Container(
//                               width: 60,
//                               height: 60,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(12),
//                                 image: DecorationImage(
//                                   image: _normalizeImageUrl(product['image']?.toString()).isNotEmpty
//                                       ? NetworkImage(_normalizeImageUrl(product['image']?.toString()))
//                                       : const AssetImage('assets/placeholder.png') as ImageProvider,
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 12),

//                             // Product Details
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     product['name'] ?? 'Product',
//                                     style: theme.textTheme.bodyMedium?.copyWith(
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     '${quantity} x ₹${price.toStringAsFixed(2)}',
//                                     style: theme.textTheme.bodySmall?.copyWith(
//                                       color: theme.colorScheme.onSurface.withOpacity(0.6),
//                                     ),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     'Total: ₹${lineTotal.toStringAsFixed(2)}',
//                                     style: theme.textTheme.bodySmall?.copyWith(
//                                       fontWeight: FontWeight.w600,
//                                       color: theme.colorScheme.primary,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),

//                             // Favorite Icon
//                             IconButton(
//                               onPressed: () {
//                                 _toggleFavorite(product['_id'] ?? product['id'] ?? '');
//                               },
//                               icon: Icon(
//                                 _favorites[product['_id'] ?? product['id'] ?? ''] ?? false
//                                     ? Icons.favorite
//                                     : Icons.favorite_border,
//                                 color: Colors.red,
//                                 size: 20,
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     }).toList(),

//                     const SizedBox(height: 16),

//                     // Order summary (matches backend charges)
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: theme.colorScheme.primary.withOpacity(0.04),
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(
//                           color: theme.colorScheme.primary.withOpacity(0.3),
//                         ),
//                       ),
//                       child: Column(
//                         children: [
//                           _summaryRow('Items Total', subTotal, theme),
//                           _summaryRow('GST', gstAmount, theme),
//                           _summaryRow('Platform Charge', platformCharge, theme),
//                           _summaryRow('Delivery Charge', deliveryCharge, theme),
//                           if (couponDiscount > 0)
//                             _summaryRow('Coupon Discount', -couponDiscount, theme, isDiscount: true),
//                           const Divider(height: 18),
//                           _summaryRow('Total Payable', totalPayable, theme, isTotal: true),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             ),
//           ],
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

//   // ---------- INVOICE DOWNLOAD FROM RAW MAP USING Order MODEL ----------

// Future<void> _downloadInvoice(dynamic orderModel) async {
//   final theme = Theme.of(context);

//   try {
//     // 1) Build pretty Veegify HTML from the Order model
//     final htmlContent = buildInvoiceHtml(orderModel);

//     // 2) Convert HTML → PDF bytes
//     final pdfBytes = await Printing.convertHtml(
//       format: PdfPageFormat.a4,
//       html: htmlContent,
//     );

//     // 3) File name
//     final shortId = orderModel.id.length > 8
//         ? orderModel.id.substring(0, 8)
//         : orderModel.id;
//     final fileName = 'Veegify_Invoice_$shortId.pdf';

//     // 4) Save to app documents directory
//     final dir = await getApplicationDocumentsDirectory();
//     final file = File('${dir.path}/$fileName');
//     await file.writeAsBytes(pdfBytes, flush: true);

//     // 5) Try opening via any PDF app
//     final result = await OpenFilex.open(file.path);
//     debugPrint('OpenFilex result: ${result.type} - ${result.message}');

//     if (!mounted) return;

//     if (result.type == ResultType.done) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Invoice opened: $fileName'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Invoice saved in app storage.\n$fileName'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//     }
//   } catch (e, st) {
//     debugPrint('Invoice error: $e\n$st');
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Failed to download invoice: $e'),
//         backgroundColor: theme.colorScheme.error,
//       ),
//     );
//   }
// }


//   Widget _buildOrderCard(Map<String, dynamic> order) {
//     final theme = Theme.of(context);
//     final isDarkMode = theme.brightness == Brightness.dark;

//     final products = order['products'] as List<dynamic>? ?? [];
//     final mainProduct = products.isNotEmpty ? products[0] : null;
//     final rawImageUrl = mainProduct != null ? (mainProduct['image'] ?? '') : '';
//     final imageUrl = _normalizeImageUrl(rawImageUrl?.toString());
//     final name = mainProduct != null ? (mainProduct['name'] ?? 'Item') : 'Item';
//     final price = mainProduct != null ? _getProductPrice(mainProduct) : 0.0;
//     final productId =
//         mainProduct != null ? (mainProduct['_id'] ?? mainProduct['id'] ?? '') : '';

//     final restaurantName = order['restaurantId'] != null
//         ? (order['restaurantId']['restaurantName'] ?? '')
//         : '';

//     final orderStatusRaw = (order['orderStatus'] ?? '').toString();
//     final deliveryStatusRaw = (order['deliveryStatus'] ?? '').toString();
//     final statusLower = orderStatusRaw.toLowerCase();
//     final deliveryLower = deliveryStatusRaw.toLowerCase();

//     final isDelivered = statusLower.contains('delivered') ||
//         statusLower.contains('completed') ||
//         deliveryLower.contains('delivered');

//     final chipText = isDelivered
//         ? 'Delivered'
//         : (deliveryStatusRaw.isNotEmpty ? deliveryStatusRaw : orderStatusRaw);

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: theme.cardColor,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: theme.dividerColor.withOpacity(0.3),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(isDarkMode ? 0.1 : 0.05),
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
//                           color:
//                               theme.colorScheme.onSurface.withOpacity(0.6),
//                         ),
//                         const SizedBox(width: 4),
//                         Expanded(
//                           child: Text(
//                             restaurantName,
//                             style:
//                                 theme.textTheme.bodySmall?.copyWith(
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
//                         horizontal: 12, vertical: 4),
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
//                             style: theme.textTheme.bodyMedium?.copyWith(
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
//             Stack(
//               clipBehavior: Clip.none,
//               children: [
//                 Container(
//                   width: 120,
//                   height: 140,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                     image: DecorationImage(
//                       image: imageUrl.isNotEmpty
//                           ? NetworkImage(imageUrl)
//                           : const AssetImage('assets/placeholder.png')
//                               as ImageProvider,
//                       fit: BoxFit.cover,
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
//         child: _buildNetworkErrorWidget(
//             _lastError ?? _error!, _fetchPreviousOrders),
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
//                 color:
//                     theme.colorScheme.onSurface.withOpacity(0.5),
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return ListView.builder(
//       controller: widget.scrollController,
//       padding: const EdgeInsets.only(top: 16, bottom: 80),
//       itemCount: _orders.length,
//       itemBuilder: (context, index) {
//         final order = _orders[index] as Map<String, dynamic>;
//         return _buildOrderCard(order);
//       },
//     );
//   }

//   Widget _buildNetworkErrorWidget(Object error, VoidCallback onRetry) {
//     final theme = Theme.of(context);
//     final isNetwork = error is SocketException ||
//         (error is HttpException) ||
//         error.toString().toLowerCase().contains('socket') ||
//         error.toString().toLowerCase().contains('failed host lookup') ||
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
//             isNetwork ? Icons.wifi_off : Icons.error_outline,
//             size: 64,
//             color: theme.colorScheme.onSurface.withOpacity(0.3),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             isNetwork ? "No Internet Connection" : "Something went wrong",
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
//           const SizedBox(height: 20),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton(
//                 onPressed: () => onRetry(),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: theme.colorScheme.primary,
//                   foregroundColor: theme.colorScheme.onPrimary,
//                 ),
//                 child: const Text("Retry"),
//               ),
//               const SizedBox(width: 12),
//               OutlinedButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: const Text("Close"),
//               )
//             ],
//           ),
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
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
// ↑↑↑ INVOICE RELATED ↑↑↑

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

  // ✅ use typed Order list
  List<Order> _orders = [];

  final Map<String, bool> _favorites = {}; // Track favorites by product ID

  static const String _apiHost = "http://31.97.206.144:5051";

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
        // ✅ Use helper from order.dart
        final List<Order> orders =
            ordersFromApiResponse(response.body);

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
    final couponDiscount = order.couponDiscount;
    final totalPayable = order.totalPayable;

    return Container(
      constraints: BoxConstraints(
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
                          color: theme.colorScheme.surface.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.dividerColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Product Image
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

                            // Product Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${product.quantity} x ₹${price.toStringAsFixed(2)}',
                                    style: theme.textTheme.bodySmall
                                        ?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Total: ₹${lineTotal.toStringAsFixed(2)}',
                                    style: theme.textTheme.bodySmall
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Favorite Icon
                            // IconButton(
                            //   onPressed: () {
                            //     _toggleFavorite(product.id);
                            //   },
                            //   icon: Icon(
                            //     _favorites[product.id] ?? false
                            //         ? Icons.favorite
                            //         : Icons.favorite_border,
                            //     color: Colors.red,
                            //     size: 20,
                            //   ),
                            // ),
                          ],
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 16),

                    // Order summary (matches backend charges)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.primary.withOpacity(0.04),
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
          ],
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
          print("kfldsjfdskjfdfjdsl;fjld;fds;fkd;fkd;sfk;df$htmlContent");


    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async {
        // This converts your HTML to PDF bytes
        final pdfBytes = await Printing.convertHtml(
          format: format,
          html: htmlContent,
        );

        return pdfBytes;
      },
    );
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                            style: theme.textTheme.bodySmall
                                ?.copyWith(
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
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDelivered
                          ? Colors.green.withOpacity(0.08)
                          : Colors.orange.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      chipText,
                      style: TextStyle(
                        color:
                            isDelivered ? Colors.green : Colors.orange,
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
                            backgroundColor:
                                theme.colorScheme.primary,
                            foregroundColor:
                                theme.colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                            padding:
                                const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: Text(
                            'View Items',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(
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
                            foregroundColor:
                                theme.colorScheme.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(
                            Icons.download_rounded,
                            size: 18,
                          ),
                          label: Text(
                            'Invoice',
                            style:
                                theme.textTheme.bodySmall?.copyWith(
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
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 120,
                  height: 140,
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
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    final theme = Theme.of(context);

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
        child: _buildNetworkErrorWidget(
            _lastError ?? _error!, _fetchPreviousOrders),
      );
    }

    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 80,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No previous orders',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface
                    .withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.only(top: 16, bottom: 80),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final order = _orders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildNetworkErrorWidget(Object error, VoidCallback onRetry) {
    final theme = Theme.of(context);
    final isNetwork = error is SocketException ||
        (error is HttpException) ||
        error.toString().toLowerCase().contains('socket') ||
        error.toString().toLowerCase().contains('failed host lookup') ||
        error.toString().toLowerCase().contains('network');

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
            isNetwork ? Icons.wifi_off : Icons.error_outline,
            size: 64,
            color:
                theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            isNetwork
                ? "No Internet Connection"
                : "Something went wrong",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
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
              color: theme.colorScheme.onSurface
                  .withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => onRetry(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor:
                      theme.colorScheme.onPrimary,
                ),
                child: const Text("Retry"),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Close"),
              )
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Previous Orders',
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
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(child: _buildBody()),
    );
  }
}
