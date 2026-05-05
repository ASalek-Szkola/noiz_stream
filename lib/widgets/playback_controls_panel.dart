import 'package:flutter/material.dart';

class PlaybackControlsPanel extends StatelessWidget {
  const PlaybackControlsPanel({
    super.key,
    required this.hasActiveNoiseSelection,
    required this.presetNames,
    required this.activePresetName,
    required this.presetColorForName,
    required this.isCustomPresetName,
    required this.onPresetSelected,
    required this.onPresetDeleteRequested,
    required this.onSavePreset,
    required this.formattedRemaining,
    required this.isPlaying,
    required this.repeatEnabled,
    required this.shuffleEnabled,
    required this.onTogglePlayPause,
    required this.onToggleRepeat,
    required this.onToggleShuffle,
    this.scale = 1.0,
  });

  final bool hasActiveNoiseSelection;
  final List<String> presetNames;
  final String? activePresetName;
  final Color Function(String name, Color fallback) presetColorForName;
  final bool Function(String name) isCustomPresetName;
  final ValueChanged<String> onPresetSelected;
  final ValueChanged<String> onPresetDeleteRequested;
  final VoidCallback onSavePreset;
  final String formattedRemaining;
  final bool isPlaying;
  final bool repeatEnabled;
  final bool shuffleEnabled;
  final VoidCallback onTogglePlayPause;
  final VoidCallback onToggleRepeat;
  final VoidCallback onToggleShuffle;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clampedScale = scale.clamp(0.9, 1.2).toDouble();
    final outerHorizontal = 20.0 * clampedScale;
    final outerVertical = 18.0 * clampedScale;
    final innerHorizontal = 16.0 * clampedScale;
    final innerVertical = 12.0 * clampedScale;
    final containerRadius = 18.0 * clampedScale;
    final presetDotSize = 10.0 * clampedScale;
    final presetLabelSize = 12.0 * clampedScale;
    final presetIconSize = 18.0 * clampedScale;
    final remainingSize = 16.0 * clampedScale;
    final statusSize = 11.0 * clampedScale;
    final playButtonSize = 64.0 * clampedScale;
    final playIconSize = 28.0 * clampedScale;
    final smallIconSize = 14.0 * clampedScale;
    final actionIconSize = 22.0 * clampedScale;
    final rowGap = 14.0 * clampedScale;
    final columnGap = 8.0 * clampedScale;
    final smallGap = 6.0 * clampedScale;
    final tinyGap = 2.0 * clampedScale;
    final shadowBlur = 8.0 * clampedScale;
    final shadowOffset = 4.0 * clampedScale;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: outerHorizontal,
        vertical: outerVertical,
      ),
      child: AbsorbPointer(
        absorbing: !hasActiveNoiseSelection,
        child: Opacity(
          opacity: !hasActiveNoiseSelection ? 0.5 : 1.0,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: innerHorizontal,
              vertical: innerVertical,
            ),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white,
              borderRadius: BorderRadius.circular(containerRadius),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          PopupMenuButton<String>(
                            onSelected: onPresetSelected,
                            itemBuilder: (BuildContext context) => presetNames
                                .map((name) {
                                  final color = presetColorForName(
                                    name,
                                    theme.colorScheme.primary,
                                  );
                                  final isCustom = isCustomPresetName(name);

                                  return PopupMenuItem<String>(
                                    value: name,
                                    child: InkWell(
                                      onLongPress: isCustom
                                          ? () {
                                              Navigator.pop(context);
                                              onPresetDeleteRequested(name);
                                            }
                                          : null,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: presetDotSize,
                                            height: presetDotSize,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: color,
                                            ),
                                          ),
                                          SizedBox(width: columnGap),
                                          Expanded(
                                            child: Text(
                                              name,
                                              style: TextStyle(
                                                color:
                                                    theme.colorScheme.onSurface,
                                                fontSize: presetLabelSize,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (isCustom) ...[
                                            Padding(
                                              padding: EdgeInsets.only(
                                                left: smallGap,
                                              ),
                                              child: Icon(
                                                Icons.bookmark,
                                                size: smallIconSize,
                                                color: theme
                                                    .colorScheme.secondary,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                left: smallGap,
                                              ),
                                              child: Icon(
                                                Icons.close,
                                                size: smallIconSize,
                                                color: theme.colorScheme
                                                    .secondary
                                                    .withValues(alpha: 0.5),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  );
                                })
                                .toList(growable: false),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: presetDotSize,
                                  height: presetDotSize,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: activePresetName != null
                                        ? presetColorForName(
                                            activePresetName!,
                                            theme.colorScheme.secondary,
                                          )
                                        : theme.colorScheme.secondary,
                                  ),
                                ),
                                SizedBox(width: smallGap),
                                Text(
                                  activePresetName ?? 'MIX',
                                  style: TextStyle(
                                    color: theme.colorScheme.secondary,
                                    fontSize: presetLabelSize,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: tinyGap),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  size: presetIconSize,
                                  color: theme.colorScheme.secondary,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: onSavePreset,
                            icon: Icon(
                              Icons.bookmark_add_outlined,
                              size: presetIconSize,
                              color: theme.colorScheme.secondary,
                            ),
                            visualDensity: VisualDensity.compact,
                            splashRadius: 18 * clampedScale,
                            tooltip: 'Zapisz własny preset',
                          ),
                        ],
                      ),
                      SizedBox(height: columnGap),
                      Text(
                        formattedRemaining,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: remainingSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4 * clampedScale),
                      Text(
                        isPlaying ? 'session remaining' : 'session paused',
                        style: TextStyle(
                          color: theme.colorScheme.secondary.withValues(
                            alpha: 0.7,
                          ),
                          fontSize: statusSize,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: playButtonSize,
                  height: playButtonSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.35,
                        ),
                        blurRadius: shadowBlur,
                        offset: Offset(0, shadowOffset),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: theme.colorScheme.onPrimary,
                    ),
                    iconSize: playIconSize,
                    onPressed: hasActiveNoiseSelection
                        ? onTogglePlayPause
                        : null,
                  ),
                ),
                SizedBox(width: rowGap),
                Column(
                  children: [
                    IconButton(
                      onPressed: hasActiveNoiseSelection
                          ? onToggleRepeat
                          : null,
                      icon: Icon(
                        Icons.repeat,
                        color: !hasActiveNoiseSelection
                            ? theme.colorScheme.secondary.withValues(alpha: 0.3)
                            : repeatEnabled
                            ? theme.colorScheme.primary
                            : theme.colorScheme.secondary,
                      ),
                      iconSize: actionIconSize,
                    ),
                    IconButton(
                      onPressed: hasActiveNoiseSelection
                          ? onToggleShuffle
                          : null,
                      icon: Icon(
                        Icons.shuffle,
                        color: !hasActiveNoiseSelection
                            ? theme.colorScheme.secondary.withValues(alpha: 0.3)
                            : shuffleEnabled
                            ? theme.colorScheme.primary
                            : theme.colorScheme.secondary,
                      ),
                      iconSize: actionIconSize,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
