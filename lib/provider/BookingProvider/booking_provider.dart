// lib/providers/order_provider.dart
import 'package:flutter/material.dart';
import 'package:veegify/model/order.dart';
import 'package:veegify/services/BookingService/booking_service.dart';

enum OrdersState { idle, loading, loaded, error }

class OrderProvider with ChangeNotifier {
  final OrderService service;
  List<Order> _orders = [];
  String? error;
  OrdersState state = OrdersState.idle;

  OrderProvider({required this.service});

  List<Order> get orders => _orders;

  Future<void> loadAllOrders(String? userId, {Map<String, String>? headers}) async {
    state = OrdersState.loading;
    notifyListeners();
    try {
      final fetched = await service.fetchAllOrders(userId.toString(), headers: headers);
      _orders = fetched;
      state = OrdersState.loaded;
      error = null;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      state = OrdersState.error;
      notifyListeners();
    }
  }

  Future<void> loadTodayOrders(String userId, {Map<String, String>? headers}) async {
    state = OrdersState.loading;
    notifyListeners();
    try {
      final fetched = await service.fetchTodayOrders(userId, headers: headers);
      _orders = fetched;
      state = OrdersState.loaded;
      error = null;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      state = OrdersState.error;
      notifyListeners();
    }
  }

  // filtered lists for UI
  List<Order> get todayOrders {
    final now = DateTime.now();
    return _orders.where((o) {
      final sameDay = o.createdAt?.year == now.year && o.createdAt?.month == now.month && o.createdAt?.day == now.day;
      return sameDay;
    }).toList();
  }

  List<Order> get cancelledOrders {
    return _orders.where((o) =>
        o.orderStatus.toLowerCase() == 'cancelled' ||
        o.deliveryStatus.toLowerCase() == 'cancelled'
    ).toList();
  }

  List<Order> get completedOrders {
    return _orders.where((o) =>
        o.orderStatus.toLowerCase() == 'completed' ||
        o.deliveryStatus.toLowerCase() == 'delivered'
    ).toList();
  }

  // helper to refresh both endpoints (optional)
  Future<void> refreshBoth(String userId, {Map<String, String>? headers}) async {
    state = OrdersState.loading;
    notifyListeners();
    try {
      final all = await service.fetchAllOrders(userId, headers: headers);
      _orders = all;
      state = OrdersState.loaded;
      error = null;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      state = OrdersState.error;
      notifyListeners();
    }
  }
}
