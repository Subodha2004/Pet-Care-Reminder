# Pet-Care-Reminder
import 'package:flutter/material.dart';
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
import 'screens/add_edit_reminder_screen.dart';
import 'screens/quick_add_templates_screen.dart';
import 'theme/theme_controller.dart';
import 'models/reminder.dart';
import 'models/reminder_category.dart';
import 'database/reminder_db_helper.dart';

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
  final List<Reminder> _reminders = [];
  Database? _database;
  SharedPreferences? _prefs;
  final TextEditingController _searchController = TextEditingController();
  List<Reminder> _filteredReminders = [];
  ReminderCategory? _selectedCategoryFilter;

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
        // Text search filter
        final matchesSearch = query.isEmpty ||
            reminder.title.toLowerCase().contains(query) ||
            reminder.description.toLowerCase().contains(query);
        
        // Category filter
        final matchesCategory = _selectedCategoryFilter == null ||
            reminder.category == _selectedCategoryFilter;
        
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  Future<void> _initializeStorage() async {
    if (kIsWeb) {
      // Use SharedPreferences for web
      _prefs = await SharedPreferences.getInstance();
      _loadRemindersFromPrefs();
    } else {
      // Use new SQLite database for mobile
      try {
        await ReminderDBHelper.getDb();
        await _loadReminders();
        // Update all scheduled times on app start
        await ReminderDBHelper.updateAllScheduledTimes();
      } catch (e) {
        _prefs = await SharedPreferences.getInstance();
        await _loadRemindersFromPrefs();
      }
    }
  }

  Future<void> _loadReminders() async {
    if (kIsWeb) {
      await _loadRemindersFromPrefs();
    } else {
      await _loadRemindersFromDatabase();
    }
  }

  Future<void> _loadRemindersFromDatabase() async {
    try {
      final reminders = await ReminderDBHelper.getReminders();
      if (!mounted) return;
      
      setState(() {
        _reminders.clear();
        _reminders.addAll(reminders);
        _filterReminders();
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading reminders: $e');
      }
    }
  }

  Future<void> _loadRemindersFromPrefs() async {
    if (_prefs == null) return;
    
    final String? remindersJson = _prefs!.getString('reminders');
    if (remindersJson != null) {
      final List<dynamic> remindersList = json.decode(remindersJson);
      setState(() {
        _reminders.clear();
        for (final reminderData in remindersList) {
          _reminders.add(Reminder.fromJson(reminderData));
        }
        _filterReminders();
      });
    }
  }

  Future<void> _addReminder(Reminder reminder) async {
    if (kIsWeb) {
      await _addReminderToPrefs(reminder);
    } else {
      await _addReminderToDatabase(reminder);
    }
  }

  Future<void> _addReminderToDatabase(Reminder reminder) async {
    try {
      await ReminderDBHelper.insertReminder(reminder);
      await _loadReminders();
    } catch (e) {
      if (kDebugMode) {
        print('Error adding reminder: $e');
      }
    }
  }

  Future<void> _addReminderToPrefs(Reminder reminder) async {
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
    try {
      await ReminderDBHelper.deleteReminder(id);
      await _loadReminders();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting reminder: $e');
      }
    }
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

  Future<void> _snoozeReminder(int id, Duration duration) async {
    if (kIsWeb) {
      // Snooze not supported in web version yet
      return;
    }
    
    try {
      await ReminderDBHelper.snoozeReminder(id, duration);
      await _loadReminders();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.snooze, color: Colors.white),
              const SizedBox(width: 8),
              Text('Snoozed for ${duration.inMinutes} minutes'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error snoozing reminder: $e');
      }
    }
  }

  void _showSnoozeOptions(BuildContext context, Reminder reminder) {
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.snooze, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                const Text(
                  'Snooze Reminder',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSnoozeOption(context, '5 minutes', const Duration(minutes: 5), reminder.id),
            _buildSnoozeOption(context, '15 minutes', const Duration(minutes: 15), reminder.id),
            _buildSnoozeOption(context, '30 minutes', const Duration(minutes: 30), reminder.id),
            _buildSnoozeOption(context, '1 hour', const Duration(hours: 1), reminder.id),
            _buildSnoozeOption(context, '2 hours', const Duration(hours: 2), reminder.id),
            _buildSnoozeOption(context, '1 day', const Duration(days: 1), reminder.id),
          ],
        ),
      ),
    );
  }

  Widget _buildSnoozeOption(BuildContext context, String label, Duration duration, int reminderId) {
    return ListTile(
      leading: const Icon(Icons.access_time),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        _snoozeReminder(reminderId, duration);
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  void _showAddReminderDialog() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditReminderScreen(),
      ),
    );
    
    if (result != null && result is Reminder) {
      await _addReminder(result);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('Added: ${result.title}'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayReminders = _searchController.text.isEmpty ? _reminders : _filteredReminders;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // Modern AppBar with gradient
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: const Text(
                'Pet Care Reminder',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 0.5,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Icon(
                        Icons.pets,
                        size: 120,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
                tooltip: 'Settings',
              ),
              IconButton(
                icon: const Icon(Icons.pets_outlined),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PetListScreen()),
                  );
                },
                tooltip: 'View Pets',
              ),
              const SizedBox(width: 8),
            ],
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enhanced Search bar
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search your reminders...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 15,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: isDark ? theme.cardColor : Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Category filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Quick Add button
                        _buildQuickAddButton(context, theme),
                        const SizedBox(width: 8),
                        
                        // All categories chip
                        _buildCategoryFilterChip(
                          null,
                          'All',
                          Icons.grid_view_rounded,
                          theme.colorScheme.primary,
                          theme,
                        ),
                        const SizedBox(width: 8),
                        
                        // Individual category chips
                        ...ReminderCategory.values.map((category) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildCategoryFilterChip(
                              category,
                              category.displayName,
                              category.icon,
                              category.color,
                              theme,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Section header
                  if (displayReminders.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Upcoming Reminders',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.grey.shade800,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${displayReminders.length}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),
          
          // Reminder list or empty state
          displayReminders.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.pets_rounded,
                            size: 80,
                            color: theme.colorScheme.primary.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No reminders yet',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white70 : Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tap the + button to add your first reminder',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Keep your pet happy and healthy!',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade400,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final reminder = displayReminders[index];
                        return _buildReminderCard(
                          context,
                          reminder: reminder,
                          index: index,
                        );
                      },
                      childCount: displayReminders.length,
                    ),
                  ),
                ),
          
          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _showAddReminderDialog,
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add_rounded, size: 24),
          label: const Text(
            'Add Reminder',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildReminderCard(BuildContext context, {required Reminder reminder, int index = 0}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Use category colors and gradients
    final gradient = reminder.category.gradientColors;
    final accentColor = reminder.category.color;
    final categoryIcon = reminder.category.icon;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Could navigate to reminder details
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark 
                    ? [theme.cardColor, theme.cardColor]
                    : gradient,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    children: [
                      // Icon container
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          categoryIcon,
                          color: accentColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Title and time
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reminder.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: isDark ? Colors.white : Colors.grey.shade800,
                                letterSpacing: 0.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 16,
                                  color: isDark ? Colors.white70 : Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  reminder.time,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? Colors.white70 : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            // Recurrence info
                            if (reminder.recurrencePattern != RecurrencePattern.none) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.repeat_rounded,
                                    size: 16,
                                    color: theme.colorScheme.primary.withOpacity(0.8),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    reminder.recurrenceDescription,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: theme.colorScheme.primary.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            // Snoozed indicator
                            if (reminder.isSnoozed) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.snooze,
                                    size: 16,
                                    color: Colors.orange.shade700,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Snoozed',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      // Active indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: reminder.isActive
                              ? Colors.green.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: reminder.isActive ? Colors.green : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              reminder.isActive ? 'Active' : 'Off',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: reminder.isActive ? Colors.green : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  // Category badge
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: reminder.category.color.withOpacity(isDark ? 0.3 : 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: reminder.category.color.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          reminder.category.icon,
                          size: 14,
                          color: reminder.category.color,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          reminder.category.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: reminder.category.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Description
                  if (reminder.description.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(isDark ? 0.1 : 0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 16,
                            color: isDark ? Colors.white70 : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              reminder.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white70 : Colors.grey.shade700,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  // Divider
                  const SizedBox(height: 12),
                  Divider(
                    color: Colors.white.withOpacity(isDark ? 0.2 : 0.5),
                    height: 1,
                  ),
                  const SizedBox(height: 8),
                  
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Snooze button
                      if (!reminder.isSnoozed)
                        _buildActionButton(
                          context,
                          icon: Icons.snooze_outlined,
                          label: 'Snooze',
                          color: Colors.orange,
                          onPressed: () => _showSnoozeOptions(context, reminder),
                        ),
                      const Spacer(),
                      _buildActionButton(
                        context,
                        icon: Icons.notifications_active_outlined,
                        label: 'Notify',
                        color: theme.colorScheme.primary,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text("Notification set for ${reminder.title}"),
                                ],
                              ),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        context,
                        icon: Icons.delete_outline_rounded,
                        label: 'Delete',
                        color: Colors.red,
                        onPressed: () => _showDeleteConfirmation(context, reminder),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showDeleteConfirmation(BuildContext context, Reminder reminder) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            const SizedBox(width: 12),
            const Text('Delete Reminder?'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${reminder.title}"?',
          style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteReminder(reminder.id);
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.delete, color: Colors.white),
                      const SizedBox(width: 8),
                      const Text('Reminder deleted'),
                    ],
                  ),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickAddButton(BuildContext context, ThemeData theme) {
    return ElevatedButton.icon(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const QuickAddTemplatesScreen(),
          ),
        );
        
        if (result != null && result is Reminder) {
          await _addReminder(result);
          
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(result.category.icon, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Added: ${result.title}'),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: result.category.color,
            ),
          );
        }
      },
      icon: const Icon(Icons.bolt, size: 20),
      label: const Text(
        'Quick Add',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
  
  Widget _buildCategoryFilterChip(
    ReminderCategory? category,
    String label,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    final isSelected = _selectedCategoryFilter == category;
    
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : color,
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      onSelected: (selected) {
        setState(() {
          _selectedCategoryFilter = selected ? category : null;
          _filterReminders();
        });
      },
      backgroundColor: color.withOpacity(0.1),
      selectedColor: color,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : color,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        fontSize: 13,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    );
  }
}

