// ─────────────────────────────────────────
//  coupon_model.dart
// ─────────────────────────────────────────

class CouponModel {
  final String id;
  final String couponCode;
  final String title;
  final String description;
  final String note;
  final String discountType; // "percentage" | "flat"
  final double discountValue;
  final double minOrderAmount;
  final double maxDiscountAmount;
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
    required this.minOrderAmount,
    required this.maxDiscountAmount,
    required this.startDate,
    required this.endDate,
    this.usageLimit,
    required this.usedCount,
    required this.isActive,
    required this.createdAt,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['_id'] as String,
      couponCode: json['couponCode'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      note: json['note'] as String? ?? '',
      discountType: json['discountType'] as String,
      discountValue: (json['discountValue'] as num).toDouble(),
      minOrderAmount: (json['minOrderAmount'] as num).toDouble(),
      maxDiscountAmount: (json['maxDiscountAmount'] as num).toDouble(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      usageLimit: json['usageLimit'] as int?,
      usedCount: (json['usedCount'] as num).toInt(),
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
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

  /// e.g. "4.98% OFF" or "₹4.98 OFF"
  String get discountLabel =>
      discountType == 'percentage'
          ? '${discountValue.toStringAsFixed(2)}% OFF'
          : '₹${discountValue.toStringAsFixed(0)} OFF';

  bool get isExpired => DateTime.now().isAfter(endDate);
}