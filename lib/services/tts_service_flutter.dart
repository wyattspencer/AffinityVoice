// lib/services/tts_service_flutter.dart

import 'package:flutter_tts/flutter_tts.dart';

import 'tts_service.dart';

class TtsServiceFlutter implements TtsService {
  final FlutterTts _flutterTts = FlutterTts();

  TtsServiceFlutter() {
    _flutterTts.setStartHandler(() {});
    _flutterTts.setCompletionHandler(() {});
    _flutterTts.setErrorHandler((msg) {});
  }

  @override
  Future<void> speak({
    required String text,
    required String voicePresetId,
    double rate = 0.5,
    double pitch = 1.0,
  }) async {
    // Basic rate/pitch support
    await _flutterTts.setSpeechRate(rate);
    await _flutterTts.setPitch(pitch);

    // Map voice preset to platform voice later.
    // For now, we just speak with current system voice.
    await _flutterTts.speak(text);
  }

  @override
  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
