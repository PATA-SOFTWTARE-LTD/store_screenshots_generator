import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Captures the current widget tree as a PNG under
/// `[basePath]/[locale]/[deviceId]/[screenshotId].png`.
///
/// Set [verbose] to log progress while writing the file.
Future<void> captureRawScreenshot(
  WidgetTester tester, {
  required String screenshotId,
  required String locale,
  required String deviceId,
  String basePath = 'raw_screenshots',
  Key? boundaryKey,
  bool verbose = false,
}) async {
  void log(String message) {
    if (verbose) {
      // ignore: avoid_print
      print(message);
    }
  }

  log('Capturing screenshot: $screenshotId...');
  await tester.pump(const Duration(milliseconds: 500));
  log('UI settled.');

  RenderRepaintBoundary? boundary;
  if (boundaryKey != null) {
    final elements = find.byKey(boundaryKey).evaluate();
    if (elements.isNotEmpty) {
      boundary = elements.first.renderObject as RenderRepaintBoundary?;
    }
  } else {
    boundary = tester.allRenderObjects
        .whereType<RenderRepaintBoundary>()
        .firstOrNull;
  }

  if (boundary == null) {
    throw Exception(
      'No RenderRepaintBoundary found in the widget tree'
      '${boundaryKey != null ? ' with key $boundaryKey' : ''}.'
      ' Please wrap your widget in a RepaintBoundary.',
    );
  }

  log('Generating image via runAsync...');

  await tester.runAsync(() async {
    final ui.Image image = await boundary!.toImage(
      pixelRatio: tester.view.devicePixelRatio,
    );

    log('Converting image to PNG...');
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    if (byteData == null) {
      throw StateError('Failed to encode screenshot PNG (byteData is null).');
    }

    final bytes = byteData.buffer.asUint8List(
      byteData.offsetInBytes,
      byteData.lengthInBytes,
    );

    final dir = Directory('$basePath/$locale/$deviceId');
    if (!dir.existsSync()) {
      log('Creating directory: ${dir.path}');
      dir.createSync(recursive: true);
    }

    final file = File('${dir.path}/$screenshotId.png');
    log('Writing file: ${file.path} (${bytes.length} bytes)...');
    await file.writeAsBytes(bytes);
  });

  log('Saved raw screenshot: $basePath/$locale/$deviceId/$screenshotId.png');
}
