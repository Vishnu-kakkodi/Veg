// ─────────────────────────────────────────
//  coupon_provider.dart
// ─────────────────────────────────────────

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:veegify/model/CouponModel/coupon_model.dart';

enum CouponStatus { idle, loading, loaded, error }

class CouponProvider extends ChangeNotifier {
  CouponStatus _status = CouponStatus.idle;
  List<CouponModel> _coupons = [];
  String _errorMessage = '';

  // ── Getters ──────────────────────────────
  CouponStatus get status => _status;
  List<CouponModel> get coupons => List.unmodifiable(_coupons);
  String get errorMessage => _errorMessage;
  bool get isLoading => _status == CouponStatus.loading;

  // ── API ──────────────────────────────────
  static const String _baseUrl =
      'https://api.vegiffyy.com/api/getallactivecoupons';

  Future<void> fetchCoupons(String userId) async {
    _setStatus(CouponStatus.loading);
    try {
      print("ppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppp$userId");
      final response = await http
          .get(Uri.parse("$_baseUrl/$userId"))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body =
            json.decode(response.body) as Map<String, dynamic>;

        if (body['success'] == true) {
          final List<dynamic> dataList = body['data'] as List<dynamic>;
          _coupons = dataList
              .map((e) => CouponModel.fromJson(e as Map<String, dynamic>))
              .toList();
          _setStatus(CouponStatus.loaded);
        } else {
          _setError('Server returned success: false');
        }
      } else {
        _setError('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      _setError('Failed to load coupons: $e');
    }
  }

  // ── Helpers ──────────────────────────────
  void _setStatus(CouponStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _status = CouponStatus.error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    _status = CouponStatus.idle;
    notifyListeners();
  }
}