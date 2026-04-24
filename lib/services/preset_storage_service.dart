import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/default_presets.dart';
import '../models/preset.dart';

class PresetStorageService {
  static const String customPresetsKeyV2 = 'custom_presets_v2';
  static const String _customPresetsKeyV1 = 'custom_presets_v1';

  Future<List<Preset>> loadCustomPresets() async {
    final prefs = await SharedPreferences.getInstance();
    final v2Payload = prefs.getString(customPresetsKeyV2);

    if (v2Payload != null && v2Payload.isNotEmpty) {
      return _decodePresets(v2Payload);
    }

    final legacyPayload = prefs.getString(_customPresetsKeyV1);
    if (legacyPayload == null || legacyPayload.isEmpty) {
      return const <Preset>[];
    }

    final migrated = _decodePresets(legacyPayload);
    if (migrated.isNotEmpty) {
      await saveCustomPresets(migrated);
      await prefs.remove(_customPresetsKeyV1);
    }

    return migrated;
  }

  Future<void> saveCustomPresets(Iterable<Preset> presets) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = presets
        .where((preset) => preset.isCustom)
        .map((preset) => preset.toStorageJson())
        .toList(growable: false);

    await prefs.setString(customPresetsKeyV2, jsonEncode(payload));
  }

  List<Preset> _decodePresets(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const <Preset>[];
      }

      final loaded = <Preset>[];
      for (final entry in decoded) {
        final map = _toStringMap(entry);
        if (map == null) {
          continue;
        }

        final preset = Preset.fromStorageJson(
          map,
          fallbackColor: presetColorOptions.first,
          isCustom: true,
        );

        if (preset != null) {
          loaded.add(preset);
        }
      }

      return loaded;
    } catch (_) {
      // Ignore malformed local data and continue with built-in presets.
      return const <Preset>[];
    }
  }

  Map<String, dynamic>? _toStringMap(dynamic source) {
    if (source is! Map) {
      return null;
    }

    final map = <String, dynamic>{};
    for (final entry in source.entries) {
      final key = entry.key;
      if (key is String) {
        map[key] = entry.value;
      }
    }

    return map;
  }
}
