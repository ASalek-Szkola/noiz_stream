import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

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
  double brownSliderValue = 0.2;
  double pinkSliderValue = 0.2;
  double greenSliderValue = 0.2;
  double whiteSliderValue = 0.2;
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.sizeOf(context).width;
    double h = MediaQuery.sizeOf(context).height;

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
              onPressed: () {}, // TODO
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
            colors: [
              Color.fromARGB(255, 96, 132, 156),
              Color.fromARGB(255, 40, 56, 79),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.count(
                  primary: false,
                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  crossAxisCount: 2,
                  childAspectRatio: 0.92,
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
                      accentColor: Colors.brown.shade300,
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
                      accentColor: Colors.pinkAccent.shade200,
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
                      accentColor: Colors.greenAccent.shade400,
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
                      accentColor: Colors.grey.shade300,
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
                            Text(
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
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.pause, color: Colors.black87),
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
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

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
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white10,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          children: [
            // waveform preview
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              child: SizedBox(
                height: 50,
                child: WaveWidget(color: accentColor, pattern: wavePattern),
              ),
            ),
            // Volume
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
              child: Row(
                children: [
                  Icon(
                    value == 0.00 ? Icons.volume_off : Icons.volume_up,
                    size: 14,
                    color: Colors.white60,
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 12,
                        ),
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                      ),
                      child: Slider(
                        value: value,
                        onChanged: onChanged,
                        activeColor: accentColor.withOpacity(0.9),
                        inactiveColor: Colors.white10,
                      ),
                    ),
                  ),
                  Text(
                    '${(value * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(color: Colors.white60, fontSize: 10),
                  ),
                ],
              ),
            ),
            // Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, color: accentColor, size: 20),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
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

class WaveWidget extends StatelessWidget {
  final Color color;
  final int pattern;

  const WaveWidget({super.key, required this.color, this.pattern = 0});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: WavePainter(color: color, pattern: pattern),
      size: Size.infinite,
    );
  }
}

class WavePainter extends CustomPainter {
  final Color color;
  final int pattern;

  WavePainter({required this.color, this.pattern = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final midY = size.height / 2;
    final amplitude = size.height / 2 * 0.6;

    path.moveTo(0, midY);

    switch (pattern) {
      case 0:
        // Brown Noise: jagged, multiple harmonics
        for (double x = 0; x <= size.width; x++) {
          final t = x / size.width;
          final y =
              midY +
              amplitude *
                  (0.6 * math.sin(t * 2 * math.pi * 1.5) +
                      0.3 * math.sin(t * 2 * math.pi * 3) +
                      0.1 * math.sin(t * 2 * math.pi * 7));
          if (x == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        break;
      case 1:
        // Pink Noise: smooth mid-frequency waves
        for (double x = 0; x <= size.width; x++) {
          final t = x / size.width;
          final y =
              midY +
              amplitude *
                  (0.8 * math.sin(t * 2 * math.pi * 2) +
                      0.2 * math.sin(t * 2 * math.pi * 5));
          if (x == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        break;
      case 2:
        // Green Noise: smooth, lower frequency
        for (double x = 0; x <= size.width; x++) {
          final t = x / size.width;
          final y =
              midY +
              amplitude *
                  (0.9 * math.sin(t * 2 * math.pi * 0.8) +
                      0.1 * math.sin(t * 2 * math.pi * 2));
          if (x == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        break;
      case 3:
        // White Noise: high frequency, jagged
        for (double x = 0; x <= size.width; x++) {
          final t = x / size.width;
          final y =
              midY +
              amplitude *
                  (0.5 * math.sin(t * 2 * math.pi * 3.5) +
                      0.3 * math.sin(t * 2 * math.pi * 6) +
                      0.2 * math.sin(t * 2 * math.pi * 10));
          if (x == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        break;
      default:
        for (double x = 0; x <= size.width; x++) {
          final t = x / size.width;
          final y = midY + amplitude * 0.6 * math.sin(t * 2 * math.pi * 2);
          if (x == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
