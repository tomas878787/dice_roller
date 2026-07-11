import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../state/dice_game_store.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.store});

  final DiceGameStore store;

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final probabilityOn = store.probabilityEnabled.value;

        return Scaffold(
          appBar: AppBar(title: const Text('设置')),
          body: SafeArea(
            child: ListView(
              padding: EdgeInsets.fromLTRB(18.r, 10.r, 18.r, 10.r),
              children: [
                _Section(
                  title: '骰子数量',
                  child: SegmentedButton<int>(
                    selectedIcon: const SizedBox.shrink(),
                    segments: List.generate(
                      6,
                      (index) => ButtonSegment<int>(
                        value: index + 1,
                        label: Text(
                          '${index + 1}',
                          key: ValueKey('dice-count-${index + 1}'),
                        ),
                      ),
                    ),
                    selected: {store.diceCount.value},
                    onSelectionChanged: (values) {
                      store.setDiceCount(values.first);
                    },
                  ),
                ),
                SizedBox(height: 14.r),
                _Panel(
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('动画效果'),
                    subtitle: const Text('关闭后立即显示结果'),
                    secondary: const Icon(Icons.motion_photos_on_rounded),
                    value: store.animationEnabled.value,
                    onChanged: store.setAnimationEnabled,
                  ),
                ),
                SizedBox(height: 14.r),
                _Panel(
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('概率模式'),
                    subtitle: const Text('明确控制目标点数出现概率'),
                    secondary: const Icon(Icons.percent_rounded),
                    value: probabilityOn,
                    onChanged: store.setProbabilityEnabled,
                  ),
                ),
                SizedBox(height: 14.r),
                _Section(
                  title: '目标点数',
                  enabled: probabilityOn,
                  child: SegmentedButton<int>(
                    selectedIcon: const SizedBox.shrink(),
                    segments: List.generate(
                      6,
                      (index) => ButtonSegment<int>(
                        value: index + 1,
                        label: Text(
                          '${index + 1}',
                          key: ValueKey('target-face-${index + 1}'),
                        ),
                        enabled: probabilityOn,
                      ),
                    ),
                    selected: {store.targetFace.value},
                    onSelectionChanged: probabilityOn
                        ? (values) => store.setTargetFace(values.first)
                        : null,
                  ),
                ),
                SizedBox(height: 14.r),
                _Panel(
                  enabled: probabilityOn,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            color: probabilityOn
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).disabledColor,
                          ),
                          SizedBox(width: 12.r),
                          Text(
                            '目标概率 ${store.targetProbability.value}%',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      Slider(
                        value: store.targetProbability.value.toDouble(),
                        min: 0,
                        max: 100,
                        divisions: 20,
                        label: '${store.targetProbability.value}%',
                        onChanged: probabilityOn
                            ? (value) => store.setTargetProbability(
                                (value / 5).round() * 5,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14.r),
                const _AboutPanel(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
    this.enabled = true,
  });

  final String title;
  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      enabled: enabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 12.r),
          child,
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.enabled = true});

  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Padding(padding: EdgeInsets.all(16.r), child: child),
      ),
    );
  }
}

class _AboutPanel extends StatelessWidget {
  const _AboutPanel();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.casino_rounded),
        title: const Text('Dice Roller'),
        subtitle: const Text('1.0.0 · 离线单机掷骰工具'),
      ),
    );
  }
}
