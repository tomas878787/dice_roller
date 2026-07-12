import 'package:dice_roller/widgets/dice_board.dart';
import 'package:dice_roller/widgets/dice_face.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Finder findDiceCupImage() {
    return find.byWidgetPredicate((widget) {
      if (widget is! Image) {
        return false;
      }
      final image = widget.image;
      return image is AssetImage &&
          image.assetName == 'assets/images/dice_cup.png';
    });
  }

  testWidgets('DiceBoard shows the dice cup while animating', (tester) async {
    await tester.pumpWidget(
      _TestHost(
        child: DiceBoard(
          diceCount: 1,
          values: const [4],
          isRolling: true,
          animationValue: 0.5,
        ),
      ),
    );

    expect(findDiceCupImage(), findsOneWidget);
    expect(find.byType(DiceFace), findsNothing);
  });

  testWidgets('DiceBoard shows the dice cup before any result exists', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestHost(
        child: DiceBoard(
          diceCount: 1,
          values: const [],
          isRolling: false,
          animationValue: 0,
        ),
      ),
    );

    expect(findDiceCupImage(), findsOneWidget);
    expect(find.byType(DiceFace), findsNothing);
  });

  testWidgets('DiceBoard leaves rolling frame empty when idle', (tester) async {
    await tester.pumpWidget(
      _TestHost(
        child: DiceBoard(
          diceCount: 1,
          values: const [4],
          isRolling: false,
          animationValue: 0,
        ),
      ),
    );

    final face = tester.widget<DiceFace>(find.byType(DiceFace));

    expect(face.value, 4);
    expect(face.rollingFrame, isNull);
  });
}

class _TestHost extends StatelessWidget {
  const _TestHost({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, _) => MaterialApp(home: Scaffold(body: child)),
    );
  }
}
