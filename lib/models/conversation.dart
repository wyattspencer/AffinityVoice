// lib/models/conversation.dart

/// A mock conversation model used for prototyping.
/// Later, this will map to real SMS thread IDs and contact metadata.
///
/// This model is intentionally IMMUTABLE.
/// All updates must be performed via `copyWith(...)` in the repository.
class Conversation {
  final String id;
  final String name;
  final String lastMessagePreview;

  /// Assigned voice ID (string for now; later will be a real voice model reference)
  final String assignedVoiceId;

  /// Whether Auto-Read is enabled for this conversation
  final bool autoReadEnabled;

  /// Expiration timestamp for Auto-Read (milliseconds since epoch)
  /// null = no expiration
  final int? autoReadExpiresAt;

  const Conversation({
    required this.id,
    required this.name,
    required this.lastMessagePreview,
    this.assignedVoiceId = 'default',
    this.autoReadEnabled = false,
    this.autoReadExpiresAt,
  });

  Conversation copyWith({
    String? assignedVoiceId,
    bool? autoReadEnabled,
    int? autoReadExpiresAt,
  }) {
    return Conversation(
      id: id,
      name: name,
      lastMessagePreview: lastMessagePreview,
      assignedVoiceId: assignedVoiceId ?? this.assignedVoiceId,
      autoReadEnabled: autoReadEnabled ?? this.autoReadEnabled,
      autoReadExpiresAt: autoReadExpiresAt,
    );
  }
}
