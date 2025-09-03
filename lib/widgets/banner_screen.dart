import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_services.dart';
import '../models/banner_model.dart';

class BannerManagement extends StatefulWidget {
  const BannerManagement({Key? key}) : super(key: key);

  @override
  State<BannerManagement> createState() => _BannerManagementState();
}

class _BannerManagementState extends State<BannerManagement> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Banner Management'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showBannerDialog(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firebaseService.getBanners(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final banners = snapshot.data!.docs
              .map((doc) => BannerModel.fromMap(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  ))
              .toList();

          return ListView.builder(
            itemCount: banners.length,
            itemBuilder: (context, index) {
              final banner = banners[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      banner.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported),
                    ),
                  ),
                  title: Text(banner.title),
                  subtitle: Text(banner.subtitle),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showBannerDialog(banner: banner),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteBanner(banner.id),
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

  void _showBannerDialog({BannerModel? banner}) {
    final titleController = TextEditingController(text: banner?.title ?? '');
    final subtitleController = TextEditingController(text: banner?.subtitle ?? '');
    final imageUrlController = TextEditingController(text: banner?.imageUrl ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(banner == null ? 'Add Banner' : 'Edit Banner'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: subtitleController,
              decoration: const InputDecoration(labelText: 'Subtitle'),
            ),
            TextField(
              controller: imageUrlController,
              decoration: const InputDecoration(labelText: 'Image URL'),
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
              final newBanner = BannerModel(
                id: banner?.id ?? '',
                title: titleController.text,
                subtitle: subtitleController.text,
                imageUrl: imageUrlController.text,
              );

              if (banner == null) {
                await _firebaseService.addBanner(newBanner);
              } else {
                await _firebaseService.updateBanner(banner.id, newBanner);
              }

              Navigator.pop(context);
            },
            child: Text(banner == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _deleteBanner(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Banner'),
        content: const Text('Are you sure you want to delete this banner?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firebaseService.deleteBanner(id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}