import 'package:flutter/material.dart';
import '../models/reminder_template.dart';
import '../models/reminder.dart';
import '../models/reminder_category.dart';
import '../database/template_db_helper.dart';

/// Screen for managing reminder templates
class TemplateManagementScreen extends StatefulWidget {
  const TemplateManagementScreen({super.key});

  @override
  State<TemplateManagementScreen> createState() => _TemplateManagementScreenState();
}

class _TemplateManagementScreenState extends State<TemplateManagementScreen> {
  List<ReminderTemplate> _templates = [];
  bool _loading = true;
  String _filterCategory = 'all';

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    setState(() => _loading = true);
    try {
      final templates = await TemplateDBHelper.getTemplates();
      if (mounted) {
        setState(() {
          _templates = templates;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading templates: $e')),
        );
      }
    }
  }

  List<ReminderTemplate> get _filteredTemplates {
    if (_filterCategory == 'all') return _templates;
    return _templates
        .where((t) => t.category.displayName.toLowerCase() == _filterCategory)
        .toList();
  }

  Future<void> _deleteTemplate(ReminderTemplate template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text('Are you sure you want to delete "${template.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && template.id != null) {
      try {
        await TemplateDBHelper.deleteTemplate(template.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Template deleted')),
          );
          _loadTemplates();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting template: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder Templates'),
        backgroundColor: theme.colorScheme.primary,
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.restart_alt),
                    SizedBox(width: 8),
                    Text('Reset to Defaults'),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'reset') {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Reset Templates'),
                    content: const Text(
                      'This will delete all custom templates and restore the default ones. Continue?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await TemplateDBHelper.resetToDefaults();
                  _loadTemplates();
                }
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: _buildFilterBar(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _filteredTemplates.isEmpty
              ? _buildEmptyState()
              : _buildTemplateList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to create template screen
          // For now, just show a message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Create custom template feature coming soon!'),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Template'),
      ),
    );
  }

  Widget _buildFilterBar() {
    final categories = [
      'all',
      'feeding',
      'walking',
      'medication',
      'grooming',
      'vet visit',
      'play time',
      'training'
    ];

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
              label: Text(
                category == 'all'
                    ? 'All'
                    : category
                        .split(' ')
                        .map((word) =>
                            '${word[0].toUpperCase()}${word.substring(1)}')
                        .join(' '),
              ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No templates found',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () async {
              await TemplateDBHelper.resetToDefaults();
              _loadTemplates();
            },
            child: const Text('Load Default Templates'),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredTemplates.length,
      itemBuilder: (context, index) {
        final template = _filteredTemplates[index];
        return _buildTemplateCard(template);
      },
    );
  }

  Widget _buildTemplateCard(ReminderTemplate template) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: template.category.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            template.category.icon,
            color: template.category.color,
          ),
        ),
        title: Text(
          template.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(template.displayDescription),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Title', template.title),
                if (template.description.isNotEmpty)
                  _buildDetailRow('Description', template.description),
                _buildDetailRow('Time', template.time),
                _buildDetailRow('Category', template.category.displayName),
                _buildDetailRow(
                  'Recurrence',
                  template.recurrencePattern == RecurrencePattern.none
                      ? 'One-time'
                      : template.recurrencePattern == RecurrencePattern.daily
                          ? 'Daily'
                          : template.recurrencePattern == RecurrencePattern.weekly
                              ? 'Weekly'
                              : template.recurrencePattern == RecurrencePattern.monthly
                                  ? 'Monthly'
                                  : 'Custom',
                ),
                if (template.weekdays != null && template.weekdays!.isNotEmpty)
                  _buildDetailRow(
                    'Weekdays',
                    template.weekdays!
                        .map((d) => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d - 1])
                        .join(', '),
                  ),
                if (template.dayOfMonth != null)
                  _buildDetailRow('Day of Month', template.dayOfMonth.toString()),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!template.isGlobal)
                      TextButton.icon(
                        onPressed: () => _deleteTemplate(template),
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context, template);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Use Template'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
