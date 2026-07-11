import 'package:dice_roller/app.dart';
import 'package:dice_roller/models/dice_probability_config.dart';
import 'package:dice_roller/state/dice_game_store.dart';
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

void main() {
  testWidgets('main screen rolls dice and writes history', (tester) async {
    final store = DiceGameStore(generator: StubDiceGenerator())
      ..setAnimationEnabled(false);

    await tester.pumpWidget(DiceRollerApp(store: store));

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

    await tester.pumpWidget(DiceRollerApp(store: store));

    await tester.tap(find.byTooltip('设置'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('dice-count-3')));
    await tester.tap(find.byType(SwitchListTile).last);
    await tester.pumpAndSettle();

    expect(store.diceCount.value, 3);
    expect(store.probabilityEnabled.value, isTrue);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('3 颗 D6'), findsOneWidget);
    expect(find.textContaining('概率模式'), findsOneWidget);
  });

  testWidgets('history clear asks for confirmation', (tester) async {
    final store = DiceGameStore(generator: StubDiceGenerator())
      ..setAnimationEnabled(false);

    await tester.pumpWidget(DiceRollerApp(store: store));
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

    await tester.pumpWidget(DiceRollerApp(store: store));

    await tester.tap(find.widgetWithText(FilledButton, '掷骰子'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(store.isRolling.value, isTrue);
    expect(store.history.value, isEmpty);

    await tester.pumpAndSettle();

    expect(store.isRolling.value, isFalse);
    expect(store.history.value, hasLength(1));
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
        DiceRollerApp(store: DiceGameStore(generator: StubDiceGenerator())),
      );
      await tester.pumpAndSettle();

      expect(find.text('掷骰子'), findsWidgets);
      expect(find.text('点击掷骰'), findsOneWidget);
    }
  });
}
