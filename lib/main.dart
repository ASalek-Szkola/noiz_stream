import 'dart:async';

import 'package:flutter/material.dart';

import 'controllers/app_settings_controller.dart';
import 'services/audio_service.dart';
import 'widgets/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final audioService = AudioService();
  unawaited(audioService.init());
  runApp(MyApp(audioService: audioService));
}

class MyApp extends StatefulWidget {
  MyApp({
    super.key,
    AppSettingsController? settingsController,
    AudioService? audioService,
  }) : settingsController = settingsController ?? AppSettingsController(),
       audioService = audioService ?? AudioService();

  final AppSettingsController settingsController;
  final AudioService audioService;

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
  void dispose() {
    unawaited(widget.audioService.dispose());
    super.dispose();
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
            audioService: widget.audioService,
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
