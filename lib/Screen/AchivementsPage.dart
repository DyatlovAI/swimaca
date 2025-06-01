import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swimaca/Screen/JournalPage.dart';
import 'package:swimaca/Screen/StatisticPage.dart';
import 'package:swimaca/Screen/AchivementsPage.dart';
import 'package:swimaca/Screen/ShopPage.dart';
import 'package:swimaca/Screen/HomePage.dart';

class AchievementsPage extends StatefulWidget {
  final Map<String, dynamic> userData; // Данные пользователя

  const AchievementsPage({super.key, required this.userData});

  @override
  _AchievementsPageState createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  int _currentIndex = 3;

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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage(userData: widget.userData)),
        );
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
  final DatabaseReference _database = FirebaseDatabase.instance.ref('zadaniya');
  final DatabaseReference _userAchievements = FirebaseDatabase.instance.ref('user_achievements');
  List<Map<String, dynamic>> achievements = [];
  Set<String> joinedAchievements = {}; // Хранит названия достижений, к которым пользователь уже присоединился

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  // Загружаем все достижения и фильтруем те, к которым уже присоединился пользователь
  Future<void> _loadAchievements() async {
    try {
      final snapshot = await _database.get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);

        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await _loadUserAchievements(user.uid); // Загружаем достижения пользователя
        }

        setState(() {
          achievements = data.entries
              .map((entry) => {
            'id': entry.key,
            ...Map<String, dynamic>.from(entry.value as Map)
          })
              .where((achievement) => !joinedAchievements.contains(achievement['title']))
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Ошибка загрузки данных: $e');
    }
  }

  // Загружаем достижения, к которым пользователь уже присоединился
  Future<void> _loadUserAchievements(String uid) async {
    try {
      final snapshot = await _userAchievements.child(uid).get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        joinedAchievements = data.values
            .map<String>((entry) => entry['title'] as String)
            .toSet();
      }
    } catch (e) {
      debugPrint('Ошибка загрузки достижений пользователя: $e');
    }
  }



  // Присоединение к достижению
  Future<void> _joinAchievement(Map<String, dynamic> achievement) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'Пользователь не авторизован';

      final uid = user.uid;
      final newEntry = {
        'title': achievement['title'] ?? '',
        'date': achievement['date'] ?? '',
        'startDate': achievement.containsKey('startDate') ? achievement['startDate'] : '',
        'endDate': achievement.containsKey('endDate') ? achievement['endDate'] : '',
        'joinedAt': DateTime.now().toIso8601String(),
      };

      await _userAchievements.child(uid).push().set(newEntry);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Вы успешно присоединились!')),
      );

      // Удаляем достижение из списка и обновляем UI
      setState(() {
        achievements.removeWhere((a) => a['title'] == achievement['title']);
      });
    } catch (e) {
      debugPrint('Ошибка при присоединении к достижению: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось присоединиться')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Задания',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 24),
            const Text(
              'Все достижения',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder(
              future: _database.get().timeout(const Duration(seconds: 5)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError || achievements.isEmpty) {
                  return const Center(child: Text('Нет доступных заданий'));
                } else {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.50,
                    ),
                    itemCount: achievements.length,
                    itemBuilder: (context, index) {
                      final achievement = achievements[index];
                      return _buildAchievementCard(achievement);
                    },
                  );
                }
              },
            ),
          ],
        ),

      ),
      backgroundColor: Colors.white,
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

    );
  }

  // Карточка достижения (по стилю ZadaniyaProsmotrAdmin)
  Widget _buildAchievementCard(Map<String, dynamic> achievement) {
    return GestureDetector(
      onDoubleTap: () => _joinAchievement(achievement),
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
                achievement['title'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              if ((achievement.containsKey('date') && achievement['date'] != null && achievement['date'].toString().isNotEmpty))
                Text('Дата: ${achievement['date']}'),
              if (achievement['startDate'] != null && achievement['startDate'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('Начало: ${achievement['startDate'].toString().split('T').first}'),
                ),
              if (achievement['endDate'] != null && achievement['endDate'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('Конец: ${achievement['endDate'].toString().split('T').first}'),
                ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _joinAchievement(achievement),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                child: const Text('Присоединиться'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}