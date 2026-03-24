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
  double brownSliderValue = 0.41;
  double pinkSliderValue = 0.51;
  double greenSliderValue = 0.20;
  double whiteSliderValue = 0.72;
  int selectedIndex = 0;

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
            colors: [Color(0xFF4C6A82), Color(0xFF27384E)],
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
