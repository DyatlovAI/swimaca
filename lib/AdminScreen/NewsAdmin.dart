import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:swimaca/AdminScreen/NewsProsmotrAdmin.dart';
import 'package:swimaca/AdminScreen/AdminHome.dart';

class NewsAdmin extends StatefulWidget {
  const NewsAdmin({super.key});

  @override
  State<NewsAdmin> createState() => _NewsAdminState();
}

class _NewsAdminState extends State<NewsAdmin> {
  final titleController = TextEditingController();
  final subtitleController = TextEditingController();
  final videoUrlController = TextEditingController();

  final List<String> _assetImages = [
    'assets/images/i.png',
    'assets/images/i2.png',
    'assets/images/i3.png',
    'assets/images/i4.png',
  ];
  String _selectedAssetImage = 'assets/images/i.png';

  bool _isSaving = false;

  Future<String> uploadFile(File file) async {
    print('Загрузка файла: ${file.path}');
    final fileName = path.basename(file.path);
    final ref = FirebaseStorage.instance.ref().child('news_images/$fileName');
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> _saveNews(String title, String subtitle, String imagePath, String videoUrl) async {
    if (_isSaving) return;
    setState(() {
      _isSaving = true;
    });
    print('Сохранение новости...');
    if (title.isEmpty || subtitle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, заполните заголовок и описание')),
      );
      setState(() {
        _isSaving = false;
      });
      return;
    }
    print('Заголовок: $title');
    print('Описание: $subtitle');
    try {
      print('Сохраняем новость в базу...');
      final DatabaseReference db = FirebaseDatabase.instance.ref().child('news');
      final newNewsRef = db.push();
      await newNewsRef.set({
        'title': title,
        'subtitle': subtitle,
        'image': imagePath,
        'videoUrl': videoUrl,
        'timestamp': DateTime.now().toIso8601String(),
      });
      print('Новость успешно сохранена');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Новость успешно сохранена')),
      );
      titleController.clear();
      subtitleController.clear();
      videoUrlController.clear();
      setState(() {
        _selectedAssetImage = _assetImages[0];
        _isSaving = false;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при сохранении: $error')),
      );
      setState(() {
        _isSaving = false;
      });
    }
  }

  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final displayImage = _selectedAssetImage;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminHome()),
            );
          },
        ),
        title: const Text(
          'Создание новости',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Заголовок',
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: subtitleController,
            decoration: const InputDecoration(
              labelText: 'Описание',
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _assetImages.map((image) {
                final isSelected = _selectedAssetImage == image;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAssetImage = image;
                    });
                  },
                  child: Container(
                    width: 150,
                    height: 150,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? Colors.blueAccent : Colors.transparent,
                        width: 3,
                      ),
                      image: DecorationImage(
                        image: AssetImage(image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _isSaving ? null : () {
              _saveNews(
                titleController.text,
                subtitleController.text,
                _selectedAssetImage,
                '',
              );
            },
            child: const Text(
              'Сохранить',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewsProsmotrAdmin()),
              );
            },
            child: const Text(
              'Новости',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}