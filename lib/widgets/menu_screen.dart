import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_services.dart';
import '../models/menu_item_model.dart';

class MenuManagement extends StatefulWidget {
  const MenuManagement({Key? key}) : super(key: key);

  @override
  State<MenuManagement> createState() => _MenuManagementState();
}

class _MenuManagementState extends State<MenuManagement> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Management'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showMenuItemDialog(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firebaseService.getMenuItems(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final menuItems = snapshot.data!.docs
              .map(
                (doc) =>
                    MenuItemModel.fromMap(doc.data() as Map<String, dynamic>),
              )
              .toList();

          return ListView.builder(
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final item = menuItems[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      // Image section
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.restaurant),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Content section
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text('₹${item.price.toStringAsFixed(2)}'),
                            Text('Category: ${item.category}'),
                            Row(
                              children: [
                                Icon(
                                  item.isVegetarian
                                      ? Icons.circle
                                      : Icons.circle,
                                  color: item.isVegetarian
                                      ? Colors.green
                                      : Colors.red,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(item.isVegetarian ? 'Veg' : 'Non-Veg'),
                                const SizedBox(width: 16),
                                Icon(
                                  item.isAvailable
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: item.isAvailable
                                      ? Colors.green
                                      : Colors.red,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item.isAvailable
                                      ? 'Available'
                                      : 'Unavailable',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Actions section
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () =>
                                _showMenuItemDialog(menuItem: item),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteMenuItem(item.id),
                          ),
                        ],
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

  void _showMenuItemDialog({MenuItemModel? menuItem}) {
    final nameController = TextEditingController(text: menuItem?.name ?? '');
    final descriptionController = TextEditingController(
      text: menuItem?.description ?? '',
    );
    final priceController = TextEditingController(
      text: menuItem?.price.toString() ?? '',
    );
    final imageUrlController = TextEditingController(
      text: menuItem?.imageUrl ?? '',
    );
    final categoryController = TextEditingController(
      text: menuItem?.category ?? '',
    );
    final preparationTimeController = TextEditingController(
      text: menuItem?.preparationTime.toString() ?? '15',
    );
    final ratingController = TextEditingController(
      text: menuItem?.rating.toString() ?? '0.0',
    );
    final reviewCountController = TextEditingController(
      text: menuItem?.reviewCount.toString() ?? '0',
    );
    final ingredientsController = TextEditingController(
      text: menuItem?.ingredients.join(', ') ?? '',
    );

    bool isVegetarian = menuItem?.isVegetarian ?? true;
    bool isAvailable = menuItem?.isAvailable ?? true;
    bool isPopular = menuItem?.isPopular ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(menuItem == null ? 'Add Menu Item' : 'Edit Menu Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: imageUrlController,
                  decoration: const InputDecoration(labelText: 'Image URL'),
                ),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                TextField(
                  controller: preparationTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Preparation Time (minutes)',
                  ),
                  keyboardType: TextInputType.number,
                ),
                CheckboxListTile(
                  title: const Text('Vegetarian'),
                  value: isVegetarian,
                  onChanged: (value) => setState(() => isVegetarian = value!),
                ),
                CheckboxListTile(
                  title: const Text('Available'),
                  value: isAvailable,
                  onChanged: (value) => setState(() => isAvailable = value!),
                ),
                CheckboxListTile(
                  title: const Text('Popular'),
                  value: isPopular,
                  onChanged: (value) => setState(() => isPopular = value!),
                ),
                TextField(
                  controller: ratingController,
                  decoration: const InputDecoration(
                    labelText: 'Rating (0.0 - 5.0)',
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: reviewCountController,
                  decoration: const InputDecoration(labelText: 'Review Count'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: ingredientsController,
                  decoration: const InputDecoration(
                    labelText: 'Ingredients',
                    hintText: 'Enter ingredients separated by commas',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newMenuItem = MenuItemModel(
                  id:
                      menuItem?.id ??
                      DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  description: descriptionController.text,
                  price: double.tryParse(priceController.text) ?? 0.0,
                  imageUrl: imageUrlController.text,
                  category: categoryController.text.trim(),
                  isVegetarian: isVegetarian,
                  isAvailable: isAvailable,
                  isPopular: isPopular,
                  preparationTime:
                      int.tryParse(preparationTimeController.text) ?? 15,
                  rating: double.tryParse(ratingController.text) ?? 0.0,
                  reviewCount: int.tryParse(reviewCountController.text) ?? 0,
                  ingredients: ingredientsController.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList(),
                  createdAt: menuItem?.createdAt ?? DateTime.now(),
                );

                if (menuItem == null) {
                  await _firebaseService.addMenuItem(newMenuItem);
                } else {
                  await _firebaseService.updateMenuItem(
                    menuItem.id,
                    newMenuItem,
                  );
                }

                Navigator.pop(context);
              },
              child: Text(menuItem == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteMenuItem(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Menu Item'),
        content: const Text('Are you sure you want to delete this menu item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firebaseService.deleteMenuItem(id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
