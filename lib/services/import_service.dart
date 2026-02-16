// lib/services/import_service.dart

import 'dart:convert';
import 'package:xml/xml.dart';

import '../models/message.dart';

/// ImportService parses SMS Backup & Restore XML files
/// and converts matching entries into Message objects.
///
/// This service does NOT insert into the repository directly.
/// It only parses and returns normalized Message objects.
class ImportService {
  /// Parses SMS Backup & Restore XML content.
  ///
  /// [xmlContent] is the raw XML string.
  /// [conversationId] is the internal app conversation ID.
  /// [externalAddress] is the normalized phone number for matching.
  ///
  /// Returns a list of Message objects ready for repository insertion.
  List<Message> parseSmsBackupXml({
    required String xmlContent,
    required String conversationId,
    required String externalAddress,
  }) {
    final document = XmlDocument.parse(xmlContent);

    final messages = <Message>[];

    for (final sms in document.findAllElements('sms')) {
      final address = sms.getAttribute('address') ?? '';
      final body = sms.getAttribute('body') ?? '';
      final dateStr = sms.getAttribute('date') ?? '';
      final typeStr = sms.getAttribute('type') ?? '';

      if (_normalize(address) != externalAddress) {
        continue;
      }

      final timestampMillis = int.tryParse(dateStr);
      if (timestampMillis == null) continue;

      final direction = typeStr == '1'
          ? MessageDirection.incoming
          : MessageDirection.outgoing;

      final timestamp =
          DateTime.fromMillisecondsSinceEpoch(timestampMillis);

      final id = _generateDeterministicId(
        externalAddress: externalAddress,
        timestamp: timestampMillis,
        body: body,
      );

      messages.add(
        Message(
          id: id,
          conversationId: conversationId,
          externalAddress: externalAddress,
          timestamp: timestamp,
          body: body,
          direction: direction,
          source: MessageSource.import,
        ),
      );
    }

    return messages;
  }

  String _normalize(String input) {
    final trimmed = input.trim();
    final buffer = StringBuffer();

    for (var i = 0; i < trimmed.length; i++) {
      final ch = trimmed[i];
      if ((ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57) || ch == '+') {
        buffer.write(ch);
      }
    }

    return buffer.toString();
  }

  String _generateDeterministicId({
    required String externalAddress,
    required int timestamp,
    required String body,
  }) {
    final content = '$externalAddress|$timestamp|$body';
    return base64Url.encode(utf8.encode(content));
  }
}
