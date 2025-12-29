
// // models/cart_model.dart
// class CartModel {
//   final String id;
//   final String userId;
//   final List<CartProduct> products;
//   final int subTotal;
//   final int deliveryCharge;
//   final int couponDiscount;
//   final int finalAmount;
//   final int totalItems;
//   final String? appliedCouponId;
//   final DateTime createdAt;
//   final String restaurantId;

//   CartModel({
//     required this.id,
//     required this.userId,
//     required this.products,
//     required this.subTotal,
//     required this.deliveryCharge,
//     required this.couponDiscount,
//     required this.finalAmount,
//     required this.totalItems,
//     this.appliedCouponId,
//     required this.createdAt,
//     required this.restaurantId,
//   });

//   factory CartModel.fromJson(Map<String, dynamic> json) {
//     String userIdValue = '';
//     if (json['userId'] is String) {
//       userIdValue = json['userId'];
//     } else if (json['userId'] is Map<String, dynamic>) {
//       userIdValue = json['userId']['_id'] ?? json['userId']['id'] ?? '';
//     }

//     return CartModel(
//       id: json['_id'] ?? '',
//       userId: userIdValue,
//       products: (json['products'] as List?)
//               ?.map((item) => CartProduct.fromJson(item))
//               .toList() ??
//           [],
//       subTotal: json['subTotal'] ?? 0,
//       deliveryCharge: json['deliveryCharge'] ?? 0,
//       couponDiscount: json['couponDiscount'] ?? 0,
//       finalAmount: json['finalAmount'] ?? 0,
//       totalItems: json['totalItems'] ?? 0,
//       appliedCouponId: json['appliedCouponId'],
//       createdAt: DateTime.parse(
//           json['createdAt'] ?? DateTime.now().toIso8601String()),
//       restaurantId: json['restaurantId'] ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'userId': userId,
//       'products': products.map((item) => item.toJson()).toList(),
//       'subTotal': subTotal,
//       'deliveryCharge': deliveryCharge,
//       'couponDiscount': couponDiscount,
//       'finalAmount': finalAmount,
//       'totalItems': totalItems,
//       'appliedCouponId': appliedCouponId,
//       'createdAt': createdAt.toIso8601String(),
//       'restaurantId': restaurantId,
//     };
//   }
// }

// class CartProduct {
//   final String id;
//   final String restaurantProductId;
//   final String recommendedId;
//   final int quantity;
//   final CartAddOn addOn;
//   final String name;
//   final int basePrice;
//   final int platePrice;
//   final String image;

//   CartProduct({
//     required this.id,
//     required this.restaurantProductId,
//     required this.recommendedId,
//     required this.quantity,
//     required this.addOn,
//     required this.name,
//     required this.basePrice,
//     required this.platePrice,
//     required this.image,
//   });

//   factory CartProduct.fromJson(Map<String, dynamic> json) {
//     String restaurantProductIdValue = '';
//     if (json['restaurantProductId'] is String) {
//       restaurantProductIdValue = json['restaurantProductId'];
//     } else if (json['restaurantProductId'] is Map<String, dynamic>) {
//       restaurantProductIdValue = json['restaurantProductId']['_id'] ??
//           json['restaurantProductId']['id'] ??
//           '';
//     }

//     return CartProduct(
//       id: json['_id'] ?? '',
//       restaurantProductId: restaurantProductIdValue,
//       recommendedId: json['recommendedId'] ?? '',
//       quantity: json['quantity'] ?? 1,
//       addOn: CartAddOn.fromJson(json['addOn'] ?? {}),
//       name: json['name'] ?? '',
//       basePrice: json['basePrice'] ?? 0,
//       platePrice: json['platePrice'] ?? 0,
//       image: json['image'] ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'restaurantProductId': restaurantProductId,
//       'recommendedId': recommendedId,
//       'quantity': quantity,
//       'addOn': addOn.toJson(),
//       'name': name,
//       'basePrice': basePrice,
//       'platePrice': platePrice,
//       'image': image,
//     };
//   }

//   int get totalPrice {
//     int variationPrice = basePrice;
//     if (addOn.variation == 'Full') {
//       variationPrice = basePrice * 2;
//     }

//     int plateTotal = platePrice * addOn.plateitems;
//     return (variationPrice + plateTotal) * quantity;
//   }
// }

// class CartAddOn {
//   final String variation;
//   final int plateitems;

//   CartAddOn({
//     required this.variation,
//     required this.plateitems,
//   });

//   factory CartAddOn.fromJson(Map<String, dynamic> json) {
//     return CartAddOn(
//       variation: json['variation'] ?? '',
//       plateitems: json['plateitems'] ?? 0,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'variation': variation,
//       'plateitems': plateitems,
//     };
//   }
// }

// class AppliedCoupon {
//   final String id;
//   final String code;
//   final int discountPercentage;
//   final int maxDiscountAmount;
//   final int minCartAmount;
//   final DateTime expiresAt;

//   AppliedCoupon({
//     required this.id,
//     required this.code,
//     required this.discountPercentage,
//     required this.maxDiscountAmount,
//     required this.minCartAmount,
//     required this.expiresAt,
//   });

//   factory AppliedCoupon.fromJson(Map<String, dynamic> json) {
//     return AppliedCoupon(
//       id: json['_id'] ?? '',
//       code: json['code'] ?? '',
//       discountPercentage: json['discountPercentage'] ?? 0,
//       maxDiscountAmount: json['maxDiscountAmount'] ?? 0,
//       minCartAmount: json['minCartAmount'] ?? 0,
//       expiresAt: DateTime.parse(
//           json['expiresAt'] ?? DateTime.now().toIso8601String()),
//     );
//   }
// }

// class CartResponse {
//   final bool success;
//   final String message;
//   final double distanceKm;
//   final CartModel? cart;
//   final AppliedCoupon? appliedCoupon;
//   final int couponDiscount;

//   CartResponse({
//     required this.success,
//     this.message = '',
//     this.distanceKm = 0.0,
//     this.cart,
//     this.appliedCoupon,
//     this.couponDiscount = 0,
//   });

//   factory CartResponse.fromJson(Map<String, dynamic> json) {
//     return CartResponse(
//       success: json['success'] ?? false,
//       message: json['message'] ?? '',
//       distanceKm: (json['distanceKm'] ?? 0).toDouble(),
//       cart: json['cart'] != null ? CartModel.fromJson(json['cart']) : null,
//       appliedCoupon: json['appliedCoupon'] != null
//           ? AppliedCoupon.fromJson(json['appliedCoupon'])
//           : null,
//       couponDiscount: json['couponDiscount'] ?? 0,
//     );
//   }
// }

// // Request models
// class AddToCartRequest {
//   final List<CartProductRequest> products;
//   final String? couponId;

//   AddToCartRequest({
//     required this.products,
//     this.couponId,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'products': products.map((p) => p.toJson()).toList(),
//       if (couponId != null) 'couponId': couponId,
//     };
//   }
// }

// class CartProductRequest {
//   final String restaurantProductId;
//   final String recommendedId;
//   final int quantity;
//   final CartAddOnRequest addOn;

//   CartProductRequest({
//     required this.restaurantProductId,
//     required this.recommendedId,
//     required this.quantity,
//     required this.addOn,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'restaurantProductId': restaurantProductId,
//       'recommendedId': recommendedId,
//       'quantity': quantity,
//       'addOn': addOn.toJson(),
//     };
//   }
// }

// class CartAddOnRequest {
//   final String variation;
//   final int plateitems;

//   CartAddOnRequest({
//     required this.variation,
//     required this.plateitems,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'variation': variation,
//       'plateitems': plateitems,
//     };
//   }
// }

// class UpdateQuantityRequest {
//   final String restaurantProductId;
//   final String recommendedId;
//   final String action; // "inc" or "dec"

//   UpdateQuantityRequest({
//     required this.restaurantProductId,
//     required this.recommendedId,
//     required this.action,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'restaurantProductId': restaurantProductId,
//       'recommendedId': recommendedId,
//       'action': action,
//     };
//   }
// }

























// // models/cart_model.dart
// class CartModel {
//   final String id;
//   final String userId;
//   final List<CartProduct> products;
//   final dynamic subTotal;
//   final dynamic deliveryCharge;
//   final dynamic couponDiscount;
//   final dynamic finalAmount;
//   final dynamic totalItems;
//   final String? appliedCouponId;
//   final DateTime createdAt;
//   final String restaurantId;
//   final dynamic totalDiscount;
//   final dynamic platformCharge;
//   final dynamic gstAmount;
//     final dynamic gstOnDelivery;
//         final dynamic packingCharges;



//   CartModel({
//     required this.id,
//     required this.userId,
//     required this.products,
//     required this.subTotal,
//     required this.deliveryCharge,
//     required this.couponDiscount,
//     required this.finalAmount,
//     required this.totalItems,
//     this.appliedCouponId,
//     required this.createdAt,
//     required this.restaurantId,
//     required this.gstAmount,
//     required this.platformCharge,
//     required this.totalDiscount,
//         required this.gstOnDelivery,
//                 required this.packingCharges


//   });

//   /// Safe double parser (int / double / string / null)
//   static double _toDouble(dynamic value) {
//     if (value == null) return 0.0;
//     if (value is int) return value.toDouble();
//     if (value is double) return value;
//     if (value is String) return double.tryParse(value) ?? 0.0;
//     return 0.0;
//   }

//   /// Safe int parser (string / double / null)
//   static int _toInt(dynamic value) {
//     if (value == null) return 0;
//     if (value is int) return value;
//     if (value is double) return value.toInt();
//     if (value is String) return int.tryParse(value) ?? 0;
//     return 0;
//   }

//   factory CartModel.fromJson(Map<String, dynamic> json) {
//     String userIdValue = '';
//     if (json['userId'] is String) {
//       userIdValue = json['userId'];
//     } else if (json['userId'] is Map<String, dynamic>) {
//       userIdValue = json['userId']['_id'] ??
//           json['userId']['id'] ??
//           '';
//     }

//     return CartModel(
//       id: json['_id'] ?? '',
//       userId: userIdValue,
//       products: (json['products'] as List?)
//               ?.map((item) => CartProduct.fromJson(item))
//               .toList() ??
//           [],
//       subTotal: _toDouble(json['subTotal']),
//       deliveryCharge: _toDouble(json['deliveryCharge']),
//       couponDiscount: _toDouble(json['couponDiscount']),
//       finalAmount: _toDouble(json['finalAmount']),
//       totalItems: _toInt(json['totalItems']),
//       appliedCouponId: json['appliedCouponId'],
//       createdAt: DateTime.tryParse(json['createdAt'] ?? '') ??
//           DateTime.now(),
//       restaurantId: json['restaurantId'] ?? '',
//       gstAmount: _toDouble(json['gstCharges']),
//             gstOnDelivery: _toDouble(json['gstOnDelivery']),
//                         packingCharges: _toDouble(json['packingCharges']),

//             totalDiscount: _toDouble(json['totalDiscount']),
            

//       platformCharge: _toDouble(json['platformCharge']),

//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'userId': userId,
//       'products': products.map((item) => item.toJson()).toList(),
//       'subTotal': subTotal,
//       'deliveryCharge': deliveryCharge,
//       'couponDiscount': couponDiscount,
//       'finalAmount': finalAmount,
//       'totalItems': totalItems,
//       'appliedCouponId': appliedCouponId,
//       'createdAt': createdAt.toIso8601String(),
//       'restaurantId': restaurantId,
//     };
//   }
// }

// class CartProduct {
//   final String id;
//   final String restaurantProductId;
//   final String recommendedId;
//   final int quantity;
//   final CartAddOn addOn;
//   final String name;
//   final double basePrice;
//   final double platePrice;
//   final String image;
//   final dynamic discountPercent;
//   final dynamic discountAmount;
//   final dynamic price;
//     final CartRecommended? recommended;
//   final CartRestaurant? restaurant;

//   CartProduct({
//     required this.id,
//     required this.restaurantProductId,
//     required this.recommendedId,
//     required this.quantity,
//     required this.addOn,
//     required this.name,
//     required this.basePrice,
//     required this.platePrice,
//     required this.image,
//     required this.discountAmount,
//     required this.discountPercent,
//     required this.price,
//         this.recommended,
//     this.restaurant,
//   });

//   static double _toDouble(dynamic value) {
//     if (value == null) return 0.0;
//     if (value is int) return value.toDouble();
//     if (value is double) return value;
//     if (value is String) return double.tryParse(value) ?? 0.0;
//     return 0.0;
//   }

//   static int _toInt(dynamic value) {
//     if (value == null) return 0;
//     if (value is int) return value;
//     if (value is double) return value.toInt();
//     if (value is String) return int.tryParse(value) ?? 0;
//     return 0;
//   }

//   factory CartProduct.fromJson(Map<String, dynamic> json) {
//     String rpId = '';
//     if (json['restaurantProductId'] is String) {
//       rpId = json['restaurantProductId'];
//     } else if (json['restaurantProductId'] is Map<String, dynamic>) {
//       rpId = json['restaurantProductId']['_id'] ??
//           json['restaurantProductId']['id'] ??
//           '';
//     }

//     return CartProduct(
//       id: json['_id'] ?? '',
//       restaurantProductId: rpId,
//       recommendedId: json['recommendedId'] ?? '',
//       quantity: _toInt(json['quantity']),
//       addOn: CartAddOn.fromJson(json['addOn'] ?? {}),
//       name: json['name'] ?? '',
//       basePrice: _toDouble(json['basePrice']),
//             price: _toDouble(json['price']),

//       platePrice: _toDouble(json['platePrice']),
//       image: json['image'] ?? '',
//             discountPercent:  _toDouble(json['discountPercent']),

//       discountAmount:  _toDouble(json['discountAmount']),
//             recommended: json['recommended'] != null
//           ? CartRecommended.fromJson(json['recommended'])
//           : null,
//       restaurant: json['restaurant'] != null
//           ? CartRestaurant.fromJson(json['restaurant'])
//           : null,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'restaurantProductId': restaurantProductId,
//       'recommendedId': recommendedId,
//       'quantity': quantity,
//       'addOn': addOn.toJson(),
//       'name': name,
//       'basePrice': basePrice,
//       'platePrice': platePrice,
//       'image': image,
//             if (recommended != null) 'recommended': recommended!.toJson(),
//       if (restaurant != null) 'restaurant': restaurant!.toJson(),
//     };
//   }

//   double get totalPrice {
//     double variationPrice = basePrice;
//     if (addOn.variation == 'Full') {
//       variationPrice = basePrice * 2;
//     }

//     double plateTotal = platePrice * addOn.plateitems;
//     return (variationPrice + plateTotal) * quantity;
//   }

//     bool get isProductActive =>
//       (recommended?.status.toLowerCase() ?? 'active') == 'active';

//   bool get isVendorActive =>
//       (restaurant?.status.toLowerCase() ?? 'active') == 'active';
// }

// class CartAddOn {
//   final String variation;
//   final int plateitems;

//   CartAddOn({
//     required this.variation,
//     required this.plateitems,
//   });

//   static int _toInt(dynamic value) {
//     if (value is int) return value;
//     if (value is String) return int.tryParse(value) ?? 0;
//     if (value is double) return value.toInt();
//     return 0;
//   }

//   factory CartAddOn.fromJson(Map<String, dynamic> json) {
//     return CartAddOn(
//       variation: json['variation'] ?? '',
//       plateitems: _toInt(json['plateitems']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'variation': variation,
//       'plateitems': plateitems,
//     };
//   }
// }

// class AppliedCoupon {
//   final String id;
//   final String code;
//   final int discountPercentage;
//   final double maxDiscountAmount;
//   final double minCartAmount;
//   final DateTime expiresAt;

//   AppliedCoupon({
//     required this.id,
//     required this.code,
//     required this.discountPercentage,
//     required this.maxDiscountAmount,
//     required this.minCartAmount,
//     required this.expiresAt,
//   });

//   static double _toDouble(dynamic value) {
//     if (value == null) return 0.0;
//     if (value is int) return value.toDouble();
//     if (value is double) return value;
//     if (value is String) return double.tryParse(value) ?? 0.0;
//     return 0.0;
//   }

//   static int _toInt(dynamic value) {
//     if (value is int) return value;
//     if (value is String) return int.tryParse(value) ?? 0;
//     if (value is double) return value.toInt();
//     return 0;
//   }

//   factory AppliedCoupon.fromJson(Map<String, dynamic> json) {
//     return AppliedCoupon(
//       id: json['_id'] ?? '',
//       code: json['code'] ?? '',
//       discountPercentage: _toInt(json['discountPercentage']),
//       maxDiscountAmount: _toDouble(json['maxDiscountAmount']),
//       minCartAmount: _toDouble(json['minCartAmount']),
//       expiresAt:
//           DateTime.tryParse(json['expiresAt'] ?? '') ?? DateTime.now(),
//     );
//   }
// }

// class CartResponse {
//   final bool success;
//   final String message;
//   final double distanceKm;
//   final CartModel? cart;
//   final AppliedCoupon? appliedCoupon;
//   final double couponDiscount;

//   CartResponse({
//     required this.success,
//     this.message = '',
//     this.distanceKm = 0.0,
//     this.cart,
//     this.appliedCoupon,
//     this.couponDiscount = 0.0,
//   });

//   static double _toDouble(dynamic value) {
//     if (value == null) return 0.0;
//     if (value is int) return value.toDouble();
//     if (value is double) return value;
//     if (value is String) return double.tryParse(value) ?? 0.0;
//     return 0.0;
//   }

//   factory CartResponse.fromJson(Map<String, dynamic> json) {
//     return CartResponse(
//       success: json['success'] ?? false,
//       message: json['message'] ?? '',
//       distanceKm: _toDouble(json['distanceKm']),
//       cart: json['cart'] != null ? CartModel.fromJson(json['cart']) : null,
//       appliedCoupon: json['appliedCoupon'] != null
//           ? AppliedCoupon.fromJson(json['appliedCoupon'])
//           : null,
//       couponDiscount: _toDouble(json['couponDiscount']),
//     );
//   }
// }

// // Request Models
// class AddToCartRequest {
//   final List<CartProductRequest> products;
//   final String? couponId;

//   AddToCartRequest({
//     required this.products,
//     this.couponId,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'products': products.map((p) => p.toJson()).toList(),
//       if (couponId != null) 'couponId': couponId,
//     };
//   }
// }

// class CartProductRequest {
//   final String restaurantProductId;
//   final String recommendedId;
//   final int quantity;
//   final CartAddOnRequest addOn;
//      final bool? isHalfPlate;
//   final bool? isFullPlate; 

//   CartProductRequest({
//     required this.restaurantProductId,
//     required this.recommendedId,
//     required this.quantity,
//     required this.addOn,
//            this.isHalfPlate,
//     this.isFullPlate,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'restaurantProductId': restaurantProductId,
//       'recommendedId': recommendedId,
//       'quantity': quantity,
//       'addOn': addOn.toJson(),
//                   if (isHalfPlate != null) 'isHalfPlate': isHalfPlate,
//       if (isFullPlate != null) 'isFullPlate': isFullPlate,
//     };
//   }
// }

// class CartAddOnRequest {
//   // final String variation;
//   final int plateitems; 


//   CartAddOnRequest({
//     // required this.variation,
//     required this.plateitems,

//   });

//   Map<String, dynamic> toJson() {
//     return {
//       // 'variation': variation,
//       'plateitems': plateitems,

//     };
//   }
// }

// class UpdateQuantityRequest {
//   final String restaurantProductId;
//   final String recommendedId;
//   final String action; // "inc" or "dec"

//   UpdateQuantityRequest({
//     required this.restaurantProductId,
//     required this.recommendedId,
//     required this.action,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'restaurantProductId': restaurantProductId,
//       'recommendedId': recommendedId,
//       'action': action,
//     };
//   }
// }


// // models/cart_model.dart

// class CartRestaurant {
//   final String restaurantId;
//   final String restaurantName;
//   final String locationName;
//   final String status; // "active" / "inactive" / etc.

//   CartRestaurant({
//     required this.restaurantId,
//     required this.restaurantName,
//     required this.locationName,
//     required this.status,
//   });

//   factory CartRestaurant.fromJson(Map<String, dynamic> json) {
//     return CartRestaurant(
//       restaurantId: json['restaurantId'] ?? '',
//       restaurantName: json['restaurantName'] ?? '',
//       locationName: json['locationName'] ?? '',
//       status: json['status'] ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'restaurantId': restaurantId,
//       'restaurantName': restaurantName,
//       'locationName': locationName,
//       'status': status,
//     };
//   }
// }

// class CartRecommended {
//   final String id;
//   final String name;
//   final double price;
//   final double halfPlatePrice;
//   final double fullPlatePrice;
//   final String status; // "active" / "inactive" / etc.

//   CartRecommended({
//     required this.id,
//     required this.name,
//     required this.price,
//     required this.halfPlatePrice,
//     required this.fullPlatePrice,
//     required this.status,
//   });

//   static double _toDouble(dynamic value) {
//     if (value == null) return 0.0;
//     if (value is int) return value.toDouble();
//     if (value is double) return value;
//     if (value is String) return double.tryParse(value) ?? 0.0;
//     return 0.0;
//   }

//   factory CartRecommended.fromJson(Map<String, dynamic> json) {
//     return CartRecommended(
//       id: json['_id'] ?? '',
//       name: json['name'] ?? '',
//       price: _toDouble(json['price']),
//       halfPlatePrice: _toDouble(json['halfPlatePrice']),
//       fullPlatePrice: _toDouble(json['fullPlatePrice']),
//       status: json['status'] ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'name': name,
//       'price': price,
//       'halfPlatePrice': halfPlatePrice,
//       'fullPlatePrice': fullPlatePrice,
//       'status': status,
//     };
//   }
// }



















// models/cart_model.dart
class CartModel {
  final String id;
  final String userId;
  final List<CartProduct> products;
  final dynamic subTotal;
  final dynamic amountSavedOnOrder;
  final dynamic deliveryCharge;
  final dynamic couponDiscount;
  final dynamic finalAmount;
  final dynamic totalItems;
  final String? appliedCouponId;
  final DateTime createdAt;
  final String restaurantId;
  final dynamic totalDiscount;
  final dynamic platformCharge;
  final dynamic gstAmount;
  final dynamic gstOnDelivery;
  final dynamic packingCharges;

  CartModel({
    required this.id,
    required this.userId,
    required this.products,
    required this.subTotal,
    required this.amountSavedOnOrder,
    required this.deliveryCharge,
    required this.couponDiscount,
    required this.finalAmount,
    required this.totalItems,
    this.appliedCouponId,
    required this.createdAt,
    required this.restaurantId,
    required this.gstAmount,
    required this.platformCharge,
    required this.totalDiscount,
    required this.gstOnDelivery,
    required this.packingCharges,
  });

  /// Safe double parser
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Safe int parser
  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  factory CartModel.fromJson(Map<String, dynamic> json) {
    String userIdValue = '';
    if (json['userId'] is String) {
      userIdValue = json['userId'];
    } else if (json['userId'] is Map<String, dynamic>) {
      userIdValue =
          json['userId']['_id'] ?? json['userId']['id'] ?? '';
    }

    return CartModel(
      id: json['_id']?.toString() ?? '',
      userId: userIdValue,
      products: (json['products'] is List)
          ? (json['products'] as List)
              .map((item) =>
                  CartProduct.fromJson(item as Map<String, dynamic>))
              .toList()
          : [],
      subTotal: _toDouble(json['subTotal']),
      amountSavedOnOrder: _toDouble(json['amountSavedOnOrder']),
      deliveryCharge: _toDouble(json['deliveryCharge']),
      couponDiscount: _toDouble(json['couponDiscount']),
      finalAmount: _toDouble(json['finalAmount']),
      totalItems: _toInt(json['totalItems']),
      appliedCouponId: json['appliedCouponId']?.toString(),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
              DateTime.now(),
      restaurantId: json['restaurantId']?.toString() ?? '',
      gstAmount: _toDouble(json['gstCharges']),
      gstOnDelivery: _toDouble(json['gstOnDelivery']),
      packingCharges: _toDouble(json['packingCharges']),
      totalDiscount: _toDouble(json['totalDiscount']),
      platformCharge: _toDouble(json['platformCharge']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'products': products.map((item) => item.toJson()).toList(),
      'subTotal': subTotal,
      'amountSavedOnOrder':amountSavedOnOrder,
      'deliveryCharge': deliveryCharge,
      'couponDiscount': couponDiscount,
      'finalAmount': finalAmount,
      'totalItems': totalItems,
      'appliedCouponId': appliedCouponId,
      'createdAt': createdAt.toIso8601String(),
      'restaurantId': restaurantId,
    };
  }
}

// =======================================================

class CartProduct {
  final String id;
  final String restaurantProductId;
  final String recommendedId;
  final int quantity;
  final CartAddOn addOn;
  final String name;
  final double basePrice;
  final double platePrice;
  final String image;
  final dynamic discountPercent;
  final dynamic discountAmount;
  final dynamic price;
  final CartRecommended? recommended;
  final CartRestaurant? restaurant;

  CartProduct({
    required this.id,
    required this.restaurantProductId,
    required this.recommendedId,
    required this.quantity,
    required this.addOn,
    required this.name,
    required this.basePrice,
    required this.platePrice,
    required this.image,
    required this.discountAmount,
    required this.discountPercent,
    required this.price,
    this.recommended,
    this.restaurant,
  });

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    String rpId = '';
    if (json['restaurantProductId'] is String) {
      rpId = json['restaurantProductId'];
    } else if (json['restaurantProductId'] is Map<String, dynamic>) {
      rpId = json['restaurantProductId']['_id'] ??
          json['restaurantProductId']['id'] ??
          '';
    }

    return CartProduct(
      id: json['_id']?.toString() ?? '',
      restaurantProductId: rpId,
      recommendedId: json['recommendedId']?.toString() ?? '',
      quantity: _toInt(json['quantity']),
      addOn: CartAddOn.fromJson(
          json['addOn'] is Map ? json['addOn'] : {}),
      name: json['name']?.toString() ?? '',
      basePrice: _toDouble(json['basePrice']),
      price: _toDouble(json['price']),
      platePrice: _toDouble(json['platePrice']),
      image: json['image']?.toString() ?? '',
      discountPercent: _toDouble(json['discountPercent']),
      discountAmount: _toDouble(json['discountAmount']),
      recommended: json['recommended'] is Map
          ? CartRecommended.fromJson(json['recommended'])
          : null,
      restaurant: json['restaurant'] is Map
          ? CartRestaurant.fromJson(json['restaurant'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'restaurantProductId': restaurantProductId,
      'recommendedId': recommendedId,
      'quantity': quantity,
      'addOn': addOn.toJson(),
      'name': name,
      'basePrice': basePrice,
      'platePrice': platePrice,
      'image': image,
      if (recommended != null) 'recommended': recommended!.toJson(),
      if (restaurant != null) 'restaurant': restaurant!.toJson(),
    };
  }

  double get totalPrice {
    double variationPrice = basePrice;
    if (addOn.variation == 'Full') {
      variationPrice = basePrice * 2;
    }
    double plateTotal = platePrice * addOn.plateitems;
    return (variationPrice + plateTotal) * quantity;
  }

  bool get isProductActive =>
      (recommended?.status.toLowerCase() ?? 'active') == 'active';

  bool get isVendorActive =>
      (restaurant?.status.toLowerCase() ?? 'active') == 'active';
}

// =======================================================

class CartAddOn {
  final String variation;
  final int plateitems;

  CartAddOn({
    required this.variation,
    required this.plateitems,
  });

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  factory CartAddOn.fromJson(Map<String, dynamic> json) {
    return CartAddOn(
      variation: json['variation']?.toString() ?? '',
      plateitems: _toInt(json['plateitems']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'variation': variation,
      'plateitems': plateitems,
    };
  }
}

// =======================================================

class AppliedCoupon {
  final String id;
  final String code;
  final int discountPercentage;
  final double maxDiscountAmount;
  final double minCartAmount;
  final DateTime expiresAt;

  AppliedCoupon({
    required this.id,
    required this.code,
    required this.discountPercentage,
    required this.maxDiscountAmount,
    required this.minCartAmount,
    required this.expiresAt,
  });

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  factory AppliedCoupon.fromJson(Map<String, dynamic> json) {
    return AppliedCoupon(
      id: json['_id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      discountPercentage: _toInt(json['discountPercentage']),
      maxDiscountAmount: _toDouble(json['maxDiscountAmount']),
      minCartAmount: _toDouble(json['minCartAmount']),
      expiresAt:
          DateTime.tryParse(json['expiresAt']?.toString() ?? '') ??
              DateTime.now(),
    );
  }
}

// =======================================================

class CartResponse {
  final bool success;
  final String message;
  final double distanceKm;
  final CartModel? cart;
  final AppliedCoupon? appliedCoupon;
  final double couponDiscount;

  CartResponse({
    required this.success,
    this.message = '',
    this.distanceKm = 0.0,
    this.cart,
    this.appliedCoupon,
    this.couponDiscount = 0.0,
  });

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      distanceKm: _toDouble(json['distanceKm']),
      cart: json['cart'] is Map
          ? CartModel.fromJson(json['cart'])
          : null,
      appliedCoupon: json['appliedCoupon'] is Map
          ? AppliedCoupon.fromJson(json['appliedCoupon'])
          : null,
      couponDiscount: _toDouble(json['couponDiscount']),
    );
  }
}

// =======================================================
// Request Models (UNCHANGED STRUCTURE)
// =======================================================

class AddToCartRequest {
  final List<CartProductRequest> products;
  final String? couponId;

  AddToCartRequest({
    required this.products,
    this.couponId,
  });

  Map<String, dynamic> toJson() {
    return {
      'products': products.map((p) => p.toJson()).toList(),
      if (couponId != null) 'couponId': couponId,
    };
  }
}

class CartProductRequest {
  final String restaurantProductId;
  final String recommendedId;
  final int quantity;
  final CartAddOnRequest addOn;
  final bool? isHalfPlate;
  final bool? isFullPlate;

  CartProductRequest({
    required this.restaurantProductId,
    required this.recommendedId,
    required this.quantity,
    required this.addOn,
    this.isHalfPlate,
    this.isFullPlate,
  });

  Map<String, dynamic> toJson() {
    return {
      'restaurantProductId': restaurantProductId,
      'recommendedId': recommendedId,
      'quantity': quantity,
      'addOn': addOn.toJson(),
      if (isHalfPlate != null) 'isHalfPlate': isHalfPlate,
      if (isFullPlate != null) 'isFullPlate': isFullPlate,
    };
  }
}

class CartAddOnRequest {
  final int plateitems;

  CartAddOnRequest({required this.plateitems});

  Map<String, dynamic> toJson() {
    return {
      'plateitems': plateitems,
    };
  }
}

// =======================================================

class UpdateQuantityRequest {
  final String restaurantProductId;
  final String recommendedId;
  final String action;

  UpdateQuantityRequest({
    required this.restaurantProductId,
    required this.recommendedId,
    required this.action,
  });

  Map<String, dynamic> toJson() {
    return {
      'restaurantProductId': restaurantProductId,
      'recommendedId': recommendedId,
      'action': action,
    };
  }
}

// =======================================================

class CartRestaurant {
  final String restaurantId;
  final String restaurantName;
  final String locationName;
  final String status;

  CartRestaurant({
    required this.restaurantId,
    required this.restaurantName,
    required this.locationName,
    required this.status,
  });

  factory CartRestaurant.fromJson(Map<String, dynamic> json) {
    return CartRestaurant(
      restaurantId: json['restaurantId']?.toString() ?? '',
      restaurantName: json['restaurantName']?.toString() ?? '',
      locationName: json['locationName']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'locationName': locationName,
      'status': status,
    };
  }
}

class CartRecommended {
  final String id;
  final String name;
  final double price;
  final double halfPlatePrice;
  final double fullPlatePrice;
  final String status;

  CartRecommended({
    required this.id,
    required this.name,
    required this.price,
    required this.halfPlatePrice,
    required this.fullPlatePrice,
    required this.status,
  });

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  factory CartRecommended.fromJson(Map<String, dynamic> json) {
    return CartRecommended(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: _toDouble(json['price']),
      halfPlatePrice: _toDouble(json['halfPlatePrice']),
      fullPlatePrice: _toDouble(json['fullPlatePrice']),
      status: json['status']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'price': price,
      'halfPlatePrice': halfPlatePrice,
      'fullPlatePrice': fullPlatePrice,
      'status': status,
    };
  }
}
