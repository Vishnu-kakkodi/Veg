// models/booking_models.dart

class BookingResponse {
  final bool success;
  final List<Booking> data;

  BookingResponse({
    required this.success,
    required this.data,
  });

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => Booking.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

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
    required this.couponDiscount,
    required this.totalPayable,
    required this.distanceKm,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      cartId: json['cartId'] ?? '',
      restaurant: Restaurant.fromJson(json['restaurantId'] ?? {}),
      restaurantLocation: json['restaurantLocation'] ?? '',
      deliveryAddress: DeliveryAddress.fromJson(json['deliveryAddress'] ?? {}),
      paymentMethod: json['paymentMethod'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      orderStatus: json['orderStatus'] ?? '',
      totalItems: (json['totalItems'] ?? 0).toInt(),
      subTotal: (json['subTotal'] ?? 0).toDouble(),
      deliveryCharge: (json['deliveryCharge'] ?? 0).toDouble(),
      couponDiscount: (json['couponDiscount'] ?? 0).toDouble(),
      totalPayable: (json['totalPayable'] ?? 0).toDouble(),
      distanceKm: (json['distanceKm'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  bool get isToday {
    final today = DateTime.now();
    return createdAt.year == today.year &&
           createdAt.month == today.month &&
           createdAt.day == today.day;
  }

  bool get isCancelled {
    return orderStatus.toLowerCase() == 'cancelled';
  }

  String get formattedDate {
    return "${createdAt.day}/${createdAt.month}/${createdAt.year}";
  }

  String get formattedTime {
    return "${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}";
  }
}

class Restaurant {
  final String id;
  final String restaurantName;
  final String locationName;

  Restaurant({
    required this.id,
    required this.restaurantName,
    required this.locationName,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['_id'] ?? '',
      restaurantName: json['restaurantName'] ?? '',
      locationName: json['locationName'] ?? '',
    );
  }
}

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

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      addressLine: json['addressLine'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pinCode: json['pinCode'] ?? '',
      country: json['country'] ?? '',
      phone: json['phone'] ?? '',
      houseNumber: json['houseNumber'] ?? '',
      apartment: json['apartment'] ?? '',
      directions: json['directions'] ?? '',
      street: json['street'] ?? '',
      latitude: (json['latitud'] ?? 0).toDouble(), // Note: API has typo "latitud"
      longitude: (json['longitud'] ?? 0).toDouble(), // Note: API has typo "longitud"
      id: json['_id'] ?? '',
    );
  }

  String get fullAddress {
    return "$houseNumber, $apartment, $street, $addressLine, $city, $state - $pinCode";
  }
}