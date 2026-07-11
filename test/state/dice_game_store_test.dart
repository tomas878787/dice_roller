import 'package:dice_roller/models/dice_probability_config.dart';
import 'package:dice_roller/state/dice_game_store.dart';
import 'package:flutter_test/flutter_test.dart';

class StubDiceGenerator implements DiceRoller {
  StubDiceGenerator(this.results);

  final List<List<int>> results;
  final List<DiceProbabilityConfig> configs = [];
  int calls = 0;

  @override
  List<int> roll({
    required int diceCount,
    required DiceProbabilityConfig config,
  }) {
    configs.add(config);
    final result = results[calls];
    calls += 1;
    return result;
  }
}

void main() {
  group('DiceGameStore', () {
    test('prepare and commit publish one result and one history record', () {
      final generator = StubDiceGenerator([
        [2, 5, 6],
      ]);
      final store = DiceGameStore(
        generator: generator,
        now: () => DateTime(2026, 7, 11, 14, 32),
      )..setDiceCount(3);

      store.prepareRoll();

      expect(store.isRolling.value, isTrue);
      expect(store.currentValues.value, isEmpty);
      expect(generator.calls, 1);

      store.commitRoll();

      expect(store.isRolling.value, isFalse);
      expect(store.currentValues.value, [2, 5, 6]);
      expect(store.total.value, 13);
      expect(store.history.value, hasLength(1));
      expect(store.history.value.first.total, 13);
    });

    test('settings changes clear current result but keep history', () {
      final store = DiceGameStore(
        generator: StubDiceGenerator([
          [6],
        ]),
      );
      store.prepareRoll();
      store.commitRoll();

      store.setDiceCount(3);

      expect(store.currentValues.value, isEmpty);
      expect(store.history.value, hasLength(1));
      expect(store.diceCount.value, 3);
    });

    test('cancel roll restores interaction without writing history', () {
      final store = DiceGameStore(
        generator: StubDiceGenerator([
          [4],
        ]),
      );

      store.prepareRoll();
      store.cancelRoll();

      expect(store.isRolling.value, isFalse);
      expect(store.currentValues.value, isEmpty);
      expect(store.history.value, isEmpty);
    });

    test('history is newest first and capped at 20 records', () {
      final generator = StubDiceGenerator(
        List.generate(21, (index) => [index % 6 + 1]),
      );
      final store = DiceGameStore(generator: generator);

      for (var i = 0; i < 21; i += 1) {
        store.prepareRoll();
        store.commitRoll();
      }

      expect(store.history.value, hasLength(20));
      expect(store.history.value.first.values, [3]);
      expect(store.history.value.last.values, [2]);
    });

    test('history keeps a probability config snapshot', () {
      final store = DiceGameStore(
        generator: StubDiceGenerator([
          [6],
        ]),
      );

      store.setProbabilityEnabled(true);
      store.setTargetFace(6);
      store.setTargetProbability(80);
      store.prepareRoll();
      store.setTargetProbability(20);
      store.commitRoll();

      expect(store.history.value.first.probabilityConfig.enabled, isTrue);
      expect(store.history.value.first.probabilityConfig.targetProbability, 80);
    });

    test('duplicate prepare while rolling is rejected', () {
      final store = DiceGameStore(
        generator: StubDiceGenerator([
          [1],
          [6],
        ]),
      );

      store.prepareRoll();

      expect(store.prepareRoll, throwsA(isA<StateError>()));
    });
  });
}
