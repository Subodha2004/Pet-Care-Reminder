import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/pet.dart';
import '../../models/pet_health.dart';
import '../../database/pet_health_db_helper.dart';

class MedicationsTab extends StatefulWidget {
  final Pet pet;
  final VoidCallback onUpdate;

  const MedicationsTab({
    super.key,
    required this.pet,
    required this.onUpdate,
  });

  @override
  State<MedicationsTab> createState() => _MedicationsTabState();
}

class _MedicationsTabState extends State<MedicationsTab> {
  List<Medication> _medications = [];
  bool _isLoading = true;
  bool _showActiveOnly = true;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    setState(() => _isLoading = true);
    final medications = _showActiveOnly
        ? await PetHealthDBHelper.getActiveMedications(widget.pet.id!)
        : await PetHealthDBHelper.getMedications(widget.pet.id!);
    setState(() {
      _medications = medications;
      _isLoading = false;
    });
  }

  void _showAddEditDialog({Medication? medication}) {
    showDialog(
      context: context,
      builder: (context) => _MedicationDialog(
        pet: widget.pet,
        medication: medication,
        onSaved: () {
          _loadMedications();
          widget.onUpdate();
        },
      ),
    );
  }

  Future<void> _deleteMedication(Medication medication) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medication'),
        content: Text('Are you sure you want to delete ${medication.medicationName}?'),
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
      await PetHealthDBHelper.deleteMedication(medication.id!);
      _loadMedications();
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
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: true,
                      label: Text('Active'),
                      icon: Icon(Icons.medication),
                    ),
                    ButtonSegment(
                      value: false,
                      label: Text('All'),
                      icon: Icon(Icons.list),
                    ),
                  ],
                  selected: {_showActiveOnly},
                  onSelectionChanged: (Set<bool> newSelection) {
                    setState(() {
                      _showActiveOnly = newSelection.first;
                      _loadMedications();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _buildMedicationsList(),
        ),
      ],
    );
  }

  Widget _buildMedicationsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_medications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medication_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _showActiveOnly ? 'No Active Medications' : 'No Medications',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add medications',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddEditDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add Medication'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _medications.length,
      itemBuilder: (context, index) {
        final medication = _medications[index];
        return _buildMedicationCard(medication);
      },
    );
  }

  Widget _buildMedicationCard(Medication medication) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final isExpired = medication.isExpired;
    final isActive = !isExpired && (medication.endDate == null || DateTime.now().isBefore(medication.endDate!));

    Color statusColor = isActive ? Colors.green : (isExpired ? Colors.red : Colors.grey);
    IconData statusIcon = isActive ? Icons.check_circle : (isExpired ? Icons.error : Icons.info);
    String statusText = isActive ? 'Active' : (isExpired ? 'Expired' : 'Completed');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showAddEditDialog(medication: medication),
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
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.medication, color: statusColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medication.medicationName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(statusIcon, size: 16, color: statusColor),
                            const SizedBox(width: 4),
                            Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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
                        _showAddEditDialog(medication: medication);
                      } else if (value == 'delete') {
                        _deleteMedication(medication);
                      }
                    },
                  ),
                ],
              ),
              const Divider(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.medical_information, size: 18, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text(
                          'Dosage Information',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildDosageRow('Dosage', medication.dosage ?? 'Not specified'),
                    const SizedBox(height: 4),
                    _buildDosageRow('Frequency', medication.frequency ?? 'Not specified'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.event, 'Start Date', dateFormat.format(medication.startDate)),
              if (medication.endDate != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(Icons.event_available, 'End Date', dateFormat.format(medication.endDate!)),
              ],
              if (medication.prescribedBy != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(Icons.person, 'Prescribed By', medication.prescribedBy!),
              ],
              if (medication.notes != null && medication.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.notes, size: 16, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          medication.notes!,
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

  Widget _buildDosageRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
}

class _MedicationDialog extends StatefulWidget {
  final Pet pet;
  final Medication? medication;
  final VoidCallback onSaved;

  const _MedicationDialog({
    required this.pet,
    this.medication,
    required this.onSaved,
  });

  @override
  State<_MedicationDialog> createState() => _MedicationDialogState();
}

class _MedicationDialogState extends State<_MedicationDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _frequencyController;

  late TextEditingController _prescribedByController;
  late TextEditingController _notesController;
  late DateTime _startDate;
  DateTime? _endDate;

  final List<String> _frequencyOptions = [
    'Once daily',
    'Twice daily',
    'Three times daily',
    'Every 8 hours',
    'Every 12 hours',
    'As needed',
    'Weekly',
  ];



  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medication?.medicationName ?? '');
    _dosageController = TextEditingController(text: widget.medication?.dosage ?? '');
    _frequencyController = TextEditingController(text: widget.medication?.frequency ?? '');

    _prescribedByController = TextEditingController(text: widget.medication?.prescribedBy ?? '');
    _notesController = TextEditingController(text: widget.medication?.notes ?? '');
    _startDate = widget.medication?.startDate ?? DateTime.now();
    _endDate = widget.medication?.endDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();

    _prescribedByController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final medication = Medication(
      id: widget.medication?.id,
      petId: widget.pet.id!,
      medicationName: _nameController.text,
      dosage: _dosageController.text,
      frequency: _frequencyController.text,
      startDate: _startDate,
      endDate: _endDate,

      prescribedBy: _prescribedByController.text.isEmpty ? null : _prescribedByController.text,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    if (widget.medication == null) {
      await PetHealthDBHelper.insertMedication(medication);
    } else {
      await PetHealthDBHelper.updateMedication(medication);
    }

    widget.onSaved();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.medication == null ? 'Add Medication' : 'Edit Medication'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Medication Name *',
                  prefixIcon: Icon(Icons.medication),
                ),
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosage *',
                  prefixIcon: Icon(Icons.local_pharmacy),
                  hintText: 'e.g., 10mg, 1 tablet',
                ),
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Autocomplete<String>(
                initialValue: TextEditingValue(text: _frequencyController.text),
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return _frequencyOptions;
                  }
                  return _frequencyOptions.where((option) {
                    return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                  });
                },
                onSelected: (value) => _frequencyController.text = value,
                fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Frequency *',
                      prefixIcon: Icon(Icons.schedule),
                    ),
                    onChanged: (value) => _frequencyController.text = value,
                    validator: (value) => value?.isEmpty == true ? 'Required' : null,
                  );
                },
              ),

              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event),
                title: const Text('Start Date'),
                subtitle: Text(DateFormat('MMM dd, yyyy').format(_startDate)),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) setState(() => _startDate = date);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_available),
                title: const Text('End Date (Optional)'),
                subtitle: Text(_endDate == null
                    ? 'Not set'
                    : DateFormat('MMM dd, yyyy').format(_endDate!)),
                trailing: _endDate != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _endDate = null),
                      )
                    : null,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _endDate ?? _startDate.add(const Duration(days: 30)),
                    firstDate: _startDate,
                    lastDate: DateTime(2100),
                  );
                  if (date != null) setState(() => _endDate = date);
                },
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _prescribedByController,
                decoration: const InputDecoration(
                  labelText: 'Prescribed By',
                  prefixIcon: Icon(Icons.person),
                ),
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
