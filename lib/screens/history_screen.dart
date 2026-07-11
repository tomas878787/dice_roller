import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../models/roll_record.dart';
import '../state/dice_game_store.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.store});

  final DiceGameStore store;

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final records = store.history.value;

        return Scaffold(
          appBar: AppBar(
            title: const Text('历史记录'),
            actions: [
              IconButton(
                tooltip: '清空历史',
                onPressed: records.isEmpty
                    ? null
                    : () => _confirmClear(context),
                icon: const Icon(Icons.delete_outline_rounded),
              ),
              SizedBox(width: 4.w),
            ],
          ),
          body: SafeArea(
            child: records.isEmpty
                ? const _EmptyHistory()
                : ListView.separated(
                    padding: EdgeInsets.all(18.r),
                    itemCount: records.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 10.r),
                    itemBuilder: (context, index) {
                      return _HistoryTile(record: records[index]);
                    },
                  ),
          ),
        );
      },
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空历史记录？'),
        content: const Text('只会清空本次运行内的记录。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('清空'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      store.clearHistory();
    }
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.record});

  final RollRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = record.probabilityConfig;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_formatTime(record.timestamp)} · ${record.diceCount} 颗 · [${record.values.join(', ')}] · 合计 ${record.total}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (config.enabled) ...[
              SizedBox(height: 8.r),
              Text(
                '概率模式：目标 ${config.targetFace} · ${config.targetProbability}%',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    String pad(int value) => value.toString().padLeft(2, '0');
    return '${pad(time.hour)}:${pad(time.minute)}';
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(28.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_toggle_off_rounded,
              size: 54.r,
              color: Theme.of(context).colorScheme.outline,
            ),
            SizedBox(height: 12.r),
            Text('还没有历史记录', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
