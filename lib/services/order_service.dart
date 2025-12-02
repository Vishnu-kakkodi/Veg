// order_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderService {
  static const String baseUrl = 'http://31.97.206.144:5051/api';

  /// Create a new order
  /// 
  /// Parameters:
  /// - orderData: Map containing userId, paymentMethod, and addressId
  /// 
  /// Returns:
  /// - Map with 'success' boolean and 'data' or 'message'
  static Future<Map<String, dynamic>> createOrder(
    Map<String, dynamic> orderData,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/createorder');
      print("kkkkkkkkkkkkkkkkkkkkkkkkkk${orderData['userId']}");
            print("kkkkkkkkkkkkkkkkkkkkkkkkkk${orderData['paymentMethod']}");

      print("kkkkkkkkkkkkkkkkkkkkkkkkkk${orderData['addressId']}");


      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          // Add authorization token if needed
          // 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(orderData),
      );

      print('Order Response Status: ${response.statusCode}');
      print('Order Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        
        return {
          'success': true,
          'data': responseData,
          'message': 'Order created successfully',
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to create order',
        };
      }
    } catch (e) {
      print('Error creating order: $e');
      return {
        'success': false,
        'message': 'Error creating order: ${e.toString()}',
      };
    }
  }

  /// Get order by ID
  static Future<Map<String, dynamic>> getOrderById(String orderId) async {
    try {
      final url = Uri.parse('$baseUrl/orders/$orderId');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          // Add authorization token if needed
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to fetch order',
        };
      }
    } catch (e) {
      print('Error fetching order: $e');
      return {
        'success': false,
        'message': 'Error fetching order: ${e.toString()}',
      };
    }
  }

  /// Get all orders for a user
  static Future<Map<String, dynamic>> getUserOrders(String userId) async {
    try {
      final url = Uri.parse('$baseUrl/orders/user/$userId');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          // Add authorization token if needed
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to fetch orders',
        };
      }
    } catch (e) {
      print('Error fetching orders: $e');
      return {
        'success': false,
        'message': 'Error fetching orders: ${e.toString()}',
      };
    }
  }

  /// Cancel an order
  static Future<Map<String, dynamic>> cancelOrder(String orderId) async {
    try {
      final url = Uri.parse('$baseUrl/orders/$orderId/cancel');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          // Add authorization token if needed
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        return {
          'success': true,
          'data': responseData,
          'message': 'Order cancelled successfully',
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to cancel order',
        };
      }
    } catch (e) {
      print('Error cancelling order: $e');
      return {
        'success': false,
        'message': 'Error cancelling order: ${e.toString()}',
      };
    }
  }
}