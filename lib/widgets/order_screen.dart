import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../firebase_services.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';

class OrderManagement extends StatefulWidget {
  const OrderManagement({Key? key}) : super(key: key);

  @override
  State<OrderManagement> createState() => _OrderManagementState();
}

class _OrderManagementState extends State<OrderManagement> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firebaseService.getOrders(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs
              .map(
                (doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>),
              )
              .toList();

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ExpansionTile(
                  title: Text('Order #${order.id.substring(0, 8)}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total: ₹${order.total.toStringAsFixed(2)}'),
                      Text('Status: ${order.statusText}'),
                      Text(
                        'Time: ${DateFormat('dd/MM/yyyy HH:mm').format(order.orderTime)}',
                      ),
                    ],
                  ),
                  trailing: _buildStatusChip(order.status),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Order Details Section
                          _buildSectionTitle('Order Details'),
                          _buildInfoRow('Order ID', '#${order.id}'),
                          _buildInfoRow('Status', order.statusText),
                          _buildInfoRow(
                            'Order Time',
                            DateFormat(
                              'dd/MM/yyyy HH:mm',
                            ).format(order.orderTime),
                          ),
                          if (order.estimatedDeliveryTime != null)
                            _buildInfoRow(
                              'Estimated Delivery',
                              DateFormat(
                                'dd/MM/yyyy HH:mm',
                              ).format(order.estimatedDeliveryTime!),
                            ),
                          if (order.actualDeliveryTime != null)
                            _buildInfoRow(
                              'Actual Delivery',
                              DateFormat(
                                'dd/MM/yyyy HH:mm',
                              ).format(order.actualDeliveryTime!),
                            ),

                          const SizedBox(height: 16),
                          // Payment Details Section
                          _buildSectionTitle('Payment Details'),
                          _buildInfoRow(
                            'Subtotal',
                            '₹${order.subtotal.toStringAsFixed(2)}',
                          ),
                          _buildInfoRow(
                            'Delivery Fee',
                            '₹${order.deliveryFee.toStringAsFixed(2)}',
                          ),
                          _buildInfoRow(
                            'Discount',
                            '₹${order.discount.toStringAsFixed(2)}',
                          ),
                          _buildInfoRow(
                            'Total Amount',
                            '₹${order.total.toStringAsFixed(2)}',
                          ),
                          _buildInfoRow('Payment Method', order.paymentMethod),
                          _buildInfoRow(
                            'Payment Status',
                            order.isPaid ? 'Paid' : 'Pending',
                          ),
                          if (order.promoCode != null &&
                              order.promoCode!.isNotEmpty)
                            _buildInfoRow('Promo Code', order.promoCode!),

                          const SizedBox(height: 16),
                          // Delivery Details Section
                          _buildSectionTitle('Delivery Details'),
                          StreamBuilder<DocumentSnapshot>(
                            stream: _firebaseService.getUserById(order.userId),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text(
                                  'Error loading user: ${snapshot.error}',
                                );
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }

                              if (!snapshot.hasData || !snapshot.data!.exists) {
                                return _buildInfoRow(
                                  'Customer ID',
                                  order.userId,
                                );
                              }

                              final userData =
                                  snapshot.data!.data() as Map<String, dynamic>;
                              final user = UserModel.fromMap(userData);

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // User Profile Section
                                  Row(
                                    children: [
                                      if (user.profileImage != null)
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            25,
                                          ),
                                          child: Image.network(
                                            user.profileImage!,
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const CircleAvatar(
                                                      radius: 25,
                                                      child: Icon(Icons.person),
                                                    ),
                                          ),
                                        ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user.name,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            if (user.isAdmin)
                                              Container(
                                                margin: const EdgeInsets.only(
                                                  top: 4,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: const Text(
                                                  'Admin',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Contact Information
                                  _buildSectionSubtitle('Contact Information'),
                                  _buildInfoRow('Customer ID', user.id),
                                  _buildInfoRow('Email', user.email),
                                  if (user.phoneNumber != null)
                                    _buildInfoRow('Phone', user.phoneNumber!),
                                  _buildInfoRow(
                                    'Member Since',
                                    DateFormat(
                                      'MMM dd, yyyy',
                                    ).format(user.createdAt),
                                  ),
                                  _buildInfoRow(
                                    'Loyalty Points',
                                    user.loyaltyPoints.toString(),
                                  ),

                                  const SizedBox(height: 16),
                                  // Delivery Address
                                  _buildSectionSubtitle('Delivery Address'),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              order.deliveryAddress.title,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            if (order.deliveryAddress.isDefault)
                                              Container(
                                                margin: const EdgeInsets.only(
                                                  left: 8,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.green
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: const Text(
                                                  'Default',
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(order.deliveryAddress.street),
                                        Text(order.deliveryAddress.area),
                                        Text(
                                          '${order.deliveryAddress.city}, ${order.deliveryAddress.state}',
                                        ),
                                        Text(order.deliveryAddress.pincode),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 16),
                                  // All Saved Addresses
                                  _buildSectionSubtitle('All Saved Addresses'),
                                  ...user.addresses
                                      .where(
                                        (addr) =>
                                            addr.id != order.deliveryAddress.id,
                                      )
                                      .map(
                                        (addr) => Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey.shade200,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    addr.title,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  if (addr.isDefault)
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                            left: 8,
                                                          ),
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 2,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.green
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      child: const Text(
                                                        'Default',
                                                        style: TextStyle(
                                                          color: Colors.green,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(addr.street),
                                              Text(addr.area),
                                              Text(
                                                '${addr.city}, ${addr.state}',
                                              ),
                                              Text(addr.pincode),
                                            ],
                                          ),
                                        ),
                                      ),
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 16),
                          // Order Items Section
                          _buildSectionTitle('Order Items'),
                          ...order.items.map(
                            (item) => Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Item Image
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.network(
                                            item.menuItem.imageUrl,
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(
                                                      Icons.restaurant,
                                                      size: 80,
                                                    ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Item Details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    '${item.quantity}x',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      item.menuItem.name,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    '₹${item.totalPrice.toStringAsFixed(2)}',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                item.menuItem.description,
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // Item Additional Details
                                    Wrap(
                                      spacing: 8,
                                      children: [
                                        _buildDetailChip(
                                          icon: Icons.category,
                                          label: item.menuItem.category,
                                        ),
                                        _buildDetailChip(
                                          icon: item.menuItem.isVegetarian
                                              ? Icons.circle
                                              : Icons.circle,
                                          label: item.menuItem.isVegetarian
                                              ? 'Vegetarian'
                                              : 'Non-Vegetarian',
                                          color: item.menuItem.isVegetarian
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                        _buildDetailChip(
                                          icon: Icons.timer,
                                          label:
                                              '${item.menuItem.preparationTime} mins',
                                        ),
                                        if (item.menuItem.isPopular)
                                          _buildDetailChip(
                                            icon: Icons.star,
                                            label: 'Popular',
                                            color: Colors.orange,
                                          ),
                                      ],
                                    ),
                                    if (item
                                        .menuItem
                                        .ingredients
                                        .isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        'Ingredients:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        item.menuItem.ingredients.join(', '),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                    if (item.menuItem.rating > 0) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.star,
                                            size: 16,
                                            color: Colors.amber,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${item.menuItem.rating.toStringAsFixed(1)} (${item.menuItem.reviewCount} reviews)',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    if (item.specialInstructions != null &&
                                        item
                                            .specialInstructions!
                                            .isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        'Special Instructions:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        item.specialInstructions!,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),
                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButton<OrderStatus>(
                                  value: order.status,
                                  isExpanded: true,
                                  items: OrderStatus.values.map((status) {
                                    return DropdownMenuItem(
                                      value: status,
                                      child: Text(
                                        status.toString().split('.').last,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (newStatus) {
                                    if (newStatus != null) {
                                      _firebaseService.updateOrderStatus(
                                        order.id,
                                        newStatus,
                                      );
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: () =>
                                    _showDeliveryPersonDialog(order),
                                child: const Text('Assign Delivery'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color color;
    switch (status) {
      case OrderStatus.placed:
      case OrderStatus.pending:
        color = Colors.blue;
        break;
      case OrderStatus.confirmed:
      case OrderStatus.preparing:
        color = Colors.orange;
        break;
      case OrderStatus.packed:
      case OrderStatus.onTheWay:
        color = Colors.purple;
        break;
      case OrderStatus.delivered:
        color = Colors.green;
        break;
      case OrderStatus.cancelled:
        color = Colors.red;
        break;
    }

    return Chip(
      label: Text(
        status.toString().split('.').last,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
    );
  }

  void _showDeliveryPersonDialog(OrderModel order) {
    final nameController = TextEditingController(
      text: order.deliveryPersonName ?? '',
    );
    final phoneController = TextEditingController(
      text: order.deliveryPersonPhone ?? '',
    );
    final idController = TextEditingController(
      text: order.deliveryPersonId ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Delivery Person'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: idController,
              decoration: const InputDecoration(
                labelText: 'Delivery Person ID',
              ),
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firebaseService.assignDeliveryPerson(
                order.id,
                idController.text,
                nameController.text,
                phoneController.text,
              );
              Navigator.pop(context);
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionSubtitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.orange,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String label,
    Color? color,
  }) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color ?? Colors.grey[700]),
      label: Text(
        label,
        style: TextStyle(fontSize: 12, color: color ?? Colors.grey[700]),
      ),
      backgroundColor: (color ?? Colors.grey[700])?.withOpacity(0.1),
    );
  }
}
