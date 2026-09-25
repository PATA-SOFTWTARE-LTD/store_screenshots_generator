// ignore_for_file: avoid_print

import 'dart:io';

import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_screenshots_generator/store_screenshots_generator.dart';

/// Captures raw PNGs defined in this test (pool for Layout Studio).
///
/// Capture ids: title_frame, full_bleed, minimal.
void main() {
  setUpAll(() async {
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
  });

  testWidgets('Generate raw screenshots for Studio example', (
    WidgetTester tester,
  ) async {
    addTearDown(() => debugDisableShadows = true);

    const deviceId = String.fromEnvironment(
      'DEVICE',
      defaultValue: 'iphone_15_pro',
    );
    const locale = String.fromEnvironment('LOCALE', defaultValue: 'it-IT');

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

    final rootKey = GlobalKey();
    final appRoot = ScreenshotScaffold(
      boundaryKey: rootKey,
      device: device,
      child: MyApp(locale: locale),
    );

    await tester.pumpWidget(appRoot);
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(Navigator));

    const captures = <({String id, String route})>[
      (id: 'title_frame', route: '/home_light'),
      (id: 'full_bleed', route: '/home_dark'),
      (id: 'minimal', route: '/insights_screen'),
    ];

    for (final capture in captures) {
      print('Capturing ${capture.id} ($deviceId, $locale)...');
      Navigator.pushReplacementNamed(context, capture.route);
      await tester.pumpAndSettle();

      await captureRawScreenshot(
        tester,
        screenshotId: capture.id,
        locale: locale,
        deviceId: deviceId,
        boundaryKey: rootKey,
      );
    }

    await tester.binding.setSurfaceSize(null);
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    debugDisableShadows = true;
  });
}
