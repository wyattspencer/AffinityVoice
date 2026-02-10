// lib/models/auto_read_session.dart

/// Represents an active Auto-Read session for a conversation.
/// This model is intentionally IMMUTABLE.
/// All updates must be done via `copyWith(...)` in the repository.
class AutoReadSession {
  final String conversationId;
  final String assignedVoiceId;

  /// Expiration timestamp in milliseconds since epoch.
  /// null = no expiration
  final int? expiresAt;

  const AutoReadSession({
    required this.conversationId,
    required this.assignedVoiceId,
    this.expiresAt,
  });

  AutoReadSession copyWith({
    String? assignedVoiceId,
    int? expiresAt,
  }) {
    return AutoReadSession(
      conversationId: conversationId,
      assignedVoiceId: assignedVoiceId ?? this.assignedVoiceId,
      expiresAt: expiresAt,
    );
  }
}
