import 'package:flutter/material.dart';
import 'wave_widget.dart';

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
  final double scale;

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
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final clampedScale = scale.clamp(0.9, 1.2).toDouble();
    final waveHeight = (50.0 * clampedScale).clamp(44.0, 60.0).toDouble();
    final borderWidth =
        (isSelected ? 2.5 * clampedScale : 1.0 * clampedScale).toDouble();
    final trackHeight = (3.0 * clampedScale).clamp(2.5, 4.0).toDouble();
    final overlayRadius =
        (12.0 * clampedScale).clamp(10.0, 16.0).toDouble();
    final thumbRadius =
        (6.0 * clampedScale).clamp(5.0, 8.0).toDouble();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16 * clampedScale),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.8)
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: borderWidth,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // waveform preview
            Padding(
              padding: EdgeInsets.fromLTRB(
                12 * clampedScale,
                12 * clampedScale,
                12 * clampedScale,
                10 * clampedScale,
              ),
              child: SizedBox(
                height: waveHeight,
                child: WaveWidget(
                  color: accentColor,
                  pattern: wavePattern,
                  volume: value < 0.4
                      ? value / 0.2 * 0.5 -
                            0.1 // Boost low volumes for better visibility
                      : value,
                ),
              ),
            ),
            // Volume
            Padding(
              padding: EdgeInsets.fromLTRB(
                12 * clampedScale,
                0,
                12 * clampedScale,
                6 * clampedScale,
              ),
              child: Row(
                children: [
                  Icon(
                    value == 0.00 ? Icons.volume_off : Icons.volume_up,
                    size: 14 * clampedScale,
                    color: theme.colorScheme.secondary.withValues(alpha: 0.6),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: trackHeight,
                        thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius: thumbRadius,
                        ),
                        overlayShape: RoundSliderOverlayShape(
                          overlayRadius: overlayRadius,
                        ),
                      ),
                      child: Slider(
                        value: value,
                        onChanged: onChanged,
                        activeColor: accentColor.withValues(alpha: 0.9),
                        inactiveColor:
                            theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  Text(
                    '${(value * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: theme.colorScheme.secondary,
                      fontSize: 10 * clampedScale,
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Container(
              padding: EdgeInsets.all(12 * clampedScale),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white.withValues(alpha: 0.4),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(15 * clampedScale),
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, color: accentColor, size: 20 * clampedScale),
                  SizedBox(width: 10 * clampedScale),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          maxLines: 1, // Overflow protection
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 13 * clampedScale,
                          ),
                        ),
                        Text(
                          subtitle,
                          maxLines: 1, // Overflow protection
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.colorScheme.secondary,
                            fontSize: 10 * clampedScale,
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
