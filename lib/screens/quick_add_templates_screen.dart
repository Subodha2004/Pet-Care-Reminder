import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../models/reminder_category.dart';

class QuickAddTemplatesScreen extends StatefulWidget {
  const QuickAddTemplatesScreen({super.key});

  @override
  State<QuickAddTemplatesScreen> createState() => _QuickAddTemplatesScreenState();
}

class _QuickAddTemplatesScreenState extends State<QuickAddTemplatesScreen> {
  ReminderCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Add Templates'),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Column(
        children: [
          // Category selector
          Container(
            padding: const EdgeInsets.all(20),
            color: isDark ? theme.cardColor : Colors.grey.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose a Category',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: ReminderCategory.values.map((category) {
                    final isSelected = _selectedCategory == category;
                    return _buildCategoryChip(category, isSelected, theme);
                  }).toList(),
                ),
              ],
            ),
          ),

          // Templates list
          Expanded(
            child: _selectedCategory == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.touch_app,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Select a category to see templates',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _selectedCategory!.quickTemplates.length,
                    itemBuilder: (context, index) {
                      final template = _selectedCategory!.quickTemplates[index];
                      return _buildTemplateCard(
                        context,
                        template,
                        _selectedCategory!,
                        theme,
                        isDark,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    ReminderCategory category,
    bool isSelected,
    ThemeData theme,
  ) {
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            category.icon,
            size: 18,
            color: isSelected ? Colors.white : category.color,
          ),
          const SizedBox(width: 6),
          Text(category.displayName),
        ],
      ),
      onSelected: (selected) {
        setState(() {
          _selectedCategory = selected ? category : null;
        });
      },
      backgroundColor: category.color.withOpacity(0.1),
      selectedColor: category.color,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : category.color,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildTemplateCard(
    BuildContext context,
    QuickTemplate template,
    ReminderCategory category,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: category.gradientColors,
        ),
        boxShadow: [
          BoxShadow(
            color: category.color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _useTemplate(context, template, category),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    category.icon,
                    color: category.color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        template.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: category.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            template.defaultTime,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: category.color,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.repeat,
                            size: 14,
                            color: category.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getRecurrenceText(template),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: category.color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: category.color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getRecurrenceText(QuickTemplate template) {
    switch (template.recurrencePattern) {
      case 0:
        return 'Daily';
      case 1:
        if (template.weekdays != null) {
          return '${template.weekdays!.length}x/week';
        }
        return 'Weekly';
      case 2:
        return 'Monthly';
      case 3:
        if (template.customIntervalValue != null) {
          return 'Every ${template.customIntervalValue}';
        }
        return 'Custom';
      default:
        return 'One-time';
    }
  }

  void _useTemplate(
    BuildContext context,
    QuickTemplate template,
    ReminderCategory category,
  ) {
    final timeParts = template.defaultTime.split(':');
    
    final reminder = Reminder(
      id: DateTime.now().millisecondsSinceEpoch,
      title: template.title,
      description: template.description,
      time: template.defaultTime,
      category: category,
      isActive: true,
      recurrencePattern: RecurrencePattern.values[template.recurrencePattern],
      weekdays: template.weekdays,
      dayOfMonth: template.dayOfMonth,
      customIntervalValue: template.customIntervalValue,
      customIntervalUnit: template.customIntervalUnit != null
          ? IntervalUnit.values[template.customIntervalUnit!]
          : null,
    );

    // Calculate next scheduled time
    final reminderWithSchedule = reminder.copyWith(
      nextScheduled: reminder.calculateNextOccurrence(),
    );

    Navigator.of(context).pop(reminderWithSchedule);
  }
}
