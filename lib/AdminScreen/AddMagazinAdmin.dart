import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AddMagazinAdmin extends StatefulWidget {
  const AddMagazinAdmin({super.key});

  @override
  State<AddMagazinAdmin> createState() => _AddMagazinAdminState();
}

class _AddMagazinAdminState extends State<AddMagazinAdmin> {
  final _nameController = TextEditingController();
  final _imageController = TextEditingController();
  final _priceController = TextEditingController();
  final _oldPriceController = TextEditingController();
  final _ratingController = TextEditingController();
  final _reviewsController = TextEditingController();
  final _urlController = TextEditingController();

  void _saveProduct() {
    final db = FirebaseDatabase.instance.ref().child('shop');
    db.push().set({
      'name': _nameController.text,
      'image': _imageController.text,
      'price': int.tryParse(_priceController.text) ?? 0,
      'oldPrice': int.tryParse(_oldPriceController.text) ?? 0,
      'rating': int.tryParse(_ratingController.text) ?? 0,
      'reviews': int.tryParse(_reviewsController.text) ?? 0,
      'url': _urlController.text,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Товар добавлен')),
      );
      _nameController.clear();
      _imageController.clear();
      _priceController.clear();
      _oldPriceController.clear();
      _ratingController.clear();
      _reviewsController.clear();
      _urlController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить товар', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Название')),
          const SizedBox(height: 12),
          TextField(controller: _imageController, decoration: const InputDecoration(labelText: 'Ссылка на изображение')),
          const SizedBox(height: 12),
          TextField(controller: _priceController, decoration: const InputDecoration(labelText: 'Цена'), keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          TextField(controller: _oldPriceController, decoration: const InputDecoration(labelText: 'Старая цена'), keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          TextField(controller: _ratingController, decoration: const InputDecoration(labelText: 'Рейтинг'), keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          TextField(controller: _reviewsController, decoration: const InputDecoration(labelText: 'Отзывы'), keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          TextField(controller: _urlController, decoration: const InputDecoration(labelText: 'Ссылка на товар')),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saveProduct,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Сохранить', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
