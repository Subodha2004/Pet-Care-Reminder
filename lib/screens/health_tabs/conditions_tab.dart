import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/pet.dart';
import '../../models/pet_health.dart';
import '../../database/pet_health_db_helper.dart';

class ConditionsTab extends StatefulWidget {
  final Pet pet;
  final VoidCallback onUpdate;

  const ConditionsTab({
    super.key,
    required this.pet,
    required this.onUpdate,
  });

  @override
  State<ConditionsTab> createState() => _ConditionsTabState();
}

class _ConditionsTabState extends State<ConditionsTab> {
  List<PetCondition> _conditions = [];
  bool _isLoading = true;
  String _filterType = 'All';

  @override
  void initState() {
    super.initState();
    _loadConditions();
  }

  Future<void> _loadConditions() async {
    setState(() => _isLoading = true);
    final conditions = _filterType == 'Allergy'
        ? await PetHealthDBHelper.getAllergies(widget.pet.id!)
        : await PetHealthDBHelper.getConditions(widget.pet.id!);
    setState(() {
      _conditions = _filterType == 'All' 
          ? conditions 
          : conditions.where((c) => c.conditionType == _filterType).toList();
      _isLoading = false;
    });
  }

  void _showAddEditDialog({PetCondition? condition}) {
    showDialog(
      context: context,
      builder: (context) => _ConditionDialog(
        pet: widget.pet,
        condition: condition,
        onSaved: () {
          _loadConditions();
          widget.onUpdate();
        },
      ),
    );
  }

  Future<void> _deleteCondition(PetCondition condition) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Condition'),
        content: Text('Are you sure you want to delete ${condition.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await PetHealthDBHelper.deleteCondition(condition.id!);
      _loadConditions();
      widget.onUpdate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'All',
                      label: Text('All'),
                      icon: Icon(Icons.list),
                    ),
                    ButtonSegment(
                      value: 'Allergy',
                      label: Text('Allergies'),
                      icon: Icon(Icons.warning),
                    ),
                    ButtonSegment(
                      value: 'Chronic',
                      label: Text('Chronic'),
                      icon: Icon(Icons.health_and_safety),
                    ),
                  ],
                  selected: {_filterType},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _filterType = newSelection.first;
                      _loadConditions();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _buildConditionsList(),
        ),
      ],
    );
  }

  Widget _buildConditionsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_conditions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.health_and_safety_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Conditions Recorded',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track allergies and chronic conditions',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddEditDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add Condition'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _conditions.length,
      itemBuilder: (context, index) {
        final condition = _conditions[index];
        return _buildConditionCard(condition);
      },
    );
  }

  Widget _buildConditionCard(PetCondition condition) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    Color typeColor = Colors.blue;
    IconData typeIcon = Icons.health_and_safety;
    
    if (condition.conditionType.toLowerCase() == 'allergy') {
      typeColor = Colors.orange;
      typeIcon = Icons.warning_amber;
    } else if (condition.conditionType.toLowerCase() == 'chronic') {
      typeColor = Colors.purple;
      typeIcon = Icons.favorite;
    }

    Color? severityColor;
    if (condition.severity != null) {
      switch (condition.severity!.toLowerCase()) {
        case 'mild':
          severityColor = Colors.green;
          break;
        case 'moderate':
          severityColor = Colors.orange;
          break;
        case 'severe':
          severityColor = Colors.red;
          break;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showAddEditDialog(condition: condition),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(typeIcon, color: typeColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          condition.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: typeColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                condition.conditionType,
                                style: TextStyle(
                                  color: typeColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (condition.severity != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: severityColor?.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  condition.severity!,
                                  style: TextStyle(
                                    color: severityColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showAddEditDialog(condition: condition);
                      } else if (value == 'delete') {
                        _deleteCondition(condition);
                      }
                    },
                  ),
                ],
              ),
              if (condition.treatment != null || condition.diagnosedDate != null) ...[
                const Divider(height: 24),
              ],
              if (condition.treatment != null) ...[
                _buildInfoSection('Treatment', condition.treatment!, Icons.medication),
                const SizedBox(height: 8),
              ],
              if (condition.diagnosedDate != null) ...[
                _buildInfoRow(Icons.event, 'Diagnosed', dateFormat.format(condition.diagnosedDate!)),
              ],
              if (condition.notes != null && condition.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.notes, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          condition.notes!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}

class _ConditionDialog extends StatefulWidget {
  final Pet pet;
  final PetCondition? condition;
  final VoidCallback onSaved;

  const _ConditionDialog({
    required this.pet,
    this.condition,
    required this.onSaved,
  });

  @override
  State<_ConditionDialog> createState() => _ConditionDialogState();
}

class _ConditionDialogState extends State<_ConditionDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _treatmentController;
  late TextEditingController _notesController;
  late String _selectedType;
  String? _selectedSeverity;
  DateTime? _diagnosedDate;

  final List<String> _conditionTypes = [
    'Allergy',
    'Chronic',
    'Hereditary',
    'Infectious',
    'Other',
  ];

  final List<String> _severityLevels = [
    'Mild',
    'Moderate',
    'Severe',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.condition?.name ?? '');
    _treatmentController = TextEditingController(text: widget.condition?.treatment ?? '');
    _notesController = TextEditingController(text: widget.condition?.notes ?? '');
    _selectedType = widget.condition?.conditionType ?? 'Allergy';
    _selectedSeverity = widget.condition?.severity;
    _diagnosedDate = widget.condition?.diagnosedDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _treatmentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final condition = PetCondition(
      id: widget.condition?.id,
      petId: widget.pet.id!,
      conditionType: _selectedType,
      name: _nameController.text,
      severity: _selectedSeverity,
      treatment: _treatmentController.text.isEmpty ? null : _treatmentController.text,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      diagnosedDate: _diagnosedDate,
    );

    if (widget.condition == null) {
      await PetHealthDBHelper.insertCondition(condition);
    } else {
      await PetHealthDBHelper.updateCondition(condition);
    }

    widget.onSaved();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.condition == null ? 'Add Condition' : 'Edit Condition'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Condition Type *',
                  prefixIcon: Icon(Icons.category),
                ),
                items: _conditionTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedType = value);
                },
                validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  prefixIcon: Icon(Icons.label),
                  hintText: 'e.g., Pollen allergy, Arthritis',
                ),
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSeverity,
                decoration: const InputDecoration(
                  labelText: 'Severity',
                  prefixIcon: Icon(Icons.priority_high),
                ),
                items: _severityLevels.map((severity) {
                  return DropdownMenuItem(value: severity, child: Text(severity));
                }).toList(),
                onChanged: (value) => setState(() => _selectedSeverity = value),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _treatmentController,
                decoration: const InputDecoration(
                  labelText: 'Treatment/Management',
                  prefixIcon: Icon(Icons.medication),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event),
                title: const Text('Diagnosed Date (Optional)'),
                subtitle: Text(_diagnosedDate == null
                    ? 'Not set'
                    : DateFormat('MMM dd, yyyy').format(_diagnosedDate!)),
                trailing: _diagnosedDate != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _diagnosedDate = null),
                      )
                    : null,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _diagnosedDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) setState(() => _diagnosedDate = date);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
