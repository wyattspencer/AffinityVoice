// lib/repositories/conversation_repository.dart

import '../models/auto_read_session.dart';
import '../models/conversation.dart';
import '../models/message.dart';

/// A simple in-memory repository for managing mock conversations,
/// messages, and Auto-Read sessions within the prototype.
///
/// This repository is the SINGLE source of truth for conversation state.
/// All updates are done by replacing model instances (immutability).
///
/// Message storage is implemented in a persistence-friendly way:
/// - deterministic message IDs (string)
/// - per-conversation message lists
/// - dedupe set per conversation
class ConversationRepository {
  // Singleton pattern for easy global access.
  static final ConversationRepository instance = ConversationRepository._internal();
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

  /// Messages stored by conversationId.
  /// For now in-memory only; later can be backed by a DB without changing UI calls.
  final Map<String, List<Message>> _messagesByConversationId = {};

  /// Dedupe index: message IDs we've already stored per conversation.
  final Map<String, Set<String>> _messageIdsByConversationId = {};

  // ------------------------------------------------------------
  // Conversation Access
  // ------------------------------------------------------------

  List<Conversation> get conversations => List.unmodifiable(_conversations);

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
  // Tagging (Step 1)
  // ------------------------------------------------------------

  void setTagged(String conversationId, bool isTagged) {
    final index = _indexOfConversation(conversationId);
    if (index == -1) return;

    final current = _conversations[index];

    // If untagging, clear externalAddress as well (MVP rule).
    final updated = isTagged
        ? current.copyWith(isTagged: true)
        : current.copyWith(isTagged: false, clearExternalAddress: true);

    _replaceConversation(index, updated);
  }

  void setExternalAddress(String conversationId, String? externalAddress) {
    final index = _indexOfConversation(conversationId);
    if (index == -1) return;

    final current = _conversations[index];

    // Only allow setting address when tagged (keeps rules tight).
    if (!current.isTagged) return;

    final normalized = _normalizeExternalAddress(externalAddress);

    final updated = current.copyWith(
      externalAddress: normalized,
    );

    _replaceConversation(index, updated);
  }

  String? _normalizeExternalAddress(String? input) {
    if (input == null) return null;
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    // MVP normalization: keep digits and leading '+'. No heavy parsing yet.
    final buffer = StringBuffer();
    for (var i = 0; i < trimmed.length; i++) {
      final ch = trimmed[i];
      if ((ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57) || ch == '+') {
        buffer.write(ch);
      }
    }
    final out = buffer.toString();
    return out.isEmpty ? null : out;
  }

  // ------------------------------------------------------------
  // Messages (Step 2.2)
  // ------------------------------------------------------------

  /// Returns messages for a conversation (newest last).
  /// Always returns an unmodifiable list.
  List<Message> getMessages(String conversationId) {
    final list = _messagesByConversationId[conversationId] ?? const <Message>[];
    // Ensure stable sort (older -> newer).
    final sorted = List<Message>.from(list)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return List.unmodifiable(sorted);
  }

  /// Add a single message with dedupe by message.id.
  /// Returns true if inserted, false if it was a duplicate.
  bool addMessage(Message message) {
    final convoIndex = _indexOfConversation(message.conversationId);
    if (convoIndex == -1) return false;

    final convo = _conversations[convoIndex];

    // Product rule: only store messages for tagged conversations.
    if (!convo.isTagged) return false;

    // If externalAddress is set, enforce matching.
    if (convo.externalAddress != null && convo.externalAddress!.isNotEmpty) {
      if (_normalizeExternalAddress(message.externalAddress) != convo.externalAddress) {
        return false;
      }
    }

    final ids = _messageIdsByConversationId.putIfAbsent(
      message.conversationId,
      () => <String>{},
    );

    if (ids.contains(message.id)) return false;

    final list = _messagesByConversationId.putIfAbsent(
      message.conversationId,
      () => <Message>[],
    );

    ids.add(message.id);
    list.add(message);
    return true;
  }

  /// Add multiple messages. Returns number inserted.
  int addMessages(Iterable<Message> messages) {
    var inserted = 0;
    for (final m in messages) {
      if (addMessage(m)) inserted++;
    }
    return inserted;
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
      (_, session) => session.expiresAt != null && session.expiresAt! < now,
    );

    return _autoReadSessions.values.toList();
  }
}
