import 'package:flutter/material.dart';
import 'package:swimaca/Screen/JournalPage.dart';
import 'package:swimaca/Screen/StatisticPage.dart';
import 'package:swimaca/Screen/AchivementsPage.dart';
import 'package:swimaca/Screen/ShopPage.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> userData; // Данные пользователя

  const HomePage({super.key, required this.userData});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 1;

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

        title: Text('Привет, ${widget.userData['firstName']}!'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,

      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const Text(
              //   'Для тебя',
              //   style: TextStyle(
              //     fontSize: 18,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // const SizedBox(height: 16),
              // // SingleChildScrollView(
              // //   scrollDirection: Axis.horizontal,
              // //   child: Row(
              // //     children: [
              // //       _buildWorkoutTab('Мои занятия'),
              // //       const SizedBox(width: 16),
              // //       _buildWorkoutTab('Любимые занятия'),
              // //       const SizedBox(width: 16),
              // //       _buildWorkoutTab('Другие занятия'),
              // //     ],
              // //   ),
              // // ),
              // // const SizedBox(height: 32),
              const Text(
                'Меню тренировок',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
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

            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.sports), label: 'Coach'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'You'),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Challenges'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Shop'),
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
      child: SizedBox(
        width: double.infinity,
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