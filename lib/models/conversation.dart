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

  /// Tagged for message import / notification matching (MVP feature).
  /// Only tagged conversations should receive imported or real-time messages.
  final bool isTagged;

  /// Identifier used to match imported / notification messages to this conversation.
  /// For now: phone number or address string. Prefer E.164 but accept raw digits.
  final String? externalAddress;

  const Conversation({
    required this.id,
    required this.name,
    required this.lastMessagePreview,
    this.assignedVoiceId = 'default',
    this.autoReadEnabled = false,
    this.autoReadExpiresAt,
    this.isTagged = false,
    this.externalAddress,
  });

  Conversation copyWith({
    String? assignedVoiceId,
    bool? autoReadEnabled,
    int? autoReadExpiresAt,
    bool? isTagged,
    String? externalAddress,
    bool clearExternalAddress = false,
  }) {
    return Conversation(
      id: id,
      name: name,
      lastMessagePreview: lastMessagePreview,
      assignedVoiceId: assignedVoiceId ?? this.assignedVoiceId,
      autoReadEnabled: autoReadEnabled ?? this.autoReadEnabled,
      autoReadExpiresAt: autoReadExpiresAt,
      isTagged: isTagged ?? this.isTagged,
      externalAddress: clearExternalAddress
          ? null
          : (externalAddress ?? this.externalAddress),
    );
  }
}
