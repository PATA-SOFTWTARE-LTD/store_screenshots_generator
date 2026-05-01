// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Cattura il Widget radice attualmente processato in formato PNG.
/// [locale] e [deviceId] determinano il percorso dove verrà salvato l'output.
Future<void> captureRawScreenshot(
  WidgetTester tester, {
  required String screenshotId,
  required String locale,
  required String deviceId,
  String basePath = 'raw_screenshots',
  Key? boundaryKey,
}) async {
  print('Capturing screenshot: $screenshotId...');

  // Pumping fully settled UI
  // Assicuriamoci che la UI sia pronta
  await tester.pump(const Duration(milliseconds: 500));
  print('UI settled.');

  RenderRepaintBoundary? boundary;
  if (boundaryKey != null) {
    final elements = find.byKey(boundaryKey).evaluate();
    if (elements.isNotEmpty) {
      boundary = elements.first.renderObject as RenderRepaintBoundary?;
    }
  } else {
    // Cerchiamo il primo RenderRepaintBoundary disponibile
    boundary = tester.allRenderObjects
        .whereType<RenderRepaintBoundary>()
        .firstOrNull;
  }

  if (boundary == null) {
    throw Exception(
      'No RenderRepaintBoundary found in the widget tree${boundaryKey != null ? ' with key $boundaryKey.' : '.'} Please wrap your widget in a RepaintBoundary.',
    );
  }

  // Generazione dell'immagine
  print('Generating image via runAsync...');

  await tester.runAsync(() async {
    final ui.Image image = await boundary!.toImage(
      pixelRatio: tester.view.devicePixelRatio,
    );

    print('Converting image to PNG...');
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    if (byteData == null) {
      print('FAILED: byteData is null');
      return;
    }

    print('Image converted to PNG.');
    final bytes = byteData.buffer.asUint8List(
      byteData.offsetInBytes,
      byteData.lengthInBytes,
    );

    // Scriviamo su disco
    final dir = Directory('$basePath/$locale/$deviceId');
    if (!dir.existsSync()) {
      print('Creating directory: ${dir.path}');
      dir.createSync(recursive: true);
    }

    final file = File('${dir.path}/$screenshotId.png');
    print('Writing file: ${file.path} (${bytes.length} bytes)...');
    await file.writeAsBytes(bytes);
  });

  print('Saved raw screenshot: $basePath/$locale/$deviceId/$screenshotId.png');
}
