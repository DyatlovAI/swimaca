import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:swimaca/AdminScreen/ZadaniyaEditAdmin.dart';

class ZadaniyaProsmotrAdmin extends StatefulWidget {
  const ZadaniyaProsmotrAdmin({super.key});

  @override
  State<ZadaniyaProsmotrAdmin> createState() => _ZadaniyaProsmotrAdminState();
}

class _ZadaniyaProsmotrAdminState extends State<ZadaniyaProsmotrAdmin> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('zadaniya');
  List<Map<String, dynamic>> zadaniyaList = [];

  @override
  void initState() {
    super.initState();
    _loadZadaniya();
  }

  void _loadZadaniya() {
    _database.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map && data.isNotEmpty) {
        final List<Map<String, dynamic>> loaded = [];
        data.forEach((key, value) {
          loaded.add({
            'key': key,
            'title': value['title'] ?? '',
            'description': value['description'] ?? '',
            'startDate': value['startDate'],
            'endDate': value['endDate'],
          });
        });
        setState(() {
          zadaniyaList = loaded;
        });
      } else {
        setState(() {
          zadaniyaList = [];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Задания'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: zadaniyaList.isEmpty
          ? const Center(
              child: Text(
                'Нет доступных заданий',
                style: TextStyle(fontSize: 16),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: zadaniyaList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.6,
              ),
              itemBuilder: (context, index) {
                final item = zadaniyaList[index];
                return GestureDetector(
                  onDoubleTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ZadaniyaEditAdmin(
                          id: item['key'],
                          zadanie: item,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              'assets/images/olimp.png',
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['title'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          if ((item.containsKey('startDate') && item['startDate'] != null && item['startDate'].toString().isNotEmpty) ||
                              (item.containsKey('endDate') && item['endDate'] != null && item['endDate'].toString().isNotEmpty))
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (item.containsKey('startDate') && item['startDate'] != null && item['startDate'].toString().isNotEmpty)
                                  Text('Начало: ${item['startDate'].toString().split('T').first}'),
                                if (item.containsKey('endDate') && item['endDate'] != null && item['endDate'].toString().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text('Конец: ${item['endDate'].toString().split('T').first}'),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}