import 'dart:math';

import 'package:dice_roller/models/dice_probability_config.dart';
import 'package:dice_roller/services/dice_result_generator.dart';
import 'package:flutter_test/flutter_test.dart';

class SequenceRandom implements Random {
  SequenceRandom(this.values);

  final List<int> values;
  int _index = 0;

  @override
  int nextInt(int max) {
    if (_index >= values.length) {
      throw StateError('No random value left');
    }
    final value = values[_index++];
    if (value < 0 || value >= max) {
      throw RangeError.range(value, 0, max - 1, 'value');
    }
    return value;
  }

  @override
  bool nextBool() => nextInt(2) == 0;

  @override
  double nextDouble() => nextInt(100) / 100;
}

void main() {
  group('DiceResultGenerator', () {
    test('fair mode returns the requested count with values in 1..6', () {
      final generator = DiceResultGenerator(random: SequenceRandom([0, 5, 2]));

      final values = generator.roll(
        diceCount: 3,
        config: const DiceProbabilityConfig.fair(),
      );

      expect(values, [1, 6, 3]);
      expect(values.every((value) => value >= 1 && value <= 6), isTrue);
    });

    test('probability mode excludes target face at 0 percent', () {
      final generator = DiceResultGenerator(random: SequenceRandom([50, 4]));

      final values = generator.roll(
        diceCount: 1,
        config: DiceProbabilityConfig(
          enabled: true,
          targetFace: 6,
          targetProbability: 0,
        ),
      );

      expect(values, [5]);
    });

    test('probability mode returns target face at 100 percent', () {
      final generator = DiceResultGenerator(random: SequenceRandom([0, 99]));

      final values = generator.roll(
        diceCount: 2,
        config: DiceProbabilityConfig(
          enabled: true,
          targetFace: 4,
          targetProbability: 100,
        ),
      );

      expect(values, [4, 4]);
    });

    test('probability mode handles hit and miss branches independently', () {
      final generator = DiceResultGenerator(
        random: SequenceRandom([39, 40, 0, 99, 3]),
      );

      final values = generator.roll(
        diceCount: 3,
        config: DiceProbabilityConfig(
          enabled: true,
          targetFace: 6,
          targetProbability: 40,
        ),
      );

      expect(values, [6, 1, 4]);
    });

    test('rejects invalid count and probability config', () {
      final generator = DiceResultGenerator(random: SequenceRandom([]));

      expect(
        () => generator.roll(
          diceCount: 0,
          config: const DiceProbabilityConfig.fair(),
        ),
        throwsA(isA<RangeError>()),
      );
      expect(
        () => DiceProbabilityConfig(
          enabled: true,
          targetFace: 7,
          targetProbability: 50,
        ),
        throwsA(isA<RangeError>()),
      );
      expect(
        () => DiceProbabilityConfig(
          enabled: true,
          targetFace: 6,
          targetProbability: 101,
        ),
        throwsA(isA<RangeError>()),
      );
    });
  });
}
