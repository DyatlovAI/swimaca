import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_database/firebase_database.dart';

class ZayavPage extends StatefulWidget {
  final String eventUid;
  final String eventTitle;
  final DateTime startDate;
  final DateTime? endDate;
  // Можно добавить другие поля, если нужно
  const ZayavPage({
    Key? key,
    required this.eventUid,
    required this.eventTitle,
    required this.startDate,
    this.endDate,
  }) : super(key: key);

  @override
  State<ZayavPage> createState() => _ZayavPageState();
}

class _ZayavPageState extends State<ZayavPage> {
  Stream<List<Map<String, dynamic>>> getZayavkiStream() async* {
    final ref = FirebaseDatabase.instance.ref('user_achivements');
    final snapshot = await ref.get();

    final List<Map<String, dynamic>> results = [];
    if (snapshot.exists) {
      final map = Map<String, dynamic>.from(snapshot.value as Map);
      map.forEach((key, value) {
        final item = Map<String, dynamic>.from(value);
        if (item['title'] == widget.eventTitle) {
          item['id'] = key;
          if (!item.containsKey('zadanieUid')) {
            debugPrint('Добавляем zadanieUid=${widget.eventUid} в заявку: $item');
            item['zadanieUid'] = widget.eventUid;
            FirebaseDatabase.instance.ref('user_achivements/$key').update({
              ...item,
              'zadanieUid': widget.eventUid,
            });
          }
          results.add(item);
        }
      });
    }
    yield results;
  }

  Future<void> acceptZayavka(String id) async {
    await FirebaseDatabase.instance.ref('user_achivements/$id').update({'status': 'accepted'});
  }

  Future<void> declineZayavka(String id) async {
    await FirebaseDatabase.instance.ref('user_achivements/$id').update({'status': 'declined'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Заявки')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.blue[50],
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.eventTitle,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Дата начала: ${_formatDate(widget.startDate)}'),
                if (widget.endDate != null)
                  Text('Дата окончания: ${_formatDate(widget.endDate!)}'),
                const SizedBox(height: 4),
                Text('UID мероприятия: ${widget.eventUid}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: getZayavkiStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Нет заявок'));
                }
                final zayavki = snapshot.data!;
                return ListView.builder(
                  itemCount: zayavki.length,
                  itemBuilder: (context, index) {
                    final data = zayavki[index];
                    final name = data['name'] ?? '';
                    final phone = data['phone'] ?? '';
                    final category = data['category'] ?? '';
                    final status = data['status'] ?? '';
                    final id = data['id'];

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                if (status == 'accepted')
                                  const Chip(label: Text('Принято'), backgroundColor: Colors.greenAccent)
                                else if (status == 'declined')
                                  const Chip(label: Text('Отклонено'), backgroundColor: Colors.redAccent)
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.phone, size: 18, color: Colors.blue),
                                const SizedBox(width: 4),
                                InkWell(
                                  onTap: phone.toString().isNotEmpty
                                      ? () => launchUrl(Uri.parse('tel:$phone'))
                                      : null,
                                  child: Text(
                                    phone,
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('Категория: $category'),
                            const SizedBox(height: 8),
                            if (status != 'accepted' && status != 'declined')
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      await acceptZayavka(id);
                                    },
                                    icon: const Icon(Icons.check),
                                    label: const Text('Принять'),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      await declineZayavka(id);
                                    },
                                    icon: const Icon(Icons.close),
                                    label: const Text('Отклонить'),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}

class ZadaniyaZayavkiPage extends StatefulWidget {
  const ZadaniyaZayavkiPage({Key? key}) : super(key: key);

  @override
  State<ZadaniyaZayavkiPage> createState() => _ZadaniyaZayavkiPageState();
}

class _ZadaniyaZayavkiPageState extends State<ZadaniyaZayavkiPage> {
  final DatabaseReference zadaniyaRef = FirebaseDatabase.instance.ref('zadaniya');
  final DatabaseReference userAchRef = FirebaseDatabase.instance.ref('user_achievements');
  Map<String, bool> expandedCards = {};

  Future<Map<String, dynamic>> fetchZayavkiByUid(String uid) async {
    final snapshot = await userAchRef.get();
    debugPrint('Загрузка заявок для задания UID: $uid');
    Map<String, dynamic> result = {};

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      for (final userEntry in data.entries) {
        final userId = userEntry.key;
        final achievements = Map<String, dynamic>.from(userEntry.value);

        for (final achEntry in achievements.entries) {
          final achData = Map<String, dynamic>.from(achEntry.value);
          debugPrint('Проверка заявки: $achData');
          if (achData['zadanieUid']?.toString() == uid.toString()) {
            debugPrint('Найдена заявка по UID: $uid -> $achData');
            // --- Fetch user name/surname from users/$userId
            try {
              final userSnapshot = await FirebaseDatabase.instance.ref('users/$userId').get();
              if (userSnapshot.exists) {
                final userData = Map<String, dynamic>.from(userSnapshot.value as Map);
                achData['name'] = userData['firstName'] ?? 'неизвестно';
                achData['surname'] = userData['lastName'] ?? 'неизвестно';
              }
            } catch (e) {
              // ignore error, leave defaults
            }
            // ---
            result['$userId|${achEntry.key}'] = achData;
          } else {
            debugPrint('Заявка не соответствует UID. Ожидалось: $uid, получили: ${achData['zadanieUid']}');
          }
        }
      }
    }

    return result;
  }

  Future<void> fixMissingZadanieUid(String zadanieUid, String title) async {
    final snapshot = await userAchRef.get();
    if (!snapshot.exists) return;

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    for (final userEntry in data.entries) {
      final userId = userEntry.key;
      final userZayavki = Map<String, dynamic>.from(userEntry.value);

      for (final zayavkaEntry in userZayavki.entries) {
        final achKey = zayavkaEntry.key;
        final achData = Map<String, dynamic>.from(zayavkaEntry.value);

        if (achData['title'] == title && achData['zadanieUid'] == null) {
          final ref = FirebaseDatabase.instance.ref('user_achievements/$userId/$achKey');
          await ref.update({'zadanieUid': zadanieUid});
          debugPrint('Обновлена заявка: user=$userId, ach=$achKey, добавлен zadanieUid=$zadanieUid');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Задания и заявки')),
      body: FutureBuilder<DataSnapshot>(
        future: zadaniyaRef.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists || snapshot.data!.value == null) {
            debugPrint('Нет данных по заданиям или они пусты.');
            return const Center(child: Text('Нет заданий'));
          }

          debugPrint('Значение snapshot.data!.value: ${snapshot.data!.value}');

          final rawData = Map<String, dynamic>.from(snapshot.data!.value as Map);
          final now = DateTime.now();
          final data = rawData..removeWhere((key, value) {
            final item = Map<String, dynamic>.from(value);
            if (!item.containsKey('startDate')) return true;
            try {
              final startDate = DateTime.parse(item['startDate']);
              return startDate.isBefore(now);
            } catch (_) {
              return true;
            }
          });
          debugPrint('Загружено заданий: ${data.length}');
          return ListView(
            children: data.entries.map((entry) {
              final id = entry.key;
              final item = Map<String, dynamic>.from(entry.value);
              final title = item['title'] ?? '';
              final rawDate = item['startDate'] ?? '';
              final parsedDate = DateTime.tryParse(rawDate);
              final dateFormatted = parsedDate != null
                  ? '${parsedDate.day.toString().padLeft(2, '0')}.${parsedDate.month.toString().padLeft(2, '0')}.${parsedDate.year} ${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}'
                  : rawDate;
              final expanded = expandedCards[id] ?? false;

              debugPrint('Отображение задания: $title, UID: $id');
              fixMissingZadanieUid(id, title);

              return Card(
                color: Colors.blue[50],
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  childrenPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text('Дата начала: $dateFormatted'),
                  initiallyExpanded: expanded,
                  onExpansionChanged: (bool isExpanded) {
                    setState(() {
                      expandedCards[id] = isExpanded;
                    });
                  },
                  children: [
                    FutureBuilder<Map<String, dynamic>>(
                      future: fetchZayavkiByUid(id),
                      builder: (context, zayavSnapshot) {
                        if (zayavSnapshot.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (!zayavSnapshot.hasData || zayavSnapshot.data!.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('Нет заявок'),
                          );
                        }
                        final zayavki = zayavSnapshot.data!;
                        return Column(
                          children: zayavki.entries.map((entry) {
                            final item = Map<String, dynamic>.from(entry.value);
                            final phone = item['phone'] ?? '';
                            final category = item['category'] ?? '';
                            final joinedAt = item['joinedAt'] ?? '';
                            final achKey = entry.key.split('|')[1];
                            final userId = entry.key.split('|')[0];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.person, color: Colors.blue),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text('Пользователь: $userId', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text('Имя: ${item['name'] ?? 'неизвестно'}', style: TextStyle(fontSize: 16)),
                                    const SizedBox(height: 2),
                                    Text('Фамилия: ${item['surname'] ?? 'неизвестно'}', style: TextStyle(fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.phone, size: 18, color: Colors.blue),
                                        const SizedBox(width: 4),
                                        InkWell(
                                          onTap: phone.toString().isNotEmpty
                                              ? () => launchUrl(Uri.parse('tel:$phone'))
                                              : null,
                                          child: Text(
                                            phone,
                                            style: const TextStyle(
                                              color: Colors.blue,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text('Категория: $category'),
                                    const SizedBox(height: 4),
                                    Text('Присоединился: ${_formatJoinedAt(joinedAt)}'),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () async {
                                            final category = item['category'];
                                            if (category == null || category.toString().isEmpty) {
                                              debugPrint('Категория пуста или не указана для заявки $achKey');
                                              return;
                                            }

                                            final ref = FirebaseDatabase.instance.ref('zadaniya/$id/categoriesData/$category');
                                            final catSnap = await ref.get();

                                            if (catSnap.exists) {
                                            // Безопасное преобразование: если не List, будет []
                                            final decodedList = (catSnap.value is List)
                                                ? List<Map<String, dynamic>>.from(catSnap.value as List)
                                                : [];
                                            List<dynamic> list = decodedList;
                                              bool added = false;

                                              for (int i = 1; i < list.length; i++) {
                                                if (list[i] == null || (list[i] is Map && list[i]['value'] == null)) {
                                                  await ref.child('$i').set({
                                                    'value': item['phone'],
                                                    'name': item['name'],
                                                    'surname': item['surname'],
                                                    'joinedAt': item['joinedAt'],
                                                    'userId': userId,
                                                  });
                                                  debugPrint('Заявка $achKey перемещена в категорию $category, слот $i');
                                                  added = true;
                                                  break;
                                                }
                                              }

                                              if (!added) {
                                                if (list.length > 1 && list[1] == null) {
                                                  await ref.child('1').set({
                                                    'value': item['phone'],
                                                    'name': item['name'],
                                                    'surname': item['surname'],
                                                    'joinedAt': item['joinedAt'],
                                                    'userId': userId,
                                                  });
                                                  debugPrint('Заявка $achKey заняла пустой первый слот категории $category');
                                                } else {
                                                  list.add({
                                                    'value': item['phone'],
                                                    'name': item['name'],
                                                    'surname': item['surname'],
                                                    'joinedAt': item['joinedAt'],
                                                    'userId': userId,
                                                  });
                                                  await ref.set(list);
                                                  debugPrint('Заявка $achKey добавлена в конец списка категории $category');
                                                }
                                              }

                                              await FirebaseDatabase.instance.ref('user_achievements/$userId/$achKey').remove();
                                              setState(() {});
                                            } else {
                                              debugPrint('Категория $category не найдена в zadaniya/$id');
                                            }
                                          },
                                          icon: const Icon(Icons.check),
                                          label: const Text('Принять'),
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton.icon(
                                          onPressed: () async {
                                            await FirebaseDatabase.instance.ref('user_achievements/$userId/$achKey').remove();
                                            setState(() {});
                                          },
                                          icon: const Icon(Icons.close),
                                          label: const Text('Отклонить'),
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    )
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
  String _formatJoinedAt(String rawDate) {
    try {
      final dt = DateTime.parse(rawDate);
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return rawDate;
    }
  }