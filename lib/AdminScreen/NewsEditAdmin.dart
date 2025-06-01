import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class NewsEditAdmin extends StatefulWidget {
  const NewsEditAdmin({super.key});

  @override
  State<NewsEditAdmin> createState() => _NewsEditAdminState();
}

class _NewsEditAdminState extends State<NewsEditAdmin> {
  final titleController = TextEditingController();
  final subtitleController = TextEditingController();
  String? key;
  String? image;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null) {
      key = args['key'];
      titleController.text = args['title'] ?? '';
      subtitleController.text = args['subtitle'] ?? '';
      image = args['image'];
    }
  }

  void _saveEdit() {
    if (key != null) {
      final db = FirebaseDatabase.instance.ref().child('news/$key');
      db.update({
        'title': titleController.text,
        'subtitle': subtitleController.text,
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Новость обновлена')),
        );
        Navigator.pop(context);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка обновления: $error')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать новость'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  image!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Заголовок',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent),
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
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveEdit,
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
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                if (key != null) {
                  FirebaseDatabase.instance.ref().child('news/$key').remove().then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Новость удалена')),
                    );
                    Navigator.pop(context);
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ошибка удаления: $error')),
                    );
                  });
                }
              },
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
      ),
    );
  }
}