import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:noiz_stream/controllers/app_settings_controller.dart';
import 'package:noiz_stream/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('renders mixer controls', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    expect(find.text('NoizStream'), findsOneWidget);
    expect(find.text('Brown Noise'), findsOneWidget);
    expect(find.text('Pink Noise'), findsOneWidget);
    expect(find.text('Green Noise'), findsOneWidget);
    expect(find.text('White Noise'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });

  testWidgets('loads persisted settings and autoplays on startup', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      AppSettingsController.themeModeKey: 'dark',
      AppSettingsController.playOnStartupKey: true,
      AppSettingsController.crossfadeDurationKey: 7.0,
    });

    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.pause), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    final darkModeTile = tester.widget<SwitchListTile>(
      find.widgetWithText(SwitchListTile, 'Dark Mode'),
    );
    final playOnStartupTile = tester.widget<SwitchListTile>(
      find.widgetWithText(SwitchListTile, 'Play on Startup'),
    );

    expect(darkModeTile.value, isTrue);
    expect(playOnStartupTile.value, isTrue);
    expect(find.text('Crossfade Duration: 7s'), findsOneWidget);
  });

  testWidgets('persists toggled settings from sheet', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(SwitchListTile, 'Dark Mode'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(SwitchListTile, 'Play on Startup'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(AppSettingsController.themeModeKey), 'dark');
    expect(prefs.getBool(AppSettingsController.playOnStartupKey), isTrue);
  });

  test('persists crossfade duration in settings controller', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final controller = AppSettingsController();

    await controller.load();
    await controller.setCrossfadeDuration(6.0);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getDouble(AppSettingsController.crossfadeDurationKey), 6.0);
  });
}
