import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'payment_service.dart';

class MobilePaymentService implements PaymentService {
  late Razorpay _razorpay;
  Function(Map<String, dynamic>)? _onSuccess;
  Function()? _onDismiss;
  Function(String)? _onError;

  @override
  Future<void> initialize() async {
    if (kIsWeb) return;
    
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (_onSuccess != null) {
      _onSuccess!({
        'razorpay_payment_id': response.paymentId,
        'razorpay_order_id': response.orderId,
        'razorpay_signature': response.signature,
      });
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (_onError != null) {
      _onError!(response.message ?? 'Payment failed');
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External Wallet: ${response.walletName}');
  }

  @override
  Future<void> initiatePayment({
    required double amount,
    required String email,
    required String contact,
    required Function(Map<String, dynamic>) onSuccess,
    required Function() onDismiss,
    required Function(String) onError,
  }) async {
    _onSuccess = onSuccess;
    _onDismiss = onDismiss;
    _onError = onError;

    var options = {
      'key': 'rzp_test_RgqXPvDLbgEIVv',
      'amount': (amount * 100).toInt(),
      'name': 'Vegiffy',
      'description': 'Order Payment',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {'contact': contact, 'email': email},
      'external': {
        'wallets': ['paytm', 'phonepe', 'gpay'],
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      onError('Error opening Razorpay: $e');
    }
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      _razorpay.clear();
    }
  }
}