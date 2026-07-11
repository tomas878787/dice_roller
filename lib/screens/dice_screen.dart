import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../services/dice_sound_player.dart';
import '../state/dice_game_store.dart';
import '../widgets/dice_board.dart';

class DiceScreen extends StatefulWidget {
  const DiceScreen({super.key, required this.store, this.soundPlayer});

  final DiceGameStore store;
  final DiceSoundPlayer? soundPlayer;

  @override
  State<DiceScreen> createState() => _DiceScreenState();
}

class _DiceScreenState extends State<DiceScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curve;
  late final DiceSoundPlayer _soundPlayer;
  late final bool _ownsSoundPlayer;

  @override
  void initState() {
    super.initState();
    _ownsSoundPlayer = widget.soundPlayer == null;
    _soundPlayer = widget.soundPlayer ?? AudioplayersDiceSoundPlayer();
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
    unawaited(_soundPlayer.stop());
    if (_ownsSoundPlayer) {
      _soundPlayer.dispose();
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
      await _playRollSound();
      try {
        await _controller.forward(from: 0);
      } finally {
        await _stopRollSound();
      }
      if (!mounted) {
        widget.store.cancelRoll();
        return;
      }
    }

    widget.store.commitRoll();
    _controller.value = 0;
  }

  Future<void> _playRollSound() async {
    try {
      await _soundPlayer.playRoll();
    } catch (error, stackTrace) {
      reportDiceSoundError(error, stackTrace);
    }
  }

  Future<void> _stopRollSound() async {
    try {
      await _soundPlayer.stop();
    } catch (error, stackTrace) {
      reportDiceSoundError(error, stackTrace);
    }
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
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF16453F),
                  Color(0xFF0F3432),
                  Color(0xFF0D2827),
                ],
              ),
            ),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20.r, 10.r, 20.r, 22.r),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 32.r,
                      ),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 560),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: 28.r),
                              _DiceTablePanel(
                                child: AnimatedBuilder(
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
                              ),
                              SizedBox(height: 22.r),
                              _ResultPanel(store: store),
                              SizedBox(height: 22.r),
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
          ),
        );
      },
    );
  }
}

class _DiceTablePanel extends StatelessWidget {
  const _DiceTablePanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.r, vertical: 24.r),
      child: child,
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
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.r, vertical: 18.r),
        child: Column(
          children: [
            Text(
              hasResult ? '合计 ${store.total.value}' : '点击掷骰',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFFFFF7E8),
              ),
            ),
            SizedBox(height: 6.r),
            Text(
              hasResult
                  ? '点数：${store.currentValues.value.join('、')}'
                  : '结果会在动画结束后一次性公布',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xCCFFF7E8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
