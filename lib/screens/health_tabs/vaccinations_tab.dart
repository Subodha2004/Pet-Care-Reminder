import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/pet.dart';
import '../../models/pet_health.dart';
import '../../database/pet_health_db_helper.dart';
import 'package:file_picker/file_picker.dart';

class VaccinationsTab extends StatefulWidget {
  final Pet pet;
  final VoidCallback onUpdate;

  const VaccinationsTab({
    super.key,
    required this.pet,
    required this.onUpdate,
  });

  @override
  State<VaccinationsTab> createState() => _VaccinationsTabState();
}

class _VaccinationsTabState extends State<VaccinationsTab> {
  List<Vaccination> _vaccinations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVaccinations();
  }

  Future<void> _loadVaccinations() async {
    setState(() => _isLoading = true);
    final vaccinations = await PetHealthDBHelper.getVaccinations(widget.pet.id!);
    setState(() {
      _vaccinations = vaccinations;
      _isLoading = false;
    });
  }

  void _showAddEditDialog({Vaccination? vaccination}) {
    showDialog(
      context: context,
      builder: (context) => _VaccinationDialog(
        pet: widget.pet,
        vaccination: vaccination,
        onSaved: () {
          _loadVaccinations();
          widget.onUpdate();
        },
      ),
    );
  }

  Future<void> _deleteVaccination(Vaccination vaccination) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vaccination'),
        content: Text('Are you sure you want to delete ${vaccination.vaccineName}?'),
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
      await PetHealthDBHelper.deleteVaccination(vaccination.id!);
      _loadVaccinations();
      widget.onUpdate();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_vaccinations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.vaccines_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Vaccination Records',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add vaccination records',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddEditDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add Vaccination'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _vaccinations.length,
      itemBuilder: (context, index) {
        final vaccination = _vaccinations[index];
        return _buildVaccinationCard(vaccination);
      },
    );
  }

  Widget _buildVaccinationCard(Vaccination vaccination) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final isOverdue = vaccination.isOverdue;
    final isDueSoon = vaccination.isDueSoon;

    Color statusColor = Colors.green;
    IconData statusIcon = Icons.check_circle;
    String statusText = 'Up to date';

    if (isOverdue) {
      statusColor = Colors.red;
      statusIcon = Icons.error;
      statusText = 'Overdue';
    } else if (isDueSoon) {
      statusColor = Colors.orange;
      statusIcon = Icons.warning;
      statusText = 'Due soon';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showAddEditDialog(vaccination: vaccination),
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
                    child: Icon(Icons.vaccines, color: statusColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vaccination.vaccineName,
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
                        _showAddEditDialog(vaccination: vaccination);
                      } else if (value == 'delete') {
                        _deleteVaccination(vaccination);
                      }
                    },
                  ),
                ],
              ),
              const Divider(height: 24),
              _buildInfoRow(Icons.event, 'Date Given', dateFormat.format(vaccination.dateGiven)),
              if (vaccination.nextDueDate != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.event_available,
                  'Next Due',
                  dateFormat.format(vaccination.nextDueDate!),
                ),
              ],
              if (vaccination.veterinarian != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(Icons.person, 'Veterinarian', vaccination.veterinarian!),
              ],
              if (vaccination.clinic != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(Icons.local_hospital, 'Clinic', vaccination.clinic!),
              ],
              if (vaccination.batchNumber != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(Icons.qr_code, 'Batch Number', vaccination.batchNumber!),
              ],
              if (vaccination.notes != null && vaccination.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildInfoRow(Icons.notes, 'Notes', vaccination.notes!),
              ],
              if (vaccination.certificatePath != null) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implement document viewing
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Document viewing coming soon')),
                    );
                  },
                  icon: const Icon(Icons.attach_file),
                  label: const Text('View Certificate'),
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
}

class _VaccinationDialog extends StatefulWidget {
  final Pet pet;
  final Vaccination? vaccination;
  final VoidCallback onSaved;

  const _VaccinationDialog({
    required this.pet,
    this.vaccination,
    required this.onSaved,
  });

  @override
  State<_VaccinationDialog> createState() => _VaccinationDialogState();
}

class _VaccinationDialogState extends State<_VaccinationDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _batchController;
  late TextEditingController _vetController;
  late TextEditingController _clinicController;
  late TextEditingController _notesController;
  late DateTime _dateGiven;
  DateTime? _nextDueDate;
  String? _certificatePath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.vaccination?.vaccineName ?? '');
    _batchController = TextEditingController(text: widget.vaccination?.batchNumber ?? '');
    _vetController = TextEditingController(text: widget.vaccination?.veterinarian ?? '');
    _clinicController = TextEditingController(text: widget.vaccination?.clinic ?? '');
    _notesController = TextEditingController(text: widget.vaccination?.notes ?? '');
    _dateGiven = widget.vaccination?.dateGiven ?? DateTime.now();
    _nextDueDate = widget.vaccination?.nextDueDate;
    _certificatePath = widget.vaccination?.certificatePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _batchController.dispose();
    _vetController.dispose();
    _clinicController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        _certificatePath = result.files.single.path;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final vaccination = Vaccination(
      id: widget.vaccination?.id,
      petId: widget.pet.id!,
      vaccineName: _nameController.text,
      dateGiven: _dateGiven,
      nextDueDate: _nextDueDate,
      batchNumber: _batchController.text.isEmpty ? null : _batchController.text,
      veterinarian: _vetController.text.isEmpty ? null : _vetController.text,
      clinic: _clinicController.text.isEmpty ? null : _clinicController.text,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      certificatePath: _certificatePath,
    );

    if (widget.vaccination == null) {
      await PetHealthDBHelper.insertVaccination(vaccination);
    } else {
      await PetHealthDBHelper.updateVaccination(vaccination);
    }

    widget.onSaved();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.vaccination == null ? 'Add Vaccination' : 'Edit Vaccination'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Vaccine Name *',
                  prefixIcon: Icon(Icons.vaccines),
                ),
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event),
                title: const Text('Date Given'),
                subtitle: Text(DateFormat('MMM dd, yyyy').format(_dateGiven)),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _dateGiven,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) setState(() => _dateGiven = date);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_available),
                title: const Text('Next Due Date (Optional)'),
                subtitle: Text(_nextDueDate == null
                    ? 'Not set'
                    : DateFormat('MMM dd, yyyy').format(_nextDueDate!)),
                trailing: _nextDueDate != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _nextDueDate = null),
                      )
                    : null,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _nextDueDate ?? DateTime.now().add(const Duration(days: 365)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) setState(() => _nextDueDate = date);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _batchController,
                decoration: const InputDecoration(
                  labelText: 'Batch Number',
                  prefixIcon: Icon(Icons.qr_code),
                ),
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
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _pickDocument,
                icon: const Icon(Icons.attach_file),
                label: Text(_certificatePath == null
                    ? 'Attach Certificate'
                    : 'Certificate Attached'),
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
