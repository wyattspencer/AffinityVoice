/// Direction of a message relative to the user.
enum MessageDirection {
  incoming,
  outgoing,
}

/// Where a message came from.
enum MessageSource {
  import,
  notification,
  manual,
}

/// Immutable message model.
/// Designed to work with both in-memory storage now and persistence later.
class Message {
  /// Deterministic unique ID (string) to support dedupe and future persistence.
  /// For imported/notification messages, we will generate this from:
  /// externalAddress + timestamp + body hash.
  final String id;

  /// Internal conversation ID in this app.
  final String conversationId;

  /// External address used for matching (phone number / sender identifier).
  final String externalAddress;

  final DateTime timestamp;
  final String body;
  final MessageDirection direction;
  final MessageSource source;

  const Message({
    required this.id,
    required this.conversationId,
    required this.externalAddress,
    required this.timestamp,
    required this.body,
    required this.direction,
    required this.source,
  });

  Message copyWith({
    String? id,
    String? conversationId,
    String? externalAddress,
    DateTime? timestamp,
    String? body,
    MessageDirection? direction,
    MessageSource? source,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      externalAddress: externalAddress ?? this.externalAddress,
      timestamp: timestamp ?? this.timestamp,
      body: body ?? this.body,
      direction: direction ?? this.direction,
      source: source ?? this.source,
    );
  }
}
