import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/notification_service.dart';
import 'firebase_services.dart';

import 'admin_dashboard.dart' show AdminDashboard;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  debugPrint('Initializing notification service...');
  final notificationService = NotificationService();
  await notificationService.init();

  // Request notification permissions
  debugPrint('Requesting notification permissions...');
  final hasPermission = await notificationService.requestPermissions();
  debugPrint('Notification permission granted: $hasPermission');

  // Start listening for new orders
  debugPrint('Starting Firebase service...');
  FirebaseService().listenToNewOrders();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Delivery Admin',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AdminDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}
