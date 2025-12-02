// lib/services/order_service.dart
import 'package:http/http.dart' as http;
import 'package:veegify/model/order.dart';
import 'dart:io';

class OrderService {
  final String baseUrl;

  OrderService({required this.baseUrl});

  // GET /api/userorders/:userId?today=true
  Future<List<Order>> fetchTodayOrders(String userId, {Map<String, String>? headers}) async {
    final uri = Uri.parse('$baseUrl/api/userorders/$userId?today=true');
    final response = await http.get(uri, headers: headers ?? {});
    if (response.statusCode == 200) {
      return ordersFromApiResponse(response.body);
    } else {
      throw HttpException('Failed to fetch today orders: ${response.statusCode}');
    }
  }

  // GET /api/userorders/:userId
  Future<List<Order>> fetchAllOrders(String userId, {Map<String, String>? headers}) async {
    final uri = Uri.parse('$baseUrl/api/userorders/$userId');
    final response = await http.get(uri, headers: headers ?? {});
    if (response.statusCode == 200) {
      return ordersFromApiResponse(response.body);
    } else {
      throw HttpException('Failed to fetch orders: ${response.statusCode}');
    }
  }

  // convenience: combines both if you want
  Future<List<Order>> fetchOrders({required String userId, bool todayOnly = false, Map<String, String>? headers}) {
    return todayOnly ? fetchTodayOrders(userId, headers: headers) : fetchAllOrders(userId, headers: headers);
  }
}
