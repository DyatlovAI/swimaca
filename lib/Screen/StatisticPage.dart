import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swimaca/Screen/Avtoriz.dart';
import 'package:swimaca/Screen/JournalPage.dart';
import 'package:swimaca/Screen/StatisticPage.dart';
import 'package:swimaca/Screen/AchivementsPage.dart';
import 'package:swimaca/Screen/ShopPage.dart';
import 'package:swimaca/Screen/HomePage.dart';

class StatisticPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const StatisticPage({super.key, required this.userData});

  @override
  _StatisticPageState createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {
  final DatabaseReference _userAchievements = FirebaseDatabase.instance.ref('user_achievements');
  List<Map<String, dynamic>> userTasks = [];


  int _currentIndex = 2;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage(userData: widget.userData)),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage(userData: widget.userData)),
        );        break;
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
  void initState() {
    super.initState();
    _loadUserTasks();
  }

  // Загружаем активные задачи по userId из Firebase
  Future<void> _loadUserTasks() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('Пользователь не авторизован');
        return;
      }

      final snapshot = await _userAchievements.child(user.uid).get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          userTasks = data.values.map((task) => Map<String, dynamic>.from(task)).toList();
        });
      }
    } catch (e) {
      debugPrint('Ошибка загрузки задач: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Профиль'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 16),
              _buildActivityCard(widget.userData),
              const SizedBox(height: 32),
              const Text(
                'Активные задачи',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              userTasks.isEmpty
                  ? const Center(child: Text("Нет активных задач"))
                  : _buildTaskGrid(),
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

  Widget _buildProfileHeader() {
    final String fullName = '${widget.userData['firstName']} ${widget.userData['lastName']}';
    final String initials = _getInitials(widget.userData['firstName'], widget.userData['lastName']);
    final String location = widget.userData['location'] ?? 'Город не указан';

    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.lightBlueAccent,
          child: Text(
            initials,
            style: const TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fullName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(location),
          ],
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.exit_to_app),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AvtorizScreen()),
            );          },
        ),
      ],
    );
  }

  /// Получает инициалы из имени и фамилии (например, "Анастасия Чекина" → "АЧ")
  String _getInitials(String firstName, String lastName) {
    String initials = '';
    if (firstName.isNotEmpty) initials += firstName[0];
    if (lastName.isNotEmpty) initials += lastName[0];
    return initials.toUpperCase();
  }

  Widget _buildActivityCard(Map<String, dynamic> userData) {
    return FutureBuilder<List<int>>(
      future: _loadTaskCounts(userData),
      builder: (context, AsyncSnapshot<List<int>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Ошибка загрузки данных'));
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('Нет данных'));
        }

        final int userTasksCount = snapshot.data![0]; // Количество задач пользователя
        final int totalTasksCount = snapshot.data![1]; // Общее количество задач

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              const Text('Активность', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$userTasksCount / $totalTasksCount',
                      style: const TextStyle(fontSize: 18)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

// Метод для загрузки количества задач
  Future<List<int>> _loadTaskCounts(Map<String, dynamic> userData) async {
    final String userId = userData['userId'] ?? ''; // UID пользователя из Firebase Auth

    try {
      // Получаем все достижения
      final achievementsSnapshot = await FirebaseDatabase.instance.ref('achievements').get();
      final int totalTasksCount = achievementsSnapshot.exists
          ? (achievementsSnapshot.value as Map).length
          : 0;

      // Получаем достижения, к которым присоединился пользователь
      final userAchievementsSnapshot = await FirebaseDatabase.instance
          .ref('user_achievements/$userId')
          .get();
      final int userTasksCount = userAchievementsSnapshot.exists
          ? (userAchievementsSnapshot.value as Map).length
          : 0;

      return [userTasksCount, totalTasksCount];
    } catch (e) {
      debugPrint('Ошибка загрузки данных: $e');
      return [0, 0]; // В случае ошибки возвращаем 0/0
    }
  }

  Widget _buildTaskGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: userTasks.length,
      itemBuilder: (context, index) {
        final task = userTasks[index];
        return _buildTaskCard(task['title'], task['date']);
      },
    );
  }

  Widget _buildTaskCard(String title, String date) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.description,
            color: Colors.white,
            size: 80,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}