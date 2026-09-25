import 'package:flutter/services.dart';

/// Carica i font minimi necessari per i test screenshot.
///
/// Va chiamato in `setUpAll()` nel progetto host quando si usa `flutter_test`
/// per evitare il fallback al font di test (Ahem), che mostra quadratini.
Future<void> loadScreenshotTestFonts() async {
  final medium = await rootBundle.load(
    'packages/store_screenshots_generator/assets/fonts/Roboto-Medium.ttf',
  );
  final semiBold = await rootBundle.load(
    'packages/store_screenshots_generator/assets/fonts/Roboto-SemiBold.ttf',
  );

  final statusBarLoader = FontLoader('StatusBarRoboto')
    ..addFont(Future.value(medium))
    ..addFont(Future.value(semiBold));

  final appTextLoader = FontLoader('Roboto')
    ..addFont(Future.value(medium))
    ..addFont(Future.value(semiBold));

  await Future.wait([
    statusBarLoader.load(),
    appTextLoader.load(),
  ]);
}
