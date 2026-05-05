import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/audio_service.dart';

class PlaybackSessionController extends ChangeNotifier {
  PlaybackSessionController({required this.audioService, Duration? defaultDuration})
    : _defaultDuration = defaultDuration ?? const Duration(minutes: 25),
      _remaining = defaultDuration ?? const Duration(minutes: 25);

  final AudioService audioService;

  final Duration _defaultDuration;
  Duration _remaining;
  bool _isPlaying = false;
  bool _repeatEnabled = false;
  bool _shuffleEnabled = false;
  Timer? _timer;

  Duration get remaining => _remaining;
  bool get isPlaying => _isPlaying;
  bool get repeatEnabled => _repeatEnabled;
  bool get shuffleEnabled => _shuffleEnabled;

  String get formattedRemaining {
    final minutes = _remaining.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final seconds = _remaining.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void applyPlayOnStartup({required bool enabled, required bool hasSelection}) {
    if (!enabled || !hasSelection) return;
    start();
  }

  void onSelectionChanged(bool hasSelection) {
    if (!hasSelection) {
      pause();
    }
  }

  void togglePlayPause() {
    if (_isPlaying) {
      pause();
    } else {
      start();
    }
  }

  void start() {
    if (_isPlaying) return;
    if (_remaining == Duration.zero) {
      _remaining = _defaultDuration;
    }
    _isPlaying = true;
    unawaited(audioService.play());
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
    notifyListeners();
  }

  void pause() {
    if (!_isPlaying) return;
    _isPlaying = false;
    unawaited(audioService.stop());
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  void toggleRepeat() {
    _repeatEnabled = !_repeatEnabled;
    notifyListeners();
  }

  void toggleShuffle() {
    _shuffleEnabled = !_shuffleEnabled;
    notifyListeners();
  }

  void resetSession([Duration? duration]) {
    _remaining = duration ?? _defaultDuration;
    notifyListeners();
  }

  void _onTick(Timer timer) {
    if (!_isPlaying) return;

    if (_remaining.inSeconds <= 1) {
      if (_repeatEnabled) {
        _remaining = _defaultDuration;
      } else {
        _remaining = Duration.zero;
        _isPlaying = false;
        unawaited(audioService.stop());
        timer.cancel();
        _timer = null;
      }
      notifyListeners();
      return;
    }

    _remaining -= const Duration(seconds: 1);
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
