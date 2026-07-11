import '../models/dice_probability_config.dart';

abstract interface class DiceRoller {
  List<int> roll({
    required int diceCount,
    required DiceProbabilityConfig config,
  });
}
