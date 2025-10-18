import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/pet.dart';
import '../../models/pet_health.dart';
import '../../database/pet_health_db_helper.dart';

class MedicalRecordsTab extends StatefulWidget {
  final Pet pet;
  final VoidCallback onUpdate;

  const MedicalRecordsTab({
    super.key,
    required this.pet,
    required this.onUpdate,
  });

  @override
  State<MedicalRecordsTab> createState() => _MedicalRecordsTabState();
}

class _MedicalRecordsTabState extends State<MedicalRecordsTab> {
  List<MedicalRecord> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    final records = await PetHealthDBHelper.getMedicalRecords(widget.pet.id!);
    setState(() {
      _records = records;
      _isLoading = false;
    });
  }

  void _showAddEditDialog({MedicalRecord? record}) {
    showDialog(
      context: context,
      builder: (context) => _MedicalRecordDialog(
        pet: widget.pet,
        record: record,
        onSaved: () {
          _loadRecords();
          widget.onUpdate();
        },
      ),
    );
  }

  Future<void> _deleteRecord(MedicalRecord record) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medical Record'),
        content: const Text('Are you sure you want to delete this medical record?'),
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
      await PetHealthDBHelper.deleteMedicalRecord(record.id!);
      _loadRecords();
      widget.onUpdate();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medical_services_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Medical Records',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add medical records',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddEditDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add Medical Record'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _records.length,
      itemBuilder: (context, index) {
        final record = _records[index];
        return _buildRecordCard(record);
      },
    );
  }

  Widget _buildRecordCard(MedicalRecord record) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    Color typeColor = Colors.blue;
    IconData typeIcon = Icons.medical_services;

    switch (record.visitType.toLowerCase()) {
      case 'emergency':
        typeColor = Colors.red;
        typeIcon = Icons.emergency;
        break;
      case 'checkup':
        typeColor = Colors.green;
        typeIcon = Icons.check_circle;
        break;
      case 'surgery':
        typeColor = Colors.orange;
        typeIcon = Icons.healing;
        break;
      case 'dental':
        typeColor = Colors.purple;
        typeIcon = Icons.sanitizer;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showAddEditDialog(record: record),
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
                          record.visitType,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat.format(record.visitDate),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
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
                        _showAddEditDialog(record: record);
                      } else if (value == 'delete') {
                        _deleteRecord(record);
                      }
                    },
                  ),
                ],
              ),
              if (record.diagnosis != null || record.treatment != null) ...[
                const Divider(height: 24),
                if (record.diagnosis != null) ...[
                  _buildInfoSection('Diagnosis', record.diagnosis!, Icons.description),
                  const SizedBox(height: 8),
                ],
                if (record.treatment != null) ...[
                  _buildInfoSection('Treatment', record.treatment!, Icons.healing),
                  const SizedBox(height: 8),
                ],
              ],
              if (record.prescription != null) ...[
                _buildInfoSection('Prescription', record.prescription!, Icons.medication),
                const SizedBox(height: 8),
              ],
              if (record.veterinarian != null || record.clinic != null) ...[
                const Divider(height: 16),
                if (record.veterinarian != null)
                  _buildInfoRow(Icons.person, 'Veterinarian', record.veterinarian!),
                if (record.clinic != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.local_hospital, 'Clinic', record.clinic!),
                ],
              ],
              if (record.cost != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(Icons.attach_money, 'Cost', '\$${record.cost!.toStringAsFixed(2)}'),
              ],
              if (record.notes != null && record.notes!.isNotEmpty) ...[
                const Divider(height: 16),
                _buildInfoSection('Notes', record.notes!, Icons.notes),
              ],
              if (record.documentPath != null) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Document viewing coming soon')),
                    );
                  },
                  icon: const Icon(Icons.attach_file),
                  label: const Text('View Document'),
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

class _MedicalRecordDialog extends StatefulWidget {
  final Pet pet;
  final MedicalRecord? record;
  final VoidCallback onSaved;

  const _MedicalRecordDialog({
    required this.pet,
    this.record,
    required this.onSaved,
  });

  @override
  State<_MedicalRecordDialog> createState() => _MedicalRecordDialogState();
}

class _MedicalRecordDialogState extends State<_MedicalRecordDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _visitTypeController;
  late TextEditingController _diagnosisController;
  late TextEditingController _treatmentController;
  late TextEditingController _prescriptionController;
  late TextEditingController _costController;
  late TextEditingController _vetController;
  late TextEditingController _clinicController;
  late TextEditingController _notesController;
  late DateTime _visitDate;
  String? _documentPath;

  final List<String> _visitTypes = [
    'Checkup',
    'Emergency',
    'Surgery',
    'Dental',
    'Vaccination',
    'Follow-up',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _visitTypeController = TextEditingController(text: widget.record?.visitType ?? '');
    _diagnosisController = TextEditingController(text: widget.record?.diagnosis ?? '');
    _treatmentController = TextEditingController(text: widget.record?.treatment ?? '');
    _prescriptionController = TextEditingController(text: widget.record?.prescription ?? '');
    _costController = TextEditingController(
      text: widget.record?.cost?.toString() ?? '',
    );
    _vetController = TextEditingController(text: widget.record?.veterinarian ?? '');
    _clinicController = TextEditingController(text: widget.record?.clinic ?? '');
    _notesController = TextEditingController(text: widget.record?.notes ?? '');
    _visitDate = widget.record?.visitDate ?? DateTime.now();
    _documentPath = widget.record?.documentPath;
  }

  @override
  void dispose() {
    _visitTypeController.dispose();
    _diagnosisController.dispose();
    _treatmentController.dispose();
    _prescriptionController.dispose();
    _costController.dispose();
    _vetController.dispose();
    _clinicController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final record = MedicalRecord(
      id: widget.record?.id,
      petId: widget.pet.id!,
      visitDate: _visitDate,
      visitType: _visitTypeController.text,
      diagnosis: _diagnosisController.text.isEmpty ? null : _diagnosisController.text,
      treatment: _treatmentController.text.isEmpty ? null : _treatmentController.text,
      prescription: _prescriptionController.text.isEmpty ? null : _prescriptionController.text,
      cost: _costController.text.isEmpty ? null : double.tryParse(_costController.text),
      veterinarian: _vetController.text.isEmpty ? null : _vetController.text,
      clinic: _clinicController.text.isEmpty ? null : _clinicController.text,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      documentPath: _documentPath,
    );

    if (widget.record == null) {
      await PetHealthDBHelper.insertMedicalRecord(record);
    } else {
      await PetHealthDBHelper.updateMedicalRecord(record);
    }

    widget.onSaved();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.record == null ? 'Add Medical Record' : 'Edit Medical Record'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _visitTypeController.text.isEmpty ? null : _visitTypeController.text,
                decoration: const InputDecoration(
                  labelText: 'Visit Type *',
                  prefixIcon: Icon(Icons.medical_services),
                ),
                items: _visitTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  if (value != null) _visitTypeController.text = value;
                },
                validator: (value) => value == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event),
                title: const Text('Visit Date'),
                subtitle: Text(DateFormat('MMM dd, yyyy').format(_visitDate)),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _visitDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) setState(() => _visitDate = date);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _diagnosisController,
                decoration: const InputDecoration(
                  labelText: 'Diagnosis',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _treatmentController,
                decoration: const InputDecoration(
                  labelText: 'Treatment',
                  prefixIcon: Icon(Icons.healing),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _prescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Prescription',
                  prefixIcon: Icon(Icons.medication),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _vetController,
                decoration: const InputDecoration(
                  labelText: 'Veterinarian',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _clinicController,
                decoration: const InputDecoration(
                  labelText: 'Clinic',
                  prefixIcon: Icon(Icons.local_hospital),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _costController,
                decoration: const InputDecoration(
                  labelText: 'Cost',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
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
