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
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0F766E),
              primary: const Color(0xFF0F766E),
              secondary: const Color(0xFFD97706),
              surface: const Color(0xFFFAFAF7),
            ),
            scaffoldBackgroundColor: const Color(0xFFFAFAF7),
            appBarTheme: const AppBarTheme(
              centerTitle: false,
              backgroundColor: Color(0xFFFAFAF7),
              foregroundColor: Color(0xFF17201F),
              elevation: 0,
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
