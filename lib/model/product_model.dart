// import 'package:veegify/model/wishlist_model.dart';

// class AddOn {
//   final String id;
//   final String name;
//   final double price;

//   AddOn({
//     required this.id,
//     required this.name,
//     required this.price,
//   });

//   factory AddOn.fromJson(Map<String, dynamic> json) {
//     return AddOn(
//       id: json['_id'] ?? '',
//       name: json['name'] ?? '',
//       price: (json['price'] ?? 0).toDouble(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'name': name,
//       'price': price,
//     };
//   }
// }


// class Product {
//   final String id;
//   final String name;
//   final double price;
//   final String category;
//   final int stock;
//   final String description;
//   final String image;
//   final String variation;
//   final String userId;
//   final List<AddOn> addOns;
//   final String locationName;
//   final double rating;
//   final int viewCount;
//   final String contentName;
//   final String deliveryTime;
//   final String restaurantId;
//   final List<dynamic> reviews;
//   final DateTime createdAt;
//   final DateTime updatedAt;

//   Product({
//     required this.id,
//     required this.name,
//     required this.price,
//     required this.category,
//     required this.stock,
//     required this.description,
//     required this.image,
//     required this.variation,
//     required this.userId,
//     required this.addOns,
//     required this.locationName,
//     required this.rating,
//     required this.viewCount,
//     required this.contentName,
//     required this.deliveryTime,
//     required this.restaurantId,
//     required this.reviews,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   factory Product.fromJson(Map<String, dynamic> json) {
//     return Product(
//       id: json['_id'] ?? '',
//       name: json['name'] ?? '',
//       price: (json['price'] ?? 0).toDouble(),
//       category: json['category'] ?? '',
//       stock: json['stock'] ?? 0,
//       description: json['description'] ?? '',
//       image: json['image'] ?? '',
//       variation: json['variation'] ?? '',
//       userId: json['userId'] ?? '',
//       addOns: (json['addOns'] as List<dynamic>?)
//           ?.map((addon) => AddOn.fromJson(addon))
//           .toList() ?? [],
//       locationName: json['locationname'] ?? '',
//       rating: (json['rating'] ?? 0).toDouble(),
//       viewCount: json['viewcount'] ?? 0,
//       contentName: json['contentname'] ?? '',
//       deliveryTime: json['deliverytime'] ?? '',
//       restaurantId: json['restaurantId'] ?? '',
//       reviews: json['reviews'] ?? [],
//       createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
//       updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'name': name,
//       'price': price,
//       'category': category,
//       'stock': stock,
//       'description': description,
//       'image': image,
//       'variation': variation,
//       'userId': userId,
//       'addOns': addOns.map((addon) => addon.toJson()).toList(),
//       'locationname': locationName,
//       'rating': rating,
//       'viewcount': viewCount,
//       'contentname': contentName,
//       'deliverytime': deliveryTime,
//       'restaurantId': restaurantId,
//       'reviews': reviews,
//       'createdAt': createdAt.toIso8601String(),
//       'updatedAt': updatedAt.toIso8601String(),
//     };
//   }

//   // Helper getter to check if item is vegetarian
//   bool get isVeg => category.toLowerCase() == 'veg';
  
//   // Helper getter to check if item is in stock
//   bool get isInStock => stock > 0;
  
//   // Helper getter for formatted rating
//   String get formattedRating => rating.toStringAsFixed(1);
// }




















import 'package:veegify/model/wishlist_model.dart';

class AddOn {
  final String id;
  final String name;
  final double price;

  AddOn({
    required this.id,
    required this.name,
    required this.price,
  });

  factory AddOn.fromJson(Map<String, dynamic> json) {
    return AddOn(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'price': price,
    };
  }
}

// =======================================================

class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final int stock;
  final String description;
  final String image;
  final String variation;
  final String userId;
  final List<AddOn> addOns;
  final String locationName;
  final double rating;
  final int viewCount;
  final String contentName;
  final String deliveryTime;
  final String restaurantId;
  final List<dynamic> reviews;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.stock,
    required this.description,
    required this.image,
    required this.variation,
    required this.userId,
    required this.addOns,
    required this.locationName,
    required this.rating,
    required this.viewCount,
    required this.contentName,
    required this.deliveryTime,
    required this.restaurantId,
    required this.reviews,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
      category: json['category']?.toString() ?? '',
      stock: (json['stock'] is num)
          ? (json['stock'] as num).toInt()
          : int.tryParse(json['stock']?.toString() ?? '') ?? 0,
      description: json['description']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      variation: json['variation']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      addOns: (json['addOns'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map((addon) => AddOn.fromJson(addon))
              .toList() ??
          [],
      locationName: json['locationname']?.toString() ?? '',
      rating: (json['rating'] is num)
          ? (json['rating'] as num).toDouble()
          : double.tryParse(json['rating']?.toString() ?? '') ?? 0.0,
      viewCount: (json['viewcount'] is num)
          ? (json['viewcount'] as num).toInt()
          : int.tryParse(json['viewcount']?.toString() ?? '') ?? 0,
      contentName: json['contentname']?.toString() ?? '',
      deliveryTime: json['deliverytime']?.toString() ?? '',
      restaurantId: json['restaurantId']?.toString() ?? '',
      reviews: json['reviews'] is List ? json['reviews'] : [],
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
              DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
              DateTime.now(),
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
      'image': image,
      'variation': variation,
      'userId': userId,
      'addOns': addOns.map((addon) => addon.toJson()).toList(),
      'locationname': locationName,
      'rating': rating,
      'viewcount': viewCount,
      'contentname': contentName,
      'deliverytime': deliveryTime,
      'restaurantId': restaurantId,
      'reviews': reviews,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper getter to check if item is vegetarian
  bool get isVeg => category.toLowerCase() == 'veg';

  // Helper getter to check if item is in stock
  bool get isInStock => stock > 0;

  // Helper getter for formatted rating
  String get formattedRating => rating.toStringAsFixed(1);
}
