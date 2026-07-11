import 'package:signals_flutter/signals_flutter.dart';

import '../models/dice_probability_config.dart';
import '../models/roll_record.dart';
import '../services/dice_roller.dart';
import '../services/dice_result_generator.dart';

export '../services/dice_roller.dart';

class DiceGameStore {
  DiceGameStore({DiceRoller? generator, DateTime Function()? now})
    : _generator = generator ?? DiceResultGenerator(),
      _now = now ?? DateTime.now;

  final DiceRoller _generator;
  final DateTime Function() _now;
  _PendingRoll? _pendingRoll;

  final diceCount = signal<int>(1);
  final currentValues = signal<List<int>>(const []);
  final history = signal<List<RollRecord>>(const []);
  final isRolling = signal<bool>(false);
  final animationEnabled = signal<bool>(true);
  final probabilityEnabled = signal<bool>(false);
  final targetFace = signal<int>(6);
  final targetProbability = signal<int>(50);

  late final total = computed<int>(
    () => currentValues.value.fold(0, (sum, value) => sum + value),
  );

  late final hasResult = computed<bool>(() => currentValues.value.isNotEmpty);
  late final hasHistory = computed<bool>(() => history.value.isNotEmpty);

  late final probabilityConfig = computed<DiceProbabilityConfig>(
    () => DiceProbabilityConfig.checked(
      enabled: probabilityEnabled.value,
      targetFace: targetFace.value,
      targetProbability: targetProbability.value,
    ),
  );

  void setDiceCount(int value) {
    RangeError.checkValueInInterval(value, 1, 6, 'diceCount');
    diceCount.value = value;
    _clearCurrentResult();
  }

  void setAnimationEnabled(bool value) {
    animationEnabled.value = value;
  }

  void setProbabilityEnabled(bool value) {
    probabilityEnabled.value = value;
    _clearCurrentResult();
  }

  void setTargetFace(int value) {
    RangeError.checkValueInInterval(value, 1, 6, 'targetFace');
    targetFace.value = value;
    _clearCurrentResult();
  }

  void setTargetProbability(int value) {
    RangeError.checkValueInInterval(value, 0, 100, 'targetProbability');
    targetProbability.value = value;
    _clearCurrentResult();
  }

  void prepareRoll() {
    if (isRolling.value) {
      throw StateError('Roll already in progress');
    }

    isRolling.value = true;
    _pendingRoll = null;
    try {
      final countSnapshot = diceCount.value;
      final configSnapshot = probabilityConfig.value;
      final values = _generator.roll(
        diceCount: countSnapshot,
        config: configSnapshot,
      );
      _pendingRoll = _PendingRoll(
        diceCount: countSnapshot,
        values: values,
        probabilityConfig: configSnapshot,
      );
    } catch (_) {
      isRolling.value = false;
      _pendingRoll = null;
      rethrow;
    }
  }

  void commitRoll() {
    final pending = _pendingRoll;
    if (pending == null) {
      throw StateError('No prepared roll to commit');
    }

    currentValues.value = List<int>.unmodifiable(pending.values);
    final nextHistory = <RollRecord>[
      RollRecord(
        timestamp: _now(),
        diceCount: pending.diceCount,
        values: pending.values,
        probabilityConfig: pending.probabilityConfig,
      ),
      ...history.value,
    ];
    history.value = List<RollRecord>.unmodifiable(nextHistory.take(20));
    _pendingRoll = null;
    isRolling.value = false;
  }

  void cancelRoll() {
    _pendingRoll = null;
    isRolling.value = false;
  }

  void clearHistory() {
    history.value = const [];
  }

  void _clearCurrentResult() {
    currentValues.value = const [];
  }
}

class _PendingRoll {
  const _PendingRoll({
    required this.diceCount,
    required this.values,
    required this.probabilityConfig,
  });

  final int diceCount;
  final List<int> values;
  final DiceProbabilityConfig probabilityConfig;
}
