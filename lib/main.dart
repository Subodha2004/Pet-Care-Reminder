import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';  // Temporarily disabled
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/pet_list_screen.dart';
import 'screens/add_reminder_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeController.load();
  
  // TODO: Initialize notifications when network issues are resolved
  // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  //     FlutterLocalNotificationsPlugin();
  
  // const AndroidInitializationSettings initializationSettingsAndroid =
  //     AndroidInitializationSettings('@mipmap/ic_launcher');
  
  // const InitializationSettings initializationSettings =
  //     InitializationSettings(android: initializationSettingsAndroid);
  
  // await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  
  runApp(const PetCareReminderApp());
}

class PetCareReminderApp extends StatelessWidget {
  const PetCareReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: ThemeController.seedColor,
      builder: (context, seed, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: ThemeController.themeMode,
          builder: (context, mode, __) {
            return ValueListenableBuilder<bool>(
              valueListenable: ThemeController.useMaterial3,
              builder: (context, m3, ___) {
                return MaterialApp(
                  title: 'Pet Care Reminder',
                  theme: ThemeData(
                    colorScheme: ColorScheme.fromSeed(seedColor: seed),
                    useMaterial3: m3,
                  ),
                  darkTheme: ThemeData(
                    colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
                    useMaterial3: m3,
                  ),
                  themeMode: mode,
                  home: const PetCareHomePage(),
              builder: (context, child) {
                return ValueListenableBuilder<double>(
                  valueListenable: ThemeController.textScaleFactor,
                  builder: (context, scale, __) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaler: TextScaler.linear(scale),
                      ),
                      child: child!,
                    );
                  },
                );
              },
                );
              },
            );
          },
        );
      },
    );
  }
}

class PetCareHomePage extends StatefulWidget {
  const PetCareHomePage({super.key});

  @override
  State<PetCareHomePage> createState() => _PetCareHomePageState();
}

class _PetCareHomePageState extends State<PetCareHomePage> {
  final List<PetReminder> _reminders = [];
  Database? _database;
  SharedPreferences? _prefs;
  final TextEditingController _searchController = TextEditingController();
  List<PetReminder> _filteredReminders = [];

  @override
  void initState() {
    super.initState();
    _initializeStorage();
    _searchController.addListener(_filterReminders);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterReminders() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredReminders = _reminders.where((reminder) {
        return reminder.title.toLowerCase().contains(query) ||
               reminder.description.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _initializeStorage() async {
    if (kIsWeb) {
      // Use SharedPreferences for web
      _prefs = await SharedPreferences.getInstance();
      _loadRemindersFromPrefs();
    } else {
      // Use SQLite for mobile, fallback to SharedPreferences if DB unavailable (e.g., tests)
      try {
        await _initializeDatabase();
      } catch (e) {
        _prefs = await SharedPreferences.getInstance();
        await _loadRemindersFromPrefs();
      }
    }
  }

  Future<void> _initializeDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = p.join(databasePath, 'pet_reminders.db');
    
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE reminders(id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'title TEXT, description TEXT, time TEXT, isActive INTEGER)',
        );
      },
    );
    
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    if (kIsWeb) {
      await _loadRemindersFromPrefs();
    } else {
      await _loadRemindersFromDatabase();
    }
  }

  Future<void> _loadRemindersFromDatabase() async {
    if (_database == null) return;
    
    final List<Map<String, dynamic>> maps = await _database!.query('reminders');
    
    setState(() {
      _reminders.clear();
      for (final map in maps) {
        _reminders.add(PetReminder.fromMap(map));
      }
      _filterReminders();
    });
  }

  Future<void> _loadRemindersFromPrefs() async {
    if (_prefs == null) return;
    
    final String? remindersJson = _prefs!.getString('reminders');
    if (remindersJson != null) {
      final List<dynamic> remindersList = json.decode(remindersJson);
      setState(() {
        _reminders.clear();
        for (final reminderData in remindersList) {
          _reminders.add(PetReminder.fromJson(reminderData));
        }
        _filterReminders();
      });
    }
  }

  Future<void> _addReminder(PetReminder reminder) async {
    if (kIsWeb) {
      await _addReminderToPrefs(reminder);
    } else {
      await _addReminderToDatabase(reminder);
    }
  }

  Future<void> _addReminderToDatabase(PetReminder reminder) async {
    if (_database == null) return;
    
    await _database!.insert('reminders', reminder.toMap());
    _loadReminders();
  }

  Future<void> _addReminderToPrefs(PetReminder reminder) async {
    if (_prefs == null) return;
    
    _reminders.add(reminder);
    final String remindersJson = json.encode(_reminders.map((r) => r.toJson()).toList());
    await _prefs!.setString('reminders', remindersJson);
    setState(() {
      _filterReminders();
    });
  }

  Future<void> _deleteReminder(int id) async {
    if (kIsWeb) {
      await _deleteReminderFromPrefs(id);
    } else {
      await _deleteReminderFromDatabase(id);
    }
  }

  Future<void> _deleteReminderFromDatabase(int id) async {
    if (_database == null) return;
    
    await _database!.delete('reminders', where: 'id = ?', whereArgs: [id]);
    _loadReminders();
  }

  Future<void> _deleteReminderFromPrefs(int id) async {
    if (_prefs == null) return;
    
    _reminders.removeWhere((reminder) => reminder.id == id);
    final String remindersJson = json.encode(_reminders.map((r) => r.toJson()).toList());
    await _prefs!.setString('reminders', remindersJson);
    setState(() {
      _filterReminders();
    });
  }

  void _showAddReminderDialog() {
    String title = '';
    String description = '';
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (buildContext, setState) {
            return AlertDialog(
              title: const Text('Add Pet Care Reminder'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Title (e.g., Feed Cat)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => title = value,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => description = value,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Time'),
                    subtitle: Text(selectedTime.format(buildContext)),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: buildContext,
                        initialTime: selectedTime,
                      );
                      if (picked != null) {
                        setState(() {
                          selectedTime = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (title.isNotEmpty) {
                      final reminder = PetReminder(
                        id: DateTime.now().millisecondsSinceEpoch,
                        title: title,
                        description: description,
                        time: '${selectedTime.hour.toString().padLeft(2, '0')}:'
                               '${selectedTime.minute.toString().padLeft(2, '0')}',
                        isActive: true,
                      );
                      _addReminder(reminder);
                      Navigator.of(dialogContext).pop();
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayReminders = _searchController.text.isEmpty ? _reminders : _filteredReminders;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Pet Care Reminder',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final newReminder = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddReminderScreen()),
              );
              if (!context.mounted) return;
              if (newReminder != null) {
                final title = (newReminder['title'] ?? '') as String;
                final petType = (newReminder['petType'] ?? '') as String;
                final time = (newReminder['time'] ?? '') as String;
                if (title.isNotEmpty && time.isNotEmpty) {
                  final reminder = PetReminder(
                    id: DateTime.now().millisecondsSinceEpoch,
                    title: title,
                    description: petType.isNotEmpty ? 'Pet type: $petType' : '',
                    time: time,
                    isActive: true,
                  );
                  await _addReminder(reminder);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added: $title at $time')),
                  );
                }
              }
            },
            tooltip: 'Add Reminder',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PetListScreen()),
              );
            },
            tooltip: 'View Pets',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🔍 Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search your reminders...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 📋 Reminder list
            Expanded(
              child: displayReminders.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.pets,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No reminders yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap the + button to add your first reminder',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: displayReminders.length,
                      itemBuilder: (context, index) {
                        final reminder = displayReminders[index];
                        return _buildReminderCard(
                          context,
                          reminder: reminder,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReminderDialog,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }

  Widget _buildReminderCard(BuildContext context, {required PetReminder reminder}) {
    // Generate different colors for different reminders
    final colors = [
      Colors.orange.shade100,
      Colors.green.shade100,
      Colors.blue.shade100,
      Colors.purple.shade100,
      Colors.pink.shade100,
      Colors.cyan.shade100,
    ];
    final color = colors[reminder.id % colors.length];

    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: const Icon(Icons.pets, color: Colors.teal, size: 32),
        title: Text(
          reminder.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Time: ${reminder.time}'),
            if (reminder.description.isNotEmpty)
              Text(reminder.description),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.teal),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Notification for ${reminder.title}")),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteReminder(reminder.id),
            ),
          ],
        ),
      ),
    );
  }
}

class PetReminder {
  final int id;
  final String title;
  final String description;
  final String time;
  final bool isActive;

  PetReminder({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'time': time,
      'isActive': isActive ? 1 : 0,
    };
  }

  factory PetReminder.fromMap(Map<String, dynamic> map) {
    return PetReminder(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      time: map['time'],
      isActive: map['isActive'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'time': time,
      'isActive': isActive,
    };
  }

  factory PetReminder.fromJson(Map<String, dynamic> json) {
    return PetReminder(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      time: json['time'],
      isActive: json['isActive'],
    );
  }
}