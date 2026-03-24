import 'package:flutter/material.dart';
import 'WaveWidget.dart';

class NoiseCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double value;
  final ValueChanged<double> onChanged;
  final IconData icon;
  final Color accentColor;
  final bool isSelected;
  final VoidCallback? onTap;
  final int wavePattern;

  const NoiseCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.icon,
    required this.accentColor,
    this.isSelected = false,
    this.onTap,
    this.wavePattern = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Colors.lightBlue.shade100.withOpacity(0.8)
                : Colors.white10,
            width: isSelected ? 2.5 : 1.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // waveform preview
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              child: SizedBox(
                height: 50,
                child: WaveWidget(color: accentColor, pattern: wavePattern),
              ),
            ),
            // Volume
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
              child: Row(
                children: [
                  Icon(
                    value == 0.00 ? Icons.volume_off : Icons.volume_up,
                    size: 14,
                    color: Colors.white60,
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 12,
                        ),
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                      ),
                      child: Slider(
                        value: value,
                        onChanged: onChanged,
                        activeColor: accentColor.withOpacity(0.9),
                        inactiveColor: Colors.white10,
                      ),
                    ),
                  ),
                  Text(
                    '${(value * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(color: Colors.white60, fontSize: 10),
                  ),
                ],
              ),
            ),
            // Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(15),
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, color: accentColor, size: 20),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
