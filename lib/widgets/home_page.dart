import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/app_settings_controller.dart';
import '../controllers/home_page_controller.dart';
import '../controllers/playback_session_controller.dart';
import '../data/default_presets.dart';
import '../services/audio_service.dart';
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
    required this.audioService,
  });

  final String title;
  final AppSettingsController settingsController;
  final AudioService audioService;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final PlaybackSessionController _sessionController;
  late final HomePageController _homePageController;
  late final ChangeNotifier _pageNotifier;
  late final VoidCallback _pageListener;
  late final VoidCallback _mixListener;

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

  Future<void> _openSavePresetDialog() async {
    final activePresetName = _homePageController.activePresetNameNotifier.value;
    final selectedColor = activePresetName != null
        ? _homePageController.presetColorForName(
            activePresetName,
            presetColorOptions.first,
          )
        : presetColorOptions.first;

    final result = await showSavePresetDialog(
      context: context,
      initialColor: selectedColor,
      colorOptions: presetColorOptions,
    );

    if (!mounted || result == null) {
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
  }

  Future<void> _deletePreset(String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usunąć preset?'),
        content: Text('Czy na pewno chcesz usunąć preset "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anuluj'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Usuń'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _homePageController.deleteCustomPreset(name);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usunięto preset: $name')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _sessionController = PlaybackSessionController(
      audioService: widget.audioService,
    );
    _homePageController = HomePageController(
      settingsController: widget.settingsController,
      sessionController: _sessionController,
      presetStorageService: PresetStorageService(),
    );
    _pageNotifier = ChangeNotifier();
    _pageListener = () {
      _pageNotifier.notifyListeners();
    };
    _sessionController.addListener(_pageListener);
    _homePageController.mixNotifier.addListener(_pageListener);
    _homePageController.selectedIndexNotifier.addListener(_pageListener);
    _homePageController.activePresetNameNotifier.addListener(_pageListener);
    _homePageController.presetNamesNotifier.addListener(_pageListener);

    widget.settingsController.addListener(_handleSettingsChanged);

    _mixListener = () {
      widget.audioService.updateVolumes(_homePageController.mixNotifier.value);
    };
    _homePageController.mixNotifier.addListener(_mixListener);
    _mixListener();

    if (widget.settingsController.isLoaded) {
      _handleSettingsChanged();
    }

    unawaited(_homePageController.loadCustomPresets());
  }

  @override
  void dispose() {
    widget.settingsController.removeListener(_handleSettingsChanged);
    _homePageController.mixNotifier.removeListener(_mixListener);
    _sessionController.removeListener(_pageListener);
    _homePageController.mixNotifier.removeListener(_pageListener);
    _homePageController.selectedIndexNotifier.removeListener(_pageListener);
    _homePageController.activePresetNameNotifier.removeListener(_pageListener);
    _homePageController.presetNamesNotifier.removeListener(_pageListener);
    _pageNotifier.dispose();
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
      animation: _pageNotifier,
      builder: (context, child) {
        final media = MediaQuery.of(context);
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
        final width = media.size.width;
        final orientation = media.orientation;
        double baseScale;

        if (width < 360) {
          baseScale = 0.92;
        } else if (width < 420) {
          baseScale = 1.0;
        } else if (width < 600) {
          baseScale = 1.05;
        } else if (width < 900) {
          baseScale = 1.12;
        } else {
          baseScale = 1.2;
        }

        if (orientation == Orientation.landscape && width < 700) {
          baseScale *= 0.95;
        }

        final scale = baseScale.clamp(0.9, 1.2).toDouble();
        final appBarTitleTop =
            (media.padding.top * 0.35).clamp(4.0, 12.0).toDouble();
        final appBarHeight = kToolbarHeight * scale + appBarTitleTop;
        final actionIconSize = 24.0 * scale;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            foregroundColor: theme.colorScheme.onSurface,
            centerTitle: true,
            toolbarHeight: appBarHeight,
            titleSpacing: 16 * scale,
            title: Padding(
              padding: EdgeInsets.only(top: appBarTitleTop),
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: 32 * scale,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(
                  top: appBarTitleTop,
                  right: 10.0 * scale,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.settings,
                    color: theme.colorScheme.onSurface,
                  ),
                  iconSize: actionIconSize,
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
                            scale: scale,
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
                            onPresetDeleteRequested: _deletePreset,
                            onSavePreset: _openSavePresetDialog,
                            formattedRemaining:
                                _sessionController.formattedRemaining,
                            isPlaying: _sessionController.isPlaying,
                            repeatEnabled: _sessionController.repeatEnabled,
                            shuffleEnabled: _sessionController.shuffleEnabled,
                            onTogglePlayPause: _togglePlayPause,
                            onToggleRepeat: _sessionController.toggleRepeat,
                            onToggleShuffle: _sessionController.toggleShuffle,
                            scale: scale,
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
