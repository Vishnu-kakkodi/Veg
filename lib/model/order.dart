// // lib/models/order.dart
// import 'dart:convert';

// class PointLocation {
//   final String type;
//   final List<double> coordinates;

//   PointLocation({required this.type, required this.coordinates});

//   factory PointLocation.fromJson(Map<String, dynamic> json) => PointLocation(
//         type: json['type'] ?? 'Point',
//         coordinates: (json['coordinates'] as List).map((e) => (e as num).toDouble()).toList(),
//       );

//   Map<String, dynamic> toJson() => {
//         'type': type,
//         'coordinates': coordinates,
//       };
// }

// class RestaurantSummary {
//   final String id;
//   final String restaurantName;
//   final String locationName;

//   RestaurantSummary({
//     required this.id,
//     required this.restaurantName,
//     required this.locationName,
//   });

//   factory RestaurantSummary.fromJson(Map<String, dynamic> json) => RestaurantSummary(
//         id: json['_id'] as String,
//         restaurantName: json['restaurantName'] as String,
//         locationName: json['locationName'] as String,
//       );

//   Map<String, dynamic> toJson() => {
//         '_id': id,
//         'restaurantName': restaurantName,
//         'locationName': locationName,
//       };
// }

// class DeliveryAddress {
//   final String id;
//   final String street;
//   final String city;
//   final String state;
//   final String country;
//   final String postalCode;
//   final String addressType;

//   DeliveryAddress({
//     required this.id,
//     required this.street,
//     required this.city,
//     required this.state,
//     required this.country,
//     required this.postalCode,
//     required this.addressType,
//   });

//   factory DeliveryAddress.fromJson(Map<String, dynamic> json) => DeliveryAddress(
//         id: json['_id'] as String,
//         street: json['street'] as String,
//         city: json['city'] as String,
//         state: json['state'] as String,
//         country: json['country'] as String,
//         postalCode: json['postalCode'] as String,
//         addressType: json['addressType'] as String,
//       );

//   Map<String, dynamic> toJson() => {
//         '_id': id,
//         'street': street,
//         'city': city,
//         'state': state,
//         'country': country,
//         'postalCode': postalCode,
//         'addressType': addressType,
//       };
// }

// class OrderProduct {
//   final String id;
//   final String restaurantProductId;
//   final String? recommendedId;
//   final int quantity;
//   final String name;
//   final double basePrice;
//   final String? image;

//   OrderProduct({
//     required this.id,
//     required this.restaurantProductId,
//     this.recommendedId,
//     required this.quantity,
//     required this.name,
//     required this.basePrice,
//     this.image,
//   });

//   factory OrderProduct.fromJson(Map<String, dynamic> json) => OrderProduct(
//         id: json['_id'] as String,
//         restaurantProductId: json['restaurantProductId'] as String,
//         recommendedId: json['recommendedId'] as String?,
//         quantity: (json['quantity'] as num).toInt(),
//         name: json['name'] as String,
//         basePrice: (json['basePrice'] as num).toDouble(),
//         image: json['image'] as String?,
//       );

//   Map<String, dynamic> toJson() => {
//         '_id': id,
//         'restaurantProductId': restaurantProductId,
//         'recommendedId': recommendedId,
//         'quantity': quantity,
//         'name': name,
//         'basePrice': basePrice,
//         'image': image,
//       };
// }

// class Order {
//   final String id;
//   final String userId;
//   final String cartId;
//   final RestaurantSummary restaurant;
//   final DeliveryAddress deliveryAddress;
//   final String paymentMethod;
//   final String paymentStatus;
//   final String orderStatus;
//   final String? deliveryBoyId;
//   final String deliveryStatus;
//   final List<OrderProduct> products;
//   final int totalItems;
//   final double subTotal;
//   final double deliveryCharge;
//   final double couponDiscount;
//   final double totalPayable;
//   final double distanceKm;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//   final PointLocation restaurantLocation;
//   final PointLocation deliveryLocation;

//   Order({
//     required this.id,
//     required this.userId,
//     required this.cartId,
//     required this.restaurant,
//     required this.deliveryAddress,
//     required this.paymentMethod,
//     required this.paymentStatus,
//     required this.orderStatus,
//     this.deliveryBoyId,
//     required this.deliveryStatus,
//     required this.products,
//     required this.totalItems,
//     required this.subTotal,
//     required this.deliveryCharge,
//     required this.couponDiscount,
//     required this.totalPayable,
//     required this.distanceKm,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.restaurantLocation,
//     required this.deliveryLocation,
//   });

//   factory Order.fromJson(Map<String, dynamic> json) {
//     return Order(
//       id: json['_id'] as String,
//       userId: json['userId'] as String,
//       cartId: json['cartId'] as String,
//       restaurant: RestaurantSummary.fromJson(json['restaurantId'] as Map<String, dynamic>),
//       deliveryAddress: DeliveryAddress.fromJson(json['deliveryAddress'] as Map<String, dynamic>),
//       paymentMethod: json['paymentMethod'] as String,
//       paymentStatus: json['paymentStatus'] as String,
//       orderStatus: json['orderStatus'] as String,
//       deliveryBoyId: json['deliveryBoyId'] as String?,
//       deliveryStatus: json['deliveryStatus'] as String,
//       products: (json['products'] as List).map((p) => OrderProduct.fromJson(p as Map<String, dynamic>)).toList(),
//       totalItems: (json['totalItems'] as num).toInt(),
//       subTotal: (json['subTotal'] as num).toDouble(),
//       deliveryCharge: (json['deliveryCharge'] as num).toDouble(),
//       couponDiscount: (json['couponDiscount'] as num).toDouble(),
//       totalPayable: (json['totalPayable'] as num).toDouble(),
//       distanceKm: (json['distanceKm'] as num).toDouble(),
//       createdAt: DateTime.parse(json['createdAt'] as String),
//       updatedAt: DateTime.parse(json['updatedAt'] as String),
//       restaurantLocation: PointLocation.fromJson(json['restaurantLocation'] as Map<String, dynamic>),
//       deliveryLocation: PointLocation.fromJson(json['deliveryLocation'] as Map<String, dynamic>),
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         '_id': id,
//         'userId': userId,
//         'cartId': cartId,
//         'restaurantId': restaurant.toJson(),
//         'deliveryAddress': deliveryAddress.toJson(),
//         'paymentMethod': paymentMethod,
//         'paymentStatus': paymentStatus,
//         'orderStatus': orderStatus,
//         'deliveryBoyId': deliveryBoyId,
//         'deliveryStatus': deliveryStatus,
//         'products': products.map((p) => p.toJson()).toList(),
//         'totalItems': totalItems,
//         'subTotal': subTotal,
//         'deliveryCharge': deliveryCharge,
//         'couponDiscount': couponDiscount,
//         'totalPayable': totalPayable,
//         'distanceKm': distanceKm,
//         'createdAt': createdAt.toIso8601String(),
//         'updatedAt': updatedAt.toIso8601String(),
//         'restaurantLocation': restaurantLocation.toJson(),
//         'deliveryLocation': deliveryLocation.toJson(),
//       };
// }

// // helper to parse list JSON response like your API returns
// List<Order> ordersFromApiResponse(String body) {
//   final Map<String, dynamic> parsed = json.decode(body) as Map<String, dynamic>;

//   if (parsed['success'] != true) return [];

//   final List<dynamic> data = parsed['data'] as List<dynamic>;

//   return data.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
// }

















// // lib/models/order.dart
// import 'dart:convert';


// class PointLocation {
//   final String type;
//   final List<double> coordinates;

//   PointLocation({required this.type, required this.coordinates});

//   factory PointLocation.fromJson(Map<String, dynamic> json) {
//     return PointLocation(
//       type: (json['type'] as String?) ?? 'Point',
//       coordinates: (json['coordinates'] as List<dynamic>?)
//               ?.map((e) => (e as num).toDouble())
//               .toList() ??
//           <double>[],
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         'type': type,
//         'coordinates': coordinates,
//       };
// }

// class RestaurantSummary {
//   final String id;
//   final String restaurantName;
//   final String locationName;

//   RestaurantSummary({
//     required this.id,
//     required this.restaurantName,
//     required this.locationName,
//   });

//   factory RestaurantSummary.fromJson(Map<String, dynamic> json) => RestaurantSummary(
//         id: (json['_id'] as String?) ?? '',
//         restaurantName: (json['restaurantName'] as String?) ?? '',
//         locationName: (json['locationName'] as String?) ?? '',
//       );

//   Map<String, dynamic> toJson() => {
//         '_id': id,
//         'restaurantName': restaurantName,
//         'locationName': locationName,
//       };
// }

// class DeliveryAddress {
//   final String id;
//   final String street;
//   final String city;
//   final String state;
//   final String country;
//   final String postalCode;
//   final String addressType;
//     final GeoPoint? location;


//   DeliveryAddress({
//     required this.id,
//     required this.street,
//     required this.city,
//     required this.state,
//     required this.country,
//     required this.postalCode,
//     required this.addressType,
//         this.location,

//   });

//   factory DeliveryAddress.fromJson(Map<String, dynamic> json) => DeliveryAddress(
//         id: (json['_id'] as String?) ?? '',
//         street: (json['street'] as String?) ?? '',
//         city: (json['city'] as String?) ?? '',
//         state: (json['state'] as String?) ?? '',
//         country: (json['country'] as String?) ?? '',
//         postalCode: (json['postalCode'] as String?) ?? '',
//         addressType: (json['addressType'] as String?) ?? '',
//         location: json['location'] != null
//           ? GeoPoint.fromJson(json['location'] as Map<String, dynamic>)
//           : null,
//       );

//   Map<String, dynamic> toJson() => {
//         '_id': id,
//         'street': street,
//         'city': city,
//         'state': state,
//         'country': country,
//         'postalCode': postalCode,
//         'addressType': addressType,
//       };
// }


// class GeoPoint {
//   final String? type;
//   final List<double> coordinates;

//   GeoPoint({
//     this.type,
//     this.coordinates = const [],
//   });

//   factory GeoPoint.fromJson(Map<String, dynamic> json) {
//     return GeoPoint(
//       type: json['type'] as String?,
//       coordinates: (json['coordinates'] as List<dynamic>?)
//               ?.map((e) => (e as num).toDouble())
//               .toList() ??
//           const [],
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         'type': type,
//         'coordinates': coordinates,
//       };
// }


// class OrderProduct {
//   final String id;
//   final String restaurantProductId;
//   final String? recommendedId;
//   final int quantity;
//   final String name;
//   final double basePrice;
//   final String? image;

//   OrderProduct({
//     required this.id,
//     required this.restaurantProductId,
//     this.recommendedId,
//     required this.quantity,
//     required this.name,
//     required this.basePrice,
//     this.image,
//   });

//   factory OrderProduct.fromJson(Map<String, dynamic> json) => OrderProduct(
//         id: (json['_id'] as String?) ?? '',
//         restaurantProductId: (json['restaurantProductId'] as String?) ?? '',
//         recommendedId: json['recommendedId'] as String?,
//         quantity: (json['quantity'] as num?)?.toInt() ?? 0,
//         name: (json['name'] as String?) ?? '',
//         basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0.0,
//         image: json['image'] as String?,
//       );

//   Map<String, dynamic> toJson() => {
//         '_id': id,
//         'restaurantProductId': restaurantProductId,
//         'recommendedId': recommendedId,
//         'quantity': quantity,
//         'name': name,
//         'basePrice': basePrice,
//         'image': image,
//       };
// }

// class AvailableDeliveryBoy {
//   final String id;
//   final String deliveryBoyId;
//   final String fullName;
//   final String mobileNumber;
//   final String vehicleType;
//   final double walletBalance;
//   final String status;

//   AvailableDeliveryBoy({
//     required this.id,
//     required this.deliveryBoyId,
//     required this.fullName,
//     required this.mobileNumber,
//     required this.vehicleType,
//     required this.walletBalance,
//     required this.status,
//   });

//   factory AvailableDeliveryBoy.fromJson(Map<String, dynamic> json) => AvailableDeliveryBoy(
//         id: (json['_id'] as String?) ?? '',
//         deliveryBoyId: (json['deliveryBoyId'] as String?) ?? '',
//         fullName: (json['fullName'] as String?) ?? '',
//         mobileNumber: (json['mobileNumber'] as String?) ?? '',
//         vehicleType: (json['vehicleType'] as String?) ?? '',
//         walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
//         status: (json['status'] as String?) ?? '',
//       );

//   Map<String, dynamic> toJson() => {
//         '_id': id,
//         'deliveryBoyId': deliveryBoyId,
//         'fullName': fullName,
//         'mobileNumber': mobileNumber,
//         'vehicleType': vehicleType,
//         'walletBalance': walletBalance,
//         'status': status,
//       };
// }

// class Order {
//   final String id;
//   final String userId;
//   final String cartId;
//   final RestaurantSummary restaurant;
//   final DeliveryAddress deliveryAddress;
//   final String paymentMethod;
//   final String paymentStatus;
//   final String orderStatus;
//   final String? deliveryBoyId;
//   final String deliveryStatus;
//   final List<OrderProduct> products;
//   final int totalItems;
//   final double subTotal;
//   final double deliveryCharge;
//   final double couponDiscount;
//   final double totalPayable;
//   final double distanceKm;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;
//   final PointLocation restaurantLocation;
//   final PointLocation? deliveryLocation; // <-- nullable now
//   final List<AvailableDeliveryBoy>? availableDeliveryBoys;
//   final DateTime? acceptedAt;
//   final String? paymentType;

//   Order({
//     required this.id,
//     required this.userId,
//     required this.cartId,
//     required this.restaurant,
//     required this.deliveryAddress,
//     required this.paymentMethod,
//     required this.paymentStatus,
//     required this.orderStatus,
//     this.deliveryBoyId,
//     required this.deliveryStatus,
//     required this.products,
//     required this.totalItems,
//     required this.subTotal,
//     required this.deliveryCharge,
//     required this.couponDiscount,
//     required this.totalPayable,
//     required this.distanceKm,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.restaurantLocation,
//     this.deliveryLocation,
//     this.availableDeliveryBoys,
//     this.acceptedAt,
//     this.paymentType,
//   });

//   factory Order.fromJson(Map<String, dynamic> json) {
//     // safe helpers
//     DateTime? _tryParseDate(dynamic v) {
//       if (v == null) return null;
//       try {
//         return DateTime.parse(v as String);
//       } catch (_) {
//         return null;
//       }
//     }

//     final productsList = (json['products'] as List<dynamic>?)
//             ?.map((p) => OrderProduct.fromJson(p as Map<String, dynamic>))
//             .toList() ??
//         <OrderProduct>[];

//     final availableDeliveryBoysList =
//         (json['availableDeliveryBoys'] as List<dynamic>?)
//             ?.map((b) => AvailableDeliveryBoy.fromJson(b as Map<String, dynamic>))
//             .toList();

//     // restaurantLocation assumed present in your API; still defend against null
//     final restaurantLocJson = json['restaurantLocation'] as Map<String, dynamic>?;
//     final restaurantLocation = restaurantLocJson != null
//         ? PointLocation.fromJson(restaurantLocJson)
//         : PointLocation(type: 'Point', coordinates: <double>[]);

//     final deliveryLocJson = json['deliveryLocation'] as Map<String, dynamic>?;

//     return Order(
//       id: (json['_id'] as String?) ?? '',
//       userId: (json['userId'] as String?) ?? '',
//       cartId: (json['cartId'] as String?) ?? '',
//       restaurant: RestaurantSummary.fromJson(
//           (json['restaurantId'] as Map<String, dynamic>?) ?? <String, dynamic>{}),
//       deliveryAddress: DeliveryAddress.fromJson(
//           (json['deliveryAddress'] as Map<String, dynamic>?) ?? <String, dynamic>{}),
//       paymentMethod: (json['paymentMethod'] as String?) ?? '',
//       paymentStatus: (json['paymentStatus'] as String?) ?? '',
//       orderStatus: (json['orderStatus'] as String?) ?? '',
//       deliveryBoyId: json['deliveryBoyId'] as String?,
//       deliveryStatus: (json['deliveryStatus'] as String?) ?? '',
//       products: productsList,
//       totalItems: (json['totalItems'] as num?)?.toInt() ?? productsList.length,
//       subTotal: (json['subTotal'] as num?)?.toDouble() ?? 0.0,
//       deliveryCharge: (json['deliveryCharge'] as num?)?.toDouble() ?? 0.0,
//       couponDiscount: (json['couponDiscount'] as num?)?.toDouble() ?? 0.0,
//       totalPayable: (json['totalPayable'] as num?)?.toDouble() ?? 0.0,
//       distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
//       createdAt: _tryParseDate(json['createdAt']),
//       updatedAt: _tryParseDate(json['updatedAt']),
//       restaurantLocation: restaurantLocation,
//       deliveryLocation:
//           deliveryLocJson != null ? PointLocation.fromJson(deliveryLocJson) : null,
//       availableDeliveryBoys: availableDeliveryBoysList,
//       acceptedAt: _tryParseDate(json['acceptedAt']),
//       paymentType: json['paymentType'] as String?,
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         '_id': id,
//         'userId': userId,
//         'cartId': cartId,
//         'restaurantId': restaurant.toJson(),
//         'deliveryAddress': deliveryAddress.toJson(),
//         'paymentMethod': paymentMethod,
//         'paymentStatus': paymentStatus,
//         'orderStatus': orderStatus,
//         'deliveryBoyId': deliveryBoyId,
//         'deliveryStatus': deliveryStatus,
//         'products': products.map((p) => p.toJson()).toList(),
//         'totalItems': totalItems,
//         'subTotal': subTotal,
//         'deliveryCharge': deliveryCharge,
//         'couponDiscount': couponDiscount,
//         'totalPayable': totalPayable,
//         'distanceKm': distanceKm,
//         'createdAt': createdAt?.toIso8601String(),
//         'updatedAt': updatedAt?.toIso8601String(),
//         'restaurantLocation': restaurantLocation.toJson(),
//         'deliveryLocation': deliveryLocation?.toJson(),
//         'availableDeliveryBoys': availableDeliveryBoys?.map((b) => b.toJson()).toList(),
//         'acceptedAt': acceptedAt?.toIso8601String(),
//         'paymentType': paymentType,
//       };
// }

// // helper to parse list JSON response like your API returns
// List<Order> ordersFromApiResponse(String body) {
//   final Map<String, dynamic> parsed = json.decode(body) as Map<String, dynamic>;

//   if (parsed['success'] != true) return [];

//   final List<dynamic> data = parsed['data'] as List<dynamic>? ?? <dynamic>[];

//   return data.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
// }
























// lib/models/order.dart
import 'dart:convert';

class PointLocation {
  final String type;
  final List<double> coordinates;

  PointLocation({required this.type, required this.coordinates});

  factory PointLocation.fromJson(Map<String, dynamic> json) {
    return PointLocation(
      type: (json['type'] as String?) ?? 'Point',
      coordinates: (json['coordinates'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          <double>[],
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'coordinates': coordinates,
      };
}

class RestaurantSummary {
  final String id;
  final String restaurantName;
  final String locationName;

  RestaurantSummary({
    required this.id,
    required this.restaurantName,
    required this.locationName,
  });

  factory RestaurantSummary.fromJson(Map<String, dynamic> json) =>
      RestaurantSummary(
        id: (json['_id'] as String?) ?? '',
        restaurantName: (json['restaurantName'] as String?) ?? '',
        locationName: (json['locationName'] as String?) ?? '',
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'restaurantName': restaurantName,
        'locationName': locationName,
      };
}

class GeoPoint {
  final String? type;
  final List<double> coordinates;

  GeoPoint({
    this.type,
    this.coordinates = const [],
  });

  factory GeoPoint.fromJson(Map<String, dynamic> json) {
    return GeoPoint(
      type: json['type'] as String?,
      coordinates: (json['coordinates'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'coordinates': coordinates,
      };
}

class DeliveryAddress {
  final String id;
  final String street;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String addressType;
  final GeoPoint? location;

  DeliveryAddress({
    required this.id,
    required this.street,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.addressType,
    this.location,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) =>
      DeliveryAddress(
        id: (json['_id'] as String?) ?? '',
        street: (json['street'] as String?) ?? '',
        city: (json['city'] as String?) ?? '',
        state: (json['state'] as String?) ?? '',
        country: (json['country'] as String?) ?? '',
        postalCode: (json['postalCode'] as String?) ?? '',
        addressType: (json['addressType'] as String?) ?? '',
        location: json['location'] != null
            ? GeoPoint.fromJson(
                json['location'] as Map<String, dynamic>,
              )
            : null,
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'street': street,
        'city': city,
        'state': state,
        'country': country,
        'postalCode': postalCode,
        'addressType': addressType,
        // 'location': location?.toJson(), // add if you need it when sending back
      };
}

class OrderProduct {
  final String id;
  final String restaurantProductId;
  final String? recommendedId;
  final int quantity;
  final String name;

  /// Your existing field used in UI/invoice
  final double basePrice;

  final String? image;

  /// NEW fields from latest response
  final bool isHalfPlate;
  final bool isFullPlate;
  final double price;            // raw price from API
  final double discountPercent;
  final double discountAmount;

  OrderProduct({
    required this.id,
    required this.restaurantProductId,
    this.recommendedId,
    required this.quantity,
    required this.name,
    required this.basePrice,
    this.image,
    this.isHalfPlate = false,
    this.isFullPlate = false,
    this.price = 0.0,
    this.discountPercent = 0.0,
    this.discountAmount = 0.0,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    final rawPrice = (json['price'] as num?)?.toDouble() ??
        (json['basePrice'] as num?)?.toDouble() ??
        0.0;

    return OrderProduct(
      id: (json['_id'] as String?) ?? '',
      restaurantProductId:
          (json['restaurantProductId'] as String?) ?? '',
      recommendedId: json['recommendedId'] as String?,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      // basePrice stays in your app API:
      basePrice:
          (json['basePrice'] as num?)?.toDouble() ?? rawPrice,
      image: json['image'] as String?,
      isHalfPlate: (json['isHalfPlate'] as bool?) ?? false,
      isFullPlate: (json['isFullPlate'] as bool?) ?? false,
      price: rawPrice,
      discountPercent:
          (json['discountPercent'] as num?)?.toDouble() ?? 0.0,
      discountAmount:
          (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'restaurantProductId': restaurantProductId,
        'recommendedId': recommendedId,
        'quantity': quantity,
        'name': name,
        'basePrice': basePrice,
        'price': price,
        'image': image,
        'isHalfPlate': isHalfPlate,
        'isFullPlate': isFullPlate,
        'discountPercent': discountPercent,
        'discountAmount': discountAmount,
      };
}

class AvailableDeliveryBoy {
  final String id;
  final String deliveryBoyId;
  final String fullName;
  final String mobileNumber;
  final String vehicleType;
  final double walletBalance;
  final String status;

  AvailableDeliveryBoy({
    required this.id,
    required this.deliveryBoyId,
    required this.fullName,
    required this.mobileNumber,
    required this.vehicleType,
    required this.walletBalance,
    required this.status,
  });

  factory AvailableDeliveryBoy.fromJson(
          Map<String, dynamic> json) =>
      AvailableDeliveryBoy(
        id: (json['_id'] as String?) ?? '',
        deliveryBoyId: (json['deliveryBoyId'] as String?) ?? '',
        fullName: (json['fullName'] as String?) ?? '',
        mobileNumber:
            (json['mobileNumber'] as String?) ?? '',
        vehicleType: (json['vehicleType'] as String?) ?? '',
        walletBalance:
            (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
        status: (json['status'] as String?) ?? '',
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'deliveryBoyId': deliveryBoyId,
        'fullName': fullName,
        'mobileNumber': mobileNumber,
        'vehicleType': vehicleType,
        'walletBalance': walletBalance,
        'status': status,
      };
}

class Order {
  final String id;
  final String userId;
  final String cartId;
  final RestaurantSummary restaurant;
  final DeliveryAddress deliveryAddress;
  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final String? deliveryBoyId;
  final String deliveryStatus;
  final List<OrderProduct> products;
  final int totalItems;
  final double subTotal;
  final double deliveryCharge;
  final double couponDiscount;
  final double gstAmount;
  final double platformCharge;
  final double totalPayable;
  final double distanceKm;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final PointLocation restaurantLocation;
  final PointLocation? deliveryLocation;
  final List<AvailableDeliveryBoy>? availableDeliveryBoys;
  final DateTime? acceptedAt;
  final String? paymentType;
  final String? transactionId;

  Order({
    required this.id,
    required this.userId,
    required this.cartId,
    required this.restaurant,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    this.deliveryBoyId,
    required this.deliveryStatus,
    required this.products,
    required this.totalItems,
    required this.subTotal,
    required this.deliveryCharge,
    required this.couponDiscount,
    required this.gstAmount,
    required this.platformCharge,
    required this.totalPayable,
    required this.distanceKm,
    required this.createdAt,
    required this.updatedAt,
    required this.restaurantLocation,
    this.deliveryLocation,
    this.availableDeliveryBoys,
    this.acceptedAt,
    this.paymentType,
    this.transactionId,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    DateTime? _tryParseDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v as String);
      } catch (_) {
        return null;
      }
    }

    final productsList = (json['products'] as List<dynamic>?)
            ?.map((p) =>
                OrderProduct.fromJson(p as Map<String, dynamic>))
            .toList() ??
        <OrderProduct>[];

    final availableDeliveryBoysList =
        (json['availableDeliveryBoys'] as List<dynamic>?)
            ?.map((b) => AvailableDeliveryBoy.fromJson(
                b as Map<String, dynamic>))
            .toList();

    final restaurantLocJson =
        json['restaurantLocation'] as Map<String, dynamic>?;
    final restaurantLocation = restaurantLocJson != null
        ? PointLocation.fromJson(restaurantLocJson)
        : PointLocation(type: 'Point', coordinates: <double>[]);

    final deliveryLocJson =
        json['deliveryLocation'] as Map<String, dynamic>?;

    return Order(
      id: (json['_id'] as String?) ?? '',
      userId: (json['userId'] as String?) ?? '',
      cartId: (json['cartId'] as String?) ?? '',
      restaurant: RestaurantSummary.fromJson(
        (json['restaurantId'] as Map<String, dynamic>?) ??
            <String, dynamic>{},
      ),
      deliveryAddress: DeliveryAddress.fromJson(
        (json['deliveryAddress'] as Map<String, dynamic>?) ??
            <String, dynamic>{},
      ),
      paymentMethod: (json['paymentMethod'] as String?) ?? '',
      paymentStatus: (json['paymentStatus'] as String?) ?? '',
      orderStatus: (json['orderStatus'] as String?) ?? '',
      deliveryBoyId: json['deliveryBoyId'] as String?,
      deliveryStatus: (json['deliveryStatus'] as String?) ?? '',
      products: productsList,
      totalItems:
          (json['totalItems'] as num?)?.toInt() ??
              productsList.length,
      subTotal: (json['subTotal'] as num?)?.toDouble() ?? 0.0,
      deliveryCharge:
          (json['deliveryCharge'] as num?)?.toDouble() ?? 0.0,
      couponDiscount:
          (json['couponDiscount'] as num?)?.toDouble() ?? 0.0,
      gstAmount:
          (json['gstAmount'] as num?)?.toDouble() ?? 0.0,
      platformCharge:
          (json['platformCharge'] as num?)?.toDouble() ?? 0.0,
      totalPayable:
          (json['totalPayable'] as num?)?.toDouble() ?? 0.0,
      distanceKm:
          (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
      createdAt: _tryParseDate(json['createdAt']),
      updatedAt: _tryParseDate(json['updatedAt']),
      restaurantLocation: restaurantLocation,
      deliveryLocation: deliveryLocJson != null
          ? PointLocation.fromJson(deliveryLocJson)
          : null,
      availableDeliveryBoys: availableDeliveryBoysList,
      acceptedAt: _tryParseDate(json['acceptedAt']),
      paymentType: json['paymentType'] as String?,
      transactionId: (json['transactionId'] is String && json['transactionId'] != '')
    ? json['transactionId'] as String
    : null,

    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'userId': userId,
        'cartId': cartId,
        'restaurantId': restaurant.toJson(),
        'deliveryAddress': deliveryAddress.toJson(),
        'paymentMethod': paymentMethod,
        'paymentStatus': paymentStatus,
        'orderStatus': orderStatus,
        'deliveryBoyId': deliveryBoyId,
        'deliveryStatus': deliveryStatus,
        'products': products.map((p) => p.toJson()).toList(),
        'totalItems': totalItems,
        'subTotal': subTotal,
        'deliveryCharge': deliveryCharge,
        'couponDiscount': couponDiscount,
        'gstAmount': gstAmount,
        'platformCharge': platformCharge,
        'totalPayable': totalPayable,
        'distanceKm': distanceKm,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'restaurantLocation': restaurantLocation.toJson(),
        'deliveryLocation': deliveryLocation?.toJson(),
        'availableDeliveryBoys':
            availableDeliveryBoys
                ?.map((b) => b.toJson())
                .toList(),
        'acceptedAt': acceptedAt?.toIso8601String(),
        'paymentType': paymentType,
        'transactionId': transactionId,
      };
}

// helper to parse list JSON response like your API returns
List<Order> ordersFromApiResponse(String body) {
  final Map<String, dynamic> parsed =
      json.decode(body) as Map<String, dynamic>;

  if (parsed['success'] != true) return [];

  final List<dynamic> data =
      parsed['data'] as List<dynamic>? ?? <dynamic>[];

  return data
      .map((e) => Order.fromJson(e as Map<String, dynamic>))
      .toList();
}
