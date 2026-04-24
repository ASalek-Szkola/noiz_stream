import 'dart:async';

import 'package:flutter/material.dart';

import 'controllers/app_settings_controller.dart';
import 'controllers/home_page_controller.dart';
import 'controllers/playback_session_controller.dart';
import 'data/default_presets.dart';
import 'services/preset_storage_service.dart';
import 'widgets/noise_grid.dart';
import 'widgets/playback_controls_panel.dart';
import 'widgets/save_preset_dialog.dart';
import 'widgets/settings_sheet.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key, AppSettingsController? settingsController})
    : settingsController = settingsController ?? AppSettingsController();

  final AppSettingsController settingsController;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    unawaited(widget.settingsController.load());
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.settingsController,
      builder: (context, child) {
        return MaterialApp(
          title: 'NoizStream',
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              foregroundColor: Color(0xFF2C2F31),
              surfaceTintColor: Colors.transparent,
              centerTitle: true,
            ),
            colorScheme: const ColorScheme.light(
              surface: Color(0xFFF7F8FA),
              onSurface: Color(0xFF2C2F31),
              primary: Color(0xFF30363C),
              onPrimary: Color(0xFFFFFFFF),
              secondary: Color(0xFF5E6266),
              onSecondary: Color(0xFFFFFFFF),
              surfaceContainerHighest: Color(0xFFEAEFF2),
              outline: Color(0xFFDCE3E8),
            ),
            scaffoldBackgroundColor: const Color(0xFFF7F8FA),
            dividerColor: const Color(0xFFDCE3E8),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Color(0xFF2C2F31)),
              bodySmall: TextStyle(color: Color(0xFF5E6266)),
            ),
            switchTheme: SwitchThemeData(
              thumbColor: WidgetStateProperty.resolveWith((states) {
                return states.contains(WidgetState.selected)
                    ? const Color(0xFF30363C)
                    : const Color(0xFF9EAAB4);
              }),
              trackColor: WidgetStateProperty.resolveWith((states) {
                return states.contains(WidgetState.selected)
                    ? const Color(0xFF30363C).withValues(alpha: 0.35)
                    : const Color(0xFFD7DDE2);
              }),
            ),
            sliderTheme: SliderThemeData(
              activeTrackColor: const Color(0xFF30363C),
              inactiveTrackColor: const Color(0xFFD7DDE2),
              thumbColor: const Color(0xFF30363C),
              overlayColor: const Color(0xFF30363C).withValues(alpha: 0.12),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: const ColorScheme.dark(
              surface: Color(0xFF161A1C),
              onSurface: Color(0xFFEBF3F6),
              primary: Color(0xFFC2D0E0),
              onPrimary: Color(0xFF161A1C),
              secondary: Color(0xFFAEBBC5),
              onSecondary: Color(0xFF161A1C),
              surfaceContainerHighest: Color(0xFF1E2428),
              outline: Color(0xFF222A30),
            ),
            scaffoldBackgroundColor: const Color(0xFF161A1C),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Color(0xFFEBF3F6)),
              bodySmall: TextStyle(color: Color(0xFFAEBBC5)),
            ),
          ),
          themeMode: widget.settingsController.themeMode,
          home: MyHomePage(
            title: 'NoizStream',
            settingsController: widget.settingsController,
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

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
