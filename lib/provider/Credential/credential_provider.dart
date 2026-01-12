import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:veegify/model/Credential/credential_model.dart';

class CredentialProvider extends ChangeNotifier {
  static const String _url =
      'https://api.vegiffyy.com/api/getallcredential';

  bool _isLoading = false;
  String _errorMessage = '';
  List<CredentialModel> _credentials = [];

  // Getters
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  List<CredentialModel> get credentials => _credentials;

  /// Fetch credentials (cached)
  Future<void> fetchCredentials() async {
    if (_credentials.isNotEmpty) return;

    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      final response = await http.get(Uri.parse(_url));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List list = decoded['credentials'] ?? [];

        _credentials =
            list.map((e) => CredentialModel.fromJson(e)).toList();
      } else {
        _errorMessage = 'Failed to load credentials';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // HELPERS
  // =========================

  CredentialModel? getByType(String type) {
    try {
      return _credentials.firstWhere((e) => e.type == type);
    } catch (_) {
      return null;
    }
  }

  String? getEmailByType(String type) {
    return getByType(type)?.email;
  }

  String? getMobileByType(String type) {
    return getByType(type)?.mobile;
  }

  /// ✅ NEW: WhatsApp number
  String? getWhatsappByType(String type) {
    return getByType(type)?.whatsappNumber ??
        getByType(type)?.mobile; // fallback
  }
}
