import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../models/reminder.dart';
import '../models/reminder_category.dart';
import '../database/reminder_db_helper.dart';

/// Screen to compare care schedules for multiple pets side-by-side
class PetComparisonScreen extends StatefulWidget {
  final List<Pet> pets;

  const PetComparisonScreen({super.key, required this.pets});

  @override
  State<PetComparisonScreen> createState() => _PetComparisonScreenState();
}

class _PetComparisonScreenState extends State<PetComparisonScreen> {
  Map<int, List<Reminder>> _petReminders = {};
  bool _loading = true;
  String _filterCategory = 'all';

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    setState(() => _loading = true);
    
    try {
      final reminders = <int, List<Reminder>>{};
      for (final pet in widget.pets) {
        if (pet.id != null) {
          final petReminders = await ReminderDBHelper.getRemindersByPet(pet.id!);
          reminders[pet.id!] = petReminders;
        }
      }
      
      if (mounted) {
        setState(() {
          _petReminders = reminders;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading reminders: $e')),
        );
      }
    }
  }

  List<Reminder> _getFilteredReminders(List<Reminder> reminders) {
    if (_filterCategory == 'all') return reminders;
    return reminders.where((r) => r.category.displayName.toLowerCase() == _filterCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Pets'),
        backgroundColor: theme.colorScheme.primary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: _buildFilterBar(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : widget.pets.isEmpty
              ? const Center(child: Text('No pets selected'))
              : _buildComparisonView(),
    );
  }

  Widget _buildFilterBar() {
    final categories = ['all', 'feeding', 'walking', 'medication', 'grooming', 'vet visit', 'play time', 'training'];
    
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _filterCategory == category;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category == 'all' ? 'All' : category.split(' ').map((word) => 
                '${word[0].toUpperCase()}${word.substring(1)}').join(' ')),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _filterCategory = selected ? category : 'all';
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildComparisonView() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.pets.map((pet) => _buildPetColumn(pet)).toList(),
      ),
    );
  }

  Widget _buildPetColumn(Pet pet) {
    final reminders = _petReminders[pet.id] ?? [];
    final filteredReminders = _getFilteredReminders(reminders);
    final theme = Theme.of(context);
    
    return Container(
      width: 280,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pet header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.7),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Column(
              children: [
                Text(
                  pet.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Age: ${pet.age} | ${filteredReminders.length} reminders',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
                if (pet.group != null && pet.group!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      pet.group!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Reminders list
          Expanded(
            child: filteredReminders.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'No ${_filterCategory == 'all' ? '' : _filterCategory} reminders',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(8),
                    itemCount: filteredReminders.length,
                    itemBuilder: (context, index) {
                      final reminder = filteredReminders[index];
                      return _buildReminderCard(reminder);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(Reminder reminder) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  reminder.category.icon,
                  size: 20,
                  color: reminder.category.color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    reminder.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  reminder.time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: reminder.category.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                reminder.recurrenceDescription,
                style: TextStyle(
                  fontSize: 11,
                  color: reminder.category.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (!reminder.isActive)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Inactive',
                  style: TextStyle(fontSize: 10, color: Colors.black54),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
