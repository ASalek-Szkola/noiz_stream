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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18),
      child: AbsorbPointer(
        absorbing: !hasActiveNoiseSelection,
        child: Opacity(
          opacity: !hasActiveNoiseSelection ? 0.5 : 1.0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white,
              borderRadius: BorderRadius.circular(18),
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
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: color,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              name,
                                              style: TextStyle(
                                                color:
                                                    theme.colorScheme.onSurface,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (isCustom) ...[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 6,
                                              ),
                                              child: Icon(
                                                Icons.bookmark,
                                                size: 14,
                                                color: theme
                                                    .colorScheme.secondary,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 6,
                                              ),
                                              child: Icon(
                                                Icons.close,
                                                size: 14,
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
                                  width: 10,
                                  height: 10,
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
                                const SizedBox(width: 6),
                                Text(
                                  activePresetName ?? 'MIX',
                                  style: TextStyle(
                                    color: theme.colorScheme.secondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 18,
                                  color: theme.colorScheme.secondary,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: onSavePreset,
                            icon: Icon(
                              Icons.bookmark_add_outlined,
                              size: 18,
                              color: theme.colorScheme.secondary,
                            ),
                            visualDensity: VisualDensity.compact,
                            splashRadius: 18,
                            tooltip: 'Zapisz własny preset',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formattedRemaining,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isPlaying ? 'session remaining' : 'session paused',
                        style: TextStyle(
                          color: theme.colorScheme.secondary.withValues(
                            alpha: 0.7,
                          ),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.35,
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: theme.colorScheme.onPrimary,
                    ),
                    onPressed: hasActiveNoiseSelection
                        ? onTogglePlayPause
                        : null,
                  ),
                ),
                const SizedBox(width: 14),
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
