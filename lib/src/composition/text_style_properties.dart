import 'package:flutter/material.dart';

import '../layouts/element_colors.dart';

/// Bundled font families available in the package.
const kPackageTextFontFamilies = <String?, String>{
  null: 'System default',
  'StatusBarRoboto': 'Roboto',
};

/// Default text element properties when adding via Studio.
Map<String, dynamic> textStyleDefaultsForAddText({
  required Map<String, String> localizedText,
  required int defaultColor,
}) {
  return {
    'text': localizedText,
    'fontSize': 64.0,
    'color': defaultColor,
    'fontWeight': 'w700',
    'textAlign': 'center',
    'lineHeight': 1.1,
    'letterSpacing': 0.0,
    'verticalAlign': 'center',
    'opacity': 1.0,
    'overflow': 'clip',
  };
}

TextAlign parseTextAlign(String? align) => switch (align) {
      'left' => TextAlign.left,
      'right' => TextAlign.right,
      _ => TextAlign.center,
    };

FontWeight parseFontWeight(String? name) => switch (name) {
      'w800' => FontWeight.w800,
      'w700' => FontWeight.w700,
      'w600' => FontWeight.w600,
      'w500' => FontWeight.w500,
      'w400' => FontWeight.w400,
      _ => FontWeight.normal,
    };

bool isBoldFontWeight(String? name) {
  final weight = parseFontWeight(name);
  return weight.value >= FontWeight.w700.value;
}

Alignment parseVerticalAlign(String? align) => switch (align) {
      'top' => Alignment.topCenter,
      'bottom' => Alignment.bottomCenter,
      _ => Alignment.center,
    };

TextOverflow parseTextOverflow(String? overflow) => switch (overflow) {
      'ellipsis' => TextOverflow.ellipsis,
      'fade' => TextOverflow.fade,
      'visible' => TextOverflow.visible,
      _ => TextOverflow.clip,
    };

bool boolFromProperties(Map<String, dynamic> properties, String key) {
  final raw = properties[key];
  if (raw is bool) return raw;
  if (raw is String) return raw == 'true';
  return false;
}

double textOpacityFromProperties(Map<String, dynamic> properties) {
  final raw = properties['opacity'];
  if (raw is num) return raw.toDouble().clamp(0.0, 1.0);
  return 1.0;
}

int? maxLinesFromProperties(Map<String, dynamic> properties) {
  final raw = properties['maxLines'];
  if (raw is int && raw > 0) return raw;
  if (raw is num && raw > 0) return raw.round();
  return null;
}

TextDecoration textDecorationFromProperties(Map<String, dynamic> properties) {
  final decorations = <TextDecoration>[];
  if (boolFromProperties(properties, 'underline')) {
    decorations.add(TextDecoration.underline);
  }
  if (boolFromProperties(properties, 'strikethrough')) {
    decorations.add(TextDecoration.lineThrough);
  }
  if (decorations.isEmpty) return TextDecoration.none;
  if (decorations.length == 1) return decorations.first;
  return TextDecoration.combine(decorations);
}

TextStyle textStyleFromProperties(
  Map<String, dynamic> properties, {
  Color? fallbackColor,
}) {
  final fontSize =
      (properties['fontSize'] as num?)?.toDouble() ?? 48.0;
  final color = colorFromProperty(
    properties['color'],
    fallback: fallbackColor ?? Colors.white,
  );
  final opacity = textOpacityFromProperties(properties);
  final letterSpacing =
      (properties['letterSpacing'] as num?)?.toDouble() ?? 0.0;
  final lineHeight =
      (properties['lineHeight'] as num?)?.toDouble() ?? 1.1;
  final fontFamily = properties['fontFamily'] as String?;
  final italic = boolFromProperties(properties, 'italic');

  final shadows = _shadowsFromProperties(properties, opacity: opacity);

  return TextStyle(
    fontSize: fontSize,
    color: color.withValues(alpha: color.a * opacity),
    fontWeight: parseFontWeight(properties['fontWeight'] as String?),
    fontStyle: italic ? FontStyle.italic : FontStyle.normal,
    letterSpacing: letterSpacing,
    height: lineHeight,
    fontFamily: fontFamily?.isEmpty == true ? null : fontFamily,
    decoration: textDecorationFromProperties(properties),
    decorationColor: color.withValues(alpha: color.a * opacity),
    shadows: shadows,
  );
}

List<Shadow>? _shadowsFromProperties(
  Map<String, dynamic> properties, {
  required double opacity,
}) {
  final shadowColorRaw = properties['shadowColor'];
  if (shadowColorRaw == null) return null;

  final baseColor = colorFromProperty(
    shadowColorRaw,
    fallback: Colors.black,
  );
  final shadowColor = baseColor.withValues(alpha: baseColor.a * opacity);

  final blur = (properties['shadowBlur'] as num?)?.toDouble() ?? 4.0;
  final offsetX = (properties['shadowOffsetX'] as num?)?.toDouble() ?? 0.0;
  final offsetY = (properties['shadowOffsetY'] as num?)?.toDouble() ?? 2.0;

  return [
    Shadow(
      color: shadowColor,
      blurRadius: blur,
      offset: Offset(offsetX, offsetY),
    ),
  ];
}
