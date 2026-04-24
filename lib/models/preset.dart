import 'package:flutter/material.dart';

import 'noise_mix.dart';

@immutable
class Preset {
  const Preset({
    required this.name,
    required this.mix,
    required this.color,
    this.isCustom = false,
  });

  final String name;
  final NoiseMix mix;
  final Color color;
  final bool isCustom;

  Preset copyWith({String? name, NoiseMix? mix, Color? color, bool? isCustom}) {
    return Preset(
      name: name ?? this.name,
      mix: mix ?? this.mix,
      color: color ?? this.color,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, Object> toStorageJson() {
    final levels = mix.toMap();
    return <String, Object>{
      'name': name,
      'color': color.toARGB32(),
      'brown': levels['brown'] ?? 0.0,
      'pink': levels['pink'] ?? 0.0,
      'green': levels['green'] ?? 0.0,
      'white': levels['white'] ?? 0.0,
    };
  }

  static Preset? fromStorageJson(
    Map<String, dynamic> json, {
    required Color fallbackColor,
    bool isCustom = true,
  }) {
    final nameValue = json['name'];
    if (nameValue is! String) {
      return null;
    }

    final normalizedName = nameValue.trim();
    if (normalizedName.isEmpty) {
      return null;
    }

    final colorValue = json['color'];

    return Preset(
      name: normalizedName,
      mix: NoiseMix.fromMap(json),
      color: colorValue is int ? Color(colorValue) : fallbackColor,
      isCustom: isCustom,
    );
  }
}
