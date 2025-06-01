import 'package:flutter/material.dart';
import 'package:swimaca/Screen/JournalPage.dart';
import 'package:swimaca/Screen/StatisticPage.dart';
import 'package:swimaca/Screen/AchivementsPage.dart';
import 'package:swimaca/Screen/ShopPage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_database/firebase_database.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> userData; // Данные пользователя

  const HomePage({super.key, required this.userData});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 1;

  List<Map<String, dynamic>> _newsList = [];

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    final ref = FirebaseDatabase.instance.ref().child('news');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final data = snapshot.value as Map;
      final List<Map<String, dynamic>> loadedNews = [];
      data.forEach((key, value) {
        loadedNews.add(Map<String, dynamic>.from(value));
      });
      setState(() {
        _newsList = loadedNews;
      });
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => JournalPage(userData: widget.userData)),
        );
        break;
      case 1:
        Navigator.pushNamed(context, '/coach');
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StatisticPage(userData: widget.userData)),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AchievementsPage(userData: widget.userData)),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ShopPage(userData: widget.userData)),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Главная страница',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Новости",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (_newsList.isNotEmpty)
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _newsList.length,
                    itemBuilder: (context, index) {
                      final news = _newsList[index];
                      final image = news['image'] ?? '';
                      return Container(
                        width: 150,
                        margin: const EdgeInsets.only(right: 12),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: image.startsWith('http')
                                  ? Image.network(image, width: double.infinity, height: double.infinity, fit: BoxFit.cover)
                                  : Image.asset(image, width: double.infinity, height: double.infinity, fit: BoxFit.cover),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                                ),
                              ),
                            ),
                            Positioned(
                              left: 12,
                              bottom: 12,
                              right: 12,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    news['title'] ?? '',
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    news['subtitle'] ?? '',
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 24),
              const Text(
                'Меню тренировок',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildStrokeCard(
                    'Урок 1: Баттерфляй',
                    'Смотрите видео',
                    'assets/images/i.png',
                    'https://www.youtube.com/watch?v=wbTlmvcw1WM',
                  ),
                  _buildStrokeCard(
                    'Урок 2: Кроль',
                    'Смотрите видео',
                    'assets/images/i2.png',
                    'https://www.youtube.com/watch?v=wbTlmvcw1WM',
                  ),
                  _buildStrokeCard(
                    'Урок 3: Брасс',
                    'Смотрите видео',
                    'assets/images/i3.png',
                    'https://www.youtube.com/watch?v=wbTlmvcw1WM',
                  ),
                  _buildStrokeCard(
                    'Урок 4: Спина',
                    'Смотрите видео',
                    'assets/images/i4.png',
                    'https://www.youtube.com/watch?v=wbTlmvcw1WM',
                  ),
                ],
              ),
              const SizedBox(height: 32),

            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Лента'),
          BottomNavigationBarItem(icon: Icon(Icons.sports), label: 'Тренер'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Задания'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Магазин'),
        ],
      ),
      backgroundColor: Colors.white,

    );
  }

  Widget _buildWorkoutTab(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Colors.blueAccent, Colors.purpleAccent],
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStrokeCard(String title, String subtitle, String imagePath, String videoUrl) {
    return GestureDetector(
      onTap: () => _launchURL(videoUrl),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.7), Colors.transparent],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }



  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    } else {
      throw 'Не удалось открыть ссылку: $url';
    }
  }
}