import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

abstract class DiceSoundPlayer {
  Future<void> playRoll();

  Future<void> stop();

  void dispose();
}

class AudioplayersDiceSoundPlayer implements DiceSoundPlayer {
  AudioplayersDiceSoundPlayer() {
    unawaited(_player.setReleaseMode(ReleaseMode.stop));
  }

  final AudioPlayer _player = AudioPlayer();

  @override
  Future<void> playRoll() async {
    await _player.stop();
    await _player.play(
      AssetSource('audio/dice_roll.wav', mimeType: 'audio/wav'),
      volume: 0.8,
    );
  }

  @override
  Future<void> stop() {
    return _player.stop();
  }

  @override
  void dispose() {
    unawaited(_player.dispose());
  }
}

class SilentDiceSoundPlayer implements DiceSoundPlayer {
  const SilentDiceSoundPlayer();

  @override
  Future<void> playRoll() async {}

  @override
  Future<void> stop() async {}

  @override
  void dispose() {}
}

void reportDiceSoundError(Object error, StackTrace stackTrace) {
  FlutterError.reportError(
    FlutterErrorDetails(
      exception: error,
      stack: stackTrace,
      library: 'dice sound',
      context: ErrorDescription('while playing dice roll sound'),
    ),
  );
}
