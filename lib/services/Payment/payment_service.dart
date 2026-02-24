abstract class PaymentService {
  Future<void> initialize();
  Future<void> initiatePayment({
    required double amount,
    required String email,
    required String contact,
    required Function(Map<String, dynamic>) onSuccess,
    required Function() onDismiss,
    required Function(String) onError,
  });
  void dispose();
}