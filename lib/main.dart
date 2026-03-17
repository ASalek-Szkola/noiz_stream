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
              GridView.count(
                primary: false,
                padding: const EdgeInsets.all(20),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                crossAxisCount: 2,
                childAspectRatio: (w / 2) / (h * 0.35),
                children: <Widget>[
                  NoiseCard(
                    title: "Brown Noise",
                    subtitle: "(Deep)",
                    value: brownSliderValue,
                    onChanged: (val) => setState(() => brownSliderValue = val),
                    icon: Icons.equalizer,
                    accentColor: Colors.brown[300]!,
                  ),
                  NoiseCard(
                    title: "Pink Noise",
                    subtitle: "(Nature)",
                    value: pinkSliderValue,
                    onChanged: (val) => setState(() => pinkSliderValue = val),
                    icon: Icons.energy_savings_leaf,
                    accentColor: Colors.pinkAccent.shade100,
                  ),
                  NoiseCard(
                    title: "Green Noise",
                    subtitle: "(Forest)",
                    value: greenSliderValue,
                    onChanged: (val) => setState(() => greenSliderValue = val),
                    icon: Icons.forest,
                    accentColor: Colors.lightGreenAccent.shade400,
                  ),
                  NoiseCard(
                    title: "White Noise",
                    subtitle: "(Detail)",
                    value: whiteSliderValue,
                    onChanged: (val) => setState(() => whiteSliderValue = val),
                    icon: Icons.equalizer,
                    accentColor: Colors.white,
                  ),
                ],
              ),

              Container(
                margin: const EdgeInsets.symmetric(vertical: 40),
                width: 200,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(42, 56, 65, 0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: const Center(
                  child: Text(
                    'Prostokąt',
                    style: TextStyle(color: Colors.white70),
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

  const NoiseCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          const Spacer(), // TODO
          // Volume
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
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
                        enabledThumbRadius: 5,
                      ),
                    ),
                    child: Slider(
                      value: value,
                      onChanged: onChanged,
                      activeColor: Colors.blue[200],
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
          const SizedBox(height: 8),

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
    );
  }
}
