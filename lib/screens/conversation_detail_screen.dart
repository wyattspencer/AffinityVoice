// lib/screens/conversation_detail_screen.dart

import 'package:flutter/material.dart';

import '../models/assigned_voice.dart';
import '../models/auto_read_session.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../repositories/conversation_repository.dart';
import '../services/service_locator.dart';

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

  Future<void> _playMessage(Message message) async {
    final convo = _conversation;

    await ServiceLocator.ttsService.speak(
      text: message.body,
      voicePresetId: convo.assignedVoiceId,
      rate: 0.5,
      pitch: 1.0,
    );
  }

  Future<void> _stopPlayback() async {
    await ServiceLocator.ttsService.stop();
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

  void _setTagged(bool value) {
    repo.setTagged(conversationId, value);
    setState(() {
      _addressControllerInitialized = false;
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
    final messages = repo.getMessages(conversationId);

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
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.stop),
            onPressed: _stopPlayback,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              title: Text(
                convo.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(convo.lastMessagePreview),
            ),

            const SizedBox(height: 16),

            const Text(
              'Message History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            if (messages.isEmpty)
              const Text('No messages yet.')
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: messages.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final m = messages[index];
                  return ListTile(
                    title: Text(m.body),
                    subtitle: Text(
                        '${m.direction.name} • ${m.timestamp.toLocal()}'),
                    onTap: () => _playMessage(m),
                  );
                },
              ),

            const Divider(height: 32),

            const Text(
              'Assigned Voice',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            for (final v in VoicePresets.all)
              RadioListTile<String>(
                title: Text(v.displayName),
                value: v.id,
                groupValue: convo.assignedVoiceId,
                onChanged: (value) {
                  if (value != null) _setVoice(value);
                },
              ),

            const Divider(height: 32),

            const Text(
              'Auto-Read Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            if (activeSession != null) ...[
              ListTile(
                title: const Text('Auto-Read Status'),
                subtitle: Text(expirationText),
              ),
              TextButton(
                onPressed: _disableAutoRead,
                child: const Text('Disable Auto-Read'),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: _enableAutoReadIndefinite,
                child: const Text('Enable Auto-Read'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
