// lib/models/app_settings.dart

/// Global app-level settings (in-memory for now).
/// Persistence will be added later behind a repository interface.
class AppSettings {
  final double ttsRate;  // 0.0–1.0 typical
  final double ttsPitch; // ~0.5–2.0 typical

  const AppSettings({
    this.ttsRate = 0.5,
    this.ttsPitch = 1.0,
  });

  AppSettings copyWith({
    double? ttsRate,
    double? ttsPitch,
  }) {
    return AppSettings(
      ttsRate: ttsRate ?? this.ttsRate,
      ttsPitch: ttsPitch ?? this.ttsPitch,
    );
  }
}
