
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class ZadaniyaAddAdmin extends StatefulWidget {
  const ZadaniyaAddAdmin({super.key});

  @override
  State<ZadaniyaAddAdmin> createState() => _ZadaniyaAddAdminState();
}

class _ZadaniyaAddAdminState extends State<ZadaniyaAddAdmin> {
  final _titleController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  final _database = FirebaseDatabase.instance.ref().child('zadaniya');

  void _pickDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue,
            colorScheme: const ColorScheme.light(primary: Colors.blue),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
            dialogBackgroundColor: Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: child!,
          ),
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

  void _saveZadanie() {
    final title = _titleController.text.trim();
    if (title.isEmpty || _startDate == null || _endDate == null) return;

    _database.push().set({
      'title': title,
      'startDate': _startDate!.toIso8601String(),
      'endDate': _endDate!.toIso8601String(),
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Задание добавлено')),
      );
      _titleController.clear();
      setState(() {
        _startDate = null;
        _endDate = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить задание'),
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
              decoration: const InputDecoration(labelText: 'Название задания'),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                _startDate == null
                    ? 'Выбрать дату начала'
                    : 'Начало: ${DateFormat('dd.MM.yyyy').format(_startDate!)}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDate(context, true),
            ),
            ListTile(
              title: Text(
                _endDate == null
                    ? 'Выбрать дату окончания'
                    : 'Окончание: ${DateFormat('dd.MM.yyyy').format(_endDate!)}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDate(context, false),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveZadanie,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Сохранить задание'),
            ),
          ],
        ),
      ),
    );
  }
}