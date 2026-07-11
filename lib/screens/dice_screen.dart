import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../state/dice_game_store.dart';
import '../widgets/dice_board.dart';

class DiceScreen extends StatefulWidget {
  const DiceScreen({super.key, required this.store});

  final DiceGameStore store;

  @override
  State<DiceScreen> createState() => _DiceScreenState();
}

class _DiceScreenState extends State<DiceScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curve;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    if (widget.store.isRolling.value) {
      widget.store.cancelRoll();
    }
    _controller.dispose();
    super.dispose();
  }

  Future<void> _roll() async {
    if (widget.store.isRolling.value) {
      return;
    }

    widget.store.prepareRoll();
    final mediaQuery = MediaQuery.of(context);
    final shouldAnimate =
        widget.store.animationEnabled.value && !mediaQuery.disableAnimations;

    if (shouldAnimate) {
      await _controller.forward(from: 0);
      if (!mounted) {
        widget.store.cancelRoll();
        return;
      }
    }

    widget.store.commitRoll();
    _controller.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final store = widget.store;
        final isRolling = store.isRolling.value;

        return Scaffold(
          appBar: AppBar(
            title: const Text('掷骰子'),
            actions: [
              IconButton(
                tooltip: '历史记录',
                onPressed: isRolling ? null : () => context.push('/history'),
                icon: const Icon(Icons.history_rounded),
              ),
              IconButton(
                tooltip: '设置',
                onPressed: isRolling ? null : () => context.push('/settings'),
                icon: const Icon(Icons.tune_rounded),
              ),
              SizedBox(width: 4.w),
            ],
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.r, 10.r, 20.r, 22.r),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 32.r,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            //_StatusStrip(store: store),
                            SizedBox(height: 22.r),
                            AnimatedBuilder(
                              animation: _curve,
                              builder: (context, child) {
                                return DiceBoard(
                                  diceCount: store.diceCount.value,
                                  values: store.currentValues.value,
                                  isRolling: isRolling,
                                  animationValue: _curve.value,
                                );
                              },
                            ),
                            SizedBox(height: 24.r),
                            _ResultPanel(store: store),
                            SizedBox(height: 24.r),
                            FilledButton.icon(
                              onPressed: isRolling ? null : _roll,
                              icon: Icon(
                                isRolling
                                    ? Icons.hourglass_top_rounded
                                    : Icons.casino_rounded,
                              ),
                              label: Text(isRolling ? '掷骰中' : '掷骰子'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _StatusStrip extends StatelessWidget {
  const _StatusStrip({required this.store});

  final DiceGameStore store;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final probabilityOn = store.probabilityEnabled.value;

    return Wrap(
      spacing: 10.r,
      runSpacing: 10.r,
      children: [
        _StatusPill(
          icon: Icons.grid_view_rounded,
          label: '${store.diceCount.value} 颗 D6',
          color: theme.colorScheme.primary,
        ),
        if (probabilityOn)
          _StatusPill(
            icon: Icons.percent_rounded,
            label:
                '概率模式 · 目标 ${store.targetFace.value} · ${store.targetProbability.value}%',
            color: theme.colorScheme.secondary,
          )
        else
          _StatusPill(
            icon: Icons.balance_rounded,
            label: '公平随机',
            color: const Color(0xFF64706B),
          ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 8.r),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18.r, color: color),
            SizedBox(width: 6.r),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({required this.store});

  final DiceGameStore store;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasResult = store.hasResult.value;

    return Semantics(
      liveRegion: true,
      label: hasResult ? '合计 ${store.total.value}' : '点击掷骰',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: const Color(0xFFE4E7DF)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.r, vertical: 18.r),
          child: Column(
            children: [
              Text(
                hasResult ? '合计 ${store.total.value}' : '点击掷骰',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF17201F),
                ),
              ),
              SizedBox(height: 6.r),
              Text(
                hasResult
                    ? '点数：${store.currentValues.value.join('、')}'
                    : '结果会在动画结束后一次性公布',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF65706B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
