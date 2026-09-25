import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_screenshots_generator/store_screenshots_generator.dart';

void main() {
  test('CompositionPresets builds title_and_frame', () {
    final c = CompositionPresets.build(
      presetId: 'title_and_frame',
      locales: ['en-US'],
      slotName: 'Home',
    );
    expect(c.elements.length, 4);
    expect(c.elements.first.type, ElementType.solidBackground);
  });

  test('lookupComposition scales default to pixel_8', () {
    final manifest = ProjectConfig(
      devices: ['iphone_15_pro', 'pixel_8'],
      locales: ['en-US'],
    );
    final project = StudioProjectFactory.fromManifest(
      manifest: manifest,
      name: 'test',
      slots: const [
        StoreSlot(
          id: 'title_frame',
          name: 'Home',
          presetId: 'title_and_frame',
          rawCaptureId: 'title_frame',
        ),
      ],
      compositions: {
        '*|*|title_frame': CompositionPresets.build(
          presetId: 'title_and_frame',
          locales: ['en-US'],
          slotName: 'Home',
        ),
      },
    );

    final iphone = lookupComposition(
      project: project,
      locale: 'en-US',
      deviceId: 'iphone_15_pro',
      slotId: 'title_frame',
    );
    final pixel = lookupComposition(
      project: project,
      locale: 'en-US',
      deviceId: 'pixel_8',
      slotId: 'title_frame',
    );

    expect(pixel.elements.first.frame.width,
        greaterThan(iphone.elements.first.frame.width * 0.5));
  });

  testWidgets('CompositionArtboard renders title text', (tester) async {
    final composition = CompositionPresets.build(
      presetId: 'minimal',
      locales: ['en-US'],
      slotName: 'Hello',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 400,
          height: 800,
          child: CompositionArtboard(
            width: 400,
            height: 800,
            composition: composition,
            renderContext: const ArtboardRenderContext(
              hostRootPath: '.',
              rawScreenshotsPath: 'raw_screenshots',
              locale: 'en-US',
              deviceId: 'iphone_15_pro',
              slotId: 'minimal',
              rawCaptureId: 'minimal',
            ),
          ),
        ),
      ),
    );

    expect(find.text('Hello'), findsOneWidget);
  });
}
