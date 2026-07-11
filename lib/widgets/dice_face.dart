import 'package:flutter/material.dart';

class DiceFace extends StatelessWidget {
  const DiceFace({
    super.key,
    required this.value,
    required this.size,
    this.index = 0,
    this.isPlaceholder = false,
    this.rollingFrame,
  });

  final int value;
  final double size;
  final int index;
  final bool isPlaceholder;
  final int? rollingFrame;

  @override
  Widget build(BuildContext context) {
    final face = value < 1 || value > 6 ? 1 : value;
    final frame = rollingFrame?.clamp(1, 3);
    final assetPath = frame == null
        ? 'assets/images/dice_$face.png'
        : 'assets/images/dice_roll_$frame.png';

    return Semantics(
      label: '骰子 ${index + 1}，点数 $value',
      image: true,
      child: SizedBox.square(
        dimension: size,
        child: Opacity(
          opacity: isPlaceholder ? 0.52 : 1,
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            gaplessPlayback: true,
            errorBuilder: (context, error, stackTrace) =>
                _DiceFaceFallback(value: face),
          ),
        ),
      ),
    );
  }
}

class _DiceFaceFallback extends StatelessWidget {
  const _DiceFaceFallback({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0E4DC)),
      ),
      child: Center(
        child: Text(
          '$value',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
