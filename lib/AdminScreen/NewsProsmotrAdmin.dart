import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:swimaca/AdminScreen/NewsEditAdmin.dart';

class NewsProsmotrAdmin extends StatefulWidget {
  const NewsProsmotrAdmin({super.key});

  @override
  State<NewsProsmotrAdmin> createState() => _NewsProsmotrAdminState();
}

class _NewsProsmotrAdminState extends State<NewsProsmotrAdmin> {
  final DatabaseReference _newsRef = FirebaseDatabase.instance.ref().child('news');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новости'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder(
        stream: _newsRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            final data = Map<String, dynamic>.from(
                snapshot.data!.snapshot.value as Map);
            final newsList = data.entries.toList();

            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: newsList.length,
                  itemBuilder: (context, index) {
                    final key = newsList[index].key;
                    final news = Map<String, dynamic>.from(newsList[index].value);
                    return GestureDetector(
                      onDoubleTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NewsEditAdmin(),
                            settings: RouteSettings(arguments: {
                              'key': key,
                              'title': news['title'],
                              'subtitle': news['subtitle'],
                              'image': news['image'],
                            }),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: index == 0 ? 12 : 0,
                          right: index == newsList.length - 1 ? 12 : 12,
                        ),
                        child: Container(
                          width: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  news['image'] ?? 'assets/images/i.png',
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 8,
                                right: 8,
                                bottom: 28,
                                child: Text(
                                  news['title'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    shadows: [
                                      Shadow(color: Colors.black, blurRadius: 4),
                                    ],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Positioned(
                                left: 8,
                                right: 8,
                                bottom: 8,
                                child: Text(
                                  news['subtitle'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    shadows: [
                                      Shadow(color: Colors.black, blurRadius: 4),
                                    ],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text('Ошибка загрузки данных.'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}