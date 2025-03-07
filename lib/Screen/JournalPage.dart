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
            'firstName': userData['firstName'] ?? 'Без имени',
            'lastName': userData['lastName'] ?? 'Без фамилии',
            'birthday': userData['birthday'] ?? 'Не указано',
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Журнал'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Поле поиска
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _filterUsers,
              decoration: const InputDecoration(
                labelText: 'Поиск по имени',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
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
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Text(
                      '${user['firstName'][0]}${user['lastName'][0]}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text('${user['firstName']} ${user['lastName']}'),
                  subtitle: Text('День рождения: ${user['birthday']}'),
                  // trailing: IconButton(
                  //   icon: const Icon(Icons.person_add),
                  //   onPressed: () {
                  //     debugPrint('Добавить: ${user['firstName']}');
                  //   },
                  // ),
                );
              },
            ),
          ),
        ],
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
}