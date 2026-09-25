import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_screenshots_generator/store_screenshots_generator.dart';

void main() {
  testWidgets('non-interactive artboard renders inside StoreScreenshotCanvas',
      (tester) async {
    final device = DeviceCatalog.getById('iphone_15_pro');
    const boundaryKey = ValueKey('export-boundary');

    final composition = CompositionPresets.build(
      presetId: 'minimal',
      locales: const ['en-US'],
      slotName: 'Insights',
    );

    await tester.binding.setSurfaceSize(device.resolution);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: StoreScreenshotCanvas(
          device: device,
          boundaryKey: boundaryKey,
          child: CompositionArtboard(
            composition: composition,
            width: device.resolution.width,
            height: device.resolution.height,
            interactive: false,
            renderContext: ArtboardRenderContext(
              hostRootPath: Directory.systemTemp.path,
              rawScreenshotsPath: 'raw_screenshots',
              locale: 'en-US',
              deviceId: device.id,
              slotId: 'insights',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Insights'), findsOneWidget);

    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(boundaryKey),
    );
    late Uint8List pngBytes;
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 1);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      pngBytes = data!.buffer.asUint8List();
    });
    expect(pngBytes.length, greaterThan(100));
  });

  test('CompositionExportCore writes PNGs via capture callback', () async {
    final temp = Directory.systemTemp.createTempSync('ssg_export_core_');
    addTearDown(() {
      if (temp.existsSync()) temp.deleteSync(recursive: true);
    });

    final project = StudioProject(
      name: 'export_core',
      deviceIds: const ['iphone_15_pro'],
      locales: const ['en-US'],
      slots: const [
        StoreSlot(
          id: 'home',
          name: 'Home',
          presetId: 'minimal',
          rawCaptureId: 'home',
        ),
      ],
      rawScreenshotsPath: 'raw_screenshots',
      compositions: {
        '*|*|home': CompositionPresets.build(
          presetId: 'minimal',
          locales: const ['en-US'],
          slotName: 'Home',
        ),
      },
    );

    final result = await CompositionExportCore.exportAll(
      project: project,
      hostRootPath: temp.path,
      syncIo: true,
      capture: ({
        required project,
        required composition,
        required device,
        required renderContext,
      }) async {
        // Minimal valid 1x1 PNG
        return Uint8List.fromList([
          0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00,
          0x0D, 0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00,
          0x00, 0x01, 0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53, 0xDE,
          0x00, 0x00, 0x00, 0x0C, 0x49, 0x44, 0x41, 0x54, 0x08, 0xD7, 0x63,
          0xF8, 0xCF, 0xC0, 0x00, 0x00, 0x00, 0x03, 0x00, 0x01, 0x00, 0x05,
          0xFE, 0xD4, 0xEF, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44,
          0xAE, 0x42, 0x60, 0x82,
        ]);
      },
    );

    expect(result.exportedCount, 1);
    expect(result.paths, hasLength(1));
    expect(File(result.paths.first).existsSync(), isTrue);
  });
}
