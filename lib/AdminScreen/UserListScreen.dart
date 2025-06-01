

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref().child('users');
  List<Map<String, dynamic>> _userList = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() async {
    final snapshot = await _usersRef.get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final List<Map<String, dynamic>> loadedUsers = [];

      data.forEach((key, value) {
        loadedUsers.add({
          'key': key,
          'email': value['email'] ?? '',
          'city': value['city'] ?? '',
        });
      });

      setState(() {
        _userList = loadedUsers;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Пользователи'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _userList.length,
        itemBuilder: (context, index) {
          final user = _userList[index];
          return Card(
            color: Colors.white,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: ListTile(
              title: Text(user['email'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Город: ${user['city']}'),
              onTap: () {
                // Переход к профилю можно будет добавить здесь
              },
            ),
          );
        },
      ),
    );
  }
}