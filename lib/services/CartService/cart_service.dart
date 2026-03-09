
// // services/cart_service.dart
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:veegify/helper/toast_helper.dart';
// import 'package:veegify/model/CartModel/cart_model.dart';

// class CartService {
//   static const String baseUrl = 'https://api.vegiffyy.com/api';

//   // Get cart by user ID
//   static Future<CartResponse?> getCart(String userId) async {
//     try {
//       print("🔹 Getting cart for userId: $userId");
//       final response = await http.get(
//         Uri.parse('$baseUrl/cart/user/$userId'),
//         headers: {'Content-Type': 'application/json'},
//       );

//       print('✅ Get Cart Status: ${response.statusCode}');
//       print('📦 Get Cart Response: ${response.body}');

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);

//         if (data['success'] == true && data['data'] != null) {
//           final cartResponseData = {
//             'success': data['success'],
//             'message': data['message'] ?? '',
//             'distanceKm': data['distanceKm'] ?? 0.0,
//             'cart': data['data'],
//             'appliedCoupon': data['appliedCoupon'],
//             'couponDiscount': data['couponDiscount'] ?? 0,
//           };
//           return CartResponse.fromJson(cartResponseData);
//         } else {
//           print('ℹ️ Cart is empty or not found');
//           return null;
//         }
//       } else if (response.statusCode == 404) {
//         print('ℹ️ Cart not found (404)');
//         return null;
//       } else {
//         throw Exception('Failed to get cart: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('❌ Error getting cart: $e');
//       rethrow;
//     }
//   }

//   // Add items to cart
//   static Future<CartResponse> addToCart(
//       String userId, AddToCartRequest request) async {
//     try {
//       final url = Uri.parse('$baseUrl/cart/$userId');
//       final payload = json.encode(request.toJson());

//       print("🔹 Adding to cart");
//       print("🔹 URL: $url");
//       print("🔹 Payload: $payload");

//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: payload,
//       );

//       print('✅ Add to Cart Status: ${response.statusCode}');
//       print('📦 Add to Cart Response: ${response.body}');


//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         return CartResponse.fromJson(data);
//       } else {
//         final Map<String, dynamic> errorData = json.decode(response.body);
//         throw Exception(errorData['message'] ?? 'Failed to add to cart');
//       }
//     } catch (e) {
//       print('❌ Error adding to cart: $e');
//       rethrow;
//     }
//   }

//   // Update item quantity using new endpoint
//   static Future<CartResponse> updateQuantity({
//     required String userId,
//     required String restaurantProductId,
//     required String recommendedId,
//     required String action, // "inc" or "dec"
//   }) async {
//     try {
//       print("llllllllllllllllllllllllllll$userId");
//       final url = Uri.parse('$baseUrl/update-quantity/$userId');
//       final request = UpdateQuantityRequest(
//         restaurantProductId: restaurantProductId,
//         recommendedId: recommendedId,
//         action: action,
//       );
//       final payload = json.encode(request.toJson());

//       print("🔹 Updating quantity");
//       print("🔹 URL: $url");
//       print("🔹 Action: $action");
//       print("🔹 Payload: $payload");

//       final response = await http.put(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: payload,
//       );

//       print('✅ Update Quantity Status: ${response.statusCode}');
//       print('📦 Update Quantity Response: ${response.body}');

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         return CartResponse.fromJson(data);
//       } else {
//         final Map<String, dynamic> errorData = json.decode(response.body);
//         throw Exception(errorData['message'] ?? 'Failed to update quantity');
//       }
//     } catch (e) {
//       print('❌ Error updating quantity: $e');
//       rethrow;
//     }
//   }

//   // Delete item from cart using new endpoint
//   static Future<CartResponse> deleteCartProduct({
//     required String userId,
//     required String productId,
//     required String recommendedId,
//   }) async {
//     print("UserId:$userId");
//         print("UserId:$productId");

//     print("UserId:$recommendedId");

//     try {
//       final url = Uri.parse(
//           '$baseUrl/deletecartproduct/$userId/$productId/$recommendedId');

//       print("🔹 Deleting cart product");
//       print("🔹 URL: $url");

//       final response = await http.delete(
//         url,
//         headers: {'Content-Type': 'application/json'},
//       );

//       print('✅ Delete Product Status: ${response.statusCode}');
//       print('📦 Delete Product Response: ${response.body}');

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         return CartResponse.fromJson(data);
//       } else {
//         final Map<String, dynamic> errorData = json.decode(response.body);
//         throw Exception(errorData['message'] ?? 'Failed to delete product');
//       }
//     } catch (e) {
//       print('❌ Error deleting product: $e');
//       rethrow;
//     }
//   }

//   // Apply coupon
//   static Future<CartResponse> applyCoupon({
//     required String userId,
//     required String couponId,
//     required List<CartProductRequest> currentProducts,
//   }) async {
//     final request = AddToCartRequest(
//       products: currentProducts,
//       couponId: couponId,
//     );

//     return await addToCart(userId, request);
//   }

//   // Clear entire cart
//   static Future<CartResponse> clearCart(String userId) async {
//     final request = AddToCartRequest(products: []);
//     return await addToCart(userId, request);
//   }

//   // Validate coupon code
//   static Future<AppliedCoupon?> validateCoupon(String couponCode) async {
//     try {
//       print("🔹 Validating coupon: $couponCode");
//       final response = await http.get(
//         Uri.parse('$baseUrl/coupon/validate/$couponCode'),
//         headers: {'Content-Type': 'application/json'},
//       );

//       print('✅ Validate Coupon Status: ${response.statusCode}');
//       print('📦 Validate Coupon Response: ${response.body}');

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         if (data['success'] == true && data['coupon'] != null) {
//           return AppliedCoupon.fromJson(data['coupon']);
//         }
//       }
//       return null;
//     } catch (e) {
//       print('❌ Error validating coupon: $e');
//       return null;
//     }
//   }

//   // Get available coupons
//   static Future<List<AppliedCoupon>> getAvailableCoupons() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/coupons'),
//         headers: {'Content-Type': 'application/json'},
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         final List<dynamic> couponsData = data['coupons'] ?? [];

//         return couponsData
//             .map((coupon) => AppliedCoupon.fromJson(coupon))
//             .toList();
//       } else {
//         throw Exception('Failed to get coupons: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('❌ Error getting coupons: $e');
//       return [];
//     }
//   }
// }












// services/cart_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:veegify/helper/storage_helper.dart';
import 'package:veegify/helper/toast_helper.dart';
import 'package:veegify/model/CartModel/cart_model.dart';

class CartService {
  static const String baseUrl = 'https://api.vegiffyy.com/api';

  // Add items to cart
  static Future<CartResponse> addToCart(
      String userId, AddToCartRequest request) async {
    try {
      final url = Uri.parse('$baseUrl/cart/$userId');
      final payload = json.encode(request.toJson());

      print("🔹 Adding to cart");
      print("🔹 URL: $url");
      print("🔹 Payload: $payload");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: payload,
      );

      print('✅ Add to Cart Status: ${response.statusCode}');
      print('📦 Add to Cart Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Return response without showing toast here
        // Let the provider handle toasts
        return CartResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Failed to add to cart';
        
        // Create an error response instead of throwing exception
        return CartResponse(
          success: false,
          message: errorMessage,
          cart: null,
          appliedCoupon: null,
          couponDiscount: 0,
          distanceKm: 0,
        );
      }
    } catch (e) {
      print('❌ Error adding to cart: $e');
      
      // Return error response instead of throwing
      return CartResponse(
        success: false,
        message: 'Error adding to cart: $e',
        cart: null,
        appliedCoupon: null,
        couponDiscount: 0,
        distanceKm: 0,
      );
    }
  }

  // Update item quantity
  static Future<CartResponse> updateQuantity({
    required String userId,
    required String restaurantProductId,
    required String recommendedId,
    required String action,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/update-quantity/$userId');
      final request = UpdateQuantityRequest(
        restaurantProductId: restaurantProductId,
        recommendedId: recommendedId,
        action: action,
      );
      final payload = json.encode(request.toJson());

      print("🔹 Updating quantity");
      print("🔹 URL: $url");
      print("🔹 Action: $action");
      print("🔹 Payload: $payload");

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: payload,
      );

      print('✅ Update Quantity Status: ${response.statusCode}');
      print('📦 Update Quantity Response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Return response without showing toast
        return CartResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Failed to update quantity';
        
        // Return error response
        return CartResponse(
          success: false,
          message: errorMessage,
          cart: null,
          appliedCoupon: null,
          couponDiscount: 0,
          distanceKm: 0,
        );
      }
    } catch (e) {
      print('❌ Error updating quantity: $e');
      
      // Return error response
      return CartResponse(
        success: false,
        message: 'Error updating quantity: $e',
        cart: null,
        appliedCoupon: null,
        couponDiscount: 0,
        distanceKm: 0,
      );
    }
  }

  // Delete item from cart
  static Future<CartResponse> deleteCartProduct({
    required String userId,
    required String productId,
    required String recommendedId,
  }) async {
    try {
      final url = Uri.parse(
          '$baseUrl/deletecartproduct/$userId/$productId/$recommendedId');

      print("🔹 Deleting cart product");
      print("🔹 URL: $url");

      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print('✅ Delete Product Status: ${response.statusCode}');
      print('📦 Delete Product Response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Return response without showing toast
        return CartResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Failed to delete product';
        
        // Return error response
        return CartResponse(
          success: false,
          message: errorMessage,
          cart: null,
          appliedCoupon: null,
          couponDiscount: 0,
          distanceKm: 0,
        );
      }
    } catch (e) {
      print('❌ Error deleting product: $e');
      
      // Return error response
      return CartResponse(
        success: false,
        message: 'Error deleting product: $e',
        cart: null,
        appliedCoupon: null,
        couponDiscount: 0,
        distanceKm: 0,
      );
    }
  }

  // Get cart by user ID
  static Future<CartResponse?> getCart(String userId) async {
    try {
          final u = UserPreferences.getUser();
          userId = u!.userId.toString();

      print("🔹 Getting cart for userId: $userId");
      final response = await http.get(
        Uri.parse('$baseUrl/cart/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('✅ Get Cart Status: ${response.statusCode}');
      print('📦 Get Cart Response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final cartResponseData = {
            'success': data['success'],
            'message': data['message'] ?? 'Cart loaded successfully',
            'distanceKm': data['distanceKm'] ?? 0.0,
            'cart': data['data'],
            'appliedCoupon': data['appliedCoupon'],
            'couponDiscount': data['couponDiscount'] ?? 0,
          };
          
          return CartResponse.fromJson(cartResponseData);
        } else {
          print('ℹ️ Cart is empty or not found');
          return null;
        }
      } else if (response.statusCode == 404) {
        print('ℹ️ Cart not found (404)');
        return null;
      } else {
        // Return null instead of throwing
        print('❌ Failed to get cart: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error getting cart: $e');
      return null;
    }
  }

  // Apply coupon
  static Future<CartResponse> applyCoupon({
    required String userId,
    required String couponId,
    required List<CartProductRequest> currentProducts,
  }) async {
    final request = AddToCartRequest(
      products: currentProducts,
      couponId: couponId,
    );

    return await addToCart(userId, request);
  }

  // Clear entire cart
  static Future<CartResponse> clearCart(String userId) async {
    final request = AddToCartRequest(products: []);
    return await addToCart(userId, request);
  }

  // Validate coupon code
  static Future<AppliedCoupon?> validateCoupon(String couponCode) async {
    try {
      print("🔹 Validating coupon: $couponCode");
      final response = await http.get(
        Uri.parse('$baseUrl/coupon/validate/$couponCode'),
        headers: {'Content-Type': 'application/json'},
      );

      print('✅ Validate Coupon Status: ${response.statusCode}');
      print('📦 Validate Coupon Response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true && data['coupon'] != null) {
          return AppliedCoupon.fromJson(data['coupon']);
        }
      }
      return null;
    } catch (e) {
      print('❌ Error validating coupon: $e');
      return null;
    }
  }

  // Get available coupons
  static Future<List<AppliedCoupon>> getAvailableCoupons() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/coupons'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> couponsData = data['coupons'] ?? [];

        return couponsData
            .map((coupon) => AppliedCoupon.fromJson(coupon))
            .toList();
      } else {
        print('❌ Failed to get coupons: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error getting coupons: $e');
      return [];
    }
  }
}