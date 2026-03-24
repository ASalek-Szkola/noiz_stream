import 'package:flutter/material.dart';
import 'NoiseCard.dart';

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
  // Główne suwaki głośności szumów
  double brownSliderValue = 0.41;
  double pinkSliderValue = 0.51;
  double greenSliderValue = 0.20;
  double whiteSliderValue = 0.72;
  int selectedIndex = 0;

  // Zmienne ustawień
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
                      activeColor: Colors.lightBlue.shade200,
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
                      activeColor: Colors.lightBlue.shade200,
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
          // LayoutBuilder + SingleChildScrollView rozwiązują problem zgniatania ekranu z góry do dołu
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints
                        .maxHeight, // Zapewnia wyśrodkowanie na dużych oknach
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Zastępuje Spacer()
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: GridView(
                          primary: false,
                          padding: const EdgeInsets.only(top: 12, bottom: 12),
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          // Tutaj naprawiamy proporcje - karty zawsze będą miały 210px wysokości
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                mainAxisExtent:
                                    210, // STAŁA WYSOKOŚĆ zapobiega błędom w kartach
                              ),
                          children: <Widget>[
                            NoiseCard(
                              title: "Brown Noise",
                              subtitle: "(Deep)",
                              value: brownSliderValue,
                              isSelected: selectedIndex == 0,
                              onTap: () => setState(() => selectedIndex = 0),
                              onChanged: (val) => setState(() {
                                brownSliderValue = val;
                                selectedIndex = 0;
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
                              onTap: () => setState(() => selectedIndex = 1),
                              onChanged: (val) => setState(() {
                                pinkSliderValue = val;
                                selectedIndex = 1;
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
                              onTap: () => setState(() => selectedIndex = 2),
                              onChanged: (val) => setState(() {
                                greenSliderValue = val;
                                selectedIndex = 2;
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
                              onTap: () => setState(() => selectedIndex = 3),
                              onChanged: (val) => setState(() {
                                whiteSliderValue = val;
                                selectedIndex = 3;
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
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'MIX',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '24:15',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
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
                                      color: Colors.black.withOpacity(0.35),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.pause,
                                    color: Colors.black87,
                                  ),
                                  onPressed: () {},
                                ),
                              ),
                              const SizedBox(width: 14),
                              Column(
                                children: [
                                  IconButton(
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.repeat,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.shuffle,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
