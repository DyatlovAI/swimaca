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

  // Загружаем активные задачи по userId из Firebase с подробностями из achievements
  Future<void> _loadUserTasks() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('Пользователь не авторизован');
        return;
      }

      final userAchievementsSnapshot = await FirebaseDatabase.instance.ref('user_achievements/${user.uid}').get();
      final Map<String, dynamic> userAchievements = userAchievementsSnapshot.exists
          ? Map<String, dynamic>.from(userAchievementsSnapshot.value as Map)
          : {};

      final allTasksSnapshot = await FirebaseDatabase.instance.ref('zadaniya').get();
      final Map<String, dynamic> allTasks = allTasksSnapshot.exists
          ? Map<String, dynamic>.from(allTasksSnapshot.value as Map)
          : {};

      final Set<String> userTitles = userAchievements.values
          .map((e) => (e as Map)['title']?.toString() ?? '')
          .toSet();

      final List<Map<String, dynamic>> filtered = allTasks.values
          .map((e) => Map<String, dynamic>.from(e as Map))
          .where((task) => userTitles.contains(task['title']?.toString() ?? ''))
          .map((task) => {
                'title': task['title'] ?? 'Без названия',
                'startDate': task['startDate'] ?? '',
                'endDate': task['endDate'] ?? '',
              })
          .toList();

      setState(() {
        userTasks = filtered;
      });
    } catch (e) {
      debugPrint('Ошибка загрузки задач: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Профиль',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
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
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () => _showCityDialog(location),
                child: Text(
                  'Город: $location',
                  style: const TextStyle(fontSize: 16, decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.exit_to_app),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const AvtorizScreen()),
              (route) => false,
            );
          },
        ),
      ],
    );
  }

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

        return SizedBox(
          width: double.infinity,
          child: Container(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Активность', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  'Вы присоединились к $userTasksCount из $totalTasksCount заданий',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: totalTasksCount > 0 ? userTasksCount / totalTasksCount : 0,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  minHeight: 8,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Метод для загрузки количества задач
  Future<List<int>> _loadTaskCounts(Map<String, dynamic> userData) async {
    try {
      final String userId = FirebaseAuth.instance.currentUser!.uid;

      // Получаем все задания
      final tasksSnapshot = await FirebaseDatabase.instance.ref('zadaniya').get();
      final Map<String, dynamic> allTasks = tasksSnapshot.exists
          ? Map<String, dynamic>.from(tasksSnapshot.value as Map)
          : {};

      // Собираем список всех названий заданий
      final Set<String> taskTitles = allTasks.values
          .map((e) => (e as Map)['title']?.toString() ?? '')
          .toSet();

      // Получаем user_achievements по uid
      final userAchievementsSnapshot =
          await FirebaseDatabase.instance.ref('user_achievements/$userId').get();

      final Map<String, dynamic> userAchievements = userAchievementsSnapshot.exists
          ? Map<String, dynamic>.from(userAchievementsSnapshot.value as Map)
          : {};

      // Считаем только те user_achievements, у которых title совпадает с title в zadaniya
      final int joinedCount = userAchievements.values
          .where((entry) =>
              taskTitles.contains((entry as Map)['title']?.toString() ?? ''))
          .length;

      return [joinedCount, taskTitles.length];
    } catch (e) {
      debugPrint('Ошибка загрузки данных: $e');
      return [0, 0];
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
        childAspectRatio: 0.65,
      ),
      itemCount: userTasks.length,
      itemBuilder: (context, index) {
        final task = userTasks[index];
        return _buildTaskCard(
          task['title']?.toString() ?? 'Без названия',
          task['startDate']?.toString() ?? '',
          task['endDate']?.toString() ?? '',
        );
      },
    );
  }

  Widget _buildTaskCard(String title, String startDate, String endDate) {
    return Container(

      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/olimp.png',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Начало: ${_formatDate(startDate)}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          Text(
            'Конец: ${_formatDate(endDate)}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String rawDate) {
    try {
      final date = DateTime.parse(rawDate);
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    } catch (e) {
      return rawDate;
    }
  }
  void _showCityDialog(String currentCity) {
    final List<String> cities = [
      'Москва',
      'Санкт-Петербург',
      'Новосибирск',
      'Екатеринбург',
      'Казань'
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Выберите город'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: cities.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(cities[index]),
                  onTap: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      await FirebaseDatabase.instance
                          .ref('users/${user.uid}/location')
                          .set(cities[index]);
                      setState(() {
                        widget.userData['location'] = cities[index];
                      });
                      Navigator.pop(context);
                    }
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}