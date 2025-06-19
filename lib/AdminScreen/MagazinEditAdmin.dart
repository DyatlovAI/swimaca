import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class MagazinEditAdmin extends StatefulWidget {
  final Map<String, dynamic> product;
  final String keyId;

  const MagazinEditAdmin({super.key, required this.product, required this.keyId});

  @override
  State<MagazinEditAdmin> createState() => _MagazinEditAdminState();
}

class _MagazinEditAdminState extends State<MagazinEditAdmin> {
  late final TextEditingController _nameController;
  late final TextEditingController _imageController;
  late final TextEditingController _priceController;
  late final TextEditingController _oldPriceController;
  late final TextEditingController _ratingController;
  late final TextEditingController _reviewsController;
  late final TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product['name']);
    _imageController = TextEditingController(text: widget.product['image']);
    _priceController = TextEditingController(text: widget.product['price'].toString());
    _oldPriceController = TextEditingController(text: widget.product['oldPrice'].toString());
    _ratingController = TextEditingController(text: widget.product['rating'].toString());
    _reviewsController = TextEditingController(text: widget.product['reviews'].toString());
    _urlController = TextEditingController(text: widget.product['url']);
  }

  void _saveChanges() {
    // Пошаговая валидация
    if (_imageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите изображение')),
      );
      return;
    }
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите заголовок')),
      );
      return;
    }
    if (_priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите описание')),
      );
      return;
    }
    if (_oldPriceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите старую цену')),
      );
      return;
    }
    if (_ratingController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите рейтинг')),
      );
      return;
    }
    if (_reviewsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите количество отзывов')),
      );
      return;
    }
    final price = int.tryParse(_priceController.text);
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите корректную цену')),
      );
      return;
    }
    final oldPrice = int.tryParse(_oldPriceController.text);
    if (oldPrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите корректную старую цену')),
      );
      return;
    }
    final rating = int.tryParse(_ratingController.text);
    if (rating == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите корректный рейтинг')),
      );
      return;
    }
    if (rating < 1 || rating > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Рейтинг должен быть от 1 до 5')),
      );
      return;
    }
    final reviews = int.tryParse(_reviewsController.text);
    if (reviews == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите корректное количество отзывов')),
      );
      return;
    }
    if (_urlController.text.trim().isNotEmpty &&
        !Uri.tryParse(_urlController.text.trim())!.isAbsolute) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите корректную ссылку на товар')),
      );
      return;
    }
    final ref = FirebaseDatabase.instance.ref().child('shop/${widget.keyId}');
    ref.update({
      'name': _nameController.text,
      'image': _imageController.text,
      'price': price,
      'oldPrice': oldPrice,
      'rating': rating,
      'reviews': reviews,
      'url': _urlController.text,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Товар обновлён')));
      Navigator.pop(context);
    });
  }

  void _deleteProduct() {
    final ref = FirebaseDatabase.instance.ref().child('shop/${widget.keyId}');
    ref.remove().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Товар удалён')));
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактирование товара'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
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
            onPressed: _saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Сохранить', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _deleteProduct,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Удалить', style: TextStyle(fontSize: 16)),
            ),
        ],
      ),
    );
  }
}