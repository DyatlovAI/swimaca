

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class ZadaniyaEditAdmin extends StatefulWidget {
  final String id;
  final Map<String, dynamic> zadanie;

  const ZadaniyaEditAdmin({
    super.key,
    required this.id,
    required this.zadanie,
  });

  @override
  State<ZadaniyaEditAdmin> createState() => _ZadaniyaEditAdminState();
}

class _ZadaniyaEditAdminState extends State<ZadaniyaEditAdmin> {
  late TextEditingController _titleController;
  DateTime? _startDate;
  DateTime? _endDate;

  final _database = FirebaseDatabase.instance.ref().child('zadaniya');

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.zadanie['title']);
    _startDate = DateTime.tryParse(widget.zadanie['startDate'] ?? '');
    _endDate = DateTime.tryParse(widget.zadanie['endDate'] ?? '');
  }

  void _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _saveChanges() async {
    final updatedData = {
      'title': _titleController.text.trim(),
      'startDate': _startDate?.toIso8601String(),
      'endDate': _endDate?.toIso8601String(),
    };

    await _database.child(widget.id).update(updatedData);

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заплыв обновлён')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Редактировать заплыв'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Название'),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(_startDate != null
                  ? 'Начало: ${DateFormat('dd.MM.yyyy').format(_startDate!)}'
                  : 'Выбрать дату начала'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDate(true),
            ),
            ListTile(
              title: Text(_endDate != null
                  ? 'Конец: ${DateFormat('dd.MM.yyyy').format(_endDate!)}'
                  : 'Выбрать дату окончания'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDate(false),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Сохранить изменения'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await _database.child(widget.id).remove();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Заплыв удалён')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Удалить заплыв'),
            ),
          ],
        ),
      ),
    );
  }
}