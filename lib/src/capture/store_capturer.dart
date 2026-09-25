import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../layouts/device_catalog.dart';

/// Captures a store promo screenshot to
/// `store_screenshots/{locale}/{FastlaneDevice}/{NN}_{slotId}.png`.
Future<void> captureStoreScreenshot(
  WidgetTester tester, {
  required String slotId,
  required String locale,
  required String deviceId,
  required int orderIndex,
  String basePath = 'store_screenshots',
  Key? boundaryKey,
}) async {
  await tester.pump(const Duration(milliseconds: 500));

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
      'No RenderRepaintBoundary found'
      '${boundaryKey != null ? ' with key $boundaryKey' : ''}.',
    );
  }

  final fastlaneName = DeviceCatalog.fastlaneNameFor(deviceId);
  final orderLabel = (orderIndex + 1).toString().padLeft(2, '0');
  final fileName = '${orderLabel}_$slotId.png';

  await tester.runAsync(() async {
    final ui.Image image = await boundary!.toImage(
      pixelRatio: tester.view.devicePixelRatio,
    );

    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    if (byteData == null) return;

    final bytes = byteData.buffer.asUint8List(
      byteData.offsetInBytes,
      byteData.lengthInBytes,
    );

    final dir = Directory('$basePath/$locale/$fastlaneName');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final file = File('${dir.path}/$fileName');
    file.writeAsBytesSync(bytes);
  });
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}
