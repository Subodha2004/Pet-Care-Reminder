import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/smart_suggestion.dart';
import '../models/pet.dart';
import '../database/suggestion_db_helper.dart';
import '../database/db_helper.dart';
import '../services/smart_suggestion_service.dart';
import 'add_edit_reminder_screen.dart';

class SmartSuggestionsScreen extends StatefulWidget {
  const SmartSuggestionsScreen({super.key});

  @override
  State<SmartSuggestionsScreen> createState() => _SmartSuggestionsScreenState();
}

class _SmartSuggestionsScreenState extends State<SmartSuggestionsScreen> {
  List<SmartSuggestion> _suggestions = [];
  List<Pet> _pets = [];
  bool _isLoading = true;
  SuggestionType? _filterType;
  int? _filterPetId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final pets = await DBHelper.getPets();
      final suggestions = await SuggestionDBHelper.getActiveSuggestions();
      
      setState(() {
        _pets = pets;
        _suggestions = suggestions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading suggestions: $e')),
        );
      }
    }
  }

  Future<void> _refreshSuggestions() async {
    setState(() => _isLoading = true);
    
    try {
      // Generate new suggestions
      final newSuggestions = await SmartSuggestionService.generateAllSuggestions();
      
      // Refresh database
      await SuggestionDBHelper.refreshSuggestions(newSuggestions);
      
      // Reload
      await _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✨ Suggestions refreshed!')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error refreshing: $e')),
        );
      }
    }
  }

  List<SmartSuggestion> get _filteredSuggestions {
    var filtered = _suggestions;
    
    if (_filterType != null) {
      filtered = filtered.where((s) => s.type == _filterType).toList();
    }
    
    if (_filterPetId != null) {
      filtered = filtered.where((s) => s.petId == _filterPetId).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('🤖 Smart Suggestions'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _refreshSuggestions,
                tooltip: 'Refresh suggestions',
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list),
                tooltip: 'Filter',
                onSelected: (value) {
                  setState(() {
                    if (value == 'clear') {
                      _filterType = null;
                      _filterPetId = null;
                    }
                  });
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'clear',
                    child: Text('Clear Filters'),
                  ),
                ],
              ),
            ],
          ),
          
          // Filter chips
          SliverToBoxAdapter(
            child: _buildFilterChips(),
          ),
          
          // Suggestions list
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_filteredSuggestions.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No suggestions available',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap refresh to generate new suggestions',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final suggestion = _filteredSuggestions[index];
                    return _buildSuggestionCard(suggestion);
                  },
                  childCount: _filteredSuggestions.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type filter
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('All Types'),
                selected: _filterType == null,
                onSelected: (selected) {
                  setState(() => _filterType = null);
                },
              ),
              ...SuggestionType.values.map((type) => FilterChip(
                label: Text(type.displayName),
                selected: _filterType == type,
                onSelected: (selected) {
                  setState(() => _filterType = selected ? type : null);
                },
              )),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Pet filter
          if (_pets.isNotEmpty)
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('All Pets'),
                  selected: _filterPetId == null,
                  onSelected: (selected) {
                    setState(() => _filterPetId = null);
                  },
                ),
                ..._pets.map((pet) => FilterChip(
                  label: Text(pet.name),
                  selected: _filterPetId == pet.id,
                  onSelected: (selected) {
                    setState(() => _filterPetId = selected ? pet.id : null);
                  },
                )),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(SmartSuggestion suggestion) {
    final pet = _pets.firstWhere(
      (p) => p.id == suggestion.petId,
      orElse: () => Pet(name: 'All Pets', age: 0),
    );
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with priority and type
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getPriorityColor(suggestion.priority).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: Row(
              children: [
                Text(
                  suggestion.priorityIcon,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  suggestion.type.displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getPriorityColor(suggestion.priority),
                  ),
                ),
                const Spacer(),
                if (suggestion.petId != null) ...[
                  Icon(Icons.pets, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    pet.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      suggestion.typeIcon,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        suggestion.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  suggestion.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          suggestion.reason,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[900],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Created: ${DateFormat('MMM dd, yyyy').format(suggestion.createdAt)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          
          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _dismissSuggestion(suggestion),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Dismiss'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _acceptSuggestion(suggestion),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(SuggestionPriority priority) {
    switch (priority) {
      case SuggestionPriority.low:
        return Colors.blue;
      case SuggestionPriority.medium:
        return Colors.orange;
      case SuggestionPriority.high:
        return Colors.deepOrange;
      case SuggestionPriority.urgent:
        return Colors.red;
    }
  }

  Future<void> _dismissSuggestion(SmartSuggestion suggestion) async {
    await SuggestionDBHelper.dismissSuggestion(suggestion.id!);
    await _loadData();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Suggestion dismissed')),
      );
    }
  }

  Future<void> _acceptSuggestion(SmartSuggestion suggestion) async {
    await SuggestionDBHelper.acceptSuggestion(suggestion.id!);
    
    // Handle action based on actionType
    if (suggestion.actionType == 'create_reminder' || 
        suggestion.actionType == 'create_feeding_reminders') {
      if (mounted) {
        // Navigate to add reminder screen
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddEditReminderScreen(),
          ),
        );
        
        // Show hint to user about the suggestion
        if (result != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Tip: ${suggestion.description}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } else if (suggestion.actionType == 'schedule_vet_visit') {
      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddEditReminderScreen(),
          ),
        );
      }
    }
    
    await _loadData();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Suggestion accepted!')),
      );
    }
  }
}
