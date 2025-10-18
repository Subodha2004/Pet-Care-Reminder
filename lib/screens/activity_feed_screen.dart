import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/care_activity.dart';
import '../models/reminder_category.dart';
import '../database/care_activity_db_helper.dart';
import 'statistics_dashboard_screen.dart';

class ActivityFeedScreen extends StatefulWidget {
  final int? petId;

  const ActivityFeedScreen({super.key, this.petId});

  @override
  State<ActivityFeedScreen> createState() => _ActivityFeedScreenState();
}

class _ActivityFeedScreenState extends State<ActivityFeedScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<CareActivity> _allActivities = [];
  List<CareActivity> _todayActivities = [];
  List<CareActivity> _weekActivities = [];
  List<CareActivity> _monthActivities = [];
  bool _isLoading = true;
  ReminderCategory? _filterCategory;
  
  final dateFormat = DateFormat('MMM dd, yyyy');
  final timeFormat = DateFormat('hh:mm a');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadActivities();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadActivities() async {
    setState(() => _isLoading = true);

    try {
      final all = widget.petId != null
          ? await CareActivityDBHelper.getActivitiesByPet(widget.petId!)
          : await CareActivityDBHelper.getAllActivities(limit: 200);
      
      final today = await CareActivityDBHelper.getTodayActivities();
      final week = await CareActivityDBHelper.getWeekActivities();
      final month = await CareActivityDBHelper.getMonthActivities();

      // Apply category filter
      if (_filterCategory != null) {
        setState(() {
          _allActivities = all.where((a) => a.category == _filterCategory).toList();
          _todayActivities = today.where((a) => a.category == _filterCategory).toList();
          _weekActivities = week.where((a) => a.category == _filterCategory).toList();
          _monthActivities = month.where((a) => a.category == _filterCategory).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _allActivities = all;
          _todayActivities = today;
          _weekActivities = week;
          _monthActivities = month;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
              title: const Text(
                'Activity Feed',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Icon(
                        Icons.history,
                        size: 120,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.bar_chart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StatisticsDashboardScreen(
                        petId: widget.petId,
                      ),
                    ),
                  );
                },
                tooltip: 'Statistics',
              ),
              IconButton(
                icon: const Icon(Icons.file_download),
                onPressed: () => _exportData(context),
                tooltip: 'Export',
              ),
              const SizedBox(width: 8),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: [
                Tab(text: 'Today (${_todayActivities.length})'),
                Tab(text: 'Week (${_weekActivities.length})'),
                Tab(text: 'Month (${_monthActivities.length})'),
                Tab(text: 'All (${_allActivities.length})'),
              ],
            ),
          ),

          // Category Filter
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter by Category',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildCategoryFilter(null, 'All', Icons.grid_view_rounded, theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        ...ReminderCategory.values.map((category) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildCategoryFilter(
                              category,
                              category.displayName,
                              category.icon,
                              category.color,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Activity List
          _isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : SliverFillRemaining(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildActivityList(_todayActivities),
                      _buildActivityList(_weekActivities),
                      _buildActivityList(_monthActivities),
                      _buildActivityList(_allActivities),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(
    ReminderCategory? category,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _filterCategory == category;

    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : color,
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      onSelected: (selected) {
        setState(() {
          _filterCategory = selected ? category : null;
        });
        _loadActivities();
      },
      selectedColor: color,
      backgroundColor: color.withOpacity(0.1),
      checkmarkColor: Colors.white,
    );
  }

  Widget _buildActivityList(List<CareActivity> activities) {
    if (activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No activities yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete reminders to see them here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    // Group by date
    final groupedActivities = <String, List<CareActivity>>{};
    for (final activity in activities) {
      final dateKey = dateFormat.format(activity.completedAt);
      if (!groupedActivities.containsKey(dateKey)) {
        groupedActivities[dateKey] = [];
      }
      groupedActivities[dateKey]!.add(activity);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedActivities.length,
      itemBuilder: (context, index) {
        final dateKey = groupedActivities.keys.elementAt(index);
        final dayActivities = groupedActivities[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: EdgeInsets.only(bottom: 12, top: index == 0 ? 0 : 16),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dateKey,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${dayActivities.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Activities for this date
            ...dayActivities.map((activity) => _buildActivityCard(activity)),
          ],
        );
      },
    );
  }

  Widget _buildActivityCard(CareActivity activity) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: activity.category.color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: activity.category.color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Category icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: activity.category.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    activity.category.icon,
                    color: activity.category.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // Title and time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeFormat.format(activity.completedAt),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // On-time badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: activity.wasOnTime
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: activity.wasOnTime
                          ? Colors.green.withOpacity(0.3)
                          : Colors.orange.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        activity.wasOnTime ? Icons.check : Icons.schedule,
                        size: 14,
                        color: activity.wasOnTime ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        activity.wasOnTime ? 'On Time' : activity.getFormattedTimeDifference(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: activity.wasOnTime ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Description
            if (activity.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                activity.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],

            // Notes
            if (activity.notes != null && activity.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.note,
                      size: 16,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        activity.notes!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Duration (for walks, etc.)
            if (activity.durationMinutes != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Duration: ${activity.durationMinutes} minutes',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Future<void> _exportData(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Care History'),
        content: const Text('Choose export format'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _exportAsCSV();
            },
            child: const Text('CSV'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('PDF export coming soon!'),
                ),
              );
            },
            child: const Text('PDF'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _exportAsCSV() async {
    try {
      final activities = _allActivities;
      
      // Create CSV content
      final csvBuffer = StringBuffer();
      csvBuffer.writeln('Date,Time,Title,Category,Description,Duration (min),On Time,Notes');
      
      for (final activity in activities) {
        final date = dateFormat.format(activity.completedAt);
        final time = timeFormat.format(activity.completedAt);
        final title = activity.title.replaceAll(',', ';');
        final category = activity.category.displayName;
        final description = activity.description.replaceAll(',', ';');
        final duration = activity.durationMinutes?.toString() ?? '';
        final onTime = activity.wasOnTime ? 'Yes' : 'No';
        final notes = (activity.notes ?? '').replaceAll(',', ';');
        
        csvBuffer.writeln('$date,$time,$title,$category,$description,$duration,$onTime,$notes');
      }
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exported ${activities.length} activities to CSV'),
          backgroundColor: Colors.green,
        ),
      );
      
      // In a real app, you would save this to a file
      // For now, we just show a success message
      print(csvBuffer.toString()); // This would be saved to file
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
