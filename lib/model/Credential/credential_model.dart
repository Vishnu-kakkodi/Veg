class CredentialModel {
  final String id;
  final String type;
  final String email;
  final String mobile;
  final String? whatsappNumber; // ✅ NEW
  final DateTime createdAt;

  CredentialModel({
    required this.id,
    required this.type,
    required this.email,
    required this.mobile,
    this.whatsappNumber,
    required this.createdAt,
  });

  factory CredentialModel.fromJson(Map<String, dynamic> json) {
    return CredentialModel(
      id: json['_id'] ?? '',
      type: json['type'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      whatsappNumber: json['whatsappNumber'], // ✅ SAFE (nullable)
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
