import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../models/pet.dart';
import '../database/db_helper.dart';

class AddEditReminderScreen extends StatefulWidget {
  final Reminder? reminder; // null for new, non-null for edit
  
  const AddEditReminderScreen({super.key, this.reminder});

  @override
  State<AddEditReminderScreen> createState() => _AddEditReminderScreenState();
}

class _AddEditReminderScreenState extends State<AddEditReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  TimeOfDay _selectedTime = TimeOfDay.now();
  RecurrencePattern _recurrencePattern = RecurrencePattern.none;
  int? _selectedPetId;
  List<Pet> _pets = [];
  
  // Custom interval fields
  int _customIntervalValue = 1;
  IntervalUnit _customIntervalUnit = IntervalUnit.days;
  
  // Weekly pattern fields
  Set<int> _selectedWeekdays = {};
  
  // Monthly pattern fields
  int _dayOfMonth = DateTime.now().day;
  
  // Smart scheduling
  DateTime? _startDate;
  DateTime? _endDate;
  bool _autoAdjustForAge = false;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPets();
    
    // If editing, populate fields
    if (widget.reminder != null) {
      final reminder = widget.reminder!;
      _titleController.text = reminder.title;
      _descriptionController.text = reminder.description;
      
      final timeParts = reminder.time.split(':');
      _selectedTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
      
      _recurrencePattern = reminder.recurrencePattern;
      _selectedPetId = reminder.petId;
      _customIntervalValue = reminder.customIntervalValue ?? 1;
      _customIntervalUnit = reminder.customIntervalUnit ?? IntervalUnit.days;
      _selectedWeekdays = reminder.weekdays?.toSet() ?? {};
      _dayOfMonth = reminder.dayOfMonth ?? DateTime.now().day;
      _startDate = reminder.startDate;
      _endDate = reminder.endDate;
      _autoAdjustForAge = reminder.autoAdjustForAge;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadPets() async {
    try {
      final pets = await DBHelper.getPets();
      if (mounted) {
        setState(() {
          _pets = pets;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _pickDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate 
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now().add(const Duration(days: 30))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _saveReminder() {
    if (!_formKey.currentState!.validate()) return;
    
    final timeString = '${_selectedTime.hour.toString().padLeft(2, '0')}:'
                      '${_selectedTime.minute.toString().padLeft(2, '0')}';
    
    final reminder = Reminder(
      id: widget.reminder?.id ?? DateTime.now().millisecondsSinceEpoch,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      time: timeString,
      isActive: true,
      petId: _selectedPetId,
      recurrencePattern: _recurrencePattern,
      customIntervalValue: _recurrencePattern == RecurrencePattern.custom 
          ? _customIntervalValue 
          : null,
      customIntervalUnit: _recurrencePattern == RecurrencePattern.custom 
          ? _customIntervalUnit 
          : null,
      weekdays: _recurrencePattern == RecurrencePattern.weekly && _selectedWeekdays.isNotEmpty
          ? (_selectedWeekdays.toList()..sort())
          : null,
      dayOfMonth: _recurrencePattern == RecurrencePattern.monthly 
          ? _dayOfMonth 
          : null,
      startDate: _startDate,
      endDate: _endDate,
      nextScheduled: null, // Will be calculated
      autoAdjustForAge: _autoAdjustForAge,
    );
    
    // Calculate next scheduled time
    final reminderWithSchedule = reminder.copyWith(
      nextScheduled: reminder.calculateNextOccurrence(),
    );
    
    Navigator.of(context).pop(reminderWithSchedule);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reminder == null ? 'Add Reminder' : 'Edit Reminder'),
        backgroundColor: theme.colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveReminder,
            tooltip: 'Save',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Title field
            _buildSectionTitle('Basic Information'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                hintText: 'e.g., Feed Buddy, Walk Max',
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Add details about this reminder',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            
            // Pet selection
            if (_pets.isNotEmpty) ...[
              DropdownButtonFormField<int>(
                value: _selectedPetId,
                decoration: InputDecoration(
                  labelText: 'Link to Pet (optional)',
                  prefixIcon: const Icon(Icons.pets),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('No specific pet'),
                  ),
                  ..._pets.map((pet) => DropdownMenuItem(
                    value: pet.id,
                    child: Text(pet.name),
                  )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedPetId = value;
                  });
                },
              ),
              const SizedBox(height: 24),
            ],
            
            // Time selection
            _buildSectionTitle('Time'),
            const SizedBox(height: 12),
            ListTile(
              leading: Icon(Icons.access_time, color: theme.colorScheme.primary),
              title: const Text('Reminder Time'),
              subtitle: Text(_selectedTime.format(context)),
              trailing: const Icon(Icons.chevron_right),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              onTap: _pickTime,
            ),
            const SizedBox(height: 24),
            
            // Recurrence pattern
            _buildSectionTitle('Recurrence'),
            const SizedBox(height: 12),
            _buildRecurrenceSelector(),
            const SizedBox(height: 16),
            
            // Pattern-specific options
            if (_recurrencePattern == RecurrencePattern.custom)
              _buildCustomIntervalSelector(),
            if (_recurrencePattern == RecurrencePattern.weekly)
              _buildWeekdaySelector(),
            if (_recurrencePattern == RecurrencePattern.monthly)
              _buildMonthlyDaySelector(),
            
            const SizedBox(height: 24),
            
            // Advanced options
            _buildSectionTitle('Advanced Options'),
            const SizedBox(height: 12),
            
            // Start date
            ListTile(
              leading: Icon(Icons.calendar_today, color: theme.colorScheme.primary),
              title: const Text('Start Date (optional)'),
              subtitle: Text(_startDate != null 
                  ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                  : 'Start immediately'),
              trailing: _startDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _startDate = null),
                    )
                  : const Icon(Icons.chevron_right),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              onTap: () => _pickDate(true),
            ),
            const SizedBox(height: 12),
            
            // End date
            ListTile(
              leading: Icon(Icons.event, color: theme.colorScheme.primary),
              title: const Text('End Date (optional)'),
              subtitle: Text(_endDate != null 
                  ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                  : 'No end date'),
              trailing: _endDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _endDate = null),
                    )
                  : const Icon(Icons.chevron_right),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              onTap: () => _pickDate(false),
            ),
            const SizedBox(height: 12),
            
            // Auto-adjust for age
            SwitchListTile(
              value: _autoAdjustForAge,
              onChanged: _selectedPetId != null 
                  ? (value) => setState(() => _autoAdjustForAge = value)
                  : null,
              title: const Text('Auto-adjust for pet age'),
              subtitle: const Text('Automatically adjust reminder frequency as pet grows'),
              secondary: Icon(
                Icons.timeline,
                color: _selectedPetId != null 
                    ? theme.colorScheme.primary 
                    : Colors.grey,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildRecurrenceSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildRecurrenceChip('One-time', RecurrencePattern.none, Icons.looks_one),
        _buildRecurrenceChip('Daily', RecurrencePattern.daily, Icons.today),
        _buildRecurrenceChip('Weekly', RecurrencePattern.weekly, Icons.view_week),
        _buildRecurrenceChip('Monthly', RecurrencePattern.monthly, Icons.calendar_month),
        _buildRecurrenceChip('Custom', RecurrencePattern.custom, Icons.tune),
      ],
    );
  }

  Widget _buildRecurrenceChip(String label, RecurrencePattern pattern, IconData icon) {
    final isSelected = _recurrencePattern == pattern;
    final theme = Theme.of(context);
    
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _recurrencePattern = pattern;
        });
      },
      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
      checkmarkColor: theme.colorScheme.primary,
    );
  }

  Widget _buildCustomIntervalSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Repeat every:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Interval',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    controller: TextEditingController(text: _customIntervalValue.toString()),
                    onChanged: (value) {
                      final parsed = int.tryParse(value);
                      if (parsed != null && parsed > 0) {
                        setState(() {
                          _customIntervalValue = parsed;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<IntervalUnit>(
                    value: _customIntervalUnit,
                    decoration: InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: IntervalUnit.days,
                        child: Text('Day(s)'),
                      ),
                      DropdownMenuItem(
                        value: IntervalUnit.weeks,
                        child: Text('Week(s)'),
                      ),
                      DropdownMenuItem(
                        value: IntervalUnit.months,
                        child: Text('Month(s)'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _customIntervalUnit = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdaySelector() {
    const weekdays = [
      ('Mon', 1),
      ('Tue', 2),
      ('Wed', 3),
      ('Thu', 4),
      ('Fri', 5),
      ('Sat', 6),
      ('Sun', 7),
    ];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Repeat on:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: weekdays.map((day) {
                final isSelected = _selectedWeekdays.contains(day.$2);
                return FilterChip(
                  label: Text(day.$1),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedWeekdays.add(day.$2);
                      } else {
                        _selectedWeekdays.remove(day.$2);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyDaySelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Day of month:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Day (1-31)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                helperText: 'For months with fewer days, the last day will be used',
              ),
              controller: TextEditingController(text: _dayOfMonth.toString()),
              onChanged: (value) {
                final parsed = int.tryParse(value);
                if (parsed != null && parsed >= 1 && parsed <= 31) {
                  setState(() {
                    _dayOfMonth = parsed;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
