// lib/models/chat_message.dart
class ChatMessage {
  final String id;
  final String deliveryBoyId;
  final String userId;
  final String senderType; // 'rider' or 'user'
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.deliveryBoyId,
    required this.userId,
    required this.senderType,
    required this.message,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    // timestamp may be ISO string
    final ts = json['timestamp'] is String ? DateTime.parse(json['timestamp']) : DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now();
    return ChatMessage(
      id: json['_id']?.toString() ?? '',
      deliveryBoyId: json['deliveryBoyId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      senderType: json['senderType']?.toString() ?? 'user',
      message: json['message']?.toString() ?? '',
      timestamp: ts.toLocal(),
    );
  }

  Map<String, dynamic> toJsonForSend() {
    return {
      'message': message,
      'senderType': senderType,
    };
  }
}
