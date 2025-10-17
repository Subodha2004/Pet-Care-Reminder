import 'package:flutter/material.dart';
import 'add_reminder_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Care Reminder'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: const Center(
        child: Text('Welcome to Pet Care Reminder'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newReminder = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddReminderScreen()),
          );

          if (!context.mounted) return;
          if (newReminder != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Added: ${newReminder['title']} at ${newReminder['time']}")
              ),
            );
          }
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}
