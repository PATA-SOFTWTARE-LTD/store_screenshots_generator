import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_screenshots_generator/studio.dart';

void main() {
  const canvas = Size(1000, 2000);
  const threshold = 10.0;

  SnapResult snap({
    required Rect moving,
    Offset rawOffset = Offset.zero,
    List<Rect> targets = const [],
    double thresh = threshold,
  }) {
    return resolveSnap(
      movingRect: moving,
      rawOffset: rawOffset,
      targets: targets,
      canvasSize: canvas,
      threshold: thresh,
    );
  }

  group('defaultSnapThreshold', () {
    test('is ~0.7% of the longer side', () {
      expect(defaultSnapThreshold(const Size(1080, 1920)), closeTo(13.44, 0.01));
      expect(defaultSnapThreshold(const Size(400, 800)), closeTo(5.6, 0.01));
    });
  });

  group('canvas center snap', () {
    test('snaps X to canvas center', () {
      // Prospective: 100-wide rect centered near 500 (center at 504).
      const prospective = Rect.fromLTWH(454, 100, 100, 100);
      const raw = Offset(20, 0);
      final result = snap(moving: prospective, rawOffset: raw);

      // Correction X: 500 - 504 = -4 → effective = 20 - 4 = 16.
      expect(result.offset.dx, closeTo(16, 0.001));
      expect(result.guides.single.axis, Axis.vertical);
      expect(result.guides.single.position, 500);
      expect(result.guides.single.kind, SnapGuideKind.canvas);
    });

    test('snaps Y to canvas center', () {
      // Prospective: 100-tall rect centered near 1000 (center at 1006).
      const prospective = Rect.fromLTWH(100, 956, 100, 100);
      const raw = Offset(0, 15);
      final result = snap(moving: prospective, rawOffset: raw);

      // Correction Y: 1000 - 1006 = -6 → effective = 15 - 6 = 9.
      expect(result.offset.dy, closeTo(9, 0.001));
      expect(result.guides.single.axis, Axis.horizontal);
      expect(result.guides.single.position, 1000);
      expect(result.guides.single.kind, SnapGuideKind.canvas);
    });
  });

  group('edge snap', () {
    test('snaps left edge to canvas left', () {
      const prospective = Rect.fromLTWH(5, 100, 100, 100);
      const raw = Offset(5, 0);
      final result = snap(moving: prospective, rawOffset: raw);

      expect(result.offset.dx, closeTo(0, 0.001));
      expect(result.guides.single.position, 0);
      expect(result.guides.single.kind, SnapGuideKind.canvas);
    });

    test('snaps left edge to another element right edge', () {
      const target = Rect.fromLTWH(50, 200, 100, 80); // right = 150
      const prospective = Rect.fromLTWH(155, 100, 100, 100); // left near 150
      const raw = Offset(30, 0);
      final result = snap(
        moving: prospective,
        rawOffset: raw,
        targets: [target],
      );

      // Correction: 150 - 155 = -5 → effective = 30 - 5 = 25.
      expect(result.offset.dx, closeTo(25, 0.001));
      expect(
        result.guides,
        contains(
          const SnapGuide(
            axis: Axis.vertical,
            position: 150,
            kind: SnapGuideKind.element,
          ),
        ),
      );
    });
  });

  group('center-to-center element snap', () {
    test('snaps moving center to target center', () {
      const target = Rect.fromLTWH(200, 300, 100, 100); // center 250, 350
      // Moving center at 256, 350.
      const prospective = Rect.fromLTWH(206, 300, 100, 100);
      const raw = Offset(10, 0);
      final result = snap(
        moving: prospective,
        rawOffset: raw,
        targets: [target],
      );

      expect(result.offset.dx, closeTo(4, 0.001)); // 10 + (250 - 256) = 4
      expect(
        result.guides,
        contains(
          const SnapGuide(
            axis: Axis.vertical,
            position: 250,
            kind: SnapGuideKind.element,
          ),
        ),
      );
    });
  });

  group('beyond threshold', () {
    test('does not snap when farther than threshold', () {
      // Center at 520, canvas center 500, distance 20 > threshold 10.
      const prospective = Rect.fromLTWH(470, 100, 100, 100);
      const raw = Offset(50, 0);
      final result = snap(moving: prospective, rawOffset: raw);

      expect(result.offset, raw);
      expect(result.guides, isEmpty);
    });
  });

  group('tie-break prefers center-to-center', () {
    test('center match wins over equidistant edge match', () {
      // Moving: left=456, w=100 → center=506.
      // Canvas center X=500 → |delta|=6, center-to-center score=4.8.
      // Target right=462 → left-to-right |delta|=6, edge score=6.
      // Center wins → snap to canvas center.
      const target = Rect.fromLTWH(362, 0, 100, 50); // right = 462
      const prospective = Rect.fromLTWH(456, 100, 100, 100);
      final result = snap(moving: prospective, targets: [target]);

      expect(result.offset.dx, closeTo(-6, 0.001));
      expect(result.guides.single.kind, SnapGuideKind.canvas);
      expect(result.guides.single.position, 500);
    });
  });

  group('guides', () {
    test('emits both axes when both snap', () {
      // Near canvas center both axes: center at (504, 1006).
      const prospective = Rect.fromLTWH(454, 956, 100, 100);
      final result = snap(moving: prospective);

      expect(result.guides, hasLength(2));
      expect(
        result.guides,
        containsAll([
          const SnapGuide(
            axis: Axis.vertical,
            position: 500,
            kind: SnapGuideKind.canvas,
          ),
          const SnapGuide(
            axis: Axis.horizontal,
            position: 1000,
            kind: SnapGuideKind.canvas,
          ),
        ]),
      );
    });
  });
}
