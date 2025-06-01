import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swimaca/Screen/JournalPage.dart';
import 'package:swimaca/Screen/StatisticPage.dart';
import 'package:swimaca/Screen/AchivementsPage.dart';
import 'package:swimaca/Screen/ShopPage.dart';
import 'package:swimaca/Screen/HomePage.dart';
class JournalPage extends StatefulWidget {
  final Map<String, dynamic> userData; // Данные пользователя

  const JournalPage({super.key, required this.userData});

  @override
  _JournalPageState createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  int _currentIndex = 0;

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
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref('users');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  String currentUserId = "";
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  // Загружаем всех пользователей, кроме текущего
  Future<void> _loadUsers() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      currentUserId = user.uid;

      final snapshot = await _usersRef.get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);

        final List<Map<String, dynamic>> loadedUsers = data.entries
            .where((entry) => entry.key != currentUserId) // Исключаем текущего пользователя
            .map((entry) {
          final userData = Map<String, dynamic>.from(entry.value as Map);
          return {
            'uid': entry.key,
            'firstName': userData['firstName'] ?? 'Без имени',
            'lastName': userData['lastName'] ?? 'Без фамилии',
          'birthday': userData['birthDate'] ?? 'Не указано',
            'email': userData['email'] ?? 'Нет email',
          };
        }).toList();

        setState(() {
          users = loadedUsers;
          filteredUsers = users; // По умолчанию показываем всех
        });
      }
    } catch (e) {
      debugPrint('Ошибка загрузки пользователей: $e');
    }
  }

  Future<List<Map<String, String>>> _loadUserTasks(String userId) async {
    final ref = FirebaseDatabase.instance.ref('user_achievements/$userId');
    final snapshot = await ref.get();
    if (!snapshot.exists) return [];

    final Map<String, dynamic> rawData =
        Map<String, dynamic>.from(snapshot.value as Map);

    List<Map<String, String>> result = [];

    for (var entry in rawData.entries) {
      final value = entry.value;
      if (value is Map && value.containsKey('title')) {
        final title = value['title']?.toString() ?? '';
        final startDate = value['startDate']?.toString() ?? '';
        final endDate = value['endDate']?.toString() ?? '';
        result.add({
          'title': title,
          'start': startDate.split('T').first,
          'end': endDate.split('T').first,
        });
      }
    }

    return result;
  }

  // Фильтрация по имени
  void _filterUsers(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredUsers = users
          .where((user) =>
      user['firstName'].toLowerCase().contains(searchQuery) ||
          user['lastName'].toLowerCase().contains(searchQuery))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Пользователи',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Column(
        children: [
          // Поле поиска
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _filterUsers,
              decoration: InputDecoration(
                labelText: 'Поиск по имени',
                prefixIcon: const Icon(Icons.search),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          // Список пользователей
          Expanded(
            child: filteredUsers.isEmpty
                ? const Center(child: Text("Пользователи не найдены"))
                : ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return FutureBuilder<List<Map<String, String>>>(
                        future: _loadUserTasks(user['uid'] ?? ''),
                        builder: (context, snapshot) {
                          print('Tasks for ${user['firstName']}: ${snapshot.data}');
                          final tasks = snapshot.data ?? [];
                          return ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserProfilePage(userData: user),
                                ),
                              );
                            },
                            leading: CircleAvatar(
                              backgroundColor: Colors.blueAccent,
                              child: Text(
                                '${user['firstName'][0]}${user['lastName'][0]}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text('${user['firstName']} ${user['lastName']}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('День рождения: ${user['birthday']}'),


                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
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
    );
  }
}

class UserProfilePage extends StatelessWidget {
  final Map<String, dynamic> userData;

  const UserProfilePage({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Профиль пользователя',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blueAccent,
                  child: Text(
                    '${userData['firstName'][0]}${userData['lastName'][0]}',
                    style: const TextStyle(color: Colors.white, fontSize: 28),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '${userData['firstName']} ${userData['lastName']}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Email: ${userData['email']}',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'День рождения: ${userData['birthday']}',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}