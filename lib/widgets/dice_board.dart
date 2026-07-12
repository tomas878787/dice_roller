import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'dice_face.dart';

class DiceBoard extends StatelessWidget {
  const DiceBoard({
    super.key,
    required this.diceCount,
    required this.values,
    required this.isRolling,
    required this.animationValue,
  });

  final int diceCount;
  final List<int> values;
  final bool isRolling;
  final double animationValue;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final shouldShowCup = isRolling || values.isEmpty;
        if (shouldShowCup) {
          final cupSize = math
              .min(constraints.maxWidth, 280.0)
              .clamp(170.0, 280.0);

          return Center(
            child: _DiceCup(
              size: cupSize,
              isShaking: isRolling,
              animationValue: animationValue,
            ),
          );
        }

        final columns = diceCount <= 3 ? diceCount : 3;
        final spacing = 14.r;
        final maxBoardWidth = math.min(constraints.maxWidth, 420.0);
        final faceSize = ((maxBoardWidth - spacing * (columns - 1)) / columns)
            .clamp(76.0, 116.0);

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Wrap(
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              spacing: spacing,
              runSpacing: spacing,
              children: List.generate(diceCount, (index) {
                final displayValue = _displayValue(index);
                final wobble = math.sin(animationValue * math.pi);
                final rotation = isRolling
                    ? (animationValue * math.pi * 4) * (index.isEven ? 1 : -1)
                    : 0.0;
                final scale = isRolling ? 1 + wobble * 0.07 : 1.0;
                final dy = isRolling ? -14.r * wobble : 0.0;

                return Transform.translate(
                  offset: Offset(0, dy),
                  child: Transform.rotate(
                    angle: rotation,
                    child: Transform.scale(
                      scale: scale,
                      child: DiceFace(
                        value: displayValue,
                        size: faceSize,
                        index: index,
                        isPlaceholder: values.isEmpty && !isRolling,
                        rollingFrame: _rollingFrame(index),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }

  int _displayValue(int index) {
    if (isRolling) {
      return ((animationValue * 24).floor() + index * 2) % 6 + 1;
    }
    if (index < values.length) {
      return values[index];
    }
    return 1;
  }

  int? _rollingFrame(int index) {
    if (!isRolling) {
      return null;
    }
    return ((animationValue * 12).floor() + index) % 3 + 1;
  }
}

class _DiceCup extends StatelessWidget {
  const _DiceCup({
    required this.size,
    required this.isShaking,
    required this.animationValue,
  });

  final double size;
  final bool isShaking;
  final double animationValue;

  @override
  Widget build(BuildContext context) {
    final shake = math.sin(animationValue * math.pi * 8);
    final settle = math.sin(animationValue * math.pi);
    final dx = isShaking ? shake * 12.r : 0.0;
    final dy = isShaking ? -settle * 8.r : 0.0;
    final rotation = isShaking ? shake * 0.1 : 0.0;
    final scale = isShaking ? 1 + settle * 0.035 : 1.0;

    return Semantics(
      label: isShaking ? '骰盅晃动中' : '骰盅',
      image: true,
      child: Transform.translate(
        offset: Offset(dx, dy),
        child: Transform.rotate(
          angle: rotation,
          child: Transform.scale(
            scale: scale,
            child: SizedBox.square(
              dimension: size,
              child: Image.asset(
                'assets/images/dice_cup.png',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                gaplessPlayback: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
