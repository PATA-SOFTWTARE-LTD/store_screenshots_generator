import 'package:flutter/material.dart';

import '../layouts/device_catalog.dart';
import '../layouts/element_colors.dart';
import 'background_fill.dart';
import 'models/composition.dart';
import 'models/element_frame.dart';
import 'models/element_type.dart';
import 'models/scene_element.dart';
import 'models/studio_project.dart';

/// Built-in layout presets as editable scene graphs.
class CompositionPresets {
  static const defaultPresetId = 'title_and_frame';

  static const supportedPresets = [
    'title_and_frame',
    'full_bleed',
    'minimal',
  ];

  static Composition build({
    required String presetId,
    required List<String> locales,
    required String slotName,
  }) {
    final device = DeviceCatalog.getById(StudioProject.referenceDeviceId);
    final w = device.resolution.width;
    final h = device.resolution.height;

    return switch (presetId) {
      'full_bleed' => _fullBleed(w, h, locales, slotName),
      'minimal' => _minimal(w, h, locales, slotName),
      _ => _titleAndFrame(w, h, locales, slotName),
    };
  }

  static String resolvePresetId({
    String? screenPreset,
    String? defaultPreset,
  }) {
    return screenPreset ?? defaultPreset ?? defaultPresetId;
  }

  static Composition _titleAndFrame(
    double w,
    double h,
    List<String> locales,
    String slotName,
  ) {
    final frameW = w * 0.72;
    final frameH = h * 0.52;
    final frameX = (w - frameW) / 2;
    final frameY = h * 0.38;

    return Composition(
      elements: [
        SceneElement(
          id: 'bg',
          type: ElementType.solidBackground,
          frame: ElementFrame(x: 0, y: 0, width: w, height: h),
          properties: BackgroundFill.linear(
            stops: [
              GradientStop(
                color: colorToProperty(const Color(0xFFF4EDDC)),
                stop: 0,
              ),
              GradientStop(
                color: colorToProperty(const Color(0xFF5FD1D3)),
                stop: 1,
              ),
            ],
          ).toProperties(),
        ),
        SceneElement(
          id: 'title',
          type: ElementType.text,
          frame: ElementFrame(x: 48, y: 120, width: w - 96, height: 200),
          properties: {
            'text': _localizedText(locales, slotName),
            'fontSize': 84.0,
            'color': colorToProperty(const Color(0xFF1A8BD7)),
            'fontWeight': 'w800',
            'textAlign': 'center',
          },
        ),
        SceneElement(
          id: 'raw',
          type: ElementType.rawScreenshot,
          frame: ElementFrame(
            x: frameX + 40,
            y: frameY + 40,
            width: frameW - 80,
            height: frameH - 80,
          ),
          properties: const {},
        ),
        SceneElement(
          id: 'frame',
          type: ElementType.deviceFrame,
          frame: ElementFrame(
            x: frameX,
            y: frameY,
            width: frameW,
            height: frameH,
          ),
          properties: const {'showBezel': true},
        ),
      ],
    );
  }

  static Composition _fullBleed(
    double w,
    double h,
    List<String> locales,
    String slotName,
  ) {
    return Composition(
      elements: [
        SceneElement(
          id: 'raw',
          type: ElementType.rawScreenshot,
          frame: ElementFrame(x: 0, y: 0, width: w, height: h),
          properties: const {},
        ),
        SceneElement(
          id: 'title',
          type: ElementType.text,
          frame: ElementFrame(x: 48, y: h - 280, width: w - 96, height: 200),
          properties: {
            'text': _localizedText(locales, slotName),
            'fontSize': 64.0,
            'color': colorToProperty(const Color(0xFFFFFFFF)),
            'fontWeight': 'w700',
            'textAlign': 'center',
          },
        ),
      ],
    );
  }

  static Composition _minimal(
    double w,
    double h,
    List<String> locales,
    String slotName,
  ) {
    return Composition(
      elements: [
        SceneElement(
          id: 'bg',
          type: ElementType.solidBackground,
          frame: ElementFrame(x: 0, y: 0, width: w, height: h),
          properties: BackgroundFill.solid(
            colorToProperty(const Color(0xFF1A237E)),
          ).toProperties(),
        ),
        SceneElement(
          id: 'title',
          type: ElementType.text,
          frame: ElementFrame(
            x: 48,
            y: h * 0.35,
            width: w - 96,
            height: 300,
          ),
          properties: {
            'text': _localizedText(locales, slotName),
            'fontSize': 96.0,
            'color': colorToProperty(const Color(0xFFFFFFFF)),
            'fontWeight': 'w800',
            'textAlign': 'center',
          },
        ),
      ],
    );
  }

  static Map<String, String> _localizedText(
    List<String> locales,
    String slotName,
  ) {
    return {for (final locale in locales) locale: slotName};
  }
}
