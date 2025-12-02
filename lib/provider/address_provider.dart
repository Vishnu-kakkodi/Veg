
import 'package:flutter/material.dart';
import 'package:veegify/model/address_model.dart';
import 'package:veegify/services/address_service.dart';
// Import your Address model and AddressService
// import 'address_model.dart';
// import 'address_service.dart';

class AddressProvider extends ChangeNotifier {
  List<Address> _addresses = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  List<Address> get addresses => _addresses;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error message
  void setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Load all addresses
  Future<bool> loadAddresses() async {
    try {
      setLoading(true);
      clearError();

      final result = await AddressService.getAllAddresses();

      if (result['success']) {
        _addresses = result['data'] ?? [];
        setLoading(false);
        return true;
      } else {
        setError(result['message'] ?? 'Failed to load addresses');
        setLoading(false);
        return false;
      }
    } catch (e) {
      setError('Error loading addresses: ${e.toString()}');
      setLoading(false);
      return false;
    }
  }

  // Add new address
  Future<bool> addAddress(Address address) async {
    try {
      setLoading(true);
      clearError();

      final result = await AddressService.createAddress(address);

      if (result['success']) {
        // Reload addresses to get the updated list
        await loadAddresses();
        return true;
      } else {
        setError(result['message'] ?? 'Failed to add address');
        setLoading(false);
        return false;
      }
    } catch (e) {
      setError('Error adding address: ${e.toString()}');
      setLoading(false);
      return false;
    }
  }

  // Update existing address
  Future<bool> updateAddress(String addressId, Address address) async {
    try {
      setLoading(true);
      clearError();

      final result = await AddressService.updateAddress(addressId, address);

      if (result['success']) {
        // Reload addresses to get the updated list
        await loadAddresses();
        return true;
      } else {
        setError(result['message'] ?? 'Failed to update address');
        setLoading(false);
        return false;
      }
    } catch (e) {
      setError('Error updating address: ${e.toString()}');
      setLoading(false);
      return false;
    }
  }

  // Remove address
  Future<bool> removeAddress(String addressId) async {
    print("ggggggggggggggggggggggggggggggggggggggggggggggggggggggg");
    try {
      print("Provider Address Idddddddddddddddddddddddddddddddddddddddddddddddddddddd: $addressId");
      setLoading(true);
      clearError();

      final result = await AddressService.removeAddress(addressId);

      if (result['success']) {
        // Remove from local list immediately
        _addresses.removeWhere((address) => address.id == addressId);
        setLoading(false);
        notifyListeners();
        return true;
      } else {
        setError(result['message'] ?? 'Failed to remove address');
        setLoading(false);
        return false;
      }
    } catch (e) {
      setError('Error removing address: ${e.toString()}');
      setLoading(false);
      return false;
    }
  }

  // Get address by ID
  Address? getAddressById(String addressId) {
    try {
      return _addresses.firstWhere((address) => address.id == addressId);
    } catch (e) {
      return null;
    }
  }

  // Get addresses by type
  List<Address> getAddressesByType(String addressType) {
    return _addresses.where((address) => 
        address.addressType.toLowerCase() == addressType.toLowerCase()).toList();
  }

  // Check if address type exists
  bool hasAddressType(String addressType) {
    return _addresses.any((address) => 
        address.addressType.toLowerCase() == addressType.toLowerCase());
  }

  // Get address types
  List<String> get addressTypes {
    return _addresses.map((address) => address.addressType).toSet().toList();
  }

  // Clear all addresses (for logout)
  void clearAddresses() {
    _addresses.clear();
    _isLoading = false;
    _errorMessage = '';
    notifyListeners();
  }

  // Refresh addresses
  Future<bool> refreshAddresses() async {
    return await loadAddresses();
  }
}