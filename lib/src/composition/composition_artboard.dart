import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/models/device_spec.dart';
import '../layouts/raw_path_resolver.dart';
import '../layouts/store_screenshot_context.dart';
import '../registry/device_frame_layout.dart';
import 'background_fill.dart';
import 'composition_asset_paths.dart';
import 'models/composition.dart';
import 'composition_capture.dart';
import 'models/element_type.dart';
import 'models/element_frame.dart';
import 'models/scene_element.dart';
import 'snap_geometry.dart';
import 'text_style_properties.dart';

/// Context required to render raw screenshots and device frames.
class ArtboardRenderContext {
  final String hostRootPath;
  final String rawScreenshotsPath;
  final String locale;
  final String deviceId;
  final String slotId;
  final String? rawCaptureId;
  final Map<String, Uint8List>? fileImageCache;

  const ArtboardRenderContext({
    required this.hostRootPath,
    required this.rawScreenshotsPath,
    required this.locale,
    required this.deviceId,
    required this.slotId,
    this.rawCaptureId,
    this.fileImageCache,
  });

  factory ArtboardRenderContext.fromStoreContext(
    StoreScreenshotContext ctx,
  ) {
    return ArtboardRenderContext(
      hostRootPath: ctx.hostRootPath,
      rawScreenshotsPath: ctx.rawScreenshotsPath,
      locale: ctx.locale,
      deviceId: ctx.deviceId,
      slotId: ctx.slotId,
      rawCaptureId: ctx.rawCaptureId,
      fileImageCache: ctx.fileImageCache,
    );
  }
}

/// Renders a [Composition] at device resolution with optional interaction.
class CompositionArtboard extends StatefulWidget {
  final double width;
  final double height;
  final Composition composition;
  final ArtboardRenderContext? renderContext;
  final String? selectedElementId;
  final bool interactive;
  final bool snapEnabled;
  final double? snapThreshold;
  final void Function(String? id)? onSelectElement;
  final void Function(String id)? onDragStart;
  final void Function(String id, double dx, double dy)? onDragEnd;
  final VoidCallback? onDragCancel;
  final VoidCallback? onClearSelection;
  final void Function(String id)? onPointerDownElement;
  final VoidCallback? onPointerUpElement;

  const CompositionArtboard({
    super.key,
    required this.width,
    required this.height,
    required this.composition,
    this.renderContext,
    this.selectedElementId,
    this.interactive = false,
    this.snapEnabled = true,
    this.snapThreshold,
    this.onSelectElement,
    this.onDragStart,
    this.onDragEnd,
    this.onDragCancel,
    this.onClearSelection,
    this.onPointerDownElement,
    this.onPointerUpElement,
  });

  @override
  State<CompositionArtboard> createState() => _CompositionArtboardState();
}

class _CompositionArtboardState extends State<CompositionArtboard> {
  String? _activeElementId;
  Composition? _dragBaseComposition;
  Offset _rawDragOffset = Offset.zero;
  Offset _effectiveDragOffset = Offset.zero;
  List<SnapGuide> _activeGuides = const [];

  Size get _canvasSize => Size(widget.width, widget.height);

  double get _threshold =>
      widget.snapThreshold ?? defaultSnapThreshold(_canvasSize);

  @override
  void didUpdateWidget(CompositionArtboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedElementId != widget.selectedElementId &&
        _activeElementId == null) {
      _rawDragOffset = Offset.zero;
      _effectiveDragOffset = Offset.zero;
      _activeGuides = const [];
      _dragBaseComposition = null;
    }
  }

  void _resetDragState() {
    _activeElementId = null;
    _dragBaseComposition = null;
    _rawDragOffset = Offset.zero;
    _effectiveDragOffset = Offset.zero;
    _activeGuides = const [];
  }

  void _startDrag(String id) {
    setState(() {
      _activeElementId = id;
      _dragBaseComposition = widget.composition;
      _rawDragOffset = Offset.zero;
      _effectiveDragOffset = Offset.zero;
      _activeGuides = const [];
    });
    widget.onDragStart?.call(id);
  }

  void _updateDrag(DragUpdateDetails details) {
    if (_activeElementId == null || _dragBaseComposition == null) return;

    final raw = _rawDragOffset + details.delta;
    final bypass = !widget.snapEnabled ||
        HardwareKeyboard.instance.isAltPressed;

    Offset effective;
    List<SnapGuide> guides;

    if (bypass) {
      effective = raw;
      guides = const [];
    } else {
      final base = _dragBaseComposition!.elements
          .where((e) => e.id == _activeElementId)
          .firstOrNull;
      final frame = base?.frame;
      if (frame == null) {
        effective = raw;
        guides = const [];
      } else {
        final moving = Rect.fromLTWH(
          frame.x + raw.dx,
          frame.y + raw.dy,
          frame.width,
          frame.height,
        );
        final targets = [
          for (final e in _dragBaseComposition!.elements)
            if (e.id != _activeElementId &&
                e.type != ElementType.solidBackground)
              Rect.fromLTWH(
                e.frame.x,
                e.frame.y,
                e.frame.width,
                e.frame.height,
              ),
        ];
        final result = resolveSnap(
          movingRect: moving,
          rawOffset: raw,
          targets: targets,
          canvasSize: _canvasSize,
          threshold: _threshold,
        );
        effective = result.offset;
        guides = result.guides;
      }
    }

    setState(() {
      _rawDragOffset = raw;
      _effectiveDragOffset = effective;
      _activeGuides = guides;
    });
  }

  void _endDrag(String id) {
    widget.onDragEnd?.call(
      id,
      _effectiveDragOffset.dx,
      _effectiveDragOffset.dy,
    );
    setState(_resetDragState);
  }

  void _cancelDrag() {
    setState(_resetDragState);
    widget.onDragCancel?.call();
  }

  ElementFrame _displayFrame(SceneElement element) {
    if (_activeElementId != element.id || _dragBaseComposition == null) {
      return element.frame;
    }

    final base = _dragBaseComposition!.elements
        .where((e) => e.id == element.id)
        .firstOrNull;
    final frame = base?.frame ?? element.frame;

    return frame.copyWith(
      x: frame.x + _effectiveDragOffset.dx,
      y: frame.y + _effectiveDragOffset.dy,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strokeWidth =
        math.max(widget.width, widget.height) * 0.0025;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (widget.interactive)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => widget.onClearSelection?.call(),
              ),
            ),
          for (final element in widget.composition.elements)
            _ElementLayer(
              element: element,
              displayFrame: _displayFrame(element),
              renderContext: widget.renderContext,
              highlighted: widget.selectedElementId == element.id ||
                  _activeElementId == element.id,
              interactive: widget.interactive,
              isActive: _activeElementId == element.id,
              onSelect: () => widget.onSelectElement?.call(element.id),
              onDragStart: () => _startDrag(element.id),
              onDragUpdate: (details) {
                if (_activeElementId != element.id) {
                  _startDrag(element.id);
                }
                _updateDrag(details);
              },
              onDragEnd: () => _endDrag(element.id),
              onDragCancel: _cancelDrag,
              onPointerDown: () =>
                  widget.onPointerDownElement?.call(element.id),
              onPointerUp: () => widget.onPointerUpElement?.call(),
            ),
          if (widget.interactive && _activeGuides.isNotEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _SnapGuidePainter(
                    guides: _activeGuides,
                    canvasColor: theme.colorScheme.tertiary,
                    elementColor: theme.colorScheme.primary,
                    strokeWidth: strokeWidth,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SnapGuidePainter extends CustomPainter {
  final List<SnapGuide> guides;
  final Color canvasColor;
  final Color elementColor;
  final double strokeWidth;

  const _SnapGuidePainter({
    required this.guides,
    required this.canvasColor,
    required this.elementColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final guide in guides) {
      final paint = Paint()
        ..color = guide.kind == SnapGuideKind.canvas
            ? canvasColor
            : elementColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke;

      if (guide.axis == Axis.vertical) {
        canvas.drawLine(
          Offset(guide.position, 0),
          Offset(guide.position, size.height),
          paint,
        );
      } else {
        canvas.drawLine(
          Offset(0, guide.position),
          Offset(size.width, guide.position),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SnapGuidePainter oldDelegate) {
    return oldDelegate.guides != guides ||
        oldDelegate.canvasColor != canvasColor ||
        oldDelegate.elementColor != elementColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class _ElementLayer extends StatelessWidget {
  final SceneElement element;
  final ElementFrame displayFrame;
  final ArtboardRenderContext? renderContext;
  final bool highlighted;
  final bool interactive;
  final bool isActive;
  final VoidCallback onSelect;
  final VoidCallback onDragStart;
  final void Function(DragUpdateDetails details) onDragUpdate;
  final VoidCallback onDragEnd;
  final VoidCallback onDragCancel;
  final VoidCallback onPointerDown;
  final VoidCallback onPointerUp;

  const _ElementLayer({
    required this.element,
    required this.displayFrame,
    required this.renderContext,
    required this.highlighted,
    required this.interactive,
    required this.isActive,
    required this.onSelect,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDragCancel,
    required this.onPointerDown,
    required this.onPointerUp,
  });

  bool get _isDraggable =>
      interactive && element.type != ElementType.solidBackground;

  @override
  Widget build(BuildContext context) {
    final intrinsic = _contentIntrinsicSize();

    Widget layer = SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.center,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: interactive && highlighted
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 3,
                  )
                : null,
          ),
          child: SizedBox(
            width: intrinsic.width,
            height: intrinsic.height,
            child: _buildContent(context),
          ),
        ),
      ),
    );

    if (displayFrame.rotation != 0) {
      layer = Transform.rotate(
        angle: displayFrame.rotation * math.pi / 180,
        alignment: Alignment.center,
        child: layer,
      );
    }

    return Positioned(
      left: displayFrame.x,
      top: displayFrame.y,
      width: displayFrame.width,
      height: displayFrame.height,
      child: Listener(
        onPointerDown: interactive ? (_) => onPointerDown() : null,
        onPointerUp: interactive ? (_) => onPointerUp() : null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: _isDraggable ? (_) => onDragStart() : null,
          onPanUpdate: _isDraggable ? onDragUpdate : null,
          onPanEnd: _isDraggable ? (_) => onDragEnd() : null,
          onPanCancel: _isDraggable ? onDragCancel : null,
          child: layer,
        ),
      ),
    );
  }

  Size _contentIntrinsicSize() {
    final usesDeviceFrame = element.type == ElementType.deviceFrame ||
        (element.type == ElementType.rawScreenshot &&
            element.properties['showFrame'] == true);

    if (!usesDeviceFrame || renderContext == null) {
      return Size(displayFrame.width, displayFrame.height);
    }

    final device = DeviceRegistry.getById(renderContext!.deviceId);
    if (element.properties['showBezel'] == false) {
      return device.resolution;
    }
    return deviceFrameTotalSize(device);
  }

  Widget _buildContent(BuildContext context) {
    return switch (element.type) {
      ElementType.solidBackground => _buildBackground(),
      ElementType.text => _buildText(),
      ElementType.rawScreenshot => _buildRawScreenshot(),
      ElementType.deviceFrame => _buildDeviceFrame(),
      ElementType.image => _buildImage(),
    };
  }

  Widget _buildBackground() {
    return DecoratedBox(
      decoration: BackgroundFill.fromProperties(element.properties).toBoxDecoration(),
    );
  }

  Widget _buildText() {
    final locale = renderContext?.locale ?? 'en-US';
    final textMap = element.properties['text'];
    String text = 'Title';
    if (textMap is Map) {
      text = (textMap[locale] ?? textMap.values.firstOrNull)?.toString() ??
          'Title';
    } else if (textMap is String) {
      text = textMap;
    }

    final props = element.properties;
    final align = parseTextAlign(props['textAlign'] as String?);
    final verticalAlign =
        parseVerticalAlign(props['verticalAlign'] as String?);
    final maxLines = maxLinesFromProperties(props);
    final overflow =
        parseTextOverflow(props['overflow'] as String?);

    return Align(
      alignment: verticalAlign,
      child: SizedBox(
        width: double.infinity,
        child: Text(
          text,
          textAlign: align,
          softWrap: true,
          maxLines: maxLines,
          overflow: overflow,
          style: textStyleFromProperties(props, fallbackColor: Colors.white),
        ),
      ),
    );
  }

  Widget _imageFromPath(String path, {Object? imageKey}) {
    final cached = renderContext?.fileImageCache?[path];
    if (cached != null) {
      return Image.memory(
        cached,
        key: imageKey != null ? ValueKey(imageKey) : null,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        gaplessPlayback: true,
      );
    }
    if (File(path).existsSync()) {
      return Image.file(
        File(path),
        key: imageKey != null ? ValueKey(imageKey) : null,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        gaplessPlayback: true,
      );
    }
    return _missingRawPlaceholder(path: path);
  }

  Widget _buildRawScreenshot() {
    final ctx = renderContext;
    if (ctx == null) return _missingRawPlaceholder();

    final captureId = captureIdForElement(
      element,
      slotFallback: ctx.rawCaptureId,
    );
    if (captureId == null) return _missingRawPlaceholder();

    final path = RawPathResolver.rawScreenshotPath(
      hostRootPath: ctx.hostRootPath,
      rawScreenshotsPath: ctx.rawScreenshotsPath,
      locale: ctx.locale,
      deviceId: ctx.deviceId,
      captureId: captureId,
    );

    if (!File(path).existsSync() && ctx.fileImageCache?[path] == null) {
      return _missingRawPlaceholder(path: path);
    }

    final inner = SizedBox.expand(child: _imageFromPath(path));
    return _wrapScreenshotContent(ctx, inner);
  }

  Widget _wrapScreenshotContent(ArtboardRenderContext ctx, Widget inner) {
    final showFrame = element.type == ElementType.deviceFrame ||
        element.properties['showFrame'] == true;
    if (!showFrame) {
      return SizedBox.expand(child: inner);
    }

    final device = DeviceRegistry.getById(ctx.deviceId);
    final showBezel = element.properties['showBezel'] != false;

    if (!showBezel) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(device.cornerRadius),
        child: SizedBox.expand(child: inner),
      );
    }

    return buildDeviceFrameStack(device, inner);
  }

  Widget _buildDeviceFrame() {
    final ctx = renderContext;
    if (ctx == null) return _placeholderBox('deviceFrame');

    final captureId = captureIdForElement(
      element,
      slotFallback: ctx.rawCaptureId,
    );
    if (captureId == null) return _placeholderBox('deviceFrame');

    final path = RawPathResolver.rawScreenshotPath(
      hostRootPath: ctx.hostRootPath,
      rawScreenshotsPath: ctx.rawScreenshotsPath,
      locale: ctx.locale,
      deviceId: ctx.deviceId,
      captureId: captureId,
    );

    final inner = SizedBox.expand(
      child: (!File(path).existsSync() &&
              ctx.fileImageCache?[path] == null)
          ? _missingRawPlaceholder(path: path)
          : _imageFromPath(path),
    );

    return _wrapScreenshotContent(ctx, inner);
  }

  Widget _buildImage() {
    final assetPath = element.properties['assetPath'] as String?;
    final hostRoot = renderContext?.hostRootPath;
    if (assetPath == null || hostRoot == null) {
      return _placeholderBox('image');
    }

    final fullPath = CompositionAssetPaths.resolveImagePath(
      hostRootPath: hostRoot,
      assetPath: assetPath,
    );

    final file = File(fullPath);
    if (!file.existsSync()) {
      return _missingRawPlaceholder(path: fullPath);
    }

    // Read bytes each build so replaced files on disk always show up.
    // Image.file would keep stale decoded pixels for the same path.
    final revision = element.properties['assetRevision'] ?? 0;
    final bytes = file.readAsBytesSync();
    return SizedBox.expand(
      child: Image.memory(
        bytes,
        key: ValueKey('$fullPath#$revision'),
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        gaplessPlayback: true,
      ),
    );
  }

  Widget _missingRawPlaceholder({String? path}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        border: Border.all(color: Colors.black26),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            path == null
                ? 'No raw'
                : 'Missing raw\n${path.split(Platform.pathSeparator).last}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, fontSize: 10),
          ),
        ),
      ),
    );
  }

  Widget _placeholderBox(String label) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey.shade700,
        border: Border.all(color: Colors.white24),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}
