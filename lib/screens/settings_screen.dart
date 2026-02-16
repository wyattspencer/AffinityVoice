// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../repositories/conversation_repository.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final repo = ConversationRepository.instance;

  late double _rate;
  late double _pitch;

  @override
  void initState() {
    super.initState();
    final settings = repo.appSettings;
    _rate = settings.ttsRate;
    _pitch = settings.ttsPitch;
  }

  void _updateSettings() {
    repo.updateAppSettings(
      AppSettings(
        ttsRate: _rate,
        ttsPitch: _pitch,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Text-to-Speech Rate',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _rate,
              min: 0.1,
              max: 1.0,
              divisions: 9,
              label: _rate.toStringAsFixed(2),
              onChanged: (value) {
                setState(() {
                  _rate = value;
                  _updateSettings();
                });
              },
            ),

            const SizedBox(height: 24),

            const Text(
              'Text-to-Speech Pitch',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _pitch,
              min: 0.5,
              max: 2.0,
              divisions: 15,
              label: _pitch.toStringAsFixed(2),
              onChanged: (value) {
                setState(() {
                  _pitch = value;
                  _updateSettings();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
