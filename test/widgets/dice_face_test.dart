import 'package:dice_roller/widgets/dice_face.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('DiceFace renders the matching image asset', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: DiceFace(value: 4, size: 96),
      ),
    );

    final image = tester.widget<Image>(find.byType(Image));
    final provider = image.image;

    expect(provider, isA<AssetImage>());
    expect((provider as AssetImage).assetName, 'assets/images/dice_4.png');
  });

  testWidgets('DiceFace renders a rolling frame asset while animating', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: DiceFace(value: 4, size: 96, rollingFrame: 2),
      ),
    );

    final image = tester.widget<Image>(find.byType(Image));
    final provider = image.image;

    expect(provider, isA<AssetImage>());
    expect((provider as AssetImage).assetName, 'assets/images/dice_roll_2.png');
  });
}
