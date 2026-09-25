import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_screenshots_generator/store_screenshots_generator.dart';

void main() {
  test('BackgroundFill solid round-trips through properties', () {
    const fill = BackgroundFill(
      kind: BackgroundFillKind.solid,
      solidColor: 0xFF1A8BD7,
    );
    final restored = BackgroundFill.fromProperties(fill.toProperties());
    expect(restored.kind, BackgroundFillKind.solid);
    expect(restored.solidColor, 0xFF1A8BD7);
    expect(restored.toBoxDecoration().color, const Color(0xFF1A8BD7));
  });

  test('BackgroundFill linear supports multiple stops', () {
    final fill = BackgroundFill.linear(
      stops: const [
        GradientStop(color: 0xFFFF0000, stop: 0),
        GradientStop(color: 0xFF00FF00, stop: 0.5),
        GradientStop(color: 0xFF0000FF, stop: 1),
      ],
      angleDegrees: 90,
    );
    final props = fill.toProperties();
    expect(props['fillKind'], 'linear');
    expect(props['gradientStopColors'], [0xFFFF0000, 0xFF00FF00, 0xFF0000FF]);
    expect(props['gradientStops'], [0.0, 0.5, 1.0]);
    expect(props['gradientAngle'], 90.0);

    final restored = BackgroundFill.fromProperties(props);
    expect(restored.stops.length, 3);
    expect(restored.angleDegrees, 90);

    final decoration = restored.toBoxDecoration();
    expect(decoration.gradient, isA<LinearGradient>());
  });

  test('BackgroundFill radial round-trips geometry', () {
    final fill = BackgroundFill.radial(
      centerX: 0.25,
      centerY: 0.75,
      radius: 0.9,
    );
    final restored = BackgroundFill.fromProperties(fill.toProperties());
    expect(restored.kind, BackgroundFillKind.radialGradient);
    expect(restored.centerX, 0.25);
    expect(restored.centerY, 0.75);
    expect(restored.radius, 0.9);
    expect(restored.toBoxDecoration().gradient, isA<RadialGradient>());
  });

  test('BackgroundFill normalizes unsorted stops', () {
    final fill = BackgroundFill.linear(
      stops: const [
        GradientStop(color: 0xFF0000FF, stop: 1),
        GradientStop(color: 0xFFFF0000, stop: 0),
      ],
    );
    expect(fill.stops.first.color, 0xFFFF0000);
    expect(fill.stops.last.color, 0xFF0000FF);
  });

  test('BackgroundFill displayLabel describes gradient stops', () {
    final fill = BackgroundFill.linear();
    expect(fill.displayLabel(), 'Linear · 2 stops');
    expect(BackgroundFill.solid().displayLabel(), '#1A8BD7');
  });
}
