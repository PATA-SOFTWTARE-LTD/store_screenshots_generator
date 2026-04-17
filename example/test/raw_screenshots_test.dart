// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_screenshots_generator/store_screenshots_generator.dart';
import 'package:example/main.dart';

void main() {
  setUpAll(() async {
    // Abilitiamo il rendering delle ombre (disabilitato di default nei test)
    debugDisableShadows = false;

    // 1. Caricamento Font di sistema per il testo (Windows)
    final fontPath = 'C:/Windows/Fonts/arial.ttf';
    if (File(fontPath).existsSync()) {
      final fontData = File(fontPath).readAsBytesSync();
      final loader = FontLoader('Roboto');
      loader.addFont(Future.value(fontData.buffer.asByteData()));
      await loader.load();
      print('Caricato font di sistema per il testo.');
    }

    // 2. Caricamento Material Icons (Percorso rilevato dal tuo sistema)
    final materialIconPath =
        'C:/Users/carlo/fvm/default/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf';
    if (File(materialIconPath).existsSync()) {
      final iconData = File(materialIconPath).readAsBytesSync();
      final loader = FontLoader('MaterialIcons');
      loader.addFont(Future.value(iconData.buffer.asByteData()));
      await loader.load();
      print('Caricato font Material Icons.');
    }
  });

  testWidgets('Generate Raw Screenshots for Home Page', (
    WidgetTester tester,
  ) async {
    // Ripristiniamo il valore predefinito alla fine di questo test per evitare errori di asserzione
    addTearDown(() => debugDisableShadows = true);

    // Definire il device e la lingua per questo test
    const deviceId = String.fromEnvironment(
      'DEVICE',
      defaultValue: 'iphone_15_pro',
    );
    const locale = String.fromEnvironment('LOCALE', defaultValue: 'it-IT');
    const includeStatusBar = bool.fromEnvironment(
      'INCLUDE_STATUS_BAR',
      defaultValue: true,
    );

    // Recuperiamo le specifiche del device
    final device = DeviceRegistry.getById(deviceId);
    final resolution = device.resolution;
    final pixelRatio = device.pixelRatio;
    print(
      'Device: ${device.name} ($deviceId), Resolution: ${resolution.width}x${resolution.height}, PixelRatio: $pixelRatio',
    );

    // 1. Set the physical size and pixel ratio to match the target device
    final logicalSize = Size(
      resolution.width / pixelRatio,
      resolution.height / pixelRatio,
    );

    // Importante: setSurfaceSize imposta la dimensione LOGICA
    await tester.binding.setSurfaceSize(logicalSize);

    // Impostiamo la vista del tester per riflettere il device reale
    tester.view.physicalSize = resolution;
    tester.view.devicePixelRatio = pixelRatio;

    // 2. Capture Home Light
    print('Capturing Home Light Screen...');
    final rootKey = GlobalKey();
    
    // Utilizziamo lo ScreenshotScaffold che gestisce automaticamente:
    // - MediaQuery (con safeArea corretta per il notch)
    // - FakeStatusBar (con altezza adattiva)
    // - RepaintBoundary
    final appRoot = ScreenshotScaffold(
      boundaryKey: rootKey,
      device: device,
      includeStatusBar: includeStatusBar,
      statusBarContentColor: Colors.white,
      child: MyApp(locale: locale),
    );

    await tester.pumpWidget(appRoot);
    await tester.pumpAndSettle();

    // Recuperiamo il contesto del Navigator per cambiare schermata
    final BuildContext context = tester.element(find.byType(Navigator));

    Navigator.pushNamed(context, '/home_light');
    await tester.pumpAndSettle();

    await captureRawScreenshot(
      tester,
      screenshotId: 'home_light',
      locale: locale,
      deviceId: deviceId,
      boundaryKey: rootKey,
    );

    // 3. Capture Home Dark
    print('Capturing Home Dark Screen...');
    Navigator.pushReplacementNamed(context, '/home_dark');
    await tester.pumpAndSettle();

    await captureRawScreenshot(
      tester,
      screenshotId: 'home_dark',
      locale: locale,
      deviceId: deviceId,
      boundaryKey: rootKey,
    );

    // 4. Capture Insights
    print('Capturing Insights Screen...');
    Navigator.pushReplacementNamed(context, '/insights_screen');
    await tester.pumpAndSettle();

    await captureRawScreenshot(
      tester,
      screenshotId: 'insights',
      locale: locale,
      deviceId: deviceId,
      boundaryKey: rootKey,
    );

    // Reset view al valore predefinito del test framework
    await tester.binding.setSurfaceSize(null);
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    debugDisableShadows = true;
  });
}
