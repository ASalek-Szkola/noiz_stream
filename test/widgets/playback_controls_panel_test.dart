import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noiz_stream/widgets/playback_controls_panel.dart';

void main() {
  Widget buildFrame({
    bool hasActiveNoiseSelection = true,
    List<String> presetNames = const ['Flat', 'Deep'],
    String? activePresetName,
    bool isPlaying = false,
    VoidCallback? onTogglePlayPause,
    VoidCallback? onSavePreset,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: PlaybackControlsPanel(
          hasActiveNoiseSelection: hasActiveNoiseSelection,
          presetNames: presetNames,
          activePresetName: activePresetName,
          presetColorForName: (name, fallback) => Colors.blue,
          isCustomPresetName: (name) => name == 'Deep',
          onPresetSelected: (_) {},
          onSavePreset: onSavePreset ?? () {},
          formattedRemaining: '00:00',
          isPlaying: isPlaying,
          repeatEnabled: false,
          shuffleEnabled: false,
          onTogglePlayPause: onTogglePlayPause ?? () {},
          onToggleRepeat: () {},
          onToggleShuffle: () {},
        ),
      ),
    );
  }

  testWidgets('PlaybackControlsPanel shows active preset name', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildFrame(activePresetName: 'Flat'));

    expect(find.text('Flat'), findsOneWidget);
    expect(find.text('MIX'), findsNothing);
  });

  testWidgets('PlaybackControlsPanel shows MIX when no preset is active', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildFrame(activePresetName: null));

    expect(find.text('MIX'), findsOneWidget);
  });

  testWidgets('PlaybackControlsPanel is disabled when no noise is selected', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildFrame(hasActiveNoiseSelection: false));

    // We look for the AbsorbPointer that has absorbing: true
    final absorbPointers = tester.widgetList<AbsorbPointer>(
      find.byType(AbsorbPointer),
    );
    expect(absorbPointers.any((a) => a.absorbing == true), isTrue);

    final opacities = tester.widgetList<Opacity>(find.byType(Opacity));
    expect(opacities.any((o) => o.opacity == 0.5), isTrue);
  });

  testWidgets('PlaybackControlsPanel play/pause button triggers callback', (
    WidgetTester tester,
  ) async {
    bool toggled = false;
    await tester.pumpWidget(
      buildFrame(onTogglePlayPause: () => toggled = true),
    );

    await tester.tap(find.byIcon(Icons.play_arrow));
    expect(toggled, isTrue);
  });

  testWidgets('PlaybackControlsPanel save button triggers callback', (
    WidgetTester tester,
  ) async {
    bool saved = false;
    await tester.pumpWidget(buildFrame(onSavePreset: () => saved = true));

    await tester.tap(find.byIcon(Icons.bookmark_add_outlined));
    expect(saved, isTrue);
  });
}
