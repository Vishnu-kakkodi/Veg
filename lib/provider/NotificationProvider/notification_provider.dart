// lib/providers/notification_provider.dart

import 'package:flutter/material.dart';
import 'package:veegify/model/NotificationModel/notification_model.dart';
import 'package:veegify/services/NotificationService/notification_service.dart';


class NotificationProvider extends ChangeNotifier {
  final NotificationService _service = NotificationService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  bool _hasError = false;
  bool _isSelectionMode = false;
  bool _isDeleting = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  bool get isSelectionMode => _isSelectionMode;
  bool get isDeleting => _isDeleting;

  List<NotificationModel> get selected =>
      _notifications.where((e) => e.isSelected).toList();

  int get unreadCount =>
      _notifications.where((e) => !e.isRead).length;

  // ───────────────── Fetch ─────────────────

  Future<void> fetchNotifications(String userId) async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      _notifications = await _service.fetchNotifications(userId);
    } catch (_) {
      _hasError = true;
    }

    _isLoading = false;
    notifyListeners();
  }

  // ───────────────── Delete ─────────────────

  Future<void> deleteSingle(
      String userId, NotificationModel model) async {
    final previous = List<NotificationModel>.from(_notifications);

    _notifications.removeWhere((n) => n.id == model.id);
    notifyListeners();

    final success =
        await _service.deleteNotifications(userId, [model.id]);

    if (!success) {
      _notifications = previous;
      notifyListeners();
    }
  }

  Future<void> deleteSelected(String userId) async {
    if (selected.isEmpty) return;

    _isDeleting = true;
    notifyListeners();

    final ids = selected.map((e) => e.id).toList();
    final success =
        await _service.deleteNotifications(userId, ids);

    if (success) {
      _notifications.removeWhere((e) => ids.contains(e.id));
      _isSelectionMode = false;
    }

    _isDeleting = false;
    notifyListeners();
  }

  // ───────────────── Selection ─────────────────

  void toggleSelectionMode() {
    _isSelectionMode = !_isSelectionMode;

    if (!_isSelectionMode) {
      for (var n in _notifications) {
        n.isSelected = false;
      }
    }

    notifyListeners();
  }

  void toggleItemSelection(NotificationModel model) {
    model.isSelected = !model.isSelected;
    notifyListeners();
  }

  void markAsRead(NotificationModel model) {
    model.isRead = true;
    notifyListeners();
  }

  void selectAll() {
    final allSelected =
        _notifications.every((e) => e.isSelected);

    for (var n in _notifications) {
      n.isSelected = !allSelected;
    }

    notifyListeners();
  }
}