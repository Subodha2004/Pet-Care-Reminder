import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/pet.dart';
import '../../models/pet_health.dart';
import '../../database/pet_health_db_helper.dart';

class VetContactsTab extends StatefulWidget {
  final Pet pet;
  final VoidCallback onUpdate;

  const VetContactsTab({
    super.key,
    required this.pet,
    required this.onUpdate,
  });

  @override
  State<VetContactsTab> createState() => _VetContactsTabState();
}

class _VetContactsTabState extends State<VetContactsTab> {
  List<VetContact> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    final contacts = await PetHealthDBHelper.getVetContacts(widget.pet.id!);
    setState(() {
      _contacts = contacts;
      _isLoading = false;
    });
  }

  void _showAddEditDialog({VetContact? contact}) {
    showDialog(
      context: context,
      builder: (context) => _VetContactDialog(
        pet: widget.pet,
        contact: contact,
        onSaved: () {
          _loadContacts();
          widget.onUpdate();
        },
      ),
    );
  }

  Future<void> _deleteContact(VetContact contact) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vet Contact'),
        content: Text('Are you sure you want to delete ${contact.clinicName}?'),
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
      await PetHealthDBHelper.deleteVetContact(contact.id!);
      _loadContacts();
      widget.onUpdate();
    }
  }

  Future<void> _makePhoneCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone dialer')),
        );
      }
    }
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch email client')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_contacts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_hospital_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Vet Contacts',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add veterinarian contact information',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddEditDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add Vet Contact'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _contacts.length,
      itemBuilder: (context, index) {
        final contact = _contacts[index];
        return _buildContactCard(contact);
      },
    );
  }

  Widget _buildContactCard(VetContact contact) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showAddEditDialog(contact: contact),
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
                      color: contact.isPrimary
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.local_hospital,
                      color: contact.isPrimary ? Colors.blue : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contact.clinicName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (contact.isPrimary) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Primary Vet',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
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
                        _showAddEditDialog(contact: contact);
                      } else if (value == 'delete') {
                        _deleteContact(contact);
                      }
                    },
                  ),
                ],
              ),
              const Divider(height: 24),
              if (contact.veterinarianName != null) ...[
                _buildInfoRow(Icons.person, 'Veterinarian', contact.veterinarianName!),
                const SizedBox(height: 8),
              ],
              if (contact.specialization != null) ...[
                _buildInfoRow(Icons.medical_services, 'Specialization', contact.specialization!),
                const SizedBox(height: 8),
              ],
              if (contact.phone != null) ...[
                InkWell(
                  onTap: () => _makePhoneCall(contact.phone!),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.phone, size: 16, color: Colors.green[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            contact.phone!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green[700],
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, size: 12, color: Colors.green[700]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (contact.email != null) ...[
                InkWell(
                  onTap: () => _sendEmail(contact.email!),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.email, size: 16, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            contact.email!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue[700],
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, size: 12, color: Colors.blue[700]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              if (contact.address != null) ...[
                _buildInfoRow(Icons.location_on, 'Address', contact.address!),
              ],
              if (contact.notes != null && contact.notes!.isNotEmpty) ...[
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
                          contact.notes!,
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
}

class _VetContactDialog extends StatefulWidget {
  final Pet pet;
  final VetContact? contact;
  final VoidCallback onSaved;

  const _VetContactDialog({
    required this.pet,
    this.contact,
    required this.onSaved,
  });

  @override
  State<_VetContactDialog> createState() => _VetContactDialogState();
}

class _VetContactDialogState extends State<_VetContactDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _clinicNameController;
  late TextEditingController _vetNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _specializationController;
  late TextEditingController _notesController;
  late bool _isPrimary;

  @override
  void initState() {
    super.initState();
    _clinicNameController = TextEditingController(text: widget.contact?.clinicName ?? '');
    _vetNameController = TextEditingController(text: widget.contact?.veterinarianName ?? '');
    _phoneController = TextEditingController(text: widget.contact?.phone ?? '');
    _emailController = TextEditingController(text: widget.contact?.email ?? '');
    _addressController = TextEditingController(text: widget.contact?.address ?? '');
    _specializationController = TextEditingController(text: widget.contact?.specialization ?? '');
    _notesController = TextEditingController(text: widget.contact?.notes ?? '');
    _isPrimary = widget.contact?.isPrimary ?? false;
  }

  @override
  void dispose() {
    _clinicNameController.dispose();
    _vetNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _specializationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final contact = VetContact(
      id: widget.contact?.id,
      petId: widget.pet.id!,
      clinicName: _clinicNameController.text,
      veterinarianName: _vetNameController.text.isEmpty ? null : _vetNameController.text,
      phone: _phoneController.text.isEmpty ? null : _phoneController.text,
      email: _emailController.text.isEmpty ? null : _emailController.text,
      address: _addressController.text.isEmpty ? null : _addressController.text,
      specialization: _specializationController.text.isEmpty ? null : _specializationController.text,
      isPrimary: _isPrimary,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    if (widget.contact == null) {
      await PetHealthDBHelper.insertVetContact(contact);
    } else {
      await PetHealthDBHelper.updateVetContact(contact);
    }

    widget.onSaved();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.contact == null ? 'Add Vet Contact' : 'Edit Vet Contact'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _clinicNameController,
                decoration: const InputDecoration(
                  labelText: 'Clinic Name *',
                  prefixIcon: Icon(Icons.local_hospital),
                ),
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _vetNameController,
                decoration: const InputDecoration(
                  labelText: 'Veterinarian Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _specializationController,
                decoration: const InputDecoration(
                  labelText: 'Specialization',
                  prefixIcon: Icon(Icons.medical_services),
                  hintText: 'e.g., General, Surgery, Dental',
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Set as Primary Vet'),
                subtitle: const Text('This will be your main veterinarian'),
                value: _isPrimary,
                onChanged: (value) => setState(() => _isPrimary = value),
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
