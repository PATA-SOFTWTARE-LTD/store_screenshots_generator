import 'dart:math' as math;

import 'package:flutter/material.dart';

enum BackgroundFillKind { solid, linearGradient, radialGradient }

class GradientStop {
  final int color;
  final double stop;

  const GradientStop({required this.color, required this.stop});

  GradientStop copyWith({int? color, double? stop}) {
    return GradientStop(
      color: color ?? this.color,
      stop: stop ?? this.stop,
    );
  }
}

/// Background fill for [ElementType.solidBackground] elements.
class BackgroundFill {
  static const int defaultSolidColor = 0xFF1A8BD7;
  static const int maxStops = 5;
  static const int minStops = 2;

  final BackgroundFillKind kind;
  final int solidColor;
  final List<GradientStop> stops;
  final double angleDegrees;
  final double centerX;
  final double centerY;
  final double radius;

  const BackgroundFill({
    required this.kind,
    this.solidColor = defaultSolidColor,
    this.stops = const [],
    this.angleDegrees = 90,
    this.centerX = 0.5,
    this.centerY = 0.5,
    this.radius = 0.75,
  });

  factory BackgroundFill.solid([int? color]) {
    return BackgroundFill(
      kind: BackgroundFillKind.solid,
      solidColor: color ?? defaultSolidColor,
    );
  }

  factory BackgroundFill.linear({
    List<GradientStop>? stops,
    double angleDegrees = 90,
  }) {
    return BackgroundFill(
      kind: BackgroundFillKind.linearGradient,
      stops: _normalizeStops(stops ?? _defaultLinearStops()),
      angleDegrees: angleDegrees,
    );
  }

  factory BackgroundFill.radial({
    List<GradientStop>? stops,
    double centerX = 0.5,
    double centerY = 0.5,
    double radius = 0.75,
  }) {
    return BackgroundFill(
      kind: BackgroundFillKind.radialGradient,
      stops: _normalizeStops(stops ?? _defaultLinearStops()),
      centerX: centerX,
      centerY: centerY,
      radius: radius,
    );
  }

  static List<GradientStop> _defaultLinearStops() {
    return const [
      GradientStop(color: defaultSolidColor, stop: 0),
      GradientStop(color: 0xFF5FD1D3, stop: 1),
    ];
  }

  factory BackgroundFill.fromProperties(Map<String, dynamic> properties) {
    final kind = _parseKind(properties['fillKind']);
    switch (kind) {
      case BackgroundFillKind.solid:
        return BackgroundFill.solid(
          _parseColorInt(properties['solidColor']) ?? defaultSolidColor,
        );
      case BackgroundFillKind.linearGradient:
        return BackgroundFill.linear(
          stops: _parseStops(properties),
          angleDegrees: _parseDouble(properties['gradientAngle']) ?? 90,
        );
      case BackgroundFillKind.radialGradient:
        return BackgroundFill.radial(
          stops: _parseStops(properties),
          centerX: _parseDouble(properties['gradientCenterX']) ?? 0.5,
          centerY: _parseDouble(properties['gradientCenterY']) ?? 0.5,
          radius: _parseDouble(properties['gradientRadius']) ?? 0.75,
        );
    }
  }

  Map<String, dynamic> toProperties() {
    return switch (kind) {
      BackgroundFillKind.solid => {
          'fillKind': 'solid',
          'solidColor': solidColor,
        },
      BackgroundFillKind.linearGradient => {
          'fillKind': 'linear',
          ..._stopProperties(),
          'gradientAngle': angleDegrees,
        },
      BackgroundFillKind.radialGradient => {
          'fillKind': 'radial',
          ..._stopProperties(),
          'gradientCenterX': centerX,
          'gradientCenterY': centerY,
          'gradientRadius': radius,
        },
    };
  }

  Map<String, dynamic> _stopProperties() {
    final normalized = _normalizeStops(stops);
    return {
      'gradientStopColors': normalized.map((s) => s.color).toList(),
      'gradientStops': normalized.map((s) => s.stop).toList(),
    };
  }

  BoxDecoration toBoxDecoration() {
    return switch (kind) {
      BackgroundFillKind.solid => BoxDecoration(
          color: Color(solidColor),
        ),
      BackgroundFillKind.linearGradient => BoxDecoration(
          gradient: LinearGradient(
            begin: _alignmentFromAngle(angleDegrees, reverse: true),
            end: _alignmentFromAngle(angleDegrees, reverse: false),
            colors: _gradientColors(),
            stops: _gradientStopValues(),
          ),
        ),
      BackgroundFillKind.radialGradient => BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(centerX * 2 - 1, centerY * 2 - 1),
            radius: radius,
            colors: _gradientColors(),
            stops: _gradientStopValues(),
          ),
        ),
    };
  }

  Color previewColor() {
    return switch (kind) {
      BackgroundFillKind.solid => Color(solidColor),
      BackgroundFillKind.linearGradient ||
      BackgroundFillKind.radialGradient =>
        Color(_normalizeStops(stops).first.color),
    };
  }

  String displayLabel() {
    return switch (kind) {
      BackgroundFillKind.solid => _rgbHex(solidColor),
      BackgroundFillKind.linearGradient =>
        'Linear · ${_normalizeStops(stops).length} stops',
      BackgroundFillKind.radialGradient =>
        'Radial · ${_normalizeStops(stops).length} stops',
    };
  }

  BackgroundFill copyWith({
    BackgroundFillKind? kind,
    int? solidColor,
    List<GradientStop>? stops,
    double? angleDegrees,
    double? centerX,
    double? centerY,
    double? radius,
  }) {
    return BackgroundFill(
      kind: kind ?? this.kind,
      solidColor: solidColor ?? this.solidColor,
      stops: stops ?? this.stops,
      angleDegrees: angleDegrees ?? this.angleDegrees,
      centerX: centerX ?? this.centerX,
      centerY: centerY ?? this.centerY,
      radius: radius ?? this.radius,
    );
  }

  List<Color> _gradientColors() {
    return _normalizeStops(stops).map((s) => Color(s.color)).toList();
  }

  List<double> _gradientStopValues() {
    return _normalizeStops(stops).map((s) => s.stop).toList();
  }

  static Alignment _alignmentFromAngle(double degrees, {required bool reverse}) {
    final radians = (degrees + (reverse ? 180 : 0)) * math.pi / 180;
    return Alignment(math.cos(radians), math.sin(radians));
  }

  static BackgroundFillKind _parseKind(dynamic value) {
    return switch (value) {
      'linear' => BackgroundFillKind.linearGradient,
      'radial' => BackgroundFillKind.radialGradient,
      _ => BackgroundFillKind.solid,
    };
  }

  static int? _parseColorInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return null;
  }

  static List<GradientStop> _parseStops(Map<String, dynamic> properties) {
    final colors = properties['gradientStopColors'];
    final positions = properties['gradientStops'];
    if (colors is! List || positions is! List || colors.isEmpty) {
      return _defaultLinearStops();
    }
    final length = math.min(colors.length, positions.length);
    final stops = <GradientStop>[];
    for (var i = 0; i < length; i++) {
      final color = _parseColorInt(colors[i]);
      final stop = _parseDouble(positions[i]);
      if (color == null || stop == null) continue;
      stops.add(GradientStop(color: color, stop: stop));
    }
    return _normalizeStops(stops.isEmpty ? _defaultLinearStops() : stops);
  }

  static List<GradientStop> _normalizeStops(List<GradientStop> input) {
    if (input.isEmpty) return _defaultLinearStops();
    final sorted = [...input]..sort((a, b) => a.stop.compareTo(b.stop));
    final clamped = sorted
        .map((s) => s.copyWith(stop: s.stop.clamp(0.0, 1.0)))
        .toList();
    if (clamped.length < minStops) {
      return _defaultLinearStops();
    }
    if (clamped.length > maxStops) {
      return clamped.sublist(0, maxStops);
    }
    return clamped;
  }

  static String _rgbHex(int color) {
    return '#${(color & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  /// Interpolate a new stop color between neighbors at [position].
  static int interpolateStopColor(List<GradientStop> stops, double position) {
    final normalized = _normalizeStops(stops);
    if (normalized.isEmpty) return defaultSolidColor;
    if (position <= normalized.first.stop) return normalized.first.color;
    if (position >= normalized.last.stop) return normalized.last.color;

    for (var i = 0; i < normalized.length - 1; i++) {
      final left = normalized[i];
      final right = normalized[i + 1];
      if (position >= left.stop && position <= right.stop) {
        final t = (position - left.stop) / (right.stop - left.stop);
        final leftColor = Color(left.color);
        final rightColor = Color(right.color);
        return Color.fromARGB(
          ((leftColor.a + (rightColor.a - leftColor.a) * t) * 255).round(),
          ((leftColor.r + (rightColor.r - leftColor.r) * t) * 255).round(),
          ((leftColor.g + (rightColor.g - leftColor.g) * t) * 255).round(),
          ((leftColor.b + (rightColor.b - leftColor.b) * t) * 255).round(),
        ).toARGB32();
      }
    }
    return normalized.last.color;
  }
}
