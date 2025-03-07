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
  final DatabaseReference _database = FirebaseDatabase.instance.ref('achievements');
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

  // Добавляем новую группу
  Future<void> _createGroup() async {
    try {
      final newGroup = {
        'title': 'Проплывите 50 метров',
        'date': '09.03-14.03',
      };

      await _database.push().set(newGroup);
      _loadAchievements();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Группа успешно создана!')),
      );
    } catch (e) {
      debugPrint('Ошибка при добавлении группы: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось создать группу')),
      );
    }
  }

  // Присоединение к достижению
  Future<void> _joinAchievement(Map<String, dynamic> achievement) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'Пользователь не авторизован';

      final uid = user.uid;
      final newEntry = {
        'title': achievement['title'],
        'date': achievement['date'],
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
        title: const Text('Заплывы'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ElevatedButton.icon(
            //   onPressed: _createGroup,
            //   icon: const Icon(Icons.add),
            //   label: const Text('Создать группу'),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.white,
            //     foregroundColor: Colors.black,
            //     elevation: 2,
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //   ),
            // ),
            const SizedBox(height: 24),
            const Text(
              'Все достижения',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            achievements.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.45,
              ),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                return _buildAchievementCard(achievement);
              },
            ),
          ],
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
    );
  }

  // Карточка достижения
  Widget _buildAchievementCard(Map<String, dynamic> achievement) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(
              'assets/images/olimp.png',
              height: 240,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement['title'] ?? 'Без названия',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement['date'] ?? 'Без даты',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _joinAchievement(achievement),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Присоединиться'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}