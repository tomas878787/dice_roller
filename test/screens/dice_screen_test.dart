import 'package:dice_roller/app.dart';
import 'package:dice_roller/models/dice_probability_config.dart';
import 'package:dice_roller/services/dice_sound_player.dart';
import 'package:dice_roller/state/dice_game_store.dart';
import 'package:dice_roller/widgets/dice_face.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class StubDiceGenerator implements DiceRoller {
  @override
  List<int> roll({
    required int diceCount,
    required DiceProbabilityConfig config,
  }) {
    return List<int>.filled(diceCount, config.enabled ? config.targetFace : 4);
  }
}

class RecordingDiceSoundPlayer implements DiceSoundPlayer {
  int playRollCount = 0;
  int stopCount = 0;
  bool disposed = false;

  @override
  Future<void> playRoll() async {
    playRollCount += 1;
  }

  @override
  Future<void> stop() async {
    stopCount += 1;
  }

  @override
  void dispose() {
    disposed = true;
  }
}

void main() {
  testWidgets('main screen rolls dice and writes history', (tester) async {
    final store = DiceGameStore(generator: StubDiceGenerator())
      ..setAnimationEnabled(false);

    await tester.pumpWidget(
      DiceRollerApp(store: store, soundPlayer: const SilentDiceSoundPlayer()),
    );

    expect(find.text('点击掷骰'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '掷骰子'));
    await tester.pumpAndSettle();

    expect(find.text('合计 4'), findsOneWidget);

    await tester.tap(find.byTooltip('历史记录'));
    await tester.pumpAndSettle();

    expect(find.textContaining('合计 4'), findsWidgets);
  });

  testWidgets('settings can change dice count and probability mode', (
    tester,
  ) async {
    final store = DiceGameStore(generator: StubDiceGenerator())
      ..setAnimationEnabled(false);

    await tester.pumpWidget(
      DiceRollerApp(store: store, soundPlayer: const SilentDiceSoundPlayer()),
    );

    await tester.tap(find.byTooltip('设置'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('dice-count-3')));
    await tester.tap(find.byType(SwitchListTile).last);
    await tester.pumpAndSettle();

    expect(store.diceCount.value, 3);
    expect(store.probabilityEnabled.value, isTrue);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('点击掷骰'), findsOneWidget);
    expect(find.text('3 颗 D6'), findsNothing);
    expect(find.textContaining('概率模式'), findsNothing);
  });

  testWidgets('settings selected dice and target options use color only', (
    tester,
  ) async {
    final store = DiceGameStore(generator: StubDiceGenerator())
      ..setAnimationEnabled(false);

    await tester.pumpWidget(
      DiceRollerApp(store: store, soundPlayer: const SilentDiceSoundPlayer()),
    );

    await tester.tap(find.byTooltip('设置'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check), findsNothing);

    await tester.tap(find.byType(SwitchListTile).last);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check), findsNothing);
  });

  testWidgets('history clear asks for confirmation', (tester) async {
    final store = DiceGameStore(generator: StubDiceGenerator())
      ..setAnimationEnabled(false);

    await tester.pumpWidget(
      DiceRollerApp(store: store, soundPlayer: const SilentDiceSoundPlayer()),
    );
    await tester.tap(find.widgetWithText(FilledButton, '掷骰子'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('历史记录'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('清空历史'));
    await tester.pumpAndSettle();

    expect(find.text('清空历史记录？'), findsOneWidget);

    await tester.tap(find.text('清空'));
    await tester.pumpAndSettle();

    expect(store.history.value, isEmpty);
    expect(find.text('还没有历史记录'), findsOneWidget);
  });

  testWidgets('rolling animation commits once after it finishes', (
    tester,
  ) async {
    final store = DiceGameStore(generator: StubDiceGenerator());

    await tester.pumpWidget(
      DiceRollerApp(store: store, soundPlayer: const SilentDiceSoundPlayer()),
    );

    await tester.tap(find.widgetWithText(FilledButton, '掷骰子'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(store.isRolling.value, isTrue);
    expect(store.history.value, isEmpty);

    await tester.pumpAndSettle();

    expect(store.isRolling.value, isFalse);
    expect(store.history.value, hasLength(1));
    expect(find.text('合计 4'), findsOneWidget);
  });

  testWidgets('roll sound plays only while rolling animation is active', (
    tester,
  ) async {
    final store = DiceGameStore(generator: StubDiceGenerator());
    final soundPlayer = RecordingDiceSoundPlayer();

    await tester.pumpWidget(
      DiceRollerApp(store: store, soundPlayer: soundPlayer),
    );

    await tester.tap(find.widgetWithText(FilledButton, '掷骰子'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(store.isRolling.value, isTrue);
    expect(soundPlayer.playRollCount, 1);
    expect(soundPlayer.stopCount, 0);

    await tester.pumpAndSettle();

    expect(store.isRolling.value, isFalse);
    expect(soundPlayer.playRollCount, 1);
    expect(soundPlayer.stopCount, 1);
    expect(soundPlayer.disposed, isFalse);
  });

  testWidgets('roll sound does not play when animation is disabled', (
    tester,
  ) async {
    final store = DiceGameStore(generator: StubDiceGenerator())
      ..setAnimationEnabled(false);
    final soundPlayer = RecordingDiceSoundPlayer();

    await tester.pumpWidget(
      DiceRollerApp(store: store, soundPlayer: soundPlayer),
    );

    await tester.tap(find.widgetWithText(FilledButton, '掷骰子'));
    await tester.pumpAndSettle();

    expect(store.isRolling.value, isFalse);
    expect(soundPlayer.playRollCount, 0);
    expect(soundPlayer.stopCount, 0);
    expect(find.text('合计 4'), findsOneWidget);
  });

  testWidgets('main screen renders on compact and wide surfaces', (
    tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    for (final size in const [Size(320, 568), Size(900, 700)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;

      await tester.pumpWidget(
        DiceRollerApp(
          store: DiceGameStore(generator: StubDiceGenerator()),
          soundPlayer: const SilentDiceSoundPlayer(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('掷骰子'), findsWidgets);
      expect(find.text('点击掷骰'), findsOneWidget);
    }
  });

  testWidgets('main screen uses a deep green table theme', (tester) async {
    await tester.pumpWidget(
      DiceRollerApp(
        store: DiceGameStore(generator: StubDiceGenerator()),
        soundPlayer: const SilentDiceSoundPlayer(),
      ),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(Scaffold).first);
    final theme = Theme.of(context);

    expect(theme.scaffoldBackgroundColor, const Color(0xFF0D2827));
    expect(theme.appBarTheme.backgroundColor, const Color(0xFF0D2827));
  });

  testWidgets('main screen keeps the dice area above the lower half', (
    tester,
  ) async {
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;

    await tester.pumpWidget(
      DiceRollerApp(
        store: DiceGameStore(generator: StubDiceGenerator()),
        soundPlayer: const SilentDiceSoundPlayer(),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.byType(DiceFace)).dy, lessThan(200));
  });
}
