// lib/screens/conversation_detail_screen.dart

import 'package:flutter/material.dart';

import '../repositories/conversation_repository.dart';
import '../models/conversation.dart';
import '../models/auto_read_session.dart';
import '../models/assigned_voice.dart';

class ConversationDetailScreen extends StatefulWidget {
  const ConversationDetailScreen({super.key});

  @override
  State<ConversationDetailScreen> createState() =>
      _ConversationDetailScreenState();
}

class _ConversationDetailScreenState extends State<ConversationDetailScreen> {
  final repo = ConversationRepository.instance;

  late String conversationId;

  final TextEditingController _addressController = TextEditingController();
  bool _addressControllerInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    conversationId = ModalRoute.of(context)!.settings.arguments as String;
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Conversation get _conversation => repo.getConversationById(conversationId);

  AutoReadSession? get _activeSession {
    return repo
        .getActiveSessions()
        .where((s) => s.conversationId == conversationId)
        .cast<AutoReadSession?>()
        .firstWhere(
          (s) => s != null,
          orElse: () => null,
        );
  }

  void _setVoice(String voiceId) {
    repo.assignVoice(conversationId, voiceId);
    setState(() {});
  }

  void _enableAutoReadIndefinite() {
    repo.enableAutoReadIndefinitely(conversationId);
    setState(() {});
  }

  void _enableAutoReadForMinutes(int minutes) {
    repo.enableAutoReadForDuration(conversationId, minutes);
    setState(() {});
  }

  void _disableAutoRead() {
    repo.disableAutoRead(conversationId);
    setState(() {});
  }

  // Step 1: tagging
  void _setTagged(bool value) {
    repo.setTagged(conversationId, value);
    setState(() {
      _addressControllerInitialized = false; // re-sync controller
    });
  }

  void _setExternalAddress(String value) {
    repo.setExternalAddress(conversationId, value);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final convo = _conversation;
    final activeSession = _activeSession;

    // Keep the text controller synced to repo state.
    if (!_addressControllerInitialized) {
      _addressController.text = convo.externalAddress ?? '';
      _addressControllerInitialized = true;
    }

    final String expirationText = activeSession == null
        ? ''
        : activeSession.expiresAt == null
            ? 'Enabled (no expiration)'
            : 'Expires at ${DateTime.fromMillisecondsSinceEpoch(activeSession.expiresAt!).toLocal()}';

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Conversation header
            ListTile(
              title: Text(
                convo.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(convo.lastMessagePreview),
              leading: CircleAvatar(
                child: Text(convo.name.isNotEmpty ? convo.name[0] : '?'),
              ),
            ),

            const SizedBox(height: 16),

            // Step 1: Tagging section
            const Text(
              'Tagging',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            SwitchListTile(
              title: const Text('Tagged for Auto-Read'),
              subtitle: const Text(
                'Only tagged conversations will be eligible for import and real-time read aloud.',
              ),
              value: convo.isTagged,
              onChanged: (value) => _setTagged(value),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _addressController,
              enabled: convo.isTagged,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone number',
                hintText: '+15551234567',
                helperText: convo.isTagged
                    ? 'Used to match imported and real-time messages.'
                    : 'Enable tagging to set a phone number.',
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) => _setExternalAddress(value),
            ),

            const Divider(height: 32),

            const Text(
              'Assigned Voice',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Voice picker
            for (final v in VoicePresets.all)
              RadioListTile<String>(
                title: Text(v.displayName),
                subtitle: Text(v.description),
                value: v.id,
                groupValue: convo.assignedVoiceId,
                onChanged: (value) {
                  if (value != null) _setVoice(value);
                },
              ),

            const Divider(height: 32),

            const Text(
              'Auto-Read Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            if (activeSession != null) ...[
              ListTile(
                title: const Text('Auto-Read Status'),
                subtitle: Text(expirationText),
                trailing: const Icon(
                  Icons.hearing,
                  color: Colors.green,
                ),
              ),
              TextButton(
                onPressed: _disableAutoRead,
                child: const Text('Disable Auto-Read'),
              ),
            ] else ...[
              ElevatedButton.icon(
                icon: const Icon(Icons.hearing),
                label: const Text('Enable Auto-Read (No Expiration)'),
                onPressed: _enableAutoReadIndefinite,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.timer),
                label: const Text('Enable Auto-Read for 30 Minutes'),
                onPressed: () => _enableAutoReadForMinutes(30),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
