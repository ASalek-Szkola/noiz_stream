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
  });

  final double brownValue;
  final double pinkValue;
  final double greenValue;
  final double whiteValue;
  final int selectedIndex;
  final ValueChanged<int> onNoiseTap;
  final void Function(int index, double value) onNoiseChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView(
        primary: false,
        padding: const EdgeInsets.only(top: 12, bottom: 12),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          mainAxisExtent: 170,
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
          ),
        ],
      ),
    );
  }
}
