import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../models/noise_mix.dart';

class AudioService {
  AudioService();

  final AudioPlayer _brownPlayer = AudioPlayer();
  final AudioPlayer _pinkPlayer = AudioPlayer();
  final AudioPlayer _greenPlayer = AudioPlayer();
  final AudioPlayer _whitePlayer = AudioPlayer();

  Future<void>? _initFuture;
  bool _disposed = false;
  NoiseMix _lastMix = const NoiseMix.defaults();

  Future<void> init() {
    _initFuture ??= _initPlayers();
    return _initFuture!;
  }

  Future<void> play() async {
    if (_disposed) return;
    try {
      await init();
      await _applyVolumes(_lastMix);
      await Future.wait(<Future<void>>[
        _brownPlayer.play(),
        _pinkPlayer.play(),
        _greenPlayer.play(),
        _whitePlayer.play(),
      ]);
    } catch (e, st) {
      if (kDebugMode) {
        print('AudioService.play() failed: $e\n$st');
      }
    }
  }

  Future<void> stop() async {
    if (_disposed) return;
    try {
      await Future.wait(<Future<void>>[
        _brownPlayer.stop(),
        _pinkPlayer.stop(),
        _greenPlayer.stop(),
        _whitePlayer.stop(),
      ]);
    } catch (e, st) {
      if (kDebugMode) {
        print('AudioService.stop() failed: $e\n$st');
      }
    }
  }

  void updateVolumes(NoiseMix mix) {
    _lastMix = mix;
    if (_disposed) return;
    unawaited(_applyVolumes(mix));
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await Future.wait(<Future<void>>[
      _brownPlayer.dispose(),
      _pinkPlayer.dispose(),
      _greenPlayer.dispose(),
      _whitePlayer.dispose(),
    ]);
  }

  Future<void> _initPlayers() async {
    await Future.wait(<Future<void>>[
      _configurePlayer(_brownPlayer, 'assets/audio/brown.mp3'),
      _configurePlayer(_pinkPlayer, 'assets/audio/pink.mp3'),
      _configurePlayer(_greenPlayer, 'assets/audio/green.mp3'),
      _configurePlayer(_whitePlayer, 'assets/audio/white.mp3'),
    ]);
    if (_disposed) return;
    updateVolumes(_lastMix);
  }

  Future<void> _configurePlayer(AudioPlayer player, String assetPath) async {
    try {
      await player.setAsset(assetPath);
      await player.setLoopMode(LoopMode.one);
    } catch (e, st) {
      if (kDebugMode) {
        print('AudioService: failed to load $assetPath: $e\n$st');
      }
    }
  }

  Future<void> _applyVolumes(NoiseMix mix) {
    return Future.wait(<Future<void>>[
      _brownPlayer.setVolume(mix.brown),
      _pinkPlayer.setVolume(mix.pink),
      _greenPlayer.setVolume(mix.green),
      _whitePlayer.setVolume(mix.white),
    ]);
  }
}
