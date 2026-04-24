import 'dart:async';

import 'package:flutter/material.dart';
import 'controllers/app_settings_controller.dart';
import 'controllers/playback_session_controller.dart';
import 'data/default_presets.dart';
import 'models/noise_mix.dart';
import 'models/preset.dart';
import 'services/preset_storage_service.dart';
import 'widgets/noise_grid.dart';
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
              surface: Color(0xFFF7F8FA), // --cc-bg
              onSurface: Color(0xFF2C2F31), // --cc-primary-color
              primary: Color(0xFF30363C), // --cc-btn-primary-bg
              onPrimary: Color(0xFFFFFFFF), // --cc-btn-primary-color
              secondary: Color(0xFF5E6266), // --cc-secondary-color
              onSecondary: Color(0xFFFFFFFF),
              surfaceContainerHighest: Color(
                0xFFEAEFF2,
              ), // --cc-cookie-category-block-bg
              outline: Color(0xFFDCE3E8), // --cc-separator-border-color
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
              activeTrackColor: Color(0xFF30363C),
              inactiveTrackColor: Color(0xFFD7DDE2),
              thumbColor: Color(0xFF30363C),
              overlayColor: Color(0xFF30363C).withValues(alpha: 0.12),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: const ColorScheme.dark(
              surface: Color(0xFF161A1C), // --cc-bg
              onSurface: Color(0xFFEBF3F6), // --cc-primary-color
              primary: Color(0xFFC2D0E0), // --cc-btn-primary-bg
              onPrimary: Color(0xFF161A1C), // --cc-btn-primary-color
              secondary: Color(0xFFAEBBC5), // --cc-secondary-color
              onSecondary: Color(0xFF161A1C),
              surfaceContainerHighest: Color(
                0xFF1E2428,
              ), // --cc-cookie-category-block-bg
              outline: Color(0xFF222A30), // --cc-separator-border-color
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
  double brownSliderValue = 0.41;
  double pinkSliderValue = 0.51;
  double greenSliderValue = 0.20;
  double whiteSliderValue = 0.72;
  int selectedIndex = 0;

  // Presets map
  final Map<String, Map<String, double>> presets = {
    'Deep Work': {'brown': 0.8, 'pink': 0.0, 'green': 0.0, 'white': 0.1},
    'Forest Walk': {'brown': 0.0, 'pink': 0.0, 'green': 0.9, 'white': 0.0},
    'Pure White': {'brown': 0.0, 'pink': 0.0, 'green': 0.0, 'white': 1.0},
    'Rainy Library': {'brown': 0.2, 'pink': 0.7, 'green': 0.1, 'white': 0.05},
    'Space Drift': {'brown': 0.9, 'pink': 0.1, 'green': 0.0, 'white': 0.0},
    'Zen Garden': {'brown': 0.1, 'pink': 0.2, 'green': 0.8, 'white': 0.1},
  };

  final Map<String, Color> presetColors = {
    'Deep Work': const Color(0xFF4B5A7A),
    'Forest Walk': const Color(0xFF2F8F60),
    'Pure White': const Color(0xFFA9B4BD),
    'Rainy Library': const Color(0xFF6D7AA8),
    'Space Drift': const Color(0xFF4D4A8C),
    'Zen Garden': const Color(0xFF5FA77F),
  };

  final Set<String> customPresetNames = <String>{};

  static const int _defaultPresetSteps = 20;
  static const int _highQualityPresetSteps = 40;
  final PresetStorageService _presetStorageService = PresetStorageService();

  // Exposed preset names list (can be updated elsewhere). UI listens to this.
  final ValueNotifier<List<String>> presetNamesNotifier =
      ValueNotifier<List<String>>([]);

  // currently active preset name for UI
  String? activePresetName;

  late final PlaybackSessionController _sessionController;
  bool _startupBehaviorApplied = false;

  bool get _hasActiveNoiseSelection => selectedIndex != -1;

  Timer? _presetTimer;

  void _applyPreset(String name) {
    final target = presets[name];
    if (target == null) return;

    // determine dominant noise and set selectedIndex accordingly
    final dominantEntry = target.entries.reduce(
      (a, b) => a.value >= b.value ? a : b,
    );
    final dominantKey = dominantEntry.key;
    final Map<String, int> indexMap = {
      'brown': 0,
      'pink': 1,
      'green': 2,
      'white': 3,
    };
    final int dominantIndex = indexMap[dominantKey] ?? -1;

    // cancel any running animation
    _presetTimer?.cancel();

    final startBrown = brownSliderValue;
    final startPink = pinkSliderValue;
    final startGreen = greenSliderValue;
    final startWhite = whiteSliderValue;

    final targetBrown = target['brown'] ?? 0.0;
    final targetPink = target['pink'] ?? 0.0;
    final targetGreen = target['green'] ?? 0.0;
    final targetWhite = target['white'] ?? 0.0;

    final bool highQuality = widget.settingsController.highQualityAudio;
    final int steps = highQuality
        ? _highQualityPresetSteps
        : _defaultPresetSteps;
    final int totalMs = (widget.settingsController.crossfadeDuration * 1000)
        .round();
    final int rawStepMs = totalMs ~/ steps;
    final int stepMs = rawStepMs < 16 ? 16 : rawStepMs;
    final stepDuration = Duration(milliseconds: stepMs);
    int step = 0;

    // immediately set selected index to show dominance and active preset name
    setState(() {
      selectedIndex = dominantIndex;
      activePresetName = name;
    });
    _sessionController.onSelectionChanged(_hasActiveNoiseSelection);

    _presetTimer = Timer.periodic(stepDuration, (timer) {
      step++;
      final double t = (step / steps).clamp(0.0, 1.0);
      final double eased = Curves.easeInOut.transform(t);

      final brown = startBrown + (targetBrown - startBrown) * eased;
      final pink = startPink + (targetPink - startPink) * eased;
      final green = startGreen + (targetGreen - startGreen) * eased;
      final white = startWhite + (targetWhite - startWhite) * eased;

      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        brownSliderValue = brown;
        pinkSliderValue = pink;
        greenSliderValue = green;
        whiteSliderValue = white;
      });

      if (step >= steps) {
        timer.cancel();
        _presetTimer = null;
        if (!mounted) return;
        setState(() {
          brownSliderValue = targetBrown;
          pinkSliderValue = targetPink;
          greenSliderValue = targetGreen;
          whiteSliderValue = targetWhite;
        });
      }
    });
  }

  Map<String, double> _currentMixValues() {
    return NoiseMix(
      brown: brownSliderValue,
      pink: pinkSliderValue,
      green: greenSliderValue,
      white: whiteSliderValue,
    ).toMap();
  }

  Future<void> _persistCustomPresets() async {
    final payload = customPresetNames
        .map((name) {
          final levels = presets[name];
          if (levels == null) {
            return null;
          }

          final color = presetColors[name] ?? presetColorOptions.first;
          return Preset(
            name: name,
            mix: NoiseMix.fromMap(levels),
            color: color,
            isCustom: true,
          );
        })
        .whereType<Preset>()
        .toList(growable: false);

    await _presetStorageService.saveCustomPresets(payload);
  }

  Future<void> _loadCustomPresets() async {
    final loadedPresets = await _presetStorageService.loadCustomPresets();
    if (!mounted || loadedPresets.isEmpty) {
      return;
    }

    setState(() {
      for (final preset in loadedPresets) {
        presets[preset.name] = preset.mix.toMap();
        presetColors[preset.name] = preset.color;
      }

      customPresetNames
        ..clear()
        ..addAll(loadedPresets.map((preset) => preset.name));
      presetNamesNotifier.value = presets.keys.toList();
    });
  }

  void _handleSettingsChanged() {
    if (!mounted) return;

    if (widget.settingsController.isLoaded && !_startupBehaviorApplied) {
      _sessionController.applyPlayOnStartup(
        enabled: widget.settingsController.playOnStartup,
        hasSelection: _hasActiveNoiseSelection,
      );
      _startupBehaviorApplied = true;
    }

    setState(() {});
  }

  void _handleSessionChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _toggleNoiseSelection(int index) {
    setState(() {
      selectedIndex = selectedIndex == index ? -1 : index;
      if (selectedIndex == -1) {
        activePresetName = null;
      }
    });
    _sessionController.onSelectionChanged(_hasActiveNoiseSelection);
  }

  void _setNoiseLevel(int index, double value) {
    setState(() {
      switch (index) {
        case 0:
          brownSliderValue = value;
          break;
        case 1:
          pinkSliderValue = value;
          break;
        case 2:
          greenSliderValue = value;
          break;
        case 3:
          whiteSliderValue = value;
          break;
      }

      selectedIndex = index;
      activePresetName = null;
    });

    _sessionController.onSelectionChanged(true);
  }

  void _togglePlayPause() {
    if (!_hasActiveNoiseSelection) return;
    _sessionController.togglePlayPause();
  }

  Future<void> _saveCurrentMixAsPreset(String name, Color color) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return;

    if (presets.containsKey(trimmedName) &&
        !customPresetNames.contains(trimmedName)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Preset o tej nazwie już istnieje jako wbudowany. Wybierz inną nazwę.',
          ),
        ),
      );
      return;
    }

    setState(() {
      presets[trimmedName] = _currentMixValues();
      presetColors[trimmedName] = color;
      customPresetNames.add(trimmedName);
      activePresetName = trimmedName;
      presetNamesNotifier.value = presets.keys.toList();
    });

    await _persistCustomPresets();

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Zapisano preset: $trimmedName')));
  }

  void _openSavePresetDialog() {
    final selectedColor = activePresetName != null
        ? (presetColors[activePresetName!] ?? presetColorOptions.first)
        : presetColorOptions.first;

    unawaited(
      showSavePresetDialog(
        context: context,
        initialColor: selectedColor,
        colorOptions: presetColorOptions,
      ).then((result) {
        if (result == null) {
          return;
        }
        unawaited(_saveCurrentMixAsPreset(result.name, result.color));
      }),
    );
  }

  @override
  void initState() {
    super.initState();
    _sessionController = PlaybackSessionController();
    _sessionController.addListener(_handleSessionChanged);
    widget.settingsController.addListener(_handleSettingsChanged);

    // initialize the preset names from the presets map
    presetNamesNotifier.value = presets.keys.toList();

    if (widget.settingsController.isLoaded) {
      _handleSettingsChanged();
    }

    unawaited(_loadCustomPresets());
  }

  @override
  void dispose() {
    widget.settingsController.removeListener(_handleSettingsChanged);
    _sessionController
      ..removeListener(_handleSessionChanged)
      ..dispose();
    _presetTimer?.cancel();
    presetNamesNotifier.dispose();
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
    final theme = Theme.of(context);
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
              icon: Icon(Icons.settings, color: theme.colorScheme.onSurface),
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
                    minHeight: constraints.maxHeight, // Centered
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      NoiseGrid(
                        brownValue: brownSliderValue,
                        pinkValue: pinkSliderValue,
                        greenValue: greenSliderValue,
                        whiteValue: whiteSliderValue,
                        selectedIndex: selectedIndex,
                        onNoiseTap: _toggleNoiseSelection,
                        onNoiseChanged: _setNoiseLevel,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 18,
                        ),
                        child: AbsorbPointer(
                          absorbing: !_hasActiveNoiseSelection,
                          child: Opacity(
                            opacity: !_hasActiveNoiseSelection ? 0.5 : 1.0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: theme.brightness == Brightness.dark
                                    ? Colors.white.withValues(alpha: 0.06)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ValueListenableBuilder<List<String>>(
                                          valueListenable: presetNamesNotifier,
                                          builder: (context, names, _) {
                                            final items = names.isNotEmpty
                                                ? names
                                                : presets.keys.toList();
                                            final activeColor =
                                                activePresetName != null
                                                ? (presetColors[activePresetName!] ??
                                                      theme
                                                          .colorScheme
                                                          .secondary)
                                                : theme.colorScheme.secondary;

                                            return Row(
                                              children: [
                                                PopupMenuButton<String>(
                                                  onSelected: (String name) {
                                                    _applyPreset(name);
                                                  },
                                                  itemBuilder: (BuildContext context) => items.map((
                                                    k,
                                                  ) {
                                                    final color =
                                                        presetColors[k] ??
                                                        theme
                                                            .colorScheme
                                                            .primary;
                                                    final isCustom =
                                                        customPresetNames
                                                            .contains(k);

                                                    return PopupMenuItem<
                                                      String
                                                    >(
                                                      value: k,
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            width: 10,
                                                            height: 10,
                                                            decoration:
                                                                BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color: color,
                                                                ),
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              k,
                                                              style: TextStyle(
                                                                color: theme
                                                                    .colorScheme
                                                                    .onSurface,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                          if (isCustom)
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets.only(
                                                                    left: 6,
                                                                  ),
                                                              child: Icon(
                                                                Icons.bookmark,
                                                                size: 14,
                                                                color: theme
                                                                    .colorScheme
                                                                    .secondary,
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    );
                                                  }).toList(),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        width: 10,
                                                        height: 10,
                                                        decoration:
                                                            BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color:
                                                                  activeColor,
                                                            ),
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        activePresetName ??
                                                            'MIX',
                                                        style: TextStyle(
                                                          color: theme
                                                              .colorScheme
                                                              .secondary,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 2),
                                                      Icon(
                                                        Icons
                                                            .keyboard_arrow_down,
                                                        size: 18,
                                                        color: theme
                                                            .colorScheme
                                                            .secondary,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed:
                                                      _openSavePresetDialog,
                                                  icon: Icon(
                                                    Icons.bookmark_add_outlined,
                                                    size: 18,
                                                    color: theme
                                                        .colorScheme
                                                        .secondary,
                                                  ),
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  splashRadius: 18,
                                                  tooltip:
                                                      'Zapisz własny preset',
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _sessionController.formattedRemaining,
                                          style: TextStyle(
                                            color: theme.colorScheme.onSurface,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _sessionController.isPlaying
                                              ? 'session remaining'
                                              : 'session paused',
                                          style: TextStyle(
                                            color: theme.colorScheme.secondary
                                                .withValues(alpha: 0.7),
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
                                          color: theme.colorScheme.primary
                                              .withValues(alpha: 0.35),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        _sessionController.isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        color: theme.colorScheme.onPrimary,
                                      ),
                                      onPressed: _hasActiveNoiseSelection
                                          ? _togglePlayPause
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Column(
                                    children: [
                                      IconButton(
                                        onPressed: !_hasActiveNoiseSelection
                                            ? null
                                            : _sessionController.toggleRepeat,
                                        icon: Icon(
                                          Icons.repeat,
                                          color: !_hasActiveNoiseSelection
                                              ? theme.colorScheme.secondary
                                                    .withValues(alpha: 0.3)
                                              : _sessionController.repeatEnabled
                                              ? theme.colorScheme.primary
                                              : theme.colorScheme.secondary,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: !_hasActiveNoiseSelection
                                            ? null
                                            : _sessionController.toggleShuffle,
                                        icon: Icon(
                                          Icons.shuffle,
                                          color: !_hasActiveNoiseSelection
                                              ? theme.colorScheme.secondary
                                                    .withValues(alpha: 0.3)
                                              : _sessionController
                                                    .shuffleEnabled
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
  }
}
