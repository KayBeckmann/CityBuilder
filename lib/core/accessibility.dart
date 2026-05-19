import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ColorBlindMode {
  none,
  deuteranopia,
  protanopia;

  String get label => switch (this) {
        ColorBlindMode.none => 'Normal',
        ColorBlindMode.deuteranopia => 'Deuteranopie (Rotgrün)',
        ColorBlindMode.protanopia => 'Protanopie (Rotgrün)',
      };
}

class AccessibilitySettings {
  const AccessibilitySettings({
    this.colorBlindMode = ColorBlindMode.none,
    this.fontSize = 1.0,
  });

  final ColorBlindMode colorBlindMode;
  final double fontSize;

  AccessibilitySettings copyWith({
    ColorBlindMode? colorBlindMode,
    double? fontSize,
  }) =>
      AccessibilitySettings(
        colorBlindMode: colorBlindMode ?? this.colorBlindMode,
        fontSize: fontSize ?? this.fontSize,
      );

  Color adaptColor(Color base) {
    if (colorBlindMode == ColorBlindMode.none) return base;
    final hsl = HSLColor.fromColor(base);
    return switch (colorBlindMode) {
      ColorBlindMode.deuteranopia => hsl.withHue((hsl.hue + 30) % 360).toColor(),
      ColorBlindMode.protanopia => hsl.withHue((hsl.hue + 60) % 360).toColor(),
      ColorBlindMode.none => base,
    };
  }
}

class AccessibilityNotifier extends Notifier<AccessibilitySettings> {
  @override
  AccessibilitySettings build() => const AccessibilitySettings();

  void setColorBlindMode(ColorBlindMode mode) {
    state = state.copyWith(colorBlindMode: mode);
  }

  void setFontSize(double scale) {
    state = state.copyWith(fontSize: scale.clamp(0.8, 1.4));
  }
}

final accessibilityProvider =
    NotifierProvider<AccessibilityNotifier, AccessibilitySettings>(
        AccessibilityNotifier.new);
