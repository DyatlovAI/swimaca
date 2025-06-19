import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

class ZadaniyaAddAdmin extends StatefulWidget {
  const ZadaniyaAddAdmin({super.key});

  @override
  State<ZadaniyaAddAdmin> createState() => _ZadaniyaAddAdminState();
}

class _ZadaniyaAddAdminState extends State<ZadaniyaAddAdmin> {
  final _titleController = TextEditingController();
  DateTime? _startDateTime;

  final _database = FirebaseDatabase.instance.ref().child('zadaniya');

  List<String> _selectedCategories = [];
  int? _categoryCount;

  Future<void> _pickDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
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

    if (pickedDate != null) {
      TimeOfDay selectedTime = TimeOfDay.now();
      await showModalBottomSheet(
        context: context,
        builder: (BuildContext builder) {
          Duration timerDuration = Duration(hours: selectedTime.hour, minutes: selectedTime.minute);
          return Container(
            height: 250,
            color: Colors.white,
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: CupertinoTimerPicker(
                    mode: CupertinoTimerPickerMode.hm,
                    initialTimerDuration: timerDuration,
                    onTimerDurationChanged: (Duration newDuration) {
                      timerDuration = newDuration;
                    },
                  ),
                ),
                TextButton(
                  child: const Text('Выбрать', style: TextStyle(color: Colors.blue)),
                  onPressed: () {
                    selectedTime = TimeOfDay(hour: timerDuration.inHours, minute: timerDuration.inMinutes % 60);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      );

      final combinedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );
      setState(() {
        _startDateTime = combinedDateTime;
      });
    }
  }

  void _showCategoryPicker({required int count}) {
    final categories = ["7-9", "9-13", "13-18", "18-25", "25+"];
    List<String> tempSelected = List.from(_selectedCategories);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Выберите категории'),
          content: SizedBox(
            width: double.maxFinite,
            child: StatefulBuilder(
              builder: (context, setStateSB) {
                return ListView(
                  shrinkWrap: true,
                  children: categories.map((category) {
                    final isSelected = tempSelected.contains(category);
                    return CheckboxListTile(
                      title: Text(category),
                      value: isSelected,
                      onChanged: (val) {
                        setStateSB(() {
                          if (val == true) {
                            if (tempSelected.length < count) {
                              tempSelected.add(category);
                            }
                          } else {
                            tempSelected.remove(category);
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: Colors.blue,
                    );
                  }).toList(),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                if (tempSelected.length != count) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Выберите $count категорий')),
                  );
                  return;
                }
                setState(() {
                  _selectedCategories = List.from(tempSelected);
                });
                Navigator.of(context).pop();
              },
              child: const Text('ОК'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCategoryCountDialog() async {
    int? selectedCount = _categoryCount;
    await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Сколько категорий добавить?'),
          content: StatefulBuilder(
            builder: (context, setStateSB) {
              return DropdownButton<int>(
                value: selectedCount,
                items: [1, 2, 3, 4, 5]
                    .map((e) => DropdownMenuItem<int>(
                          value: e,
                          child: Text(e.toString()),
                        ))
                    .toList(),
                onChanged: (val) {
                  setStateSB(() {
                    selectedCount = val;
                  });
                },
                hint: const Text('Выберите количество'),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                if (selectedCount == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Выберите количество категорий')),
                  );
                  return;
                }
                setState(() {
                  _categoryCount = selectedCount;
                  _selectedCategories.clear();
                });
                Navigator.of(context).pop();
                // Показать выбор категорий сразу после выбора количества
                Future.delayed(Duration(milliseconds: 100), () {
                  _showCategoryPicker(count: selectedCount!);
                });
              },
              child: const Text('Далее'),
            ),
          ],
        );
      },
    );
  }

  void _saveZadanie() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название')),
      );
      return;
    }
    if (_startDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите дату начала')),
      );
      return;
    }
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Добавьте хотя бы одну категорию')),
      );
      return;
    }

    final newZadanieRef = _database.push();
    newZadanieRef.set({
      'title': title,
      'startDate': _startDateTime!.toIso8601String(),
      'categories': _selectedCategories,
    }).then((_) async {
      // For each category, create subcategories with keys 1 to 10
      for (var category in _selectedCategories) {
        final categoryRef = newZadanieRef.child('categoriesData').child(category);
        for (int i = 1; i <= 1; i++) {
          await categoryRef.child(i.toString()).set({'value': i});
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Задание добавлено')),
      );
      _titleController.clear();
      setState(() {
        _startDateTime = null;
        _selectedCategories.clear();
        _categoryCount = null;
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
                _startDateTime == null
                    ? 'Выбрать дату начала'
                    : 'Начало: ${DateFormat('dd.MM.yyyy HH:mm').format(_startDateTime!)}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDate(context),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                children: _selectedCategories.map((category) {
                  return Chip(
                    label: Text(category),
                    onDeleted: () {
                      setState(() {
                        _selectedCategories.remove(category);
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                await _showCategoryCountDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Добавить категории'),
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