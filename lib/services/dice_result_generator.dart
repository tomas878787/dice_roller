import 'dart:math';

import '../models/dice_probability_config.dart';
import 'dice_roller.dart';

class DiceResultGenerator implements DiceRoller {
  DiceResultGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;

  @override
  List<int> roll({
    required int diceCount,
    required DiceProbabilityConfig config,
  }) {
    RangeError.checkValueInInterval(diceCount, 1, 6, 'diceCount');
    final checkedConfig = DiceProbabilityConfig.checked(
      enabled: config.enabled,
      targetFace: config.targetFace,
      targetProbability: config.targetProbability,
    );

    return List<int>.unmodifiable(
      List<int>.generate(
        diceCount,
        (_) => _rollOne(checkedConfig),
        growable: false,
      ),
    );
  }

  int _rollOne(DiceProbabilityConfig config) {
    if (!config.enabled) {
      return _random.nextInt(6) + 1;
    }

    if (_random.nextInt(100) < config.targetProbability) {
      return config.targetFace;
    }

    final remaining = List<int>.generate(
      6,
      (index) => index + 1,
    ).where((face) => face != config.targetFace).toList(growable: false);
    return remaining[_random.nextInt(remaining.length)];
  }
}
