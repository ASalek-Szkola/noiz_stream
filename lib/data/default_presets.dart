import 'package:flutter/material.dart';

import '../models/noise_mix.dart';
import '../models/preset.dart';

const List<Color> presetColorOptions = <Color>[
  Color(0xFF4B5A7A),
  Color(0xFF2F8F60),
  Color(0xFF6D7AA8),
  Color(0xFF4D4A8C),
  Color(0xFFC8746A),
  Color(0xFFC0A15C),
  Color(0xFF5D8E9F),
  Color(0xFF9A72A5),
];

const List<Preset> builtInPresets = <Preset>[
  Preset(
    name: 'Deep Work',
    mix: NoiseMix(brown: 0.8, pink: 0.0, green: 0.0, white: 0.1),
    color: Color(0xFF4B5A7A),
  ),
  Preset(
    name: 'Forest Walk',
    mix: NoiseMix(brown: 0.0, pink: 0.0, green: 0.9, white: 0.0),
    color: Color(0xFF2F8F60),
  ),
  Preset(
    name: 'Pure White',
    mix: NoiseMix(brown: 0.0, pink: 0.0, green: 0.0, white: 1.0),
    color: Color(0xFFA9B4BD),
  ),
  Preset(
    name: 'Rainy Library',
    mix: NoiseMix(brown: 0.2, pink: 0.7, green: 0.1, white: 0.05),
    color: Color(0xFF6D7AA8),
  ),
  Preset(
    name: 'Space Drift',
    mix: NoiseMix(brown: 0.9, pink: 0.1, green: 0.0, white: 0.0),
    color: Color(0xFF4D4A8C),
  ),
  Preset(
    name: 'Zen Garden',
    mix: NoiseMix(brown: 0.1, pink: 0.2, green: 0.8, white: 0.1),
    color: Color(0xFF5FA77F),
  ),
];
