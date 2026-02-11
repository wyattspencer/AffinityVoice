// lib/services/tts_service.dart

/// Abstract TTS service.
/// Keeps UI and repository decoupled from the concrete plugin.
abstract class TtsService {
  Future<void> speak({
    required String text,
    required String voicePresetId,
    double rate = 0.5,
    double pitch = 1.0,
  });

  Future<void> stop();
}
