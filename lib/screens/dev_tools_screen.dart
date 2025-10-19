import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

/// Developer tools screen for debugging and testing authentication
class DevToolsScreen extends StatefulWidget {
  const DevToolsScreen({super.key});

  @override
  State<DevToolsScreen> createState() => _DevToolsScreenState();
}

class _DevToolsScreenState extends State<DevToolsScreen> {
  Map<String, dynamic> _authState = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    setState(() => _isLoading = true);
    
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _authState = {
        'is_logged_in': prefs.getBool('is_logged_in'),
        'current_user': prefs.getString('current_user'),
        'user_id': prefs.getInt('user_id'),
        'all_keys': prefs.getKeys().toList(),
      };
      _isLoading = false;
    });
  }

  Future<void> _clearAllAuthData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Auth Data'),
        content: const Text(
          'This will log you out and clear all authentication data. '
          'You will need to login again. Are you sure?',
        ),
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
            child: const Text('Clear & Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', false);
      await prefs.remove('current_user');
      await prefs.remove('user_id');
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Authentication data cleared'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate to login screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
        (route) => false,
      );
    }
  }

  Future<void> _clearAppData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All App Data'),
        content: const Text(
          'This will clear ALL SharedPreferences data including theme settings. '
          'Are you sure?',
        ),
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
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ All app data cleared'),
          backgroundColor: Colors.green,
        ),
      );
      
      await _loadAuthState();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('🛠️ Developer Tools'),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Warning banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade300, width: 2),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 32),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Developer Tools\nUse with caution!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Authentication State Card
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            const Text(
                              'Authentication State',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildStateItem('Logged In', _authState['is_logged_in']?.toString() ?? 'false'),
                        _buildStateItem('Username', _authState['current_user'] ?? 'null'),
                        _buildStateItem('User ID', _authState['user_id']?.toString() ?? 'null'),
                        const Divider(height: 24),
                        const Text(
                          'All SharedPreferences Keys:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...((_authState['all_keys'] as List<String>?) ?? []).map((key) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text('  • $key', style: const TextStyle(fontSize: 12)),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Actions
                const Text(
                  'Actions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                
                ElevatedButton.icon(
                  onPressed: _loadAuthState,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh State'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
                const SizedBox(height: 12),
                
                OutlinedButton.icon(
                  onPressed: _clearAllAuthData,
                  icon: const Icon(Icons.logout, color: Colors.orange),
                  label: const Text(
                    'Clear Auth Data & Logout',
                    style: TextStyle(color: Colors.orange),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    side: const BorderSide(color: Colors.orange),
                  ),
                ),
                const SizedBox(height: 12),
                
                OutlinedButton.icon(
                  onPressed: _clearAppData,
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  label: const Text(
                    'Clear ALL App Data',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Instructions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.help_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          const Text(
                            'How to use',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '• Refresh State: Reload authentication data from SharedPreferences\n'
                        '• Clear Auth Data: Log out and clear login state only\n'
                        '• Clear ALL Data: Reset entire app including theme settings',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStateItem(String label, String value) {
    final isTrue = value.toLowerCase() == 'true';
    final isFalse = value.toLowerCase() == 'false';
    final isNull = value.toLowerCase() == 'null';
    
    Color valueColor = Colors.black87;
    if (isTrue) valueColor = Colors.green;
    if (isFalse) valueColor = Colors.red;
    if (isNull) valueColor = Colors.grey;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
