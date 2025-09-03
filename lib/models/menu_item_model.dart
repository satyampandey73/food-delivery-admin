import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItemModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isVegetarian;
  final bool isAvailable;
  final double rating;
  final int reviewCount;
  final List<String> ingredients;
  final int preparationTime;
  final bool isPopular;
  final DateTime createdAt;

  MenuItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.isVegetarian = true,
    this.isAvailable = true,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.ingredients = const [],
    this.preparationTime = 15,
    this.isPopular = true,
    required this.createdAt,
  });

  factory MenuItemModel.fromMap(Map<String, dynamic> map) {
    return MenuItemModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      isVegetarian: map['isVegetarian'] ?? true,
      isAvailable: map['isAvailable'] ?? true,
      rating: map['rating']?.toDouble() ?? 0.0,
      reviewCount: map['reviewCount'] ?? 0,
      ingredients: List<String>.from(map['ingredients'] ?? []),
      preparationTime: map['preparationTime'] ?? 15,
      isPopular: map['isPopular'] ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'isVegetarian': isVegetarian,
      'isAvailable': isAvailable,
      'rating': rating,
      'reviewCount': reviewCount,
      'ingredients': ingredients,
      'preparationTime': preparationTime,
      'isPopular': isPopular,
      'createdAt': createdAt,
    };
  }
}

class CartItem {
  final MenuItemModel menuItem;
  int quantity;
  final String? specialInstructions;

  CartItem({
    required this.menuItem,
    this.quantity = 1,
    this.specialInstructions,
  });

  double get totalPrice => menuItem.price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'menuItem': menuItem.toMap(),
      'quantity': quantity,
      'specialInstructions': specialInstructions,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      menuItem: MenuItemModel.fromMap(map['menuItem']),
      quantity: map['quantity'] ?? 1,
      specialInstructions: map['specialInstructions'],
    );
  }
}
