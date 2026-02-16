// lib/screens/conversation_detail_screen.dart

import 'package:flutter/material.dart';

import '../models/auto_read_session.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../repositories/conversation_repository.dart';
import '../services/import_service.dart';
import '../services/service_locator.dart';

class ConversationDetailScreen extends StatefulWidget {
  const ConversationDetailScreen({super.key});

  @override
  State<ConversationDetailScreen> createState() =>
      _ConversationDetailScreenState();
}

class _ConversationDetailScreenState extends State<ConversationDetailScreen> {
  final repo = ConversationRepository.instance;
  final importService = ImportService();

  late String conversationId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    conversationId = ModalRoute.of(context)!.settings.arguments as String;
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
      rate: repo.appSettings.ttsRate,
      pitch: repo.appSettings.ttsPitch,
    );
  }

  Future<void> _stopPlayback() async {
    await ServiceLocator.ttsService.stop();
  }

  void _simulateImport() {
    final convo = _conversation;

    if (!convo.isTagged ||
        convo.externalAddress == null ||
        convo.externalAddress!.isEmpty) {
      return;
    }

    const sampleXml = '''
<smses count="1">
  <sms protocol="0"
       address="+15551234567"
       date="1708000000000"
       type="1"
       body="Imported sample message"/>
</smses>
''';

    final parsed = importService.parseSmsBackupXml(
      xmlContent: sampleXml,
      conversationId: conversationId,
      externalAddress: convo.externalAddress!,
    );

    repo.addMessages(parsed);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final convo = _conversation;
    final messages = repo.getMessages(conversationId);

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
        padding: const EdgeInsets.all(16),
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
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: _simulateImport,
              icon: const Icon(Icons.file_download),
              label: const Text('Simulate Import'),
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
          ],
        ),
      ),
    );
  }
}
