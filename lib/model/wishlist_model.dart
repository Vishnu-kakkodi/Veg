// // // wishlist_product.dart
// // import 'dart:convert';

// // class WishlistProduct {
// //   final String id;
// //   final String name;
// //   final int price; // integer price (rupees)
// //   final String category;
// //   final int stock;
// //   final String description;
// //   final String image; // first image URL (empty string if none)
// //   final List<String> images; // all image URLs (maybe empty)
// //   final String variation;
// //   final String restaurantId;
// //   final String restaurantName;
// //   final DateTime? createdAt;
// //   final dynamic rating; // e.g., 4.2
// //   final dynamic viewcount;

// //   WishlistProduct({
// //     required this.id,
// //     required this.name,
// //     required this.price,
// //     required this.category,
// //     required this.stock,
// //     required this.description,
// //     required this.image,
// //     required this.images,
// //     required this.variation,
// //     required this.restaurantId,
// //     required this.restaurantName,
// //     required this.createdAt,
// //     required this.rating,
// //     required this.viewcount,
// //   });

// //   // --- Helper converters (defensive) ---
// //   static String _safeString(dynamic v, [String fallback = '']) {
// //     if (v == null) return fallback;
// //     if (v is String) return v.trim();
// //     if (v is num) return v.toString();
// //     try {
// //       return v.toString();
// //     } catch (_) {
// //       return fallback;
// //     }
// //   }

// //   static int _safeInt(dynamic v, [int fallback = 0]) {
// //     if (v == null) return fallback;
// //     if (v is int) return v;
// //     if (v is double) return v.toInt();
// //     final s = _safeString(v);
// //     if (s.isEmpty) return fallback;
// //     // remove non-digit except minus
// //     final cleaned = s.replaceAll(RegExp(r'[^0-9\-]'), '');
// //     if (cleaned.isEmpty) return fallback;
// //     return int.tryParse(cleaned) ?? fallback;
// //   }

// //   static double _safeDouble(dynamic v, [double fallback = 0.0]) {
// //     if (v == null) return fallback;
// //     if (v is double) return v;
// //     if (v is int) return v.toDouble();
// //     final s = _safeString(v);
// //     if (s.isEmpty) return fallback;
// //     final cleaned = s.replaceAll(RegExp(r'[^0-9\.\-]'), '');
// //     if (cleaned.isEmpty) return fallback;
// //     return double.tryParse(cleaned) ?? fallback;
// //   }

// //   // Try to extract a list of strings from various shapes
// //   static List<String> _extractImages(dynamic imgField) {
// //     if (imgField == null) return <String>[];
// //     if (imgField is String) {
// //       // sometimes API returns a JSON string of list
// //       final s = imgField.trim();
// //       if (s.isEmpty) return <String>[];
// //       // quick heuristic: if looks like JSON array, try decode
// //       if ((s.startsWith('[') && s.endsWith(']')) || s.contains('http')) {
// //         try {
// //           final decoded = jsonDecode(s);
// //           if (decoded is List) {
// //             return decoded.whereType<dynamic>().map((e) => _safeString(e)).where((e) => e.isNotEmpty).toList();
// //           }
// //         } catch (_) {
// //           // not JSON array, treat as single image string
// //         }
// //       }
// //       // treat as single image URL
// //       return [s];
// //     }
// //     if (imgField is List) {
// //       final out = <String>[];
// //       for (final it in imgField) {
// //         final s = _safeString(it);
// //         if (s.isNotEmpty) out.add(s);
// //       }
// //       return out;
// //     }
// //     if (imgField is Map) {
// //       // common keys to try
// //       for (final k in ['url', 'image', 'src', 'path']) {
// //         if (imgField[k] != null) {
// //           final s = _safeString(imgField[k]);
// //           if (s.isNotEmpty) return [s];
// //         }
// //       }
// //       // fallback convert whole map to string if it looks like url
// //       final asString = _safeString(imgField.toString());
// //       if (asString.contains('http')) return [asString];
// //     }
// //     try {
// //       final s = _safeString(imgField);
// //       return s.isEmpty ? <String>[] : [s];
// //     } catch (_) {
// //       return <String>[];
// //     }
// //   }

// //   // --- Factory ---
// //   factory WishlistProduct.fromJson(Map<String, dynamic> json) {
// //     // Id
// //     final id = _safeString(json['_id'] ?? json['id'] ?? '');

// //     // Name (prefer productName -> addons.productName -> name -> title)
// //     String name = '';
// //     if (json.containsKey('productName')) {
// //       name = _safeString(json['productName']);
// //     } else if (json['addons'] != null && json['addons'] is Map && (json['addons']['productName'] != null)) {
// //       name = _safeString(json['addons']['productName']);
// //     } else if (json.containsKey('name')) {
// //       name = _safeString(json['name']);
// //     } else if (json.containsKey('title')) {
// //       name = _safeString(json['title']);
// //     }

// //     // Price (productPrice / price / vendor_Price)
// //     int price = _safeInt(json['productPrice'] ?? json['price'] ?? json['vendor_Price'] ?? 0);

// //     // Category (contentname / category)
// //     final category = _safeString(json['contentname'] ?? json['category'] ?? '');

// //     // Stock
// //     int stock = 10; // default assume available
// //     if (json.containsKey('stock')) {
// //       stock = _safeInt(json['stock'], 0);
// //     } else if (json.containsKey('quantity')) {
// //       stock = _safeInt(json['quantity'], 0);
// //     }

// //     // Description
// //     final description = _safeString(json['description'] ?? json['desc'] ?? '');

// //     // Images
// //     final images = _extractImages(json['image']);
// //     final firstImage = images.isNotEmpty ? images.first : '';

// //     // Variation: try addons.variation
// //     String variation = '';
// //     try {
// //       final addons = json['addons'];
// //       if (addons != null && addons is Map && addons['variation'] != null) {
// //         final varField = addons['variation'];
// //         if (varField is Map) {
// //           if (varField['name'] != null) variation = _safeString(varField['name']);
// //           else if (varField['type'] != null) {
// //             final t = varField['type'];
// //             if (t is List && t.isNotEmpty) variation = _safeString(t.first);
// //             else variation = _safeString(t);
// //           } else {
// //             variation = _safeString(varField);
// //           }
// //         } else {
// //           variation = _safeString(varField);
// //         }
// //       } else {
// //         variation = _safeString(json['variation'] ?? '');
// //       }
// //     } catch (_) {
// //       variation = _safeString(json['variation'] ?? '');
// //     }

// //     // restaurant info
// //     final restaurantId = _safeString(json['restaurantId'] ?? json['vendorId'] ?? '');
// //     final restaurantName = _safeString(json['restaurantName'] ?? json['vendorName'] ?? '');

// //     // createdAt
// //     DateTime? createdAt;
// //     final rawCreated = json['createdAt'] ?? json['created_at'] ?? json['date'];
// //     if (rawCreated != null) {
// //       final s = _safeString(rawCreated);
// //       createdAt = DateTime.tryParse(s);
// //     }

// //     // rating & viewcount
// //     final rating = _safeDouble(json['rating'] ?? json['ratings'] ?? json['avgRating'] ?? 0.0);
// //     final viewcount = _safeInt(json['viewcount'] ?? json['views'] ?? json['viewCount'] ?? 0);

// //     return WishlistProduct(
// //       id: id,
// //       name: name.isNotEmpty ? name : 'Unnamed product',
// //       price: price,
// //       category: category,
// //       stock: stock,
// //       description: description,
// //       image: firstImage,
// //       images: images,
// //       variation: variation,
// //       restaurantId: restaurantId,
// //       restaurantName: restaurantName,
// //       createdAt: createdAt,
// //       rating: rating,
// //       viewcount: viewcount,
// //     );
// //   }

// //   // --- toJson (serialize) ---
// //   Map<String, dynamic> toJson() {
// //     return {
// //       '_id': id,
// //       'productName': name,
// //       'productPrice': price,
// //       'category': category,
// //       'stock': stock,
// //       'description': description,
// //       'image': images, // keep as list to preserve original shape
// //       'variation': variation,
// //       'restaurantId': restaurantId,
// //       'restaurantName': restaurantName,
// //       'createdAt': createdAt?.toIso8601String(),
// //       'rating': rating,
// //       'viewcount': viewcount,
// //     };
// //   }

// //   // --- Helper: parse response (Map with 'wishlist' or list) ---
// //   static List<WishlistProduct> parseWishlistResponse(dynamic response) {
// //     final List<WishlistProduct> out = [];
// //     if (response == null) return out;

// //     try {
// //       if (response is Map<String, dynamic> && response.containsKey('wishlist')) {
// //         final list = response['wishlist'];
// //         if (list is List) {
// //           for (final item in list) {
// //             if (item is Map<String, dynamic>) {
// //               out.add(WishlistProduct.fromJson(item));
// //             } else {
// //               // try to coerce
// //               out.add(WishlistProduct.fromJson(Map<String, dynamic>.from(item)));
// //             }
// //           }
// //         }
// //       } else if (response is List) {
// //         for (final item in response) {
// //           if (item is Map<String, dynamic>) {
// //             out.add(WishlistProduct.fromJson(item));
// //           } else {
// //             out.add(WishlistProduct.fromJson(Map<String, dynamic>.from(item)));
// //           }
// //         }
// //       } else if (response is String) {
// //         // possibly a raw JSON string
// //         try {
// //           final decoded = jsonDecode(response);
// //           return parseWishlistResponse(decoded);
// //         } catch (_) {
// //           // ignore
// //         }
// //       }
// //     } catch (_) {
// //       // ignore parsing errors - return whatever collected
// //     }

// //     return out;
// //   }

// //   @override
// //   String toString() {
// //     return 'WishlistProduct(id: $id, name: $name, price: $price, image: $image, rating: $rating, viewcount: $viewcount)';
// //   }
// // }



















// // import 'dart:convert';

// // class WishlistProduct {
// //   final String id;
// //   final String name;
// //   final int price; // integer price (rupees)
// //   final String category;
// //   final int stock;
// //   final String description;
// //   final String image; // first image URL (empty string if none)
// //   final List<String> images; // all image URLs (maybe empty)
// //   final String variation;
// //   final String restaurantId;
// //   final String restaurantName;
// //   final String restaurantLocationName; // NEW
// //   final String status; // product status: active/inactive
// //   final String restaurantStatus; // restaurant.status: active/inactive
// //   final int halfPlatePrice; // NEW
// //   final int fullPlatePrice; // NEW
// //   final int discount; // NEW
// //   final List<String> tags; // NEW
// //   final String preparationTime; // NEW
// //   final DateTime? createdAt;
// //   final dynamic rating; // e.g., 4.2
// //   final dynamic viewcount;

// //   WishlistProduct({
// //     required this.id,
// //     required this.name,
// //     required this.price,
// //     required this.category,
// //     required this.stock,
// //     required this.description,
// //     required this.image,
// //     required this.images,
// //     required this.variation,
// //     required this.restaurantId,
// //     required this.restaurantName,
// //     required this.restaurantLocationName,
// //     required this.status,
// //     required this.restaurantStatus,
// //     required this.halfPlatePrice,
// //     required this.fullPlatePrice,
// //     required this.discount,
// //     required this.tags,
// //     required this.preparationTime,
// //     required this.createdAt,
// //     required this.rating,
// //     required this.viewcount,
// //   });

// //   // --- Helper converters (defensive) ---
// //   static String _safeString(dynamic v, [String fallback = '']) {
// //     if (v == null) return fallback;
// //     if (v is String) return v.trim();
// //     if (v is num) return v.toString();
// //     try {
// //       return v.toString();
// //     } catch (_) {
// //       return fallback;
// //     }
// //   }

// //   static int _safeInt(dynamic v, [int fallback = 0]) {
// //     if (v == null) return fallback;
// //     if (v is int) return v;
// //     if (v is double) return v.toInt();
// //     final s = _safeString(v);
// //     if (s.isEmpty) return fallback;
// //     // remove non-digit except minus
// //     final cleaned = s.replaceAll(RegExp(r'[^0-9\-]'), '');
// //     if (cleaned.isEmpty) return fallback;
// //     return int.tryParse(cleaned) ?? fallback;
// //   }

// //   static double _safeDouble(dynamic v, [double fallback = 0.0]) {
// //     if (v == null) return fallback;
// //     if (v is double) return v;
// //     if (v is int) return v.toDouble();
// //     final s = _safeString(v);
// //     if (s.isEmpty) return fallback;
// //     final cleaned = s.replaceAll(RegExp(r'[^0-9\.\-]'), '');
// //     if (cleaned.isEmpty) return fallback;
// //     return double.tryParse(cleaned) ?? fallback;
// //   }

// //   // Try to extract a list of strings from various shapes
// //   static List<String> _extractImages(dynamic imgField) {
// //     if (imgField == null) return <String>[];
// //     if (imgField is String) {
// //       final s = imgField.trim();
// //       if (s.isEmpty) return <String>[];
// //       // if looks like JSON array or contains http, try decode
// //       if ((s.startsWith('[') && s.endsWith(']')) || s.contains('http')) {
// //         try {
// //           final decoded = jsonDecode(s);
// //           if (decoded is List) {
// //             return decoded
// //                 .whereType<dynamic>()
// //                 .map((e) => _safeString(e))
// //                 .where((e) => e.isNotEmpty)
// //                 .toList();
// //           }
// //         } catch (_) {
// //           // ignore, fallback below
// //         }
// //       }
// //       return [s];
// //     }
// //     if (imgField is List) {
// //       final out = <String>[];
// //       for (final it in imgField) {
// //         final s = _safeString(it);
// //         if (s.isNotEmpty) out.add(s);
// //       }
// //       return out;
// //     }
// //     if (imgField is Map) {
// //       for (final k in ['url', 'image', 'src', 'path']) {
// //         if (imgField[k] != null) {
// //           final s = _safeString(imgField[k]);
// //           if (s.isNotEmpty) return [s];
// //         }
// //       }
// //       final asString = _safeString(imgField.toString());
// //       if (asString.contains('http')) return [asString];
// //     }
// //     try {
// //       final s = _safeString(imgField);
// //       return s.isEmpty ? <String>[] : [s];
// //     } catch (_) {
// //       return <String>[];
// //     }
// //   }

// //   // --- Factory: tuned for wishlist response ---
// //   factory WishlistProduct.fromJson(Map<String, dynamic> json) {
// //     // Id
// //     final id = _safeString(json['_id'] ?? json['id'] ?? '');

// //     // Name (in your response it's "name")
// //     String name = '';
// //     if (json.containsKey('name')) {
// //       name = _safeString(json['name']);
// //     } else if (json.containsKey('productName')) {
// //       name = _safeString(json['productName']);
// //     } else if (json['addons'] != null &&
// //         json['addons'] is Map &&
// //         (json['addons']['productName'] != null)) {
// //       name = _safeString(json['addons']['productName']);
// //     } else if (json.containsKey('title')) {
// //       name = _safeString(json['title']);
// //     }

// //     // Price (your response uses "price")
// //     int price = _safeInt(
// //       json['price'] ??
// //           json['productPrice'] ??
// //           json['vendor_Price'] ??
// //           0,
// //     );

// //     // Category (in your response it's 'category' as ID)
// //     final category = _safeString(
// //       json['category'] ?? json['contentname'] ?? '',
// //     );

// //     // Stock - default 10 if unknown
// //     int stock = 10;
// //     if (json.containsKey('stock')) {
// //       stock = _safeInt(json['stock'], 0);
// //     } else if (json.containsKey('quantity')) {
// //       stock = _safeInt(json['quantity'], 0);
// //     }

// //     // Description - your response uses 'content'
// //     final description = _safeString(
// //       json['content'] ?? json['description'] ?? json['desc'] ?? '',
// //     );

// //     // Images - single string in your response
// //     final images = _extractImages(json['image']);
// //     final firstImage = images.isNotEmpty ? images.first : '';

// //     // Variation: keep old logic, but your current wishlist doesn't use it
// //     String variation = '';
// //     try {
// //       final addons = json['addons'];
// //       if (addons != null &&
// //           addons is Map &&
// //           (addons['variation'] != null)) {
// //         final varField = addons['variation'];
// //         if (varField is Map) {
// //           if (varField['name'] != null) {
// //             variation = _safeString(varField['name']);
// //           } else if (varField['type'] != null) {
// //             final t = varField['type'];
// //             if (t is List && t.isNotEmpty) {
// //               variation = _safeString(t.first);
// //             } else {
// //               variation = _safeString(t);
// //             }
// //           } else {
// //             variation = _safeString(varField);
// //           }
// //         } else {
// //           variation = _safeString(varField);
// //         }
// //       } else {
// //         variation = _safeString(json['variation'] ?? '');
// //       }
// //     } catch (_) {
// //       variation = _safeString(json['variation'] ?? '');
// //     }

// //     // restaurant info (your response has nested 'restaurant')
// //     final restaurantObj = json['restaurant'];
// //     String restaurantName = '';
// //     String restaurantLocationName = '';
// //     String restaurantStatus = '';

// //     if (restaurantObj is Map<String, dynamic>) {
// //       restaurantName = _safeString(
// //         restaurantObj['restaurantName'] ?? restaurantObj['name'] ?? '',
// //       );
// //       restaurantLocationName = _safeString(
// //         restaurantObj['locationName'] ?? '',
// //       );
// //       restaurantStatus = _safeString(
// //         restaurantObj['status'] ?? '',
// //       );
// //     }

// //     // Id might also be present separately
// //     final restaurantId = _safeString(
// //       json['restaurantId'] ?? json['vendorId'] ?? '',
// //     );

// //     // product status
// //     final status = _safeString(json['status'] ?? '');

// //     // half / full plate & discount
// //     final halfPlatePrice = _safeInt(json['halfPlatePrice'] ?? 0);
// //     final fullPlatePrice = _safeInt(json['fullPlatePrice'] ?? 0);
// //     final discount = _safeInt(json['discount'] ?? 0);

// //     // tags
// //     List<String> tags = [];
// //     if (json['tags'] is List) {
// //       tags = (json['tags'] as List)
// //           .map((e) => _safeString(e))
// //           .where((e) => e.isNotEmpty)
// //           .toList();
// //     }

// //     // preparationTime
// //     final preparationTime = _safeString(json['preparationTime'] ?? '');

// //     // createdAt
// //     DateTime? createdAt;
// //     final rawCreated = json['createdAt'] ?? json['created_at'] ?? json['date'];
// //     if (rawCreated != null) {
// //       final s = _safeString(rawCreated);
// //       createdAt = DateTime.tryParse(s);
// //     }

// //     // rating & viewcount (not present in this response, but keep defensive)
// //     final rating = _safeDouble(
// //       json['rating'] ?? json['ratings'] ?? json['avgRating'] ?? 0.0,
// //     );
// //     final viewcount = _safeInt(
// //       json['viewcount'] ?? json['views'] ?? json['viewCount'] ?? 0,
// //     );

// //     return WishlistProduct(
// //       id: id,
// //       name: name.isNotEmpty ? name : 'Unnamed product',
// //       price: price,
// //       category: category,
// //       stock: stock,
// //       description: description,
// //       image: firstImage,
// //       images: images,
// //       variation: variation,
// //       restaurantId: restaurantId,
// //       restaurantName: restaurantName,
// //       restaurantLocationName: restaurantLocationName,
// //       status: status,
// //       restaurantStatus: restaurantStatus,
// //       halfPlatePrice: halfPlatePrice,
// //       fullPlatePrice: fullPlatePrice,
// //       discount: discount,
// //       tags: tags,
// //       preparationTime: preparationTime,
// //       createdAt: createdAt,
// //       rating: rating,
// //       viewcount: viewcount,
// //     );
// //   }

// //   // --- toJson (serialize) ---
// //   Map<String, dynamic> toJson() {
// //     return {
// //       '_id': id,
// //       'name': name,
// //       'price': price,
// //       'category': category,
// //       'stock': stock,
// //       'description': description,
// //       'image': images, // preserve list
// //       'variation': variation,
// //       'restaurantId': restaurantId,
// //       'restaurantName': restaurantName,
// //       'restaurantLocationName': restaurantLocationName,
// //       'status': status,
// //       'restaurantStatus': restaurantStatus,
// //       'halfPlatePrice': halfPlatePrice,
// //       'fullPlatePrice': fullPlatePrice,
// //       'discount': discount,
// //       'tags': tags,
// //       'preparationTime': preparationTime,
// //       'createdAt': createdAt?.toIso8601String(),
// //       'rating': rating,
// //       'viewcount': viewcount,
// //     };
// //   }

// //   // --- Helper: parse response (Map with 'wishlist' or list) ---
// //   static List<WishlistProduct> parseWishlistResponse(dynamic response) {
// //     final List<WishlistProduct> out = [];
// //     if (response == null) return out;

// //     try {
// //       if (response is Map<String, dynamic> && response.containsKey('wishlist')) {
// //         final list = response['wishlist'];
// //         if (list is List) {
// //           for (final item in list) {
// //             if (item is Map<String, dynamic>) {
// //               out.add(WishlistProduct.fromJson(item));
// //             } else {
// //               out.add(WishlistProduct.fromJson(
// //                   Map<String, dynamic>.from(item)));
// //             }
// //           }
// //         }
// //       } else if (response is List) {
// //         for (final item in response) {
// //           if (item is Map<String, dynamic>) {
// //             out.add(WishlistProduct.fromJson(item));
// //           } else {
// //             out.add(WishlistProduct.fromJson(
// //                 Map<String, dynamic>.from(item)));
// //           }
// //         }
// //       } else if (response is String) {
// //         // possibly a raw JSON string
// //         try {
// //           final decoded = jsonDecode(response);
// //           return parseWishlistResponse(decoded);
// //         } catch (_) {
// //           // ignore
// //         }
// //       }
// //     } catch (_) {
// //       // ignore parsing errors - return whatever collected
// //     }

// //     return out;
// //   }

// //   @override
// //   String toString() {
// //     return 'WishlistProduct(id: $id, name: $name, price: $price, status: $status, restaurantStatus: $restaurantStatus, image: $image, rating: $rating, viewcount: $viewcount)';
// //   }
// // }















// import 'dart:convert';

// class WishlistProduct {
//   final String id;
//   final String name;
//   final int price; // integer price (rupees)
//   final String category;
//   final int stock;
//   final String description;
//   final String image; // first image URL (empty string if none)
//   final List<String> images; // all image URLs (maybe empty)
//   final String variation;
//   final String restaurantId;
//   final String restaurantName;
//   final String restaurantLocationName; // from nested restaurant.locationName
//   final String status; // product status: active/inactive
//   final String restaurantStatus; // restaurant.status: active/inactive
//   final int halfPlatePrice;
//   final int fullPlatePrice;
//   final int discount;
//   final String restaurantProductId;
//   final List<String> tags;
//   final String preparationTime;
//   final DateTime? createdAt;
//   final dynamic rating; // e.g., 4.2
//   final dynamic viewcount;

//   WishlistProduct({
//     required this.id,
//     required this.name,
//     required this.price,
//     required this.category,
//     required this.stock,
//     required this.description,
//     required this.image,
//     required this.images,
//     required this.variation,
//     required this.restaurantId,
//     required this.restaurantName,
//     required this.restaurantLocationName,
//     required this.status,
//     required this.restaurantStatus,
//     required this.halfPlatePrice,
//     required this.fullPlatePrice,
//     required this.discount,
//     required this.restaurantProductId,
//     required this.tags,
//     required this.preparationTime,
//     required this.createdAt,
//     required this.rating,
//     required this.viewcount,
//   });

//   // --- Helper converters (defensive) ---
//   static String _safeString(dynamic v, [String fallback = '']) {
//     if (v == null) return fallback;
//     if (v is String) return v.trim();
//     if (v is num) return v.toString();
//     try {
//       return v.toString();
//     } catch (_) {
//       return fallback;
//     }
//   }

//   static int _safeInt(dynamic v, [int fallback = 0]) {
//     if (v == null) return fallback;
//     if (v is int) return v;
//     if (v is double) return v.toInt();
//     final s = _safeString(v);
//     if (s.isEmpty) return fallback;
//     // remove non-digit except minus
//     final cleaned = s.replaceAll(RegExp(r'[^0-9\-]'), '');
//     if (cleaned.isEmpty) return fallback;
//     return int.tryParse(cleaned) ?? fallback;
//   }

//   static double _safeDouble(dynamic v, [double fallback = 0.0]) {
//     if (v == null) return fallback;
//     if (v is double) return v;
//     if (v is int) return v.toDouble();
//     final s = _safeString(v);
//     if (s.isEmpty) return fallback;
//     final cleaned = s.replaceAll(RegExp(r'[^0-9\.\-]'), '');
//     if (cleaned.isEmpty) return fallback;
//     return double.tryParse(cleaned) ?? fallback;
//   }

//   // Try to extract a list of strings from various shapes
//   static List<String> _extractImages(dynamic imgField) {
//     if (imgField == null) return <String>[];
//     if (imgField is String) {
//       final s = imgField.trim();
//       if (s.isEmpty) return <String>[];
//       // if looks like JSON array or contains http, try decode
//       if ((s.startsWith('[') && s.endsWith(']')) || s.contains('http')) {
//         try {
//           final decoded = jsonDecode(s);
//           if (decoded is List) {
//             return decoded
//                 .whereType<dynamic>()
//                 .map((e) => _safeString(e))
//                 .where((e) => e.isNotEmpty)
//                 .toList();
//           }
//         } catch (_) {
//           // ignore, fallback below
//         }
//       }
//       return [s];
//     }
//     if (imgField is List) {
//       final out = <String>[];
//       for (final it in imgField) {
//         final s = _safeString(it);
//         if (s.isNotEmpty) out.add(s);
//       }
//       return out;
//     }
//     if (imgField is Map) {
//       for (final k in ['url', 'image', 'src', 'path']) {
//         if (imgField[k] != null) {
//           final s = _safeString(imgField[k]);
//           if (s.isNotEmpty) return [s];
//         }
//       }
//       final asString = _safeString(imgField.toString());
//       if (asString.contains('http')) return [asString];
//     }
//     try {
//       final s = _safeString(imgField);
//       return s.isEmpty ? <String>[] : [s];
//     } catch (_) {
//       return <String>[];
//     }
//   }

//   // --- Factory: tuned for wishlist response ---
//   factory WishlistProduct.fromJson(Map<String, dynamic> json) {
//     // Id
//     final id = _safeString(json['_id'] ?? json['id'] ?? '');

//     // Name (in your response it's "name")
//     String name = '';
//     if (json.containsKey('name')) {
//       name = _safeString(json['name']);
//     } else if (json.containsKey('productName')) {
//       name = _safeString(json['productName']);
//     } else if (json['addons'] != null &&
//         json['addons'] is Map &&
//         (json['addons']['productName'] != null)) {
//       name = _safeString(json['addons']['productName']);
//     } else if (json.containsKey('title')) {
//       name = _safeString(json['title']);
//     }

//     // Price
//     int price = _safeInt(
//       json['price'] ??
//           json['productPrice'] ??
//           json['vendor_Price'] ??
//           0,
//     );

//     // Category (id)
//     final category = _safeString(
//       json['category'] ?? json['contentname'] ?? '',
//     );

//     // Stock - default 10 if unknown
//     int stock = 10;
//     if (json.containsKey('stock')) {
//       stock = _safeInt(json['stock'], 0);
//     } else if (json.containsKey('quantity')) {
//       stock = _safeInt(json['quantity'], 0);
//     }

//     // Description - your response uses 'content'
//     final description = _safeString(
//       json['content'] ?? json['description'] ?? json['desc'] ?? '',
//     );

//     // Images
//     final images = _extractImages(json['image']);
//     final firstImage = images.isNotEmpty ? images.first : '';

//     // Variation (not really used, but kept)
//     String variation = '';
//     try {
//       final addons = json['addons'];
//       if (addons != null &&
//           addons is Map &&
//           (addons['variation'] != null)) {
//         final varField = addons['variation'];
//         if (varField is Map) {
//           if (varField['name'] != null) {
//             variation = _safeString(varField['name']);
//           } else if (varField['type'] != null) {
//             final t = varField['type'];
//             if (t is List && t.isNotEmpty) {
//               variation = _safeString(t.first);
//             } else {
//               variation = _safeString(t);
//             }
//           } else {
//             variation = _safeString(varField);
//           }
//         } else {
//           variation = _safeString(varField);
//         }
//       } else {
//         variation = _safeString(json['variation'] ?? '');
//       }
//     } catch (_) {
//       variation = _safeString(json['variation'] ?? '');
//     }

//     // restaurant info (nested "restaurant")
//     final restaurantObj = json['restaurant'];
//     String restaurantName = '';
//     String restaurantLocationName = '';
//     String restaurantStatus = '';
//     String restaurantId = '';

//     if (restaurantObj is Map<String, dynamic>) {
//       restaurantName = _safeString(
//         restaurantObj['restaurantName'] ?? restaurantObj['name'] ?? '',
//       );
//       restaurantLocationName = _safeString(
//         restaurantObj['locationName'] ?? '',
//       );
//       restaurantStatus = _safeString(
//         restaurantObj['status'] ?? '',
//       );
//             restaurantId = _safeString(
//         restaurantObj['restaurantId'] ?? restaurantObj['restaurantId'] ?? '',
//       );
//     }


//     // product status
//     final status = _safeString(json['status'] ?? '');

//     // half / full plate & discount
//     final halfPlatePrice = _safeInt(json['halfPlatePrice'] ?? 0);
//     final fullPlatePrice = _safeInt(json['fullPlatePrice'] ?? 0);
//     final discount = _safeInt(json['discount'] ?? 0);
// final restaurantProductId = json['restaurantProductId'] ?? '';
//     // tags
//     List<String> tags = [];
//     if (json['tags'] is List) {
//       tags = (json['tags'] as List)
//           .map((e) => _safeString(e))
//           .where((e) => e.isNotEmpty)
//           .toList();
//     }

//     // preparationTime
//     final preparationTime = _safeString(json['preparationTime'] ?? '');

//     // createdAt
//     DateTime? createdAt;
//     final rawCreated = json['createdAt'] ?? json['created_at'] ?? json['date'];
//     if (rawCreated != null) {
//       final s = _safeString(rawCreated);
//       createdAt = DateTime.tryParse(s);
//     }

//     // rating & viewcount
//     final rating = _safeDouble(
//       json['rating'] ?? json['ratings'] ?? json['avgRating'] ?? 0.0,
//     );
//     final viewcount = _safeInt(
//       json['viewcount'] ?? json['views'] ?? json['viewCount'] ?? 0,
//     );

//     return WishlistProduct(
//       id: id,
//       name: name.isNotEmpty ? name : 'Unnamed product',
//       price: price,
//       category: category,
//       stock: stock,
//       description: description,
//       image: firstImage,
//       images: images,
//       variation: variation,
//       restaurantId: restaurantId,
//       restaurantName: restaurantName,
//       restaurantLocationName: restaurantLocationName,
//       status: status,
//       restaurantStatus: restaurantStatus,
//       halfPlatePrice: halfPlatePrice,
//       fullPlatePrice: fullPlatePrice,
//       discount: discount,
//       restaurantProductId:restaurantProductId,
//       tags: tags,
//       preparationTime: preparationTime,
//       createdAt: createdAt,
//       rating: rating,
//       viewcount: viewcount,
//     );
//   }

//   // --- toJson (serialize) ---
//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'name': name,
//       'price': price,
//       'category': category,
//       'stock': stock,
//       'description': description,
//       'image': images, // preserve list
//       'variation': variation,
//       'restaurantId': restaurantId,
//       'restaurantName': restaurantName,
//       'restaurantLocationName': restaurantLocationName,
//       'status': status,
//       'restaurantStatus': restaurantStatus,
//       'halfPlatePrice': halfPlatePrice,
//       'fullPlatePrice': fullPlatePrice,
//       'discount': discount,
//       'restaurantProductId': restaurantProductId,
//       'tags': tags,
//       'preparationTime': preparationTime,
//       'createdAt': createdAt?.toIso8601String(),
//       'rating': rating,
//       'viewcount': viewcount,

//       // 🔥 NEW: nested restaurant object, matching your API shape
//       'restaurant': {
//         'restaurantName': restaurantName,
//         'locationName': restaurantLocationName,
//         'status': restaurantStatus,
//       },
//     };
//   }

//   // --- Helper: parse response (Map with 'wishlist' or list) ---
//   static List<WishlistProduct> parseWishlistResponse(dynamic response) {
//     final List<WishlistProduct> out = [];
//     if (response == null) return out;

//     try {
//       if (response is Map<String, dynamic> && response.containsKey('wishlist')) {
//         final list = response['wishlist'];
//         if (list is List) {
//           for (final item in list) {
//             if (item is Map<String, dynamic>) {
//               out.add(WishlistProduct.fromJson(item));
//             } else {
//               out.add(
//                 WishlistProduct.fromJson(Map<String, dynamic>.from(item)),
//               );
//             }
//           }
//         }
//       } else if (response is List) {
//         for (final item in response) {
//           if (item is Map<String, dynamic>) {
//             out.add(WishlistProduct.fromJson(item));
//           } else {
//             out.add(
//               WishlistProduct.fromJson(Map<String, dynamic>.from(item)),
//             );
//           }
//         }
//       } else if (response is String) {
//         // possibly a raw JSON string
//         try {
//           final decoded = jsonDecode(response);
//           return parseWishlistResponse(decoded);
//         } catch (_) {
//           // ignore
//         }
//       }
//     } catch (_) {
//       // ignore parsing errors - return whatever collected
//     }

//     return out;
//   }

//   @override
//   String toString() {
//     return 'WishlistProduct(id: $id, name: $name, price: $price, '
//         'status: $status, restaurantStatus: $restaurantStatus, '
//         'image: $image, rating: $rating, viewcount: $viewcount)';
//   }
// }




























import 'dart:convert';

class WishlistProduct {
  final String id;
  final String name;
  final int price; // integer price (rupees)
  final String category;
  final int stock;
  final String description;
  final String image; // first image URL (empty string if none)
  final List<String> images; // all image URLs (maybe empty)
  final String variation;
  final String restaurantId;
  final String restaurantName;
  final String restaurantLocationName; // from nested restaurant.locationName
  final String status; // product status: active/inactive
  final String restaurantStatus; // restaurant.status: active/inactive
  final int halfPlatePrice;
  final int fullPlatePrice;
  final int discount;
  final String restaurantProductId;
  final List<String> tags;
  final String preparationTime;
  final DateTime? createdAt;
  final dynamic rating; // e.g., 4.2
  final dynamic viewcount;

  WishlistProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.stock,
    required this.description,
    required this.image,
    required this.images,
    required this.variation,
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantLocationName,
    required this.status,
    required this.restaurantStatus,
    required this.halfPlatePrice,
    required this.fullPlatePrice,
    required this.discount,
    required this.restaurantProductId,
    required this.tags,
    required this.preparationTime,
    required this.createdAt,
    required this.rating,
    required this.viewcount,
  });

  // --- Helper converters (defensive) ---
  static String _safeString(dynamic v, [String fallback = '']) {
    if (v == null) return fallback;
    if (v is String) return v.trim();
    if (v is num) return v.toString();
    try {
      return v.toString();
    } catch (_) {
      return fallback;
    }
  }

  static int _safeInt(dynamic v, [int fallback = 0]) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is double) return v.toInt();
    final s = _safeString(v);
    if (s.isEmpty) return fallback;
    final cleaned = s.replaceAll(RegExp(r'[^0-9\-]'), '');
    if (cleaned.isEmpty) return fallback;
    return int.tryParse(cleaned) ?? fallback;
  }

  static double _safeDouble(dynamic v, [double fallback = 0.0]) {
    if (v == null) return fallback;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    final s = _safeString(v);
    if (s.isEmpty) return fallback;
    final cleaned = s.replaceAll(RegExp(r'[^0-9\.\-]'), '');
    if (cleaned.isEmpty) return fallback;
    return double.tryParse(cleaned) ?? fallback;
  }

  static List<String> _extractImages(dynamic imgField) {
    if (imgField == null) return <String>[];
    if (imgField is String) {
      final s = imgField.trim();
      if (s.isEmpty) return <String>[];
      if ((s.startsWith('[') && s.endsWith(']')) || s.contains('http')) {
        try {
          final decoded = jsonDecode(s);
          if (decoded is List) {
            return decoded
                .map((e) => _safeString(e))
                .where((e) => e.isNotEmpty)
                .toList();
          }
        } catch (_) {}
      }
      return [s];
    }
    if (imgField is List) {
      return imgField
          .map((e) => _safeString(e))
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (imgField is Map) {
      for (final k in ['url', 'image', 'src', 'path']) {
        if (imgField[k] != null) {
          final s = _safeString(imgField[k]);
          if (s.isNotEmpty) return [s];
        }
      }
    }
    return [];
  }

  factory WishlistProduct.fromJson(Map<String, dynamic> json) {
    final id = _safeString(json['_id'] ?? json['id'] ?? '');
    final name = _safeString(json['name']);
    final price = _safeInt(json['price']);
    final category = _safeString(json['category']);
    final stock = _safeInt(json['stock'], 10);
    final description = _safeString(json['content'] ?? json['description']);
    final images = _extractImages(json['image']);
    final image = images.isNotEmpty ? images.first : '';
    final variation = _safeString(json['variation']);
    final status = _safeString(json['status']);
    final halfPlatePrice = _safeInt(json['halfPlatePrice']);
    final fullPlatePrice = _safeInt(json['fullPlatePrice']);
    final discount = _safeInt(json['discount']);
    final restaurantProductId = _safeString(json['restaurantProductId']);
    final preparationTime = _safeString(json['preparationTime']);
    final createdAt = DateTime.tryParse(_safeString(json['createdAt']));
    final rating = _safeDouble(json['rating']);
    final viewcount = _safeInt(json['viewcount']);

    final restaurant = json['restaurant'] as Map<String, dynamic>? ?? {};
    final restaurantName = _safeString(restaurant['restaurantName']);
    final restaurantLocationName =
        _safeString(restaurant['locationName']);
    final restaurantStatus = _safeString(restaurant['status']);
    final restaurantId = _safeString(restaurant['restaurantId']);

    final tags = (json['tags'] is List)
        ? (json['tags'] as List)
            .map((e) => _safeString(e))
            .where((e) => e.isNotEmpty)
            .toList()
        : <String>[];

    return WishlistProduct(
      id: id,
      name: name.isNotEmpty ? name : 'Unnamed product',
      price: price,
      category: category,
      stock: stock,
      description: description,
      image: image,
      images: images,
      variation: variation,
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      restaurantLocationName: restaurantLocationName,
      status: status,
      restaurantStatus: restaurantStatus,
      halfPlatePrice: halfPlatePrice,
      fullPlatePrice: fullPlatePrice,
      discount: discount,
      restaurantProductId: restaurantProductId,
      tags: tags,
      preparationTime: preparationTime,
      createdAt: createdAt,
      rating: rating,
      viewcount: viewcount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'price': price,
      'category': category,
      'stock': stock,
      'description': description,
      'image': images,
      'variation': variation,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'restaurantLocationName': restaurantLocationName,
      'status': status,
      'restaurantStatus': restaurantStatus,
      'halfPlatePrice': halfPlatePrice,
      'fullPlatePrice': fullPlatePrice,
      'discount': discount,
      'restaurantProductId': restaurantProductId,
      'tags': tags,
      'preparationTime': preparationTime,
      'createdAt': createdAt?.toIso8601String(),
      'rating': rating,
      'viewcount': viewcount,
      'restaurant': {
        'restaurantName': restaurantName,
        'locationName': restaurantLocationName,
        'status': restaurantStatus,
      },
    };
  }

  static List<WishlistProduct> parseWishlistResponse(dynamic response) {
    final List<WishlistProduct> out = [];
    if (response == null) return out;

    try {
      if (response is Map<String, dynamic> &&
          response.containsKey('wishlist')) {
        final list = response['wishlist'];
        if (list is List) {
          for (final item in list) {
            out.add(WishlistProduct.fromJson(
                Map<String, dynamic>.from(item)));
          }
        }
      } else if (response is List) {
        for (final item in response) {
          out.add(WishlistProduct.fromJson(
              Map<String, dynamic>.from(item)));
        }
      } else if (response is String) {
        final decoded = jsonDecode(response);
        return parseWishlistResponse(decoded);
      }
    } catch (_) {}

    return out;
  }

  @override
  String toString() {
    return 'WishlistProduct(id: $id, name: $name, price: $price, '
        'status: $status, restaurantStatus: $restaurantStatus, '
        'image: $image, rating: $rating, viewcount: $viewcount)';
  }
}
