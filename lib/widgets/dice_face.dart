import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DiceFace extends StatelessWidget {
  const DiceFace({
    super.key,
    required this.value,
    required this.size,
    this.index = 0,
    this.isPlaceholder = false,
  });

  final int value;
  final double size;
  final int index;
  final bool isPlaceholder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dotColor = isPlaceholder
        ? theme.colorScheme.outlineVariant
        : theme.colorScheme.onSurface;

    return Semantics(
      label: '骰子 ${index + 1}，点数 $value',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isPlaceholder ? const Color(0xFFF1F3EF) : Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: const Color(0xFFE0E4DC)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18.r,
              offset: Offset(0, 10.r),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.9),
              blurRadius: 2.r,
              offset: Offset(-2.r, -2.r),
            ),
          ],
        ),
        child: SizedBox.square(
          dimension: size,
          child: Stack(
            children: _dotOffsets(value)
                .map(
                  (alignment) => Align(
                    alignment: alignment,
                    child: Container(
                      width: (size * 0.13).clamp(8.0, 16.0),
                      height: (size * 0.13).clamp(8.0, 16.0),
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ),
    );
  }

  List<Alignment> _dotOffsets(int face) {
    const topLeft = Alignment(-0.46, -0.46);
    const topRight = Alignment(0.46, -0.46);
    const centerLeft = Alignment(-0.46, 0);
    const center = Alignment(0, 0);
    const centerRight = Alignment(0.46, 0);
    const bottomLeft = Alignment(-0.46, 0.46);
    const bottomRight = Alignment(0.46, 0.46);

    return switch (face) {
      1 => [center],
      2 => [topLeft, bottomRight],
      3 => [topLeft, center, bottomRight],
      4 => [topLeft, topRight, bottomLeft, bottomRight],
      5 => [topLeft, topRight, center, bottomLeft, bottomRight],
      6 => [
        topLeft,
        centerLeft,
        bottomLeft,
        topRight,
        centerRight,
        bottomRight,
      ],
      _ => [center],
    };
  }
}
