import 'dice_probability_config.dart';

class RollRecord {
  RollRecord({
    required this.timestamp,
    required this.diceCount,
    required List<int> values,
    required this.probabilityConfig,
  }) : values = List<int>.unmodifiable(values);

  final DateTime timestamp;
  final int diceCount;
  final List<int> values;
  final DiceProbabilityConfig probabilityConfig;

  int get total => values.fold(0, (sum, value) => sum + value);
}
