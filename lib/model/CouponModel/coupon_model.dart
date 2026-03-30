class CouponModel {
  final String id;
  final String couponCode;
  final String title;
  final String description;
  final String note;
  final String discountType;
  final double discountValue;
  final double? minOrderAmount;
  final double? maxDiscountAmount;
  final DateTime startDate;
  final DateTime endDate;
  final int? usageLimit;
  final int usedCount;
  final bool isActive;
  final DateTime createdAt;

  const CouponModel({
    required this.id,
    required this.couponCode,
    required this.title,
    required this.description,
    required this.note,
    required this.discountType,
    required this.discountValue,
    this.minOrderAmount,
    this.maxDiscountAmount,
    required this.startDate,
    required this.endDate,
    this.usageLimit,
    required this.usedCount,
    required this.isActive,
    required this.createdAt,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    int? toInt(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }

    return CouponModel(
      id: json['_id']?.toString() ?? '',
      couponCode: json['couponCode']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      note: json['note']?.toString() ?? '',
      discountType: json['discountType']?.toString() ?? 'flat',
      discountValue: toDouble(json['discountValue']) ?? 0.0,
      minOrderAmount: toDouble(json['minOrderAmount']),
      maxDiscountAmount: toDouble(json['maxDiscountAmount']),
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate'] ?? '') ?? DateTime.now(),
      usageLimit: toInt(json['usageLimit']),
      usedCount: toInt(json['usedCount']) ?? 0,
      isActive: json['isActive'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'couponCode': couponCode,
        'title': title,
        'description': description,
        'note': note,
        'discountType': discountType,
        'discountValue': discountValue,
        'minOrderAmount': minOrderAmount,
        'maxDiscountAmount': maxDiscountAmount,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'usageLimit': usageLimit,
        'usedCount': usedCount,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
      };

  String get discountLabel => discountType == 'percentage'
      ? '${discountValue.toStringAsFixed(0)}% OFF'
      : '₹${discountValue.toStringAsFixed(0)} OFF';

  bool get isExpired => DateTime.now().isAfter(endDate);
}
