import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:veegify/constants/api.dart';
import 'package:veegify/helper/storage_helper.dart';
import 'package:veegify/model/address_model.dart';


class AddressService {
  static const String baseUrl = ApiConstants.baseUrl;
      static final user = UserPreferences.getUser();


  // Create address
  static Future<Map<String, dynamic>> createAddress(Address address) async {
    try {
                    print('Saving addressssssssssssssssss22222222222${user?.userId}'); // Debug print

      final url = '$baseUrl/addaddress/${user?.userId}';
      print("kkkkkkkkkkkkkkkk$url");
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(address.toJson()),
      );

      print('Create Address Body: ${address.toJson()}');

      print('Create Address Response: ${response.statusCode}');
      print('Create Address Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'Address created successfully',
          'data': responseData,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to create address',
          'data': null,
        };
      }
    } catch (e) {
      print('Error creating address: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'data': null,
      };
    }
  }


  // Fixed getAllAddresses method for your AddressService class
static Future<Map<String, dynamic>> getAllAddresses() async {
  try {

    final url = '$baseUrl/getaddresses/${user?.userId}';
    print("koooooooooooooooooooooooooookkkkkkkkkkkk$url");

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    print(url);

    print('Get Addresses Response: ${response.statusCode}');
    print('Get Addresses Body: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      
      // Parse addresses from response - FIXED: Look for 'addresses' field instead of 'data'
      List<Address> addresses = [];
      if (responseData['addresses'] != null) {  // Changed from 'data' to 'addresses'
        final addressList = responseData['addresses'] as List;
        addresses = addressList.map((item) => Address.fromJson(item)).toList();
      }
      
      return {
        'success': true,
        'message': 'Addresses fetched successfully',
        'data': addresses,
      };
    } else {
      final errorData = jsonDecode(response.body);
      return {
        'success': false,
        'message': errorData['message'] ?? 'Failed to fetch addresses',
        'data': null,
      };
    }
  } catch (e) {
    print('Error fetching addresses: $e');
    return {
      'success': false,
      'message': 'Network error: ${e.toString()}',
      'data': null,
    };
  }
}

  // Update address
  static Future<Map<String, dynamic>> updateAddress(String addressId, Address address) async {
    try {


      final url = '$baseUrl/updateaddresses/${user?.userId}/$addressId';
      print('Update Address Response: $url');
      print('Create Address Body: ${address.toJson()}');

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(address.toJson()),
      );



      print('Update Address Response: ${response.statusCode}');
      print('Update Address Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'Address updated successfully',
          'data': responseData,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to update address',
          'data': null,
        };
      }
    } catch (e) {
      print('Error updating address: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'data': null,
      };
    }
  }

  // Remove address
  static Future<Map<String, dynamic>> removeAddress(String addressId) async {
    try {

      final url = '$baseUrl/deleteaddresses/${user?.userId}/$addressId';

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Remove Address Response: ${response.statusCode}');
      print('Remove Address Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'Address removed successfully',
          'data': responseData,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to remove address',
          'data': null,
        };
      }
    } catch (e) {
      print('Error removing address: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'data': null,
      };
    }
  }
}