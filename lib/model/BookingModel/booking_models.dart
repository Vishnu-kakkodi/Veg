// // models/booking_models.dart

// class BookingResponse {
//   final bool success;
//   final List<Booking> data;

//   BookingResponse({
//     required this.success,
//     required this.data,
//   });

//   factory BookingResponse.fromJson(Map<String, dynamic> json) {
//     return BookingResponse(
//       success: json['success'] ?? false,
//       data: (json['data'] as List<dynamic>?)
//           ?.map((item) => Booking.fromJson(item as Map<String, dynamic>))
//           .toList() ?? [],
//     );
//   }
// }

// class Booking {
//   final String id;
//   final String userId;
//   final String cartId;
//   final Restaurant restaurant;
//   final String restaurantLocation;
//   final DeliveryAddress deliveryAddress;
//   final String paymentMethod;
//   final String paymentStatus;
//   final String orderStatus;
//   final int totalItems;
//   final double subTotal;
//   final double deliveryCharge;
//   final double couponDiscount;
//   final double totalPayable;
//   final double distanceKm;
//   final DateTime createdAt;
//   final DateTime updatedAt;

//   Booking({
//     required this.id,
//     required this.userId,
//     required this.cartId,
//     required this.restaurant,
//     required this.restaurantLocation,
//     required this.deliveryAddress,
//     required this.paymentMethod,
//     required this.paymentStatus,
//     required this.orderStatus,
//     required this.totalItems,
//     required this.subTotal,
//     required this.deliveryCharge,
//     required this.couponDiscount,
//     required this.totalPayable,
//     required this.distanceKm,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   factory Booking.fromJson(Map<String, dynamic> json) {
//     return Booking(
//       id: json['_id'] ?? '',
//       userId: json['userId'] ?? '',
//       cartId: json['cartId'] ?? '',
//       restaurant: Restaurant.fromJson(json['restaurantId'] ?? {}),
//       restaurantLocation: json['restaurantLocation'] ?? '',
//       deliveryAddress: DeliveryAddress.fromJson(json['deliveryAddress'] ?? {}),
//       paymentMethod: json['paymentMethod'] ?? '',
//       paymentStatus: json['paymentStatus'] ?? '',
//       orderStatus: json['orderStatus'] ?? '',
//       totalItems: (json['totalItems'] ?? 0).toInt(),
//       subTotal: (json['subTotal'] ?? 0).toDouble(),
//       deliveryCharge: (json['deliveryCharge'] ?? 0).toDouble(),
//       couponDiscount: (json['couponDiscount'] ?? 0).toDouble(),
//       totalPayable: (json['totalPayable'] ?? 0).toDouble(),
//       distanceKm: (json['distanceKm'] ?? 0).toDouble(),
//       createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
//       updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
//     );
//   }

//   bool get isToday {
//     final today = DateTime.now();
//     return createdAt.year == today.year &&
//            createdAt.month == today.month &&
//            createdAt.day == today.day;
//   }

//   bool get isCancelled {
//     return orderStatus.toLowerCase() == 'cancelled';
//   }

//   String get formattedDate {
//     return "${createdAt.day}/${createdAt.month}/${createdAt.year}";
//   }

//   String get formattedTime {
//     return "${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}";
//   }
// }

// class Restaurant {
//   final String id;
//   final String restaurantName;
//   final String locationName;

//   Restaurant({
//     required this.id,
//     required this.restaurantName,
//     required this.locationName,
//   });

//   factory Restaurant.fromJson(Map<String, dynamic> json) {
//     return Restaurant(
//       id: json['_id'] ?? '',
//       restaurantName: json['restaurantName'] ?? '',
//       locationName: json['locationName'] ?? '',
//     );
//   }
// }

// class DeliveryAddress {
//   final String addressLine;
//   final String city;
//   final String state;
//   final String pinCode;
//   final String country;
//   final String phone;
//   final String houseNumber;
//   final String apartment;
//   final String directions;
//   final String street;
//   final double latitude;
//   final double longitude;
//   final String id;

//   DeliveryAddress({
//     required this.addressLine,
//     required this.city,
//     required this.state,
//     required this.pinCode,
//     required this.country,
//     required this.phone,
//     required this.houseNumber,
//     required this.apartment,
//     required this.directions,
//     required this.street,
//     required this.latitude,
//     required this.longitude,
//     required this.id,
//   });

//   factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
//     return DeliveryAddress(
//       addressLine: json['addressLine'] ?? '',
//       city: json['city'] ?? '',
//       state: json['state'] ?? '',
//       pinCode: json['pinCode'] ?? '',
//       country: json['country'] ?? '',
//       phone: json['phone'] ?? '',
//       houseNumber: json['houseNumber'] ?? '',
//       apartment: json['apartment'] ?? '',
//       directions: json['directions'] ?? '',
//       street: json['street'] ?? '',
//       latitude: (json['latitud'] ?? 0).toDouble(), // Note: API has typo "latitud"
//       longitude: (json['longitud'] ?? 0).toDouble(), // Note: API has typo "longitud"
//       id: json['_id'] ?? '',
//     );
//   }

//   String get fullAddress {
//     return "$houseNumber, $apartment, $street, $addressLine, $city, $state - $pinCode";
//   }
// }









// models/booking_models.dart

// --------------------
// Helper functions
// --------------------
String _asString(dynamic value, {String defaultValue = ''}) {
  if (value == null) return defaultValue;
  if (value is String) return value;
  return value.toString();
}

int _asInt(dynamic value, {int defaultValue = 0}) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? defaultValue;
  return defaultValue;
}

double _asDouble(dynamic value, {double defaultValue = 0.0}) {
  if (value == null) return defaultValue;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? defaultValue;
  return defaultValue;
}

bool _asBool(dynamic value, {bool defaultValue = false}) {
  if (value == null) return defaultValue;
  if (value is bool) return value;
  if (value is String) {
    return value.toLowerCase() == 'true';
  }
  return defaultValue;
}

DateTime _asDateTime(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is DateTime) return value;
  if (value is String) {
    return DateTime.tryParse(value) ?? DateTime.now();
  }
  return DateTime.now();
}

// --------------------
// Booking Response
// --------------------
class BookingResponse {
  final bool success;
  final List<Booking> data;

  BookingResponse({
    required this.success,
    required this.data,
  });

  factory BookingResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return BookingResponse(success: false, data: []);
    }

    return BookingResponse(
      success: _asBool(json['success']),
      data: (json['data'] is List)
          ? (json['data'] as List)
              .map((e) => Booking.fromJson(e as Map<String, dynamic>?))
              .toList()
          : [],
    );
  }
}

// --------------------
// Booking
// --------------------
class Booking {
  final String id;
  final String userId;
  final String cartId;
  final Restaurant restaurant;
  final String restaurantLocation;
  final DeliveryAddress deliveryAddress;
  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final int totalItems;
  final double subTotal;
  final double deliveryCharge;
  final double amountSavedOnOrder;
  final double couponDiscount;
  final double totalPayable;
  final double distanceKm;
  final DateTime createdAt;
  final DateTime updatedAt;

  Booking({
    required this.id,
    required this.userId,
    required this.cartId,
    required this.restaurant,
    required this.restaurantLocation,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    required this.totalItems,
    required this.subTotal,
    required this.deliveryCharge,
    required this.amountSavedOnOrder,
    required this.couponDiscount,
    required this.totalPayable,
    required this.distanceKm,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Booking(
        id: '',
        userId: '',
        cartId: '',
        restaurant: Restaurant.empty(),
        restaurantLocation: '',
        deliveryAddress: DeliveryAddress.empty(),
        paymentMethod: '',
        paymentStatus: '',
        orderStatus: '',
        totalItems: 0,
        subTotal: 0,
        deliveryCharge: 0,
        amountSavedOnOrder: 0,
        couponDiscount: 0,
        totalPayable: 0,
        distanceKm: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    return Booking(
      id: _asString(json['_id']),
      userId: _asString(json['userId']),
      cartId: _asString(json['cartId']),
      restaurant: Restaurant.fromJson(json['restaurantId']),
      restaurantLocation: _asString(json['restaurantLocation']),
      deliveryAddress: DeliveryAddress.fromJson(json['deliveryAddress']),
      paymentMethod: _asString(json['paymentMethod']),
      paymentStatus: _asString(json['paymentStatus']),
      orderStatus: _asString(json['orderStatus']),
      totalItems: _asInt(json['totalItems']),
      subTotal: _asDouble(json['subTotal']),
      deliveryCharge: _asDouble(json['deliveryCharge']),
      amountSavedOnOrder: _asDouble(json['amountSavedOnOrder']),
      couponDiscount: _asDouble(json['couponDiscount']),
      totalPayable: _asDouble(json['totalPayable']),
      distanceKm: _asDouble(json['distanceKm']),
      createdAt: _asDateTime(json['createdAt']),
      updatedAt: _asDateTime(json['updatedAt']),
    );
  }

  // --------------------
  // Computed helpers
  // --------------------
  bool get isToday {
    final now = DateTime.now();
    return createdAt.year == now.year &&
        createdAt.month == now.month &&
        createdAt.day == now.day;
  }

  bool get isCancelled =>
      orderStatus.toLowerCase() == 'cancelled';

  String get formattedDate =>
      "${createdAt.day.toString().padLeft(2, '0')}/"
      "${createdAt.month.toString().padLeft(2, '0')}/"
      "${createdAt.year}";

  String get formattedTime =>
      "${createdAt.hour.toString().padLeft(2, '0')}:"
      "${createdAt.minute.toString().padLeft(2, '0')}";
}

// --------------------
// Restaurant
// --------------------
class Restaurant {
  final String id;
  final String restaurantName;
  final String locationName;

  Restaurant({
    required this.id,
    required this.restaurantName,
    required this.locationName,
  });

  factory Restaurant.fromJson(dynamic json) {
    if (json == null || json is! Map<String, dynamic>) {
      return Restaurant.empty();
    }

    return Restaurant(
      id: _asString(json['_id']),
      restaurantName: _asString(json['restaurantName']),
      locationName: _asString(json['locationName']),
    );
  }

  factory Restaurant.empty() {
    return Restaurant(
      id: '',
      restaurantName: '',
      locationName: '',
    );
  }
}

// --------------------
// Delivery Address
// --------------------
class DeliveryAddress {
  final String addressLine;
  final String city;
  final String state;
  final String pinCode;
  final String country;
  final String phone;
  final String houseNumber;
  final String apartment;
  final String directions;
  final String street;
  final double latitude;
  final double longitude;
  final String id;

  DeliveryAddress({
    required this.addressLine,
    required this.city,
    required this.state,
    required this.pinCode,
    required this.country,
    required this.phone,
    required this.houseNumber,
    required this.apartment,
    required this.directions,
    required this.street,
    required this.latitude,
    required this.longitude,
    required this.id,
  });

  factory DeliveryAddress.fromJson(dynamic json) {
    if (json == null || json is! Map<String, dynamic>) {
      return DeliveryAddress.empty();
    }

    return DeliveryAddress(
      addressLine: _asString(json['addressLine']),
      city: _asString(json['city']),
      state: _asString(json['state']),
      pinCode: _asString(json['pinCode']),
      country: _asString(json['country']),
      phone: _asString(json['phone']),
      houseNumber: _asString(json['houseNumber']),
      apartment: _asString(json['apartment']),
      directions: _asString(json['directions']),
      street: _asString(json['street']),
      latitude: _asDouble(json['latitud'] ?? json['latitude']), // API typo safe
      longitude: _asDouble(json['longitud'] ?? json['longitude']),
      id: _asString(json['_id']),
    );
  }

  factory DeliveryAddress.empty() {
    return DeliveryAddress(
      addressLine: '',
      city: '',
      state: '',
      pinCode: '',
      country: '',
      phone: '',
      houseNumber: '',
      apartment: '',
      directions: '',
      street: '',
      latitude: 0,
      longitude: 0,
      id: '',
    );
  }

  String get fullAddress {
    return [
      houseNumber,
      apartment,
      street,
      addressLine,
      city,
      state,
      pinCode
    ].where((e) => e.isNotEmpty).join(', ');
  }
}
