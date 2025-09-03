import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? profileImage;
  final List<Address> addresses;
  final int loyaltyPoints;
  final bool isAdmin;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.profileImage,
    this.addresses = const [],
    this.loyaltyPoints = 0,
    this.isAdmin = false,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
     DateTime parseCreatedAt() {
      final createdAt = map['createdAt'];
      if (createdAt is Timestamp) {
        return createdAt.toDate();
      } else if (createdAt is String) {
        return DateTime.parse(createdAt);
      } else {
        return DateTime.now(); // fallback default value
      }
    }
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'],
      profileImage: map['profileImage'],
      addresses: (map['addresses'] as List<dynamic>?)
          ?.map((addr) => Address.fromMap(addr))
          .toList() ?? [],
      loyaltyPoints: map['loyaltyPoints'] ?? 0,
      isAdmin: map['isAdmin'] ?? false,
      createdAt: parseCreatedAt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'addresses': addresses.map((addr) => addr.toMap()).toList(),
      'loyaltyPoints': loyaltyPoints,
      'isAdmin': isAdmin,
      'createdAt': createdAt,
    };
  }
}

class Address {
  final String id;
  final String title;
  final String street;
  final String area;
  final String city;
  final String state;
  final String pincode;

  final bool isDefault;

  Address({
    required this.id,
    required this.title,
    required this.street,
    required this.area,
    required this.city,
    required this.state,
    required this.pincode,
    this.isDefault = false,
  });

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      street: map['street'] ?? '',
      area: map['area'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      pincode: map['pincode'] ?? '',
      isDefault: map['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'street': street,
      'area': area,
      'city': city,
      'state': state,
      'pincode': pincode,
      'isDefault': isDefault,
    };
  }
}