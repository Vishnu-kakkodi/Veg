// lib/services/notification_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../model/NotificationModel/notification_model.dart';

class NotificationService {
  static const String _baseUrl = 'https://api.vegiffyy.com/api';

  Future<List<NotificationModel>> fetchNotifications(String userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/getnotification/$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        final List list = data['notifications'] ?? [];

        return list
            .map((e) => NotificationModel.fromJson(e))
            .toList();
      }
    }

    throw Exception('Failed to load notifications');
  }

  Future<bool> deleteNotifications(
      String userId, List<String> ids) async {
    final cleanIds =
        ids.where((id) => id.trim().isNotEmpty).toList();

    if (cleanIds.isEmpty) return false;

    final response = await http.delete(
      Uri.parse('$_baseUrl/delete-notifications/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'notificationIds': cleanIds}),
    );

    return response.statusCode == 200;
  }
}