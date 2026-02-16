// lib/services/service_locator.dart

import 'tts_service.dart';
import 'tts_service_flutter.dart';

class ServiceLocator {
  static final TtsService ttsService = TtsServiceFlutter();
}
