import 'dart:async';

import 'package:flutter/material.dart';

import '../data/default_presets.dart';
import '../models/noise_mix.dart';
import '../models/preset.dart';
import '../services/preset_storage_service.dart';
import 'app_settings_controller.dart';
import 'playback_session_controller.dart';

enum SavePresetStatus { saved, emptyName, builtInNameConflict }

class SavePresetResult {
  const SavePresetResult._(this.status, this.savedName);

  const SavePresetResult.saved(String name)
    : this._(SavePresetStatus.saved, name);

  const SavePresetResult.emptyName() : this._(SavePresetStatus.emptyName, null);

  const SavePresetResult.builtInNameConflict()
    : this._(SavePresetStatus.builtInNameConflict, null);

  final SavePresetStatus status;
  final String? savedName;
}

class HomePageController {
  HomePageController({
    required this.settingsController,
    required this.sessionController,
    required this.presetStorageService,
  }) : mixNotifier = ValueNotifier<NoiseMix>(const NoiseMix.defaults()),
       selectedIndexNotifier = ValueNotifier<int>(0),
       activePresetNameNotifier = ValueNotifier<String?>(null),
       presetsNotifier = ValueNotifier<List<Preset>>(
         List<Preset>.unmodifiable(builtInPresets),
       ),
       presetNamesNotifier = ValueNotifier<List<String>>(
         builtInPresets.map((preset) => preset.name).toList(growable: false),
       );

  static const int _defaultPresetSteps = 20;
  static const int _minFrameMs = 16;

  final AppSettingsController settingsController;
  final PlaybackSessionController sessionController;
  final PresetStorageService presetStorageService;

  final ValueNotifier<NoiseMix> mixNotifier;
  final ValueNotifier<int> selectedIndexNotifier;
  final ValueNotifier<String?> activePresetNameNotifier;
  final ValueNotifier<List<Preset>> presetsNotifier;
  final ValueNotifier<List<String>> presetNamesNotifier;

  final Set<String> _customPresetNames = <String>{};

  Timer? _presetTimer;
  bool _startupBehaviorApplied = false;
  bool _disposed = false;

  bool get hasActiveNoiseSelection => selectedIndexNotifier.value != -1;

  Future<void> loadCustomPresets() async {
    final loaded = await presetStorageService.loadCustomPresets();
    if (loaded.isEmpty || _disposed) {
      return;
    }

    final merged = List<Preset>.from(presetsNotifier.value);

    for (final preset in loaded) {
      final index = merged.indexWhere(
        (existing) => existing.name == preset.name,
      );
      if (index >= 0) {
        if (merged[index].isCustom) {
          merged[index] = preset.copyWith(isCustom: true);
        }
        continue;
      }
      merged.add(preset.copyWith(isCustom: true));
    }

    _customPresetNames
      ..clear()
      ..addAll(
        merged.where((preset) => preset.isCustom).map((preset) => preset.name),
      );

    _setPresets(merged);
  }

  void applyStartupBehaviorIfNeeded() {
    if (!settingsController.isLoaded || _startupBehaviorApplied) {
      return;
    }

    sessionController.applyPlayOnStartup(
      enabled: settingsController.playOnStartup,
      hasSelection: hasActiveNoiseSelection,
    );
    _startupBehaviorApplied = true;
  }

  void applyPresetByName(String name) {
    final preset = _findPresetByName(name);
    if (preset == null) {
      return;
    }
    _applyPreset(preset);
  }

  void toggleNoiseSelection(int index) {
    final current = selectedIndexNotifier.value;
    final next = current == index ? -1 : index;

    selectedIndexNotifier.value = next;
    if (next == -1) {
      activePresetNameNotifier.value = null;
    }

    sessionController.onSelectionChanged(hasActiveNoiseSelection);
  }

  void setNoiseLevel(int index, double value) {
    mixNotifier.value = mixNotifier.value.withLevelForIndex(index, value);
    selectedIndexNotifier.value = index;
    activePresetNameNotifier.value = null;
    sessionController.onSelectionChanged(true);
  }

  Future<SavePresetResult> saveCurrentMixAsPreset(
    String name,
    Color color,
  ) async {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      return const SavePresetResult.emptyName();
    }

    final existing = _findPresetByName(normalizedName);
    if (existing != null && !existing.isCustom) {
      return const SavePresetResult.builtInNameConflict();
    }

    final customPreset = Preset(
      name: normalizedName,
      mix: mixNotifier.value,
      color: color,
      isCustom: true,
    );

    final updated = List<Preset>.from(presetsNotifier.value);
    final existingIndex = updated.indexWhere(
      (preset) => preset.name == normalizedName,
    );

    if (existingIndex >= 0) {
      updated[existingIndex] = customPreset;
    } else {
      updated.add(customPreset);
    }

    _customPresetNames.add(normalizedName);
    activePresetNameNotifier.value = normalizedName;
    _setPresets(updated);

    await _persistCustomPresets();
    return SavePresetResult.saved(normalizedName);
  }

  Color presetColorForName(String name, Color fallback) {
    final preset = _findPresetByName(name);
    return preset?.color ?? fallback;
  }

  bool isCustomPresetName(String name) {
    return _customPresetNames.contains(name);
  }

  Future<void> deleteCustomPreset(String name) async {
    if (!_customPresetNames.contains(name)) {
      return;
    }

    final updated = List<Preset>.from(presetsNotifier.value)
        .where((preset) => preset.name != name)
        .toList();

    _customPresetNames.remove(name);
    if (activePresetNameNotifier.value == name) {
      activePresetNameNotifier.value = null;
    }

    _setPresets(updated);
    await _persistCustomPresets();
  }

  void dispose() {
    _disposed = true;
    _presetTimer?.cancel();
    mixNotifier.dispose();
    selectedIndexNotifier.dispose();
    activePresetNameNotifier.dispose();
    presetsNotifier.dispose();
    presetNamesNotifier.dispose();
  }

  void _applyPreset(Preset preset) {
    _presetTimer?.cancel();

    final start = mixNotifier.value;
    final target = preset.mix;
    final steps = _defaultPresetSteps;
    final totalMs = (settingsController.crossfadeDuration * 1000).round();
    final rawStepMs = totalMs ~/ steps;
    final stepMs = rawStepMs < _minFrameMs ? _minFrameMs : rawStepMs;

    selectedIndexNotifier.value = target.dominantIndex();
    activePresetNameNotifier.value = preset.name;
    sessionController.onSelectionChanged(hasActiveNoiseSelection);

    var step = 0;
    _presetTimer = Timer.periodic(Duration(milliseconds: stepMs), (timer) {
      if (_disposed) {
        timer.cancel();
        return;
      }

      step++;
      final t = (step / steps).clamp(0.0, 1.0);
      final eased = Curves.easeInOut.transform(t);

      mixNotifier.value = NoiseMix(
        brown: start.brown + (target.brown - start.brown) * eased,
        pink: start.pink + (target.pink - start.pink) * eased,
        green: start.green + (target.green - start.green) * eased,
        white: start.white + (target.white - start.white) * eased,
      );

      if (step >= steps) {
        timer.cancel();
        _presetTimer = null;
        mixNotifier.value = target;
      }
    });
  }

  Preset? _findPresetByName(String name) {
    for (final preset in presetsNotifier.value) {
      if (preset.name == name) {
        return preset;
      }
    }
    return null;
  }

  Future<void> _persistCustomPresets() {
    final customPresets = presetsNotifier.value.where(
      (preset) => preset.isCustom,
    );
    return presetStorageService.saveCustomPresets(customPresets);
  }

  void _setPresets(List<Preset> presets) {
    final frozen = List<Preset>.unmodifiable(presets);
    presetsNotifier.value = frozen;
    presetNamesNotifier.value = frozen
        .map((preset) => preset.name)
        .toList(growable: false);
  }
}
