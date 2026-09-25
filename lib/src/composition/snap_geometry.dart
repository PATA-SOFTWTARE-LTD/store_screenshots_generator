import 'dart:math' as math;
import 'dart:ui' show Offset, Rect, Size;

import 'package:flutter/painting.dart' show Axis;

/// Whether a snap guide comes from the canvas bounds/center or another element.
enum SnapGuideKind { canvas, element }

/// A horizontal or vertical alignment guide shown while dragging.
///
/// [axis] == [Axis.vertical] means a vertical line (match on X).
/// [axis] == [Axis.horizontal] means a horizontal line (match on Y).
class SnapGuide {
  final Axis axis;
  final double position;
  final SnapGuideKind kind;

  const SnapGuide({
    required this.axis,
    required this.position,
    required this.kind,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SnapGuide &&
          axis == other.axis &&
          position == other.position &&
          kind == other.kind;

  @override
  int get hashCode => Object.hash(axis, position, kind);
}

/// Result of resolving snap for a prospective frame position.
class SnapResult {
  /// Offset to apply to the base frame (raw offset + snap correction).
  final Offset offset;

  /// Active guides for the axes that snapped (0–2 entries).
  final List<SnapGuide> guides;

  const SnapResult({required this.offset, this.guides = const []});
}

/// Default snap threshold: ~0.7% of the longer canvas side (~13px on 1920).
double defaultSnapThreshold(Size canvas) =>
    math.max(canvas.width, canvas.height) * 0.007;

class _SnapCandidate {
  final double line;
  final double anchor;
  final SnapGuideKind kind;
  final bool isCenterToCenter;

  const _SnapCandidate({
    required this.line,
    required this.anchor,
    required this.kind,
    required this.isCenterToCenter,
  });

  double get delta => line - anchor;

  /// Weighted distance: center-to-center ties beat edge matches.
  double get score => delta.abs() * (isCenterToCenter ? 0.8 : 1.0);
}

class _AxisSnap {
  final double correction;
  final SnapGuide guide;

  const _AxisSnap({required this.correction, required this.guide});
}

/// Resolves edge/center snap of [movingRect] against canvas and [targets].
///
/// [movingRect] should already include the raw drag offset (prospective frame).
/// Returns [SnapResult.offset] as the effective offset from the base frame
/// (`rawOffset` plus any per-axis snap correction).
SnapResult resolveSnap({
  required Rect movingRect,
  required Offset rawOffset,
  required List<Rect> targets,
  required Size canvasSize,
  required double threshold,
}) {
  final xSnap = _bestAxisSnap(
    anchors: [movingRect.left, movingRect.center.dx, movingRect.right],
    centerIndex: 1,
    canvasLines: [0.0, canvasSize.width / 2, canvasSize.width],
    targetLines: [
      for (final t in targets) ...[t.left, t.center.dx, t.right],
    ],
    threshold: threshold,
    axis: Axis.vertical,
  );

  final ySnap = _bestAxisSnap(
    anchors: [movingRect.top, movingRect.center.dy, movingRect.bottom],
    centerIndex: 1,
    canvasLines: [0.0, canvasSize.height / 2, canvasSize.height],
    targetLines: [
      for (final t in targets) ...[t.top, t.center.dy, t.bottom],
    ],
    threshold: threshold,
    axis: Axis.horizontal,
  );

  final guides = <SnapGuide>[
    if (xSnap != null) xSnap.guide,
    if (ySnap != null) ySnap.guide,
  ];

  return SnapResult(
    offset: Offset(
      rawOffset.dx + (xSnap?.correction ?? 0),
      rawOffset.dy + (ySnap?.correction ?? 0),
    ),
    guides: guides,
  );
}

_AxisSnap? _bestAxisSnap({
  required List<double> anchors,
  required int centerIndex,
  required List<double> canvasLines,
  required List<double> targetLines,
  required double threshold,
  required Axis axis,
}) {
  final candidates = <_SnapCandidate>[];

  for (var i = 0; i < anchors.length; i++) {
    final anchor = anchors[i];
    final isCenter = i == centerIndex;

    for (var c = 0; c < canvasLines.length; c++) {
      final line = canvasLines[c];
      final delta = line - anchor;
      if (delta.abs() > threshold) continue;
      candidates.add(
        _SnapCandidate(
          line: line,
          anchor: anchor,
          kind: SnapGuideKind.canvas,
          isCenterToCenter: isCenter && c == 1,
        ),
      );
    }

    for (var t = 0; t < targetLines.length; t++) {
      final line = targetLines[t];
      final delta = line - anchor;
      if (delta.abs() > threshold) continue;
      // Target lines are packed as left/center/right (or top/center/bottom)
      // in groups of 3.
      final targetIsCenter = t % 3 == 1;
      candidates.add(
        _SnapCandidate(
          line: line,
          anchor: anchor,
          kind: SnapGuideKind.element,
          isCenterToCenter: isCenter && targetIsCenter,
        ),
      );
    }
  }

  if (candidates.isEmpty) return null;

  candidates.sort((a, b) {
    final scoreCmp = a.score.compareTo(b.score);
    if (scoreCmp != 0) return scoreCmp;
    // Prefer canvas guides on equal score.
    if (a.kind != b.kind) {
      return a.kind == SnapGuideKind.canvas ? -1 : 1;
    }
    return 0;
  });

  final best = candidates.first;
  return _AxisSnap(
    correction: best.delta,
    guide: SnapGuide(
      axis: axis,
      position: best.line,
      kind: best.kind,
    ),
  );
}
