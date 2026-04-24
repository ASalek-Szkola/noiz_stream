import 'package:flutter/foundation.dart';

@immutable
class NoiseMix {
  const NoiseMix({
    required this.brown,
    required this.pink,
    required this.green,
    required this.white,
  });

  const NoiseMix.defaults()
    : brown = 0.41,
      pink = 0.51,
      green = 0.20,
      white = 0.72;

  final double brown;
  final double pink;
  final double green;
  final double white;

  NoiseMix copyWith({
    double? brown,
    double? pink,
    double? green,
    double? white,
  }) {
    return NoiseMix(
      brown: _normalizeLevel(brown ?? this.brown),
      pink: _normalizeLevel(pink ?? this.pink),
      green: _normalizeLevel(green ?? this.green),
      white: _normalizeLevel(white ?? this.white),
    );
  }

  NoiseMix withLevelForIndex(int index, double value) {
    final normalized = _normalizeLevel(value);
    switch (index) {
      case 0:
        return copyWith(brown: normalized);
      case 1:
        return copyWith(pink: normalized);
      case 2:
        return copyWith(green: normalized);
      case 3:
        return copyWith(white: normalized);
      default:
        return this;
    }
  }

  double valueForIndex(int index) {
    switch (index) {
      case 0:
        return brown;
      case 1:
        return pink;
      case 2:
        return green;
      case 3:
        return white;
      default:
        return 0.0;
    }
  }

  int dominantIndex() {
    final values = <double>[brown, pink, green, white];
    var maxIndex = 0;
    var maxValue = values[0];

    for (var i = 1; i < values.length; i++) {
      if (values[i] > maxValue) {
        maxValue = values[i];
        maxIndex = i;
      }
    }

    return maxIndex;
  }

  Map<String, double> toMap() {
    return <String, double>{
      'brown': brown,
      'pink': pink,
      'green': green,
      'white': white,
    };
  }

  factory NoiseMix.fromMap(Map<String, dynamic> map) {
    double readLevel(String key) {
      final level = map[key];
      if (level is num) {
        return _normalizeLevel(level.toDouble());
      }
      return 0.0;
    }

    return NoiseMix(
      brown: readLevel('brown'),
      pink: readLevel('pink'),
      green: readLevel('green'),
      white: readLevel('white'),
    );
  }

  static double _normalizeLevel(double value) {
    return value.clamp(0.0, 1.0).toDouble();
  }
}
