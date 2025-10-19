import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../database/db_helper.dart';

/// Widget for quick pet selection during reminder creation
class QuickPetSwitcher extends StatefulWidget {
  final int? selectedPetId;
  final Function(int? petId) onPetChanged;
  final bool allowMultiSelect;
  final Set<int>? selectedPetIds; // For bulk creation

  const QuickPetSwitcher({
    super.key,
    this.selectedPetId,
    required this.onPetChanged,
    this.allowMultiSelect = false,
    this.selectedPetIds,
  });

  @override
  State<QuickPetSwitcher> createState() => _QuickPetSwitcherState();
}

class _QuickPetSwitcherState extends State<QuickPetSwitcher> {
  List<Pet> _pets = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    try {
      final pets = await DBHelper.getPets();
      if (mounted) {
        setState(() {
          _pets = pets;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 60,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_pets.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.grey.shade600),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No pets available. Add a pet first!',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.pets, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              widget.allowMultiSelect ? 'Select Pets (Bulk Create)' : 'Select Pet',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _pets.length + 1, // +1 for "No specific pet" option
            itemBuilder: (context, index) {
              if (index == 0) {
                // "No specific pet" option
                final isSelected = widget.selectedPetId == null && 
                                 (widget.selectedPetIds?.isEmpty ?? true);
                return _buildPetChip(
                  null,
                  'All Pets',
                  Icons.pets,
                  isSelected,
                );
              }
              
              final pet = _pets[index - 1];
              final isSelected = widget.allowMultiSelect
                  ? widget.selectedPetIds?.contains(pet.id) ?? false
                  : widget.selectedPetId == pet.id;
              
              return _buildPetChip(
                pet.id,
                pet.name,
                Icons.pets,
                isSelected,
                pet: pet,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPetChip(
    int? petId,
    String name,
    IconData icon,
    bool isSelected, {
    Pet? pet,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? Colors.white : theme.colorScheme.primary,
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (pet?.group != null && pet!.group!.isNotEmpty)
              Text(
                pet.group!,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? Colors.white70 : Colors.grey.shade600,
                ),
              ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        selectedColor: theme.colorScheme.primary,
        checkmarkColor: Colors.white,
        onSelected: (selected) {
          widget.onPetChanged(selected ? petId : null);
        },
        showCheckmark: true,
      ),
    );
  }
}

/// Dialog for bulk reminder creation across multiple pets
class BulkReminderDialog extends StatefulWidget {
  const BulkReminderDialog({super.key});

  @override
  State<BulkReminderDialog> createState() => _BulkReminderDialogState();
}

class _BulkReminderDialogState extends State<BulkReminderDialog> {
  List<Pet> _pets = [];
  Set<int> _selectedPetIds = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    try {
      final pets = await DBHelper.getPets();
      if (mounted) {
        setState(() {
          _pets = pets;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Bulk Create Reminder'),
      content: SizedBox(
        width: double.maxFinite,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _pets.isEmpty
                ? const Text('No pets available')
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select pets for this reminder:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 16),
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _pets.length,
                          itemBuilder: (context, index) {
                            final pet = _pets[index];
                            final isSelected = _selectedPetIds.contains(pet.id);
                            
                            return CheckboxListTile(
                              value: isSelected,
                              onChanged: (checked) {
                                setState(() {
                                  if (checked == true) {
                                    _selectedPetIds.add(pet.id!);
                                  } else {
                                    _selectedPetIds.remove(pet.id);
                                  }
                                });
                              },
                              title: Text(pet.name),
                              subtitle: pet.group != null && pet.group!.isNotEmpty
                                  ? Text(pet.group!)
                                  : null,
                              secondary: const Icon(Icons.pets),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                if (_selectedPetIds.length == _pets.length) {
                                  _selectedPetIds.clear();
                                } else {
                                  _selectedPetIds = _pets
                                      .where((p) => p.id != null)
                                      .map((p) => p.id!)
                                      .toSet();
                                }
                              });
                            },
                            child: Text(
                              _selectedPetIds.length == _pets.length
                                  ? 'Deselect All'
                                  : 'Select All',
                            ),
                          ),
                          Text(
                            '${_selectedPetIds.length} selected',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedPetIds.isEmpty
              ? null
              : () => Navigator.of(context).pop(_selectedPetIds),
          child: const Text('Continue'),
        ),
      ],
    );
  }
}
