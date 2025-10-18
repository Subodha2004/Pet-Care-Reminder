import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/care_activity.dart';
import '../models/reminder_category.dart';
import '../database/care_activity_db_helper.dart';

class StatisticsDashboardScreen extends StatefulWidget {
  final int? petId;

  const StatisticsDashboardScreen({super.key, this.petId});

  @override
  State<StatisticsDashboardScreen> createState() =>
      _StatisticsDashboardScreenState();
}

class _StatisticsDashboardScreenState extends State<StatisticsDashboardScreen> {
  ActivityStatistics? _overallStats;
  Map<ReminderCategory, ActivityStatistics> _categoryStats = {};
  Map<ReminderCategory, int> _categoryBreakdown = {};
  List<Achievement> _achievements = [];
  bool _isLoading = true;
  String _selectedPeriod = '30 days';

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);

    try {
      // Get date range based on selected period
      final endDate = DateTime.now();
      DateTime startDate;
      
      switch (_selectedPeriod) {
        case '7 days':
          startDate = endDate.subtract(const Duration(days: 7));
          break;
        case '30 days':
          startDate = endDate.subtract(const Duration(days: 30));
          break;
        case '3 months':
          startDate = DateTime(endDate.year, endDate.month - 3, endDate.day);
          break;
        case 'All time':
          startDate = DateTime(2020, 1, 1);
          break;
        default:
          startDate = endDate.subtract(const Duration(days: 30));
      }

      // Load overall statistics
      final overallStats = await CareActivityDBHelper.getStatistics(
        startDate: startDate,
        endDate: endDate,
      );

      // Load category statistics
      final categoryStats = <ReminderCategory, ActivityStatistics>{};
      for (final category in ReminderCategory.values) {
        final stats = await CareActivityDBHelper.getStatistics(
          category: category,
          startDate: startDate,
          endDate: endDate,
        );
        if (stats.totalActivities > 0) {
          categoryStats[category] = stats;
        }
      }

      // Load category breakdown
      final breakdown = await CareActivityDBHelper.getCategoryBreakdown(
        startDate: startDate,
        endDate: endDate,
      );

      // Load achievements
      final achievements = await CareActivityDBHelper.getAllAchievements();

      setState(() {
        _overallStats = overallStats;
        _categoryStats = categoryStats;
        _categoryBreakdown = breakdown;
        _achievements = achievements;
        _isLoading = false;
      });
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
                'Statistics',
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
                        Icons.bar_chart,
                        size: 120,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          _isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Period Selector
                      _buildPeriodSelector(),
                      const SizedBox(height: 20),

                      // Overall Stats
                      if (_overallStats != null) ...[
                        _buildOverallStatsCard(),
                        const SizedBox(height: 20),
                      ],

                      // Streaks
                      if (_overallStats != null) ...[
                        _buildStreaksCard(),
                        const SizedBox(height: 20),
                      ],

                      // Category Breakdown
                      if (_categoryBreakdown.isNotEmpty) ...[
                        _buildCategoryBreakdownCard(),
                        const SizedBox(height: 20),
                      ],

                      // Time Patterns
                      if (_overallStats != null) ...[
                        _buildTimePatternsCard(),
                        const SizedBox(height: 20),
                      ],

                      // Achievements
                      if (_achievements.isNotEmpty) ...[
                        _buildAchievementsCard(),
                        const SizedBox(height: 20),
                      ],

                      // Category Details
                      ..._categoryStats.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildCategoryStatsCard(entry.key, entry.value),
                        );
                      }),
                    ]),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Time Period',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['7 days', '30 days', '3 months', 'All time'].map((period) {
                  final isSelected = _selectedPeriod == period;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(period),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedPeriod = period);
                          _loadStatistics();
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallStatsCard() {
    final stats = _overallStats!;
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                const Text(
                  'Overall Performance',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatBox(
                    'Total',
                    stats.totalActivities.toString(),
                    Icons.check_circle,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatBox(
                    'On Time',
                    '${stats.onTimePercentage.toStringAsFixed(1)}%',
                    Icons.schedule,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatBox(
                    'Completed',
                    stats.onTimeCount.toString(),
                    Icons.done_all,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatBox(
                    'Late',
                    stats.lateCount.toString(),
                    Icons.warning,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            if (stats.averageDurationMinutes > 0) ...[
              const SizedBox(height: 12),
              _buildStatBox(
                'Avg Duration',
                '${stats.averageDurationMinutes.toStringAsFixed(1)} min',
                Icons.timer,
                theme.colorScheme.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreaksCard() {
    final stats = _overallStats!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Streaks',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStreakBox(
                    'Current Streak',
                    '${stats.currentStreak} days',
                    Icons.bolt,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStreakBox(
                    'Best Streak',
                    '${stats.longestStreak} days',
                    Icons.emoji_events,
                    Colors.amber,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdownCard() {
    final total = _categoryBreakdown.values.fold(0, (sum, count) => sum + count);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.pie_chart, color: Colors.purple),
                const SizedBox(width: 8),
                const Text(
                  'Category Breakdown',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ..._categoryBreakdown.entries.map((entry) {
              final percentage = (entry.value / total * 100).toStringAsFixed(1);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(entry.key.icon, size: 20, color: entry.key.color),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.key.displayName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(
                          '$percentage%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: entry.key.color,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${entry.value}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: entry.value / total,
                      backgroundColor: entry.key.color.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(entry.key.color),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePatternsCard() {
    final stats = _overallStats!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.teal),
                const SizedBox(width: 8),
                const Text(
                  'Activity Patterns',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (stats.mostActiveDay != null) ...[
              _buildPatternItem(
                'Most Active Day',
                stats.mostActiveDay!,
                Icons.calendar_today,
                Colors.blue,
              ),
              const SizedBox(height: 12),
            ],
            if (stats.mostActiveHour != null) ...[
              _buildPatternItem(
                'Most Active Hour',
                _formatHour(stats.mostActiveHour!),
                Icons.schedule,
                Colors.purple,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPatternItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber),
                const SizedBox(width: 8),
                const Text(
                  'Achievements',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${_achievements.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _achievements.map((achievement) {
                return Tooltip(
                  message: achievement.type.description,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          achievement.type.emoji,
                          style: const TextStyle(fontSize: 28),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          achievement.type.displayName,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryStatsCard(ReminderCategory category, ActivityStatistics stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(category.icon, color: category.color),
                const SizedBox(width: 8),
                Text(
                  category.displayName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildMiniStat('Total', stats.totalActivities.toString(), category.color),
                const SizedBox(width: 8),
                _buildMiniStat('On Time', '${stats.onTimePercentage.toStringAsFixed(0)}%', Colors.green),
                if (stats.averageDurationMinutes > 0)
                  _buildMiniStat('Avg', '${stats.averageDurationMinutes.toStringAsFixed(0)}m', Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12:00 AM';
    if (hour < 12) return '$hour:00 AM';
    if (hour == 12) return '12:00 PM';
    return '${hour - 12}:00 PM';
  }
}
