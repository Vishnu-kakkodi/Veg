import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:js_util' as js_util;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'payment_service.dart';

class WebPaymentService implements PaymentService {
  Completer<void>? _scriptCompleter;

  @override
  Future<void> initialize() async {
    if (!kIsWeb) return;
    await _loadRazorpayScript();
  }

  Future<void> _loadRazorpayScript() async {
    // Check if script already exists
    if (html.document.querySelector('script[src="https://checkout.razorpay.com/v1/checkout.js"]') != null) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    _scriptCompleter = Completer<void>();

    final script = html.ScriptElement()
      ..src = 'https://checkout.razorpay.com/v1/checkout.js'
      ..type = 'text/javascript'
      ..async = true;

    script.onLoad.listen((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!_scriptCompleter!.isCompleted) {
          _scriptCompleter!.complete();
        }
      });
    });

    script.onError.listen((_) {
      if (!_scriptCompleter!.isCompleted) {
        _scriptCompleter!.completeError('Failed to load Razorpay script');
      }
    });

    html.document.head!.append(script);

    return _scriptCompleter!.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception('Razorpay script loading timeout'),
    );
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
    try {
      await _loadRazorpayScript();

      final Map<String, dynamic> options = {
        "key": "rzp_test_RgqXPvDLbgEIVv",
        "amount": (amount * 100).toInt(),
        "name": "Vegiffy",
        "description": "Order Payment",
        "prefill": {
          "contact": contact,
          "email": email,
        },
        "theme": {
          "color": "#F37254"
        }
      };

      final String jsonOptions = jsonEncode(options);
      final String callbackName = 'razorpay_callback_${DateTime.now().millisecondsSinceEpoch}';
      final String dismissCallbackName = 'razorpay_dismiss_${DateTime.now().millisecondsSinceEpoch}';

      // Create JavaScript functions
      final successCallback = js_util.allowInterop((response) {
        onSuccess(Map<String, dynamic>.from(js_util.dartify(response) as Map));
      });
      
      final dismissCallback = js_util.allowInterop(() {
        onDismiss();
      });

      // Set on window object
      js_util.setProperty(html.window, callbackName, successCallback);
      js_util.setProperty(html.window, dismissCallbackName, dismissCallback);

      // Execute Razorpay
      final script = '''
        (function() {
          try {
            var options = $jsonOptions;
            options.handler = function(response) {
              window.$callbackName(response);
            };
            options.modal = {
              ondismiss: function() {
                window.$dismissCallbackName();
              }
            };
            var rzp = new Razorpay(options);
            rzp.open();
          } catch (e) {
            console.error('Razorpay Error:', e);
            window.$callbackName({error: e.toString()});
          }
        })();
      ''';
      
      js_util.callMethod(html.window, 'eval', [script]);
      
    } catch (e) {
      onError('Failed to open payment gateway: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    // No disposal needed for web
  }
}