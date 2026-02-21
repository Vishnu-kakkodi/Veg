// lib/models/notification_model.dart

class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String message;
  final DateTime timestamp;
  bool isRead;
  bool isSelected;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
    this.isSelected = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final id = (json['_id'] ?? json['id'] ?? '').toString().trim();

    return NotificationModel(
      id: id,
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      isRead: json['status'] == 'read',
    );
  }
}