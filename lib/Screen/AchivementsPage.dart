import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swimaca/Screen/JournalPage.dart';
import 'package:swimaca/Screen/StatisticPage.dart';
import 'package:swimaca/Screen/AchivementsPage.dart';
import 'package:swimaca/Screen/ShopPage.dart';
import 'package:swimaca/Screen/HomePage.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

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

        // Определяем userId заранее
        final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
        final now = DateTime.now();

        final filtered = data.entries
            .map((entry) => {
                  // Ensure each achievement has a valid 'id' field, derived from the key if missing
                  'id': entry.key,
                  ...Map<String, dynamic>.from(entry.value as Map)
                })
            .where((achievement) {
              debugPrint('Проверка достижения: ${achievement['title']}');
              debugPrint('ID достижения: ${achievement['id']}');
              debugPrint('Присоединен ли пользователь: ${joinedAchievements.contains(achievement['id'])}');
              final startDateStr = achievement['startDate'];
              if (startDateStr != null && startDateStr.toString().isNotEmpty) {
                try {
                  final startDate = DateTime.parse(startDateStr);
                  if (startDate.isBefore(now)) return false;
                } catch (_) {
                  return false;
                }
              }

              // Исключаем достижения, к которым пользователь уже присоединился по userId
              if (joinedAchievements.contains(achievement['id'])) {
                return false;
              }

              final categoriesData = achievement['categoriesData'];
              if (categoriesData is Map) {
                for (final category in categoriesData.values) {
                  if (category is List) {
                    for (final slot in category) {
                      if (slot is Map && slot['userId'] == userId) {
                        debugPrint('Пропуск достижения ${achievement['id']} — пользователь уже присоединился');
                        return false;
                      }
                    }
                  }
                }
              }

              return true;
            })
            .toList();

        debugPrint('Финальный список достижений (${filtered.length}):');
        filtered.forEach((a) => debugPrint(' - ${a['title']}'));
        setState(() {
          achievements = filtered;
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
            .whereType<Map>()
            .map<String>((entry) => entry['id'] as String? ?? '')
            .where((id) => id.isNotEmpty)
            .toSet();
      }
    } catch (e) {
      debugPrint('Ошибка загрузки достижений пользователя: $e');
    }
  }

  Future<void> _showPhoneInputDialog(Map<String, dynamic> achievement) async {
    debugPrint('Показ диалога ввода телефона');
    final TextEditingController phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final maskFormatter = MaskTextInputFormatter(
      mask: '+7 (###) ###-##-##',
      filter: { "#": RegExp(r'[0-9]') },
      initialText: '',
    );

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Введите номер телефона',
          style: TextStyle(color: Colors.blue),
        ),
        content: Form(
          key: formKey,
          child: TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [maskFormatter],
            decoration: const InputDecoration(
              hintText: '+7 (___) ___-__-__',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(null);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
            ),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = phoneController.text.trim();
              final regExp = RegExp(r'^\+7 \(\d{3}\) \d{3}-\d{2}-\d{2}$');
              if (text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Пожалуйста, введите номер телефона')),
                );
                return;
              }
              if (!regExp.hasMatch(text)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Введите корректный номер телефона')),
                );
                return;
              }
              Navigator.of(context).pop(text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Подтвердить'),
          ),
        ],
      ),
    );

    if (result != null) {
      debugPrint('Введён номер телефона: $result');
      await _joinAchievementWithPhone(achievement, result);
    } else {
      debugPrint('Ввод номера телефона отменён');
    }
  }

  // Присоединение к достижению с номером телефона
  Future<void> _joinAchievementWithPhone(Map<String, dynamic> achievement, String phone) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('Ошибка: FirebaseAuth.instance.currentUser == null');
        throw 'Пользователь не авторизован';
      }

      // Логируем наличие и значения title и категории
      debugPrint('achievement[\'title\']: ${achievement['title']}');
      // debugPrint('achievement[\'category\']: ${achievement['category']}');

      final uid = user.uid;

      // --- Получение даты рождения пользователя из базы данных ---
      final userId = FirebaseAuth.instance.currentUser?.uid;
      String? birthdateStr;

      if (userId != null) {
        final userSnapshot = await FirebaseDatabase.instance.ref('users/$userId').get();
        if (userSnapshot.exists) {
          final userMap = Map<String, dynamic>.from(userSnapshot.value as Map);
          birthdateStr = userMap['birthDate'];
        }
      }

      debugPrint('Дата рождения пользователя: $birthdateStr');
      int? age;
      if (birthdateStr != null) {
        try {
          final birthDate = DateFormat('dd.MM.yyyy').parse(birthdateStr);
          final now = DateTime.now();
          age = now.year - birthDate.year;
          if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
            age--;
          }
          debugPrint('Рассчитанный возраст: $age');
          if (age != null) {
            debugPrint('Пользователю $age лет');
          }
        } catch (e) {
          debugPrint('Ошибка парсинга даты рождения: $e');
        }
      }
      // --- Конец вычисления возраста ---

      // Проверяем наличие категорий у достижения
      final categories = achievement['categories'];
      String? category;

      if (categories == null) {
        debugPrint('achievement["categories"] == null');
      } else if (categories is! List) {
        debugPrint('achievement["categories"] не является списком');
      } else if (categories.isEmpty) {
        debugPrint('achievement["categories"] пустой список');
      }
      // Проверка наличия и валидности categories перед определением категории
      if (categories == null || !(categories is List) || categories.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Для этого достижения не указаны категории')),
          );
        }
        debugPrint('Ошибка: achievement["categories"] отсутствует или пусто');
        return;
      }

      if (categories is List && categories.isNotEmpty) {
        category = categories.firstWhere(
          (c) {
            if (age == null) return false;
            if (c == '7-9') return age >= 7 && age <= 9;
            if (c == '9-13') return age >= 9 && age <= 13;
            if (c == '13-18') return age >= 13 && age <= 18;
            if (c == '18-25') return age >= 18 && age <= 25;
            if (c == '25+') return age > 25;
            return false;
          },
          orElse: () => null,
        );
        category ??= categories.first;
      }
      final title = achievement['title'] ?? '';
      if (title == '') {
        debugPrint('Ошибка: achievement[\'title\'] отсутствует или пустой');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ошибка: не найдено название достижения')),
          );
        }
        return;
      }

      // Получаем все заявки пользователя и фильтруем вручную по title и category
      final snapshot = await _userAchievements.child(uid).get();
      int countInCategory = 0;
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        countInCategory = data.values.where((entry) {
          if (entry is Map) {
            return (entry['title'] ?? '') == title && (entry['category'] ?? '') == category;
          }
          return false;
        }).length;
      }
      debugPrint('Текущее количество заявок в категории "$category": $countInCategory');

      if (countInCategory >= 10) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Извините, в этой категории нет свободных мест')),
          );
        }
        debugPrint('Нет свободных мест в категории "$category"');
        return;
      }

      final newEntry = {
        'id': achievement['id'],
        'title': title,
        'date': achievement['date'] ?? '',
        'startDate': achievement.containsKey('startDate') ? achievement['startDate'] : '',
        'endDate': achievement.containsKey('endDate') ? achievement['endDate'] : '',
        'joinedAt': DateTime.now().toIso8601String(),
        'phone': phone,
        'category': category,
        'userId': uid,
      };

      debugPrint('Возраст пользователя: $age');
      debugPrint('Выбранная категория: $category');
      debugPrint('newEntry перед сохранением: $newEntry');

      await _userAchievements.child(uid).push().set(newEntry);
      debugPrint('Заявка сохранена в базе данных');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Вы успешно присоединились!')),
        );
      }

      await _sendConfirmationEmail(user.email ?? '', achievement, category ?? '');

      // Удаляем достижение из списка и обновляем UI
      if (mounted) {
        setState(() {
          achievements.removeWhere((a) => a['title'] == title);
        });
      }
    } catch (e, stack) {
      debugPrint('Ошибка при присоединении к достижению: $e');
      debugPrint('Stacktrace: ${stack.toString()}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось присоединиться')),
        );
      }
    }
  }

  Future<void> _sendConfirmationEmail(String email, Map<String, dynamic> achievement, String category) async {
    debugPrint('Начинаем отправку подтверждающего письма');
    final smtpServer = SmtpServer(
      'smtp.mail.ru',
      username: 'artem.dyatlov.2023@mail.ru',
      password: 'lFNACmVifAtXRWOSAuJ9',
      port: 587,
      ssl: false,
      ignoreBadCertificate: true,
    );

    final message = Message()
      ..from = const Address('artem.dyatlov.2023@mail.ru', 'Swimaca')
      ..recipients.add(email)
      ..subject = 'Подтверждение заявки на достижение: ${achievement['title']}'
      ..text = '''
Здравствуйте!

Вы успешно подали заявку на достижение "${achievement['title']}".
Категория: $category.

Спасибо за участие!

С уважением,
Команда Swimaca
''';

    try {
      final sendReport = await send(message, smtpServer);
      debugPrint('Письмо отправлено: ' + sendReport.toString());
    } on MailerException catch (e) {
      debugPrint('Ошибка при отправке письма: $e');
    } catch (e) {
      debugPrint('Неизвестная ошибка при отправке письма: $e');
    }
  }

  // Присоединение к достижению
  Future<void> _joinAchievement(Map<String, dynamic> achievement) async {
    await _showPhoneInputDialog(achievement);
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