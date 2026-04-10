import 'dart:async';

import 'package:flutter/material.dart';
import 'noise_card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NoizStream',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'NoizStream'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

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

  // Exposed preset names list (can be updated elsewhere). UI listens to this.
  final ValueNotifier<List<String>> presetNamesNotifier =
      ValueNotifier<List<String>>([]);

  // currently active preset name for UI
  String? activePresetName;

  Timer? _presetTimer;
  final int _presetSteps = 20;
  final Duration _presetDuration = const Duration(milliseconds: 450);

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

    final int steps = _presetSteps;
    final int stepMs = (_presetDuration.inMilliseconds ~/ steps);
    final stepDuration = Duration(milliseconds: stepMs);
    int step = 0;

    // immediately set selected index to show dominance and active preset name
    setState(() {
      selectedIndex = dominantIndex;
      activePresetName = name;
    });

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

  @override
  void initState() {
    super.initState();
    // initialize the preset names from the presets map
    presetNamesNotifier.value = presets.keys.toList();
  }

  @override
  void dispose() {
    _presetTimer?.cancel();
    presetNamesNotifier.dispose();
    super.dispose();
  }

  // Settings
  bool playOnStartup = false;
  double crossfadeDuration = 3.0;
  bool highQualityAudio = false;

  void _openSettingsPanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF27384E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 24.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Settings",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        "Play on Startup",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        "Start playing audio immediately when app opens",
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      value: playOnStartup,
                      activeThumbColor: Colors.lightBlue.shade200,
                      onChanged: (bool value) {
                        setModalState(() => playOnStartup = value);
                        setState(() {});
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        "High Quality Audio",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        "Use uncompressed .wav files instead of .mp3",
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      value: highQualityAudio,
                      activeThumbColor: Colors.lightBlue.shade200,
                      onChanged: (bool value) {
                        setModalState(() => highQualityAudio = value);
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Crossfade Duration",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "${crossfadeDuration.toInt()}s",
                              style: TextStyle(
                                color: Colors.lightBlue.shade200,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Transition time between changing noise types",
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4,
                            activeTrackColor: Colors.lightBlue.shade200,
                            inactiveTrackColor: Colors.white10,
                            thumbColor: Colors.lightBlue.shade100,
                          ),
                          child: Slider(
                            value: crossfadeDuration,
                            min: 1,
                            max: 10,
                            divisions: 9,
                            onChanged: (double value) {
                              setModalState(() => crossfadeDuration = value);
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: const Color.fromARGB(255, 209, 217, 226),
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _openSettingsPanel,
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4C6A82), Color(0xFF27384E)],
          ),
        ),
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: GridView(
                          primary: false,
                          padding: const EdgeInsets.only(top: 12, bottom: 12),
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                mainAxisExtent: 170, // Fixed height
                              ),
                          children: <Widget>[
                            NoiseCard(
                              title: "Brown Noise",
                              subtitle: "(Deep)",
                              value: brownSliderValue,
                              isSelected: selectedIndex == 0,
                              onTap: () => setState(() {
                                selectedIndex = selectedIndex == 0 ? -1 : 0;
                              }),
                              onChanged: (val) => setState(() {
                                brownSliderValue = val;
                                selectedIndex = 0;
                                activePresetName = null;
                              }),
                              icon: Icons.equalizer,
                              accentColor: const Color(0xFFC38965),
                              wavePattern: 0,
                            ),
                            NoiseCard(
                              title: "Pink Noise",
                              subtitle: "(Nature)",
                              value: pinkSliderValue,
                              isSelected: selectedIndex == 1,
                              onTap: () => setState(() {
                                selectedIndex = selectedIndex == 1 ? -1 : 1;
                              }),
                              onChanged: (val) => setState(() {
                                pinkSliderValue = val;
                                selectedIndex = 1;
                                activePresetName = null;
                              }),
                              icon: Icons.nature,
                              accentColor: const Color(0xFFE484A3),
                              wavePattern: 1,
                            ),
                            NoiseCard(
                              title: "Green Noise",
                              subtitle: "(Forest)",
                              value: greenSliderValue,
                              isSelected: selectedIndex == 2,
                              onTap: () => setState(() {
                                selectedIndex = selectedIndex == 2 ? -1 : 2;
                              }),
                              onChanged: (val) => setState(() {
                                greenSliderValue = val;
                                selectedIndex = 2;
                                activePresetName = null;
                              }),
                              icon: Icons.park,
                              accentColor: const Color(0xFF6DCA78),
                              wavePattern: 2,
                            ),
                            NoiseCard(
                              title: "White Noise",
                              subtitle: "(Detail)",
                              value: whiteSliderValue,
                              isSelected: selectedIndex == 3,
                              onTap: () => setState(() {
                                selectedIndex = selectedIndex == 3 ? -1 : 3;
                              }),
                              onChanged: (val) => setState(() {
                                whiteSliderValue = val;
                                selectedIndex = 3;
                                activePresetName = null;
                              }),
                              icon: Icons.blur_on,
                              accentColor: const Color(0xFFD1D1D1),
                              wavePattern: 3,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 18,
                        ),
                        child: AbsorbPointer(
                          absorbing: selectedIndex == -1,
                          child: Opacity(
                            opacity: selectedIndex == -1 ? 0.5 : 1.0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: Colors.white10),
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
                                            return PopupMenuButton<String>(
                                              onSelected: (String name) {
                                                _applyPreset(name);
                                              },
                                              itemBuilder:
                                                  (BuildContext context) =>
                                                      items
                                                          .map(
                                                            (k) =>
                                                                PopupMenuItem<
                                                                  String
                                                                >(
                                                                  value: k,
                                                                  child: Text(
                                                                    k,
                                                                  ),
                                                                ),
                                                          )
                                                          .toList(),
                                              child: Text(
                                                activePresetName ?? 'MIX',
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '24:15',
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.9,
                                            ),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'min remaining',
                                          style: TextStyle(
                                            color: Colors.white38,
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
                                      color: const Color(0xFFD3E4F6),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.35,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.pause,
                                        color: selectedIndex == -1
                                            ? Colors.black26
                                            : Colors.black87,
                                      ),
                                      onPressed: selectedIndex == -1
                                          ? null
                                          : () {},
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Column(
                                    children: [
                                      IconButton(
                                        onPressed: selectedIndex == -1
                                            ? null
                                            : () {},
                                        icon: Icon(
                                          Icons.repeat,
                                          color: selectedIndex == -1
                                              ? Colors.white30
                                              : Colors.white70,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: selectedIndex == -1
                                            ? null
                                            : () {},
                                        icon: Icon(
                                          Icons.shuffle,
                                          color: selectedIndex == -1
                                              ? Colors.white30
                                              : Colors.white70,
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
