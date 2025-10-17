import 'dart:io';

import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../models/pet.dart';
import 'pet_profile_screen.dart';

class PetListScreen extends StatefulWidget {
  const PetListScreen({super.key});

  @override
  State<PetListScreen> createState() => _PetListScreenState();
}

class _PetListScreenState extends State<PetListScreen> {
  List<Pet> _pets = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final pets = await DBHelper.getPets();
      if (!mounted) return;
      setState(() {
        _pets = pets;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load pets: $e';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Pets'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPets,
            tooltip: 'Refresh',
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _pets.isEmpty
                  ? const Center(child: Text('No pets saved yet'))
                  : ListView.builder(
                      itemCount: _pets.length,
                      itemBuilder: (context, index) {
                        final pet = _pets[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: _buildAvatar(pet),
                            title: Text(pet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Age: ${pet.age}'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => PetProfileScreen(pet: pet)),
                              );
                              await _loadPets();
                            },
                          ),
                        );
                      },
                    ),
    );
  }

  Widget _buildAvatar(Pet pet) {
    if (pet.photo != null && pet.photo!.isNotEmpty) {
      final file = File(pet.photo!);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.file(file, width: 48, height: 48, fit: BoxFit.cover),
        );
      }
    }
    return const CircleAvatar(
      radius: 24,
      child: Icon(Icons.pets),
    );
  }
}
