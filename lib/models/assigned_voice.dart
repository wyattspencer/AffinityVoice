/// Simple voice preset model for prototyping.

class VoicePreset {
  final String id;
  final String displayName;
  final String description;

  const VoicePreset({
    required this.id,
    required this.displayName,
    required this.description,
  });
}

class VoicePresets {
  static const List<VoicePreset> all = [
    VoicePreset(
      id: 'default',
      displayName: 'Default',
      description: 'Default voice preset',
    ),
    VoicePreset(
      id: 'calm',
      displayName: 'Calm',
      description: 'Softer, calmer delivery',
    ),
    VoicePreset(
      id: 'bright',
      displayName: 'Bright',
      description: 'Livelier, brighter delivery',
    ),
  ];

  static VoicePreset byId(String id) {
    return all.firstWhere(
      (v) => v.id == id,
      orElse: () => all.first,
    );
  }
}
