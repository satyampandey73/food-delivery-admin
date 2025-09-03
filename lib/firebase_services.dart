import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'models/banner_model.dart';
import 'models/menu_item_model.dart';
import 'models/order_model.dart';
import 'services/notification_service.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  // Banner operations
  Stream<QuerySnapshot> getBanners() {
    return _firestore.collection('banners').snapshots();
  }

  Future<void> addBanner(BannerModel banner) async {
    await _firestore.collection('banners').add(banner.toMap());
  }

  Future<void> updateBanner(String id, BannerModel banner) async {
    await _firestore.collection('banners').doc(id).update(banner.toMap());
  }

  Future<void> deleteBanner(String id) async {
    await _firestore.collection('banners').doc(id).delete();
  }

  // Menu Item operations
  Stream<QuerySnapshot> getMenuItems() {
    return _firestore.collection('menu_items').snapshots();
  }

  Future<void> addMenuItem(MenuItemModel menuItem) async {
    await _firestore
        .collection('menu_items')
        .doc(menuItem.id)
        .set(menuItem.toMap());
  }

  Future<void> updateMenuItem(String id, MenuItemModel menuItem) async {
    await _firestore.collection('menu_items').doc(id).update(menuItem.toMap());
  }

  Future<void> deleteMenuItem(String id) async {
    await _firestore.collection('menu_items').doc(id).delete();
  }

  // Order operations
  Stream<QuerySnapshot> getOrders() {
    return _firestore
        .collection('orders')
        .orderBy('orderTime', descending: true)
        .snapshots();
  }

  void listenToNewOrders() {
    debugPrint('Starting to listen for new orders...');
    _firestore
        .collection('orders')
        .orderBy('orderTime', descending: true)
        .snapshots()
        .listen((snapshot) {
          debugPrint(
            'Received snapshot with ${snapshot.docChanges.length} changes',
          );
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              debugPrint('New order detected: ${change.doc.id}');
              // New order received
              final orderData = change.doc.data() as Map<String, dynamic>;
              orderData['id'] = change.doc.id;
              final order = OrderModel.fromMap(orderData);
              debugPrint(
                'Processing order #${order.id} with total: \$${order.total}',
              );
              _notificationService.showNotification(
                'New Order Received',
                'Order #${order.id} - Total: \$${order.total.toStringAsFixed(2)}',
              );
            }
          }
        });
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status.toString().split('.').last,
    });
  }

  Future<void> assignDeliveryPerson(
    String orderId,
    String deliveryPersonId,
    String name,
    String phone,
  ) async {
    await _firestore.collection('orders').doc(orderId).update({
      'deliveryPersonId': deliveryPersonId,
      'deliveryPersonName': name,
      'deliveryPersonPhone': phone,
    });
  }

  // User operations
  Stream<QuerySnapshot> getUsers() {
    return _firestore.collection('users').snapshots();
  }

  Stream<DocumentSnapshot> getUserById(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots();
  }

  Future<void> updateUserLoyaltyPoints(String userId, int points) async {
    await _firestore.collection('users').doc(userId).update({
      'loyaltyPoints': points,
    });
  }

  Future<void> toggleUserAdminStatus(String userId, bool isAdmin) async {
    await _firestore.collection('users').doc(userId).update({
      'isAdmin': isAdmin,
    });
  }

  // Analytics
  Future<Map<String, dynamic>> getDashboardStats() async {
    final ordersSnapshot = await _firestore.collection('orders').get();
    final usersSnapshot = await _firestore.collection('users').get();
    final menuItemsSnapshot = await _firestore.collection('menu_items').get();

    double totalRevenue = 0;
    int pendingOrders = 0;
    int deliveredOrders = 0;

    for (var doc in ordersSnapshot.docs) {
      final order = OrderModel.fromMap(doc.data());
      totalRevenue += order.total;
      if (order.status == OrderStatus.pending ||
          order.status == OrderStatus.placed) {
        pendingOrders++;
      } else if (order.status == OrderStatus.delivered) {
        deliveredOrders++;
      }
    }

    return {
      'totalOrders': ordersSnapshot.docs.length,
      'totalUsers': usersSnapshot.docs.length,
      'totalMenuItems': menuItemsSnapshot.docs.length,
      'totalRevenue': totalRevenue,
      'pendingOrders': pendingOrders,
      'deliveredOrders': deliveredOrders,
    };
  }
}
