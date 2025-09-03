import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../firebase_services.dart';
import '../models/user_model.dart';

class UserManagement extends StatefulWidget {
  const UserManagement({Key? key}) : super(key: key);

  @override
  State<UserManagement> createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firebaseService.getUsers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs
              .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
              .toList();

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user.profileImage != null
                        ? NetworkImage(user.profileImage!)
                        : null,
                    child: user.profileImage == null
                        ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U')
                        : null,
                  ),
                  title: Text(user.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.email),
                      if (user.phoneNumber != null) Text('Phone: ${user.phoneNumber}'),
                      Text('Loyalty Points: ${user.loyaltyPoints}'),
                      Text('Joined: ${DateFormat('dd/MM/yyyy').format(user.createdAt)}'),
                      if (user.isAdmin)
                        const Chip(
                          label: Text('Admin', style: TextStyle(color: Colors.white)),
                          backgroundColor: Colors.red,
                        ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('Update Loyalty Points'),
                        onTap: () => _showLoyaltyPointsDialog(user),
                      ),
                      PopupMenuItem(
                        child: Text(user.isAdmin ? 'Remove Admin' : 'Make Admin'),
                        onTap: () => _firebaseService.toggleUserAdminStatus(user.id, !user.isAdmin),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showLoyaltyPointsDialog(UserModel user) {
    final pointsController = TextEditingController(text: user.loyaltyPoints.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Loyalty Points'),
        content: TextField(
          controller: pointsController,
          decoration: const InputDecoration(labelText: 'Loyalty Points'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final points = int.tryParse(pointsController.text) ?? 0;
              await _firebaseService.updateUserLoyaltyPoints(user.id, points);
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}