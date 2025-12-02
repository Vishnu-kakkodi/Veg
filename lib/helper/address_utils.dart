import 'dart:convert';

class AddressParser {
  static Map<String, String> parseFullAddress(String fullAddress) {
    Map<String, String> addressComponents = {
      'street': '',
      'city': '',
      'state': '',
      'country': '',
      'postalCode': '',
    };

    try {
      // Split the address by commas
      List<String> parts = fullAddress.split(', ').map((part) => part.trim()).toList();
      
      if (parts.isEmpty) return addressComponents;

      // Extract postal code (usually 5-6 digits)
      String postalCode = '';
      for (int i = 0; i < parts.length; i++) {
        RegExp postalCodeRegex = RegExp(r'\b\d{5,6}\b');
        Match? match = postalCodeRegex.firstMatch(parts[i]);
        if (match != null) {
          postalCode = match.group(0) ?? '';
          // Remove postal code from the part
          parts[i] = parts[i].replaceFirst(postalCode, '').trim();
          // Remove any remaining comma or dash
          parts[i] = parts[i].replaceAll(RegExp(r'^[-,\s]+|[-,\s]+$'), '');
          break;
        }
      }

      // Remove empty parts
      parts = parts.where((part) => part.isNotEmpty).toList();

      if (parts.isNotEmpty) {
        // Last part is usually country
        String country = parts.removeLast();
        
        if (parts.isNotEmpty) {
          // Second to last is usually state/province
          String state = parts.removeLast();
          
          if (parts.isNotEmpty) {
            // Third to last is usually city
            String city = parts.removeLast();
            
            // Everything else is street address
            String street = parts.join(', ');
            
            addressComponents = {
              'street': street.isNotEmpty ? street : (parts.isNotEmpty ? parts.first : ''),
              'city': city,
              'state': state,
              'country': country,
              'postalCode': postalCode,
            };
          } else {
            // Only country and state available
            addressComponents = {
              'street': '',
              'city': state, // Use state as city if no city is available
              'state': '',
              'country': country,
              'postalCode': postalCode,
            };
          }
        } else {
          // Only country available
          addressComponents = {
            'street': '',
            'city': '',
            'state': '',
            'country': country,
            'postalCode': postalCode,
          };
        }
      }

      // Clean up components - remove extra whitespace and formatting
      addressComponents = addressComponents.map((key, value) => 
          MapEntry(key, _cleanAddressComponent(value)));

    } catch (e) {
      print('Error parsing address: $e');
      // Return basic parsing as fallback
      List<String> basicParts = fullAddress.split(', ');
      if (basicParts.isNotEmpty) {
        addressComponents['street'] = basicParts.first;
        if (basicParts.length > 1) {
          addressComponents['city'] = basicParts[1];
        }
        if (basicParts.length > 2) {
          addressComponents['state'] = basicParts[2];
        }
        if (basicParts.length > 3) {
          addressComponents['country'] = basicParts.last;
        }
      }
    }

    return addressComponents;
  }

  static String _cleanAddressComponent(String component) {
    return component
        .replaceAll(RegExp(r'^\W+|\W+$'), '') // Remove leading/trailing non-word chars
        .replaceAll(RegExp(r'\s+'), ' ') // Replace multiple spaces with single space
        .trim();
  }

  // Alternative parsing method for specific address formats
  static Map<String, String> parseNominatimAddress(Map<String, dynamic> nominatimData) {
    Map<String, String> addressComponents = {
      'street': '',
      'city': '',
      'state': '',
      'country': '',
      'postalCode': '',
    };

    try {
      Map<String, dynamic> address = nominatimData['address'] ?? {};
      
      // Extract street information
      String street = '';
      if (address['house_number'] != null) {
        street += address['house_number'].toString() + ' ';
      }
      if (address['road'] != null) {
        street += address['road'].toString();
      } else if (address['street'] != null) {
        street += address['street'].toString();
      }
      
      addressComponents['street'] = street.trim();
      
      // Extract city
      addressComponents['city'] = (address['city'] ?? 
                                  address['town'] ?? 
                                  address['village'] ?? 
                                  address['municipality'] ?? '').toString();
      
      // Extract state
      addressComponents['state'] = (address['state'] ?? 
                                   address['region'] ?? 
                                   address['province'] ?? '').toString();
      
      // Extract country
      addressComponents['country'] = (address['country'] ?? '').toString();
      
      // Extract postal code
      addressComponents['postalCode'] = (address['postcode'] ?? '').toString();

    } catch (e) {
      print('Error parsing Nominatim address: $e');
    }

    return addressComponents;
  }
}