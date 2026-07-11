import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/dice_screen.dart';
import '../screens/history_screen.dart';
import '../screens/settings_screen.dart';
import '../services/dice_sound_player.dart';
import '../state/dice_game_store.dart';

GoRouter createAppRouter(DiceGameStore store, {DiceSoundPlayer? soundPlayer}) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            DiceScreen(store: store, soundPlayer: soundPlayer),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => HistoryScreen(store: store),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => SettingsScreen(store: store),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('页面不存在')),
      body: Center(
        child: FilledButton.icon(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.casino_outlined),
          label: const Text('返回掷骰子'),
        ),
      ),
    ),
  );
}
