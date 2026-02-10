// lib/screens/conversation_list_screen.dart

import 'package:flutter/material.dart';

import '../repositories/conversation_repository.dart';
import '../models/conversation.dart';

class ConversationListScreen extends StatefulWidget {
  const ConversationListScreen({super.key});

  @override
  State<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> {
  final repo = ConversationRepository.instance;

  @override
  Widget build(BuildContext context) {
    final List<Conversation> conversations = repo.conversations;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
      ),
      body: ListView.separated(
        itemCount: conversations.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final convo = conversations[index];

          // Trailing indicators: Tag + AutoRead
          final trailing = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (convo.isTagged)
                const Icon(
                  Icons.local_offer,
                ),
              if (convo.isTagged && convo.autoReadEnabled) const SizedBox(width: 8),
              if (convo.autoReadEnabled)
                const Icon(
                  Icons.hearing,
                  color: Colors.green,
                ),
            ],
          );

          return ListTile(
            leading: CircleAvatar(
              child: Text(convo.name.isNotEmpty ? convo.name[0] : '?'),
            ),
            title: Text(convo.name),
            subtitle: Text(convo.lastMessagePreview),
            trailing: (convo.isTagged || convo.autoReadEnabled) ? trailing : null,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/conversation-detail',
                arguments: convo.id,
              ).then((_) {
                // Refresh when returning
                setState(() {});
              });
            },
          );
        },
      ),
    );
  }
}
