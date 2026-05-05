import 'package:flutter/material.dart';

import '../noise_card.dart';

class NoiseGrid extends StatelessWidget {
  const NoiseGrid({
    super.key,
    required this.brownValue,
    required this.pinkValue,
    required this.greenValue,
    required this.whiteValue,
    required this.selectedIndex,
    required this.onNoiseTap,
    required this.onNoiseChanged,
    this.scale = 1.0,
  });

  final double brownValue;
  final double pinkValue;
  final double greenValue;
  final double whiteValue;
  final int selectedIndex;
  final ValueChanged<int> onNoiseTap;
  final void Function(int index, double value) onNoiseChanged;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final clampedScale = scale.clamp(0.9, 1.2).toDouble();
    final crossAxisCount = width >= 900
        ? 4
        : width >= 600
        ? 3
        : 2;
    final spacing = 14.0 * clampedScale;
    final horizontalPadding = 16.0 * clampedScale;
    final verticalPadding = 12.0 * clampedScale;
    final cardHeight = (170.0 * clampedScale).clamp(150.0, 210.0).toDouble();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: GridView(
        primary: false,
        padding: EdgeInsets.only(top: verticalPadding, bottom: verticalPadding),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          mainAxisExtent: cardHeight,
        ),
        children: <Widget>[
          NoiseCard(
            title: 'Brown Noise',
            subtitle: '(Deep)',
            value: brownValue,
            isSelected: selectedIndex == 0,
            onTap: () => onNoiseTap(0),
            onChanged: (value) => onNoiseChanged(0, value),
            icon: Icons.equalizer,
            accentColor: const Color(0xFFC38965),
            wavePattern: 0,
            scale: clampedScale,
          ),
          NoiseCard(
            title: 'Pink Noise',
            subtitle: '(Nature)',
            value: pinkValue,
            isSelected: selectedIndex == 1,
            onTap: () => onNoiseTap(1),
            onChanged: (value) => onNoiseChanged(1, value),
            icon: Icons.nature,
            accentColor: const Color(0xFFE484A3),
            wavePattern: 1,
            scale: clampedScale,
          ),
          NoiseCard(
            title: 'Green Noise',
            subtitle: '(Forest)',
            value: greenValue,
            isSelected: selectedIndex == 2,
            onTap: () => onNoiseTap(2),
            onChanged: (value) => onNoiseChanged(2, value),
            icon: Icons.park,
            accentColor: const Color(0xFF6DCA78),
            wavePattern: 2,
            scale: clampedScale,
          ),
          NoiseCard(
            title: 'White Noise',
            subtitle: '(Detail)',
            value: whiteValue,
            isSelected: selectedIndex == 3,
            onTap: () => onNoiseTap(3),
            onChanged: (value) => onNoiseChanged(3, value),
            icon: Icons.blur_on,
            accentColor: const Color(0xFFD1D1D1),
            wavePattern: 3,
            scale: clampedScale,
          ),
        ],
      ),
    );
  }
}
