import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../composition/composition_artboard.dart';
import '../composition/composition_capture.dart';
import '../composition/composition_lookup.dart';
import '../composition/models/studio_project.dart';
import '../config/models/device_spec.dart';
import '../layouts/layout_widgets.dart';
import '../layouts/store_screenshot_context.dart';
import 'store_capturer.dart';
import 'test_font_loader.dart';

/// Registers the headless store export integration test used by
/// [export_store_screenshots] (`flutter test` + `DEVICE` / `LOCALE` defines).
void runStoreScreenshotExportTests({
  required StudioProject Function() loadProject,
  String configFileName = 'screenshots.yaml',
}) {
  setUpAll(_setupStoreScreenshotExportFonts);

  testWidgets('Export store screenshots from generated compositions', (
    WidgetTester tester,
  ) async {
    addTearDown(() => debugDisableShadows = true);

    const deviceId = String.fromEnvironment(
      'DEVICE',
      defaultValue: 'iphone_15_pro',
    );
    const locale = String.fromEnvironment('LOCALE', defaultValue: 'en-US');

    final hostRoot = Directory.current.path;
    final configFile = File(configFileName);
    if (!configFile.existsSync()) {
      fail('$configFileName not found in $hostRoot');
    }

    await _exportStoreScreenshotsForDeviceLocale(
      tester: tester,
      loadProject: loadProject,
      hostRoot: hostRoot,
      deviceId: deviceId,
      locale: locale,
    );

    await tester.binding.setSurfaceSize(null);
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    debugDisableShadows = true;
  });
}

/// Loads fonts used by promo layouts during `flutter test` export.
Future<void> _setupStoreScreenshotExportFonts() async {
  debugDisableShadows = false;
  await loadScreenshotTestFonts();

  final materialIconPath =
      '${Platform.environment['FLUTTER_ROOT'] ?? ''}'
      '/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf';
  if (File(materialIconPath).existsSync()) {
    final iconData = File(materialIconPath).readAsBytesSync();
    final loader = FontLoader('MaterialIcons');
    loader.addFont(Future.value(iconData.buffer.asByteData()));
    await loader.load();
  }
}

Future<void> _exportStoreScreenshotsForDeviceLocale({
  required WidgetTester tester,
  required StudioProject Function() loadProject,
  required String hostRoot,
  required String deviceId,
  required String locale,
}) async {
  final project = loadProject();
  final device = DeviceRegistry.getById(deviceId);
  final resolution = device.resolution;
  final pixelRatio = device.pixelRatio;

  final logicalSize = Size(
    resolution.width / pixelRatio,
    resolution.height / pixelRatio,
  );

  await tester.binding.setSurfaceSize(logicalSize);
  tester.view.physicalSize = resolution;
  tester.view.devicePixelRatio = pixelRatio;

  final captureIds = project.configuredRawCaptureIds().toSet();
  final imageCache = LayoutWidgets.preloadRawImages(
    hostRootPath: hostRoot,
    rawScreenshotsPath: project.rawScreenshotsPath,
    locale: locale,
    deviceId: deviceId,
    captureIds: captureIds,
  );

  for (var i = 0; i < project.slots.length; i++) {
    final slot = project.slots[i];
    if (!slotIsExportable(project, slot)) continue;
    final slotId = slot.id;

    // ignore: avoid_print
    print('Exporting $slotId ($deviceId, $locale)...');

    final composition = lookupComposition(
      project: project,
      locale: locale,
      deviceId: deviceId,
      slotId: slotId,
    );

    final boundaryKey = GlobalKey();
    final renderContext = StoreScreenshotContext(
      locale: locale,
      deviceId: deviceId,
      slotId: slotId,
      rawCaptureId: fallbackCaptureId(slot, composition.elements),
      hostRootPath: hostRoot,
      rawScreenshotsPath: project.rawScreenshotsPath,
      fileImageCache: imageCache,
    );

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: StoreScreenshotCanvas(
          device: device,
          boundaryKey: boundaryKey,
          child: CompositionArtboard(
            width: resolution.width,
            height: resolution.height,
            composition: composition,
            renderContext: ArtboardRenderContext.fromStoreContext(
              renderContext,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await captureStoreScreenshot(
      tester,
      slotId: slotId,
      locale: locale,
      deviceId: deviceId,
      orderIndex: i,
      boundaryKey: boundaryKey,
    );
  }
}
