class DiceProbabilityConfig {
  factory DiceProbabilityConfig({
    required bool enabled,
    required int targetFace,
    required int targetProbability,
  }) {
    _checkTargetFace(targetFace);
    _checkTargetProbability(targetProbability);
    return DiceProbabilityConfig._(
      enabled: enabled,
      targetFace: targetFace,
      targetProbability: targetProbability,
    );
  }

  const DiceProbabilityConfig.fair()
    : enabled = false,
      targetFace = 6,
      targetProbability = 50;

  const DiceProbabilityConfig._({
    required this.enabled,
    required this.targetFace,
    required this.targetProbability,
  });

  final bool enabled;
  final int targetFace;
  final int targetProbability;

  DiceProbabilityConfig copyWith({
    bool? enabled,
    int? targetFace,
    int? targetProbability,
  }) {
    return DiceProbabilityConfig.checked(
      enabled: enabled ?? this.enabled,
      targetFace: targetFace ?? this.targetFace,
      targetProbability: targetProbability ?? this.targetProbability,
    );
  }

  factory DiceProbabilityConfig.checked({
    required bool enabled,
    required int targetFace,
    required int targetProbability,
  }) {
    _checkTargetFace(targetFace);
    _checkTargetProbability(targetProbability);
    return DiceProbabilityConfig(
      enabled: enabled,
      targetFace: targetFace,
      targetProbability: targetProbability,
    );
  }

  static void _checkTargetFace(int value) {
    RangeError.checkValueInInterval(value, 1, 6, 'targetFace');
  }

  static void _checkTargetProbability(int value) {
    RangeError.checkValueInInterval(value, 0, 100, 'targetProbability');
  }
}
