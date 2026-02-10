// lib/repositories/conversation_repository.dart

import '../models/conversation.dart';
import '../models/auto_read_session.dart';

/// A simple in-memory repository for managing mock conversations
/// and Auto-Read sessions within the prototype.
///
/// This repository is the SINGLE source of truth for conversation state.
/// All updates are done by replacing Conversation instances (immutability).
class ConversationRepository {
  // Singleton pattern for easy global access.
  static final ConversationRepository instance =
      ConversationRepository._internal();
  ConversationRepository._internal();

  // ------------------------------------------------------------
  // Internal State
  // ------------------------------------------------------------

  final List<Conversation> _conversations = [
    Conversation(
      id: 'c1',
      name: 'Alice',
      lastMessagePreview: 'Hey! Are you free later?',
    ),
    Conversation(
      id: 'c2',
      name: 'Bob',
      lastMessagePreview: 'Did you see that link I sent?',
    ),
    Conversation(
      id: 'c3',
      name: 'Family Group',
      lastMessagePreview: 'Dinner at 6!',
    ),
    Conversation(
      id: 'c4',
      name: 'Coworker',
      lastMessagePreview: 'Meeting rescheduled to 2pm.',
    ),
  ];

  /// Active Auto-Read sessions by conversation ID.
  final Map<String, AutoReadSession> _autoReadSessions = {};

  // ------------------------------------------------------------
  // Conversation Access
  // ------------------------------------------------------------

  List<Conversation> get conversations =>
      List.unmodifiable(_conversations);

  Conversation getConversationById(String id) {
    return _conversations.firstWhere(
      (c) => c.id == id,
      orElse: () => throw Exception('Conversation not found'),
    );
  }

  int _indexOfConversation(String id) {
    return _conversations.indexWhere((c) => c.id == id);
  }

  void _replaceConversation(int index, Conversation updated) {
    _conversations[index] = updated;
  }

  // ------------------------------------------------------------
  // Voice Assignment
  // ------------------------------------------------------------

  void assignVoice(String conversationId, String voiceId) {
    final index = _indexOfConversation(conversationId);
    if (index == -1) return;

    final current = _conversations[index];
    final updated = current.copyWith(
      assignedVoiceId: voiceId,
    );

    _replaceConversation(index, updated);

    // Update Auto-Read session voice if one exists
    if (_autoReadSessions.containsKey(conversationId)) {
      _autoReadSessions[conversationId] =
          _autoReadSessions[conversationId]!.copyWith(
        assignedVoiceId: voiceId,
      );
    }
  }

  // ------------------------------------------------------------
  // Auto-Read Management
  // ------------------------------------------------------------

  /// Enable Auto-Read indefinitely for a conversation.
  void enableAutoReadIndefinitely(String conversationId) {
    final index = _indexOfConversation(conversationId);
    if (index == -1) return;

    final updated = _conversations[index].copyWith(
      autoReadEnabled: true,
      autoReadExpiresAt: null,
    );

    _replaceConversation(index, updated);

    _autoReadSessions[conversationId] = AutoReadSession(
      conversationId: conversationId,
      assignedVoiceId: updated.assignedVoiceId,
      expiresAt: null,
    );
  }

  /// Enable Auto-Read for a set number of minutes.
  void enableAutoReadForDuration(String conversationId, int minutes) {
    final index = _indexOfConversation(conversationId);
    if (index == -1) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final expiration = now + (minutes * 60 * 1000);

    final updated = _conversations[index].copyWith(
      autoReadEnabled: true,
      autoReadExpiresAt: expiration,
    );

    _replaceConversation(index, updated);

    _autoReadSessions[conversationId] = AutoReadSession(
      conversationId: conversationId,
      assignedVoiceId: updated.assignedVoiceId,
      expiresAt: expiration,
    );
  }

  /// Disable Auto-Read for a conversation.
  void disableAutoRead(String conversationId) {
    final index = _indexOfConversation(conversationId);
    if (index == -1) return;

    final updated = _conversations[index].copyWith(
      autoReadEnabled: false,
      autoReadExpiresAt: null,
    );

    _replaceConversation(index, updated);
    _autoReadSessions.remove(conversationId);
  }

  /// Return all currently active Auto-Read sessions.
  List<AutoReadSession> getActiveSessions() {
    final now = DateTime.now().millisecondsSinceEpoch;

    _autoReadSessions.removeWhere(
      (_, session) =>
          session.expiresAt != null &&
          session.expiresAt! < now,
    );

    return _autoReadSessions.values.toList();
  }
}
