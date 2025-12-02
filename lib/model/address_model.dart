// class Address {
//   final String? id;
//   final String street;
//   final String city;
//   final String state;
//   final String country;
//   final String postalCode;
//   final String addressType;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;

//   Address({
//     this.id,
//     required this.street,
//     required this.city,
//     required this.state,
//     required this.country,
//     required this.postalCode,
//     required this.addressType,
//     this.createdAt,
//     this.updatedAt,
//   });

//   // Convert Address to JSON
//   Map<String, dynamic> toJson() {
//     return {
//       'street': street,
//       'city': city,
//       'state': state,
//       'country': country,
//       'postalCode': postalCode,
//       'addressType': addressType,
//     };
//   }

//   // Create Address from JSON
//   factory Address.fromJson(Map<String, dynamic> json) {
//     return Address(
//       id: json['_id'] ?? json['id'],
//       street: json['street'] ?? '',
//       city: json['city'] ?? '',
//       state: json['state'] ?? '',
//       country: json['country'] ?? '',
//       postalCode: json['postalCode'] ?? '',
//       addressType: json['addressType'] ?? '',
//       createdAt: json['createdAt'] != null 
//           ? DateTime.parse(json['createdAt']) 
//           : null,
//       updatedAt: json['updatedAt'] != null 
//           ? DateTime.parse(json['updatedAt']) 
//           : null,
//     );
//   }

//   // Create a copy of Address with updated fields
//   Address copyWith({
//     String? id,
//     String? street,
//     String? city,
//     String? state,
//     String? country,
//     String? postalCode,
//     String? addressType,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//   }) {
//     return Address(
//       id: id ?? this.id,
//       street: street ?? this.street,
//       city: city ?? this.city,
//       state: state ?? this.state,
//       country: country ?? this.country,
//       postalCode: postalCode ?? this.postalCode,
//       addressType: addressType ?? this.addressType,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//     );
//   }

//   // Get full address as a formatted string
//   String get fullAddress {
//     return '$street, $city, $state, $country - $postalCode';
//   }

//   @override
//   String toString() {
//     return 'Address{id: $id, street: $street, city: $city, state: $state, country: $country, postalCode: $postalCode, addressType: $addressType}';
//   }

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
//     return other is Address &&
//         other.id == id &&
//         other.street == street &&
//         other.city == city &&
//         other.state == state &&
//         other.country == country &&
//         other.postalCode == postalCode &&
//         other.addressType == addressType;
//   }

//   @override
//   int get hashCode {
//     return id.hashCode ^
//         street.hashCode ^
//         city.hashCode ^
//         state.hashCode ^
//         country.hashCode ^
//         postalCode.hashCode ^
//         addressType.hashCode;
//   }
// }


















class Address {
  final String? id;
  final String street;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String addressType;
  final double? latitude;        
  final double? longitude;       
  final String? fullAddress; 

  Address({
    this.id,
    required this.street,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.addressType,
    this.latitude,
    this.longitude,
    this.fullAddress,
  });

  // Convert Address to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'street': street,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'addressType': addressType,
      'latitude': latitude,
      'longitude': longitude,
      'fullAddress': fullAddress,
    };
  }

  // Create Address from JSON
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['_id'],
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      postalCode: json['postalCode'] ?? '',
      addressType: json['addressType'] ?? 'Home',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      fullAddress: json['fullAddress'],
    );
  }

  // Copy with method for easy updates
  Address copyWith({
    String? id,
    String? street,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? addressType,
    double? latitude,
    double? longitude,
    String? fullAddress,
  }) {
    return Address(
      id: id ?? this.id,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      addressType: addressType ?? this.addressType,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      fullAddress: fullAddress ?? this.fullAddress,
    );
  }

  // Get formatted address string
  String get formattedAddress {
    return '$street, $city, $state $postalCode, $country';
  }

  @override
  String toString() {
    return 'Address{id: $id, street: $street, city: $city, state: $state, country: $country, postalCode: $postalCode, addressType: $addressType, latitude: $latitude, lng: $longitude, fullAddress: $fullAddress}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Address &&
        other.id == id &&
        other.street == street &&
        other.city == city &&
        other.state == state &&
        other.country == country &&
        other.postalCode == postalCode &&
        other.addressType == addressType &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.fullAddress == fullAddress;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        street.hashCode ^
        city.hashCode ^
        state.hashCode ^
        country.hashCode ^
        postalCode.hashCode ^
        addressType.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        fullAddress.hashCode;
  }
}