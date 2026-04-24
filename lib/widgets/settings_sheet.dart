import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/app_settings_controller.dart';

Future<void> showSettingsSheet({
  required BuildContext context,
  required AppSettingsController settingsController,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          final backgroundColor = isDark
              ? theme.colorScheme.surface
              : const Color(0xFFFFFFFF);

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16.0,
                24.0,
                16.0,
                MediaQuery.of(context).viewInsets.bottom + 24.0,
              ),
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Dark Mode',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Switch between light and dark theme',
                          style: TextStyle(
                            color: theme.colorScheme.secondary,
                            fontSize: 12,
                          ),
                        ),
                        value: settingsController.themeMode == ThemeMode.dark,
                        activeThumbColor: theme.colorScheme.primary,
                        onChanged: (bool value) {
                          unawaited(
                            settingsController.setThemeMode(
                              value ? ThemeMode.dark : ThemeMode.light,
                            ),
                          );
                          setModalState(() {});
                        },
                      ),
                      Divider(color: theme.dividerColor),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Play on Startup',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Start playing audio immediately when app opens',
                          style: TextStyle(
                            color: theme.colorScheme.secondary,
                            fontSize: 12,
                          ),
                        ),
                        value: settingsController.playOnStartup,
                        activeThumbColor: theme.colorScheme.primary,
                        onChanged: (bool value) {
                          unawaited(settingsController.setPlayOnStartup(value));
                          setModalState(() {});
                        },
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'High Quality Audio',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Enable 48kHz lossless streaming (uses more data)',
                          style: TextStyle(
                            color: theme.colorScheme.secondary,
                            fontSize: 12,
                          ),
                        ),
                        value: settingsController.highQualityAudio,
                        activeThumbColor: theme.colorScheme.primary,
                        onChanged: (bool value) {
                          unawaited(
                            settingsController.setHighQualityAudio(value),
                          );
                          setModalState(() {});
                        },
                      ),
                      Divider(color: theme.dividerColor),
                      const SizedBox(height: 8),
                      Text(
                        'Crossfade Duration: ${settingsController.crossfadeDuration.toInt()}s',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Slider(
                        value: settingsController.crossfadeDuration,
                        min: 1,
                        max: 10,
                        divisions: 9,
                        activeColor: theme.colorScheme.primary,
                        onChanged: (double value) {
                          unawaited(
                            settingsController.setCrossfadeDuration(
                              value,
                              persist: false,
                            ),
                          );
                          setModalState(() {});
                        },
                        onChangeEnd: (value) {
                          unawaited(
                            settingsController.setCrossfadeDuration(value),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
