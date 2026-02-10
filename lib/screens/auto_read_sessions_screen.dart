// lib/screens/auto_read_sessions_screen.dart

import 'package:flutter/material.dart';

import '../repositories/conversation_repository.dart';
import '../models/auto_read_session.dart';
import '../models/conversation.dart';
import '../models/assigned_voice.dart';

class AutoReadSessionsScreen extends StatefulWidget {
  const AutoReadSessionsScreen({super.key});

  @override
  State<AutoReadSessionsScreen> createState() =>
      _AutoReadSessionsScreenState();
}

class _AutoReadSessionsScreenState
    extends State<AutoReadSessionsScreen> {
  final repo = ConversationRepository.instance;

  @override
  Widget build(BuildContext context) {
    final List<AutoReadSession> sessions =
        repo.getActiveSessions();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto-Read Sessions'),
      ),
      body: sessions.isEmpty
          ? const Center(
              child: Text(
                'No active Auto-Read sessions.',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.separated(
              itemCount: sessions.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1),
              itemBuilder: (context, index) {
                final session = sessions[index];
                final Conversation conversation =
                    repo.getConversationById(
                        session.conversationId);
                final voice =
                    VoicePresets.byId(session.assignedVoiceId);

                final String expirationText =
                    session.expiresAt == null
                        ? 'No expiration'
                        : 'Expires at ${DateTime.fromMillisecondsSinceEpoch(session.expiresAt!).toLocal()}';

                return ListTile(
                  leading: CircleAvatar(
                    child: Text(conversation.name[0]),
                  ),
                  title: Text(conversation.name),
                  subtitle: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text('Voice: ${voice.displayName}'),
                      Text(expirationText),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.hearing,
                    color: Colors.green,
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/conversation-detail',
                      arguments: conversation.id,
                    ).then((_) {
                      setState(() {});
                    });
                  },
                );
              },
            ),
    );
  }
}
