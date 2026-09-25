import 'models/composition.dart';
import 'models/element_frame.dart';
import 'models/element_type.dart';
import 'models/scene_element.dart';
import 'models/store_slot.dart';
import 'models/studio_project.dart';

/// Parses generated composition Dart (emitter format only).
class CompositionDartParser {
  Map<String, Composition> parseCompositions(String source) {
    final result = <String, Composition>{};
    final keyPattern = RegExp(
      r"'([^']+)':\s*Composition\(\s*elements:\s*\[(.*?)\],\s*\)",
      dotAll: true,
    );

    for (final match in keyPattern.allMatches(source)) {
      final key = match.group(1)!;
      final elementsBlock = match.group(2)!;
      result[key] = Composition(elements: _parseElements(elementsBlock));
    }

    return result;
  }

  StudioProject parseProject(
    String projectSource,
    Map<String, Composition> compositions,
  ) {
    final name = _extractString(projectSource, 'name') ?? 'project';
    final rawPath =
        _extractString(projectSource, 'rawScreenshotsPath') ?? 'raw_screenshots';
    final deviceIds = _extractStringList(projectSource, 'deviceIds');
    final locales = _extractStringList(projectSource, 'locales');
    final slots = _extractSlots(projectSource);

    return StudioProject(
      name: name,
      deviceIds: deviceIds,
      locales: locales,
      slots: slots,
      compositions: compositions,
      rawScreenshotsPath: rawPath,
    );
  }

  List<SceneElement> _parseElements(String block) {
    final elements = <SceneElement>[];
    final headerPattern = RegExp(
      r"SceneElement\(\s*id:\s*'([^']+)',\s*type:\s*ElementType\.(\w+),\s*frame:\s*ElementFrame\(\s*x:\s*([\d.]+),\s*y:\s*([\d.]+),\s*width:\s*([\d.]+),\s*height:\s*([\d.]+),\s*rotation:\s*([\d.]+),\s*\),\s*properties:\s*",
      dotAll: true,
    );

    for (final match in headerPattern.allMatches(block)) {
      final propsLiteral = _readPropertiesLiteral(block, match.end);
      if (propsLiteral == null) continue;

      elements.add(
        SceneElement(
          id: match.group(1)!,
          type: ElementType.values.byName(match.group(2)!),
          frame: ElementFrame(
            x: double.parse(match.group(3)!),
            y: double.parse(match.group(4)!),
            width: double.parse(match.group(5)!),
            height: double.parse(match.group(6)!),
            rotation: double.parse(match.group(7)!),
          ),
          properties: _parseProperties(propsLiteral),
        ),
      );
    }

    return elements;
  }

  String? _readPropertiesLiteral(String block, int start) {
    final rest = block.substring(start).trimLeft();
    if (rest.startsWith('const {}')) return 'const {}';

    final offset = block.length - rest.length;
    if (offset >= block.length || block[offset] != '{') return null;

    var depth = 0;
    for (var i = offset; i < block.length; i++) {
      final char = block[i];
      if (char == '{') depth++;
      if (char == '}') {
        depth--;
        if (depth == 0) return block.substring(offset, i + 1);
      }
    }
    return null;
  }

  Map<String, dynamic> _parseProperties(String literal) {
    if (literal.contains('const {}')) return {};
    final result = <String, dynamic>{};
    final textMap = RegExp(r"'text':\s*\{([^}]*)\}").firstMatch(literal);
    if (textMap != null) {
      final map = <String, String>{};
      final entry = RegExp(r"'([^']+)':\s*'([^']*)'");
      for (final m in entry.allMatches(textMap.group(1)!)) {
        map[m.group(1)!] = m.group(2)!;
      }
      result['text'] = map;
    }

    for (final key in [
      'color',
      'solidColor',
      'fontSize',
      'fontWeight',
      'textAlign',
      'fontFamily',
      'verticalAlign',
      'overflow',
      'lineHeight',
      'letterSpacing',
      'opacity',
      'shadowColor',
      'shadowBlur',
      'shadowOffsetX',
      'shadowOffsetY',
      'gradientAngle',
      'gradientCenterX',
      'gradientCenterY',
      'gradientRadius',
    ]) {
      final m = RegExp("'$key':\\s*'?([^',}\\]]+)'?").firstMatch(literal);
      if (m == null) continue;
      final raw = m.group(1)!;
      if (key == 'fontSize' ||
          key == 'lineHeight' ||
          key == 'letterSpacing' ||
          key == 'opacity' ||
          key == 'shadowBlur' ||
          key == 'shadowOffsetX' ||
          key == 'shadowOffsetY' ||
          key == 'gradientAngle' ||
          key == 'gradientCenterX' ||
          key == 'gradientCenterY' ||
          key == 'gradientRadius') {
        result[key] = double.tryParse(raw) ?? raw;
      } else if (key == 'color' ||
          key == 'solidColor' ||
          key == 'shadowColor') {
        result[key] = int.tryParse(raw) ?? raw;
      } else {
        result[key] = raw.replaceAll("'", '');
      }
    }

    final maxLines = RegExp(r"'maxLines':\s*(\d+)").firstMatch(literal);
    if (maxLines != null) {
      result['maxLines'] = int.parse(maxLines.group(1)!);
    }
    final assetRevision =
        RegExp(r"'assetRevision':\s*(\d+)").firstMatch(literal);
    if (assetRevision != null) {
      result['assetRevision'] = int.parse(assetRevision.group(1)!);
    }

    final fillKind = RegExp(r"'fillKind':\s*'([^']+)'").firstMatch(literal);
    if (fillKind != null) {
      result['fillKind'] = fillKind.group(1);
    }

    final stopColors = _parseIntList(literal, 'gradientStopColors');
    if (stopColors != null) {
      result['gradientStopColors'] = stopColors;
    }
    final stopPositions = _parseDoubleList(literal, 'gradientStops');
    if (stopPositions != null) {
      result['gradientStops'] = stopPositions;
    }

    final showBezel = RegExp(r"'showBezel':\s*(true|false)").firstMatch(literal);
    if (showBezel != null) {
      result['showBezel'] = showBezel.group(1) == 'true';
    }
    final showFrame = RegExp(r"'showFrame':\s*(true|false)").firstMatch(literal);
    if (showFrame != null) {
      result['showFrame'] = showFrame.group(1) == 'true';
    }
    for (final key in ['italic', 'underline', 'strikethrough']) {
      final m = RegExp("'$key':\\s*(true|false)").firstMatch(literal);
      if (m != null) {
        result[key] = m.group(1) == 'true';
      }
    }
    final captureId =
        RegExp(r"'captureId':\s*'([^']*)'").firstMatch(literal);
    if (captureId != null) {
      result['captureId'] = captureId.group(1);
    }
    final assetPath =
        RegExp(r"'assetPath':\s*'([^']*)'").firstMatch(literal);
    if (assetPath != null) {
      result['assetPath'] = assetPath.group(1);
    }

    return result;
  }

  List<int>? _parseIntList(String literal, String key) {
    final block =
        RegExp("'$key':\\s*\\[([^\\]]*)\\]").firstMatch(literal)?.group(1);
    if (block == null) return null;
    final values = <int>[];
    for (final raw in block.split(',')) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) continue;
      final parsed = int.tryParse(trimmed);
      if (parsed != null) values.add(parsed);
    }
    return values.isEmpty ? null : values;
  }

  List<double>? _parseDoubleList(String literal, String key) {
    final block =
        RegExp("'$key':\\s*\\[([^\\]]*)\\]").firstMatch(literal)?.group(1);
    if (block == null) return null;
    final values = <double>[];
    for (final raw in block.split(',')) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) continue;
      final parsed = double.tryParse(trimmed);
      if (parsed != null) values.add(parsed);
    }
    return values.isEmpty ? null : values;
  }

  String? _extractString(String source, String field) {
    return RegExp("$field:\\s*'([^']*)'").firstMatch(source)?.group(1);
  }

  List<String> _extractStringList(String source, String field) {
    final block =
        RegExp('$field:\\s*\\[([^\\]]*)\\]').firstMatch(source)?.group(1);
    if (block == null) return [];
    return RegExp(r"'([^']*)'")
        .allMatches(block)
        .map((m) => m.group(1)!)
        .toList();
  }

  List<StoreSlot> _extractSlots(String source) {
    final slots = <StoreSlot>[];

    final storeSlotPattern = RegExp(
      r"StoreSlot\(id:\s*'([^']*)',\s*name:\s*'([^']*)'"
      r"(?:,\s*presetId:\s*'([^']*)')?"
      r"(?:,\s*rawCaptureId:\s*'([^']*)')?\s*\)",
    );
    for (final match in storeSlotPattern.allMatches(source)) {
      slots.add(
        StoreSlot(
          id: match.group(1)!,
          name: match.group(2)!,
          presetId: match.group(3),
          rawCaptureId: match.group(4),
        ),
      );
    }
    return slots;
  }
}
