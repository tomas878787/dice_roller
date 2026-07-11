import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const faceImagePaths = [
    'assets/images/dice_1.png',
    'assets/images/dice_2.png',
    'assets/images/dice_3.png',
    'assets/images/dice_4.png',
    'assets/images/dice_5.png',
    'assets/images/dice_6.png',
  ];

  const diceImagePaths = [
    ...faceImagePaths,
    'assets/images/dice_roll_1.png',
    'assets/images/dice_roll_2.png',
    'assets/images/dice_roll_3.png',
  ];

  test('dice image corners are transparent', () async {
    for (final path in diceImagePaths) {
      final bytes = await File(path).readAsBytes();
      final image = await decodeImage(bytes);
      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );

      expect(byteData, isNotNull);

      final transparentCorners = [
        _alphaAt(byteData!, image.width, 0, 0),
        _alphaAt(byteData, image.width, image.width - 1, 0),
        _alphaAt(byteData, image.width, 0, image.height - 1),
        _alphaAt(byteData, image.width, image.width - 1, image.height - 1),
      ];

      expect(transparentCorners, everyElement(0), reason: path);
      image.dispose();
    }
  });

  test('dice face images keep the dice body intact', () async {
    for (final path in faceImagePaths) {
      final bytes = await File(path).readAsBytes();
      final image = await decodeImage(bytes);
      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );

      expect(byteData, isNotNull);

      var transparentPixels = 0;
      for (var y = 0; y < image.height; y += 1) {
        for (var x = 0; x < image.width; x += 1) {
          if (_alphaAt(byteData!, image.width, x, y) == 0) {
            transparentPixels += 1;
          }
        }
      }

      final transparentRatio = transparentPixels / (image.width * image.height);

      expect(transparentRatio, lessThan(0.75), reason: path);
      image.dispose();
    }
  });

  test('dice images use a white body without red fill', () async {
    for (final path in diceImagePaths) {
      final bytes = await File(path).readAsBytes();
      final image = await decodeImage(bytes);
      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );

      expect(byteData, isNotNull);
      final data = byteData!;

      var whiteBodyPixels = 0;
      final redFillPixels = <(int, int)>[];
      for (var y = 0; y < image.height; y += 1) {
        for (var x = 0; x < image.width; x += 1) {
          if (_isWhiteBodyPixel(data, image.width, x, y)) {
            whiteBodyPixels += 1;
          }
          if (_isRedFillPixel(data, image.width, x, y)) {
            redFillPixels.add((x, y));
          }
        }
      }

      expect(whiteBodyPixels, greaterThan(1000), reason: path);
      expect(redFillPixels, isEmpty, reason: path);
      image.dispose();
    }
  });
}

Future<ui.Image> decodeImage(Uint8List bytes) {
  final codecFuture = ui.instantiateImageCodec(bytes);
  return codecFuture.then((codec) async {
    final frame = await codec.getNextFrame();
    codec.dispose();
    return frame.image;
  });
}

int _alphaAt(ByteData byteData, int width, int x, int y) {
  final offset = (y * width + x) * 4;
  return byteData.getUint8(offset + 3);
}

bool _isWhiteBodyPixel(ByteData byteData, int width, int x, int y) {
  final offset = (y * width + x) * 4;
  final red = byteData.getUint8(offset);
  final green = byteData.getUint8(offset + 1);
  final blue = byteData.getUint8(offset + 2);
  final alpha = byteData.getUint8(offset + 3);
  final maxChannel = [red, green, blue].reduce((a, b) => a > b ? a : b);
  final minChannel = [red, green, blue].reduce((a, b) => a < b ? a : b);

  return alpha > 0 &&
      red >= 220 &&
      green >= 220 &&
      blue >= 220 &&
      maxChannel - minChannel <= 40;
}

bool _isRedFillPixel(ByteData byteData, int width, int x, int y) {
  final offset = (y * width + x) * 4;
  final red = byteData.getUint8(offset);
  final green = byteData.getUint8(offset + 1);
  final blue = byteData.getUint8(offset + 2);
  final alpha = byteData.getUint8(offset + 3);

  return alpha > 0 && red > 40 && red > green + 20 && red > blue + 20;
}
