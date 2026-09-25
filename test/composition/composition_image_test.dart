import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_screenshots_generator/store_screenshots_generator.dart';

void main() {
  testWidgets('image element renders from store_screenshots_assets path',
      (tester) async {
    final tempDir = Directory.systemTemp.createTempSync('image_element_test');
    final assetDir = Directory(
      '${tempDir.path}${Platform.pathSeparator}store_screenshots_assets'
      '${Platform.pathSeparator}images',
    )..createSync(recursive: true);

    final hostRoot = tempDir.path;
    final examplePng = File(
      '${Directory('../example').absolute.path}${Platform.pathSeparator}'
      'store_screenshots${Platform.pathSeparator}en-US${Platform.pathSeparator}'
      'iPhone15Pro${Platform.pathSeparator}01_title_frame.png',
    );
    if (!examplePng.existsSync()) {
      tempDir.deleteSync(recursive: true);
      return;
    }

    final assetFile = File('${assetDir.path}${Platform.pathSeparator}logo.png');
    await examplePng.copy(assetFile.path);

    const composition = Composition(
      elements: [
        SceneElement(
          id: 'logo',
          type: ElementType.image,
          frame: ElementFrame(x: 0, y: 0, width: 200, height: 200),
          properties: {'assetPath': 'images/logo.png'},
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CompositionArtboard(
            width: 400,
            height: 800,
            composition: composition,
            renderContext: ArtboardRenderContext(
              hostRootPath: hostRoot,
              rawScreenshotsPath: 'raw_screenshots',
              locale: 'en-US',
              deviceId: 'iphone_15_pro',
              slotId: 'test',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);

    tempDir.deleteSync(recursive: true);
  });
}
