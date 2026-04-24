import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/app_settings_controller.dart';
import '../controllers/home_page_controller.dart';
import '../controllers/playback_session_controller.dart';
import '../data/default_presets.dart';
import '../services/preset_storage_service.dart';
import 'noise_grid.dart';
import 'playback_controls_panel.dart';
import 'save_preset_dialog.dart';
import 'settings_sheet.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.settingsController,
  });

  final String title;
  final AppSettingsController settingsController;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final PlaybackSessionController _sessionController;
  late final HomePageController _homePageController;
  late final Listenable _pageListenable;

  void _handleSettingsChanged() {
    if (!mounted) {
      return;
    }
    _homePageController.applyStartupBehaviorIfNeeded();
  }

  void _togglePlayPause() {
    if (!_homePageController.hasActiveNoiseSelection) {
      return;
    }
    _sessionController.togglePlayPause();
  }

  void _openSavePresetDialog() {
    final activePresetName = _homePageController.activePresetNameNotifier.value;
    final selectedColor = activePresetName != null
        ? _homePageController.presetColorForName(
            activePresetName,
            presetColorOptions.first,
          )
        : presetColorOptions.first;

    unawaited(
      showSavePresetDialog(
        context: context,
        initialColor: selectedColor,
        colorOptions: presetColorOptions,
      ).then((result) async {
        if (result == null) {
          return;
        }

        final saveResult = await _homePageController.saveCurrentMixAsPreset(
          result.name,
          result.color,
        );

        if (!mounted) {
          return;
        }

        switch (saveResult.status) {
          case SavePresetStatus.saved:
            final savedName = saveResult.savedName ?? result.name;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Zapisano preset: $savedName')),
            );
            break;
          case SavePresetStatus.builtInNameConflict:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Preset o tej nazwie juz istnieje jako wbudowany. Wybierz inna nazwe.',
                ),
              ),
            );
            break;
          case SavePresetStatus.emptyName:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Podaj nazwe presetu.')),
            );
            break;
        }
      }),
    );
  }

  @override
  void initState() {
    super.initState();
    _sessionController = PlaybackSessionController();
    _homePageController = HomePageController(
      settingsController: widget.settingsController,
      sessionController: _sessionController,
      presetStorageService: PresetStorageService(),
    );
    _pageListenable = Listenable.merge(<Listenable>[
      _sessionController,
      _homePageController.mixNotifier,
      _homePageController.selectedIndexNotifier,
      _homePageController.activePresetNameNotifier,
      _homePageController.presetNamesNotifier,
    ]);

    widget.settingsController.addListener(_handleSettingsChanged);

    if (widget.settingsController.isLoaded) {
      _handleSettingsChanged();
    }

    unawaited(_homePageController.loadCustomPresets());
  }

  @override
  void dispose() {
    widget.settingsController.removeListener(_handleSettingsChanged);
    _homePageController.dispose();
    _sessionController.dispose();
    super.dispose();
  }

  void _openSettingsPanel() {
    unawaited(
      showSettingsSheet(
        context: context,
        settingsController: widget.settingsController,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pageListenable,
      builder: (context, child) {
        final theme = Theme.of(context);
        final mix = _homePageController.mixNotifier.value;
        final selectedIndex = _homePageController.selectedIndexNotifier.value;
        final activePresetName =
            _homePageController.activePresetNameNotifier.value;
        final presetNames = _homePageController.presetNamesNotifier.value;
        final items = presetNames.isNotEmpty
            ? presetNames
            : builtInPresets
                  .map((preset) => preset.name)
                  .toList(growable: false);
        final hasActiveNoiseSelection =
            _homePageController.hasActiveNoiseSelection;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            foregroundColor: theme.colorScheme.onSurface,
            centerTitle: true,
            title: Text(
              widget.title,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: IconButton(
                  icon: Icon(
                    Icons.settings,
                    color: theme.colorScheme.onSurface,
                  ),
                  onPressed: _openSettingsPanel,
                ),
              ),
            ],
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            color: theme.scaffoldBackgroundColor,
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          NoiseGrid(
                            brownValue: mix.brown,
                            pinkValue: mix.pink,
                            greenValue: mix.green,
                            whiteValue: mix.white,
                            selectedIndex: selectedIndex,
                            onNoiseTap:
                                _homePageController.toggleNoiseSelection,
                            onNoiseChanged: _homePageController.setNoiseLevel,
                          ),
                          PlaybackControlsPanel(
                            hasActiveNoiseSelection: hasActiveNoiseSelection,
                            presetNames: items,
                            activePresetName: activePresetName,
                            presetColorForName:
                                _homePageController.presetColorForName,
                            isCustomPresetName:
                                _homePageController.isCustomPresetName,
                            onPresetSelected:
                                _homePageController.applyPresetByName,
                            onSavePreset: _openSavePresetDialog,
                            formattedRemaining:
                                _sessionController.formattedRemaining,
                            isPlaying: _sessionController.isPlaying,
                            repeatEnabled: _sessionController.repeatEnabled,
                            shuffleEnabled: _sessionController.shuffleEnabled,
                            onTogglePlayPause: _togglePlayPause,
                            onToggleRepeat: _sessionController.toggleRepeat,
                            onToggleShuffle: _sessionController.toggleShuffle,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
