import 'package:flutter/material.dart';

import '../theme/theme_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ThemeMode _mode;
  late Color _color;
  late bool _useMaterial3;
  late bool _use24Hour;
  late double _textScale;

  final List<Color> _presetColors = <Color>[
    Colors.teal,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.red,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();
    _mode = ThemeController.themeMode.value;
    _color = ThemeController.seedColor.value;
    _useMaterial3 = ThemeController.useMaterial3.value;
    _use24Hour = ThemeController.use24HourTime.value;
    _textScale = ThemeController.textScaleFactor.value;
  }

  void _save() async {
    await ThemeController.update(mode: _mode, color: _color, material3: _useMaterial3, use24h: _use24Hour, textScale: _textScale);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Theme', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          RadioListTile<ThemeMode>(
            value: ThemeMode.light,
            groupValue: _mode,
            title: const Text('Light'),
            onChanged: (v) => setState(() => _mode = v!),
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.dark,
            groupValue: _mode,
            title: const Text('Dark'),
            onChanged: (v) => setState(() => _mode = v!),
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.system,
            groupValue: _mode,
            title: const Text('System'),
            onChanged: (v) => setState(() => _mode = v!),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Use Material 3'),
            value: _useMaterial3,
            onChanged: (v) => setState(() => _useMaterial3 = v),
            secondary: const Icon(Icons.auto_awesome),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('24-hour time'),
            value: _use24Hour,
            onChanged: (v) => setState(() => _use24Hour = v),
            secondary: const Icon(Icons.schedule),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.format_size),
            title: const Text('Text size'),
            subtitle: Slider(
              value: _textScale,
              min: 1.0,
              max: 1.4,
              divisions: 4,
              label: _textScale.toStringAsFixed(1),
              onChanged: (v) => setState(() => _textScale = v),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Accent Color', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _presetColors.map((c) {
              final bool selected = _color.value == c.value;
              return GestureDetector(
                onTap: () => setState(() => _color = c),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? Colors.black : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text('Save'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }
}
