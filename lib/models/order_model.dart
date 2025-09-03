import 'package:cloud_firestore/cloud_firestore.dart';

import 'menu_item_model.dart';
import 'user_model.dart';

enum OrderStatus {
  placed,
  confirmed,
  preparing,
  packed,
  onTheWay,
  delivered,
  cancelled,
  pending,
}

class OrderModel {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final Address deliveryAddress;
  final OrderStatus status;
  final String? deliveryPersonId;
  final String? deliveryPersonName;
  final String? deliveryPersonPhone;
  final DateTime orderTime;
  final DateTime? estimatedDeliveryTime;
  final DateTime? actualDeliveryTime;
  final String paymentMethod;
  final String? promoCode;
  final String? specialInstructions;
  final bool isPaid;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.total,
    required this.deliveryAddress,
    this.status = OrderStatus.placed,
    this.deliveryPersonId,
    this.deliveryPersonName,
    this.deliveryPersonPhone,
    required this.orderTime,
    this.estimatedDeliveryTime,
    this.actualDeliveryTime,
    required this.paymentMethod,
    this.promoCode,
    this.specialInstructions,
    this.isPaid = false,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      items: (map['items'] as List<dynamic>)
          .map((item) => CartItem.fromMap(item))
          .toList(),
      subtotal: map['subtotal']?.toDouble() ?? 0.0,
      deliveryFee: map['deliveryFee']?.toDouble() ?? 0.0,
      discount: map['discount']?.toDouble() ?? 0.0,
      total: map['total']?.toDouble() ?? 0.0,
      deliveryAddress: Address.fromMap(map['deliveryAddress']),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${map['status']}',
        orElse: () => OrderStatus.placed,
      ),
      deliveryPersonId: map['deliveryPersonId'],
      deliveryPersonName: map['deliveryPersonName'],
      deliveryPersonPhone: map['deliveryPersonPhone'],
      orderTime: _parseTimestamp(map['orderTime']),
      estimatedDeliveryTime: _parseNullableTimestamp(
        map['estimatedDeliveryTime'],
      ),
      actualDeliveryTime: _parseNullableTimestamp(map['actualDeliveryTime']),

      paymentMethod: map['paymentMethod'] ?? '',
      promoCode: map['promoCode'],
      specialInstructions: map['specialInstructions'],
      isPaid: map['isPaid'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'total': total,
      'deliveryAddress': deliveryAddress.toMap(),
      'status': status.toString().split('.').last,
      'deliveryPersonId': deliveryPersonId,
      'deliveryPersonName': deliveryPersonName,
      'deliveryPersonPhone': deliveryPersonPhone,
      'orderTime': Timestamp.fromDate(orderTime),
      'estimatedDeliveryTime': estimatedDeliveryTime != null
          ? Timestamp.fromDate(estimatedDeliveryTime!)
          : null,
      'actualDeliveryTime': actualDeliveryTime != null
          ? Timestamp.fromDate(actualDeliveryTime!)
          : null,
      'paymentMethod': paymentMethod,
      'promoCode': promoCode,
      'specialInstructions': specialInstructions,
      'isPaid': isPaid,
    };
  }

  String get statusText {
    switch (status) {
      case OrderStatus.placed:
        return 'Order Placed';
      case OrderStatus.confirmed:
        return 'Order Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.packed:
        return 'Packed';
      case OrderStatus.onTheWay:
        return 'On The Way';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.pending:
        return 'Pending';
    }
  }

  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is DateTime) {
      return timestamp;
    }
    return DateTime.now();
  }

  static DateTime? _parseNullableTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is DateTime) {
      return timestamp;
    }
    return null;
  }
}
