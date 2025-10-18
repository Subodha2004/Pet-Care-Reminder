import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../database/pet_health_db_helper.dart';
import 'health_tabs/vaccinations_tab.dart';
import 'health_tabs/medical_records_tab.dart';
import 'health_tabs/weight_tracking_tab.dart';
import 'health_tabs/medications_tab.dart';
import 'health_tabs/conditions_tab.dart';
import 'health_tabs/vet_contacts_tab.dart';

class PetHealthDashboard extends StatefulWidget {
  final Pet pet;
  
  const PetHealthDashboard({super.key, required this.pet});

  @override
  State<PetHealthDashboard> createState() => _PetHealthDashboardState();
}

class _PetHealthDashboardState extends State<PetHealthDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, int> _healthSummary = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadHealthSummary();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHealthSummary() async {
    setState(() => _loading = true);
    try {
      final summary = await PetHealthDBHelper.getHealthSummary(widget.pet.id!);
      if (mounted) {
        setState(() {
          _healthSummary = summary;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.pet.name}\'s Health'),
        backgroundColor: theme.colorScheme.primary,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              icon: const Icon(Icons.vaccines),
              text: 'Vaccines',
              iconMargin: const EdgeInsets.only(bottom: 4),
            ),
            Tab(
              icon: const Icon(Icons.medical_services),
              text: 'Medical',
              iconMargin: const EdgeInsets.only(bottom: 4),
            ),
            Tab(
              icon: const Icon(Icons.monitor_weight),
              text: 'Weight',
              iconMargin: const EdgeInsets.only(bottom: 4),
            ),
            Tab(
              icon: const Icon(Icons.medication),
              text: 'Meds',
              iconMargin: const EdgeInsets.only(bottom: 4),
            ),
            Tab(
              icon: const Icon(Icons.warning_amber),
              text: 'Conditions',
              iconMargin: const EdgeInsets.only(bottom: 4),
            ),
            Tab(
              icon: const Icon(Icons.local_hospital),
              text: 'Vets',
              iconMargin: const EdgeInsets.only(bottom: 4),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Health Summary Card
          if (!_loading)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.1),
                    theme.colorScheme.secondary.withOpacity(0.1),
                  ],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    Icons.vaccines,
                    'Vaccines',
                    _healthSummary['vaccinations'] ?? 0,
                    Colors.blue,
                  ),
                  _buildSummaryItem(
                    Icons.medication,
                    'Active Meds',
                    _healthSummary['activeMedications'] ?? 0,
                    Colors.orange,
                  ),
                  _buildSummaryItem(
                    Icons.medical_services,
                    'Visits',
                    _healthSummary['medicalVisits'] ?? 0,
                    Colors.green,
                  ),
                  _buildSummaryItem(
                    Icons.warning_amber,
                    'Conditions',
                    _healthSummary['conditions'] ?? 0,
                    Colors.red,
                  ),
                ],
              ),
            ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                VaccinationsTab(pet: widget.pet, onUpdate: _loadHealthSummary),
                MedicalRecordsTab(pet: widget.pet, onUpdate: _loadHealthSummary),
                WeightTrackingTab(pet: widget.pet, onUpdate: _loadHealthSummary),
                MedicationsTab(pet: widget.pet, onUpdate: _loadHealthSummary),
                ConditionsTab(pet: widget.pet, onUpdate: _loadHealthSummary),
                VetContactsTab(pet: widget.pet, onUpdate: _loadHealthSummary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String label, int count, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
