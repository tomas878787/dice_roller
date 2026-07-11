import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'router/app_router.dart';
import 'services/dice_sound_player.dart';
import 'state/dice_game_store.dart';

class DiceRollerApp extends StatelessWidget {
  DiceRollerApp({super.key, DiceGameStore? store, this.soundPlayer})
    : store = store ?? DiceGameStore() {
    router = createAppRouter(this.store, soundPlayer: soundPlayer);
  }

  final DiceGameStore store;
  final DiceSoundPlayer? soundPlayer;
  late final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: false,
      builder: (context, child) {
        return MaterialApp.router(
          title: '掷骰子',
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              brightness: Brightness.dark,
              seedColor: const Color(0xFF0D2827),
              primary: const Color(0xFFF6B656),
              secondary: const Color(0xFFFFD891),
              surface: const Color(0xFF123431),
              surfaceContainerHighest: const Color(0xFF1B4842),
            ),
            scaffoldBackgroundColor: const Color(0xFF0D2827),
            appBarTheme: const AppBarTheme(
              centerTitle: false,
              backgroundColor: Color(0xFF0D2827),
              foregroundColor: Color(0xFFFFF7E8),
              elevation: 0,
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFF6B656),
                foregroundColor: const Color(0xFF18312D),
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.r),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
