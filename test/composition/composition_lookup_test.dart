import 'package:flutter_test/flutter_test.dart';
import 'package:store_screenshots_generator/store_screenshots_generator.dart';

void main() {
  test('lookup ignores locale and returns same layout', () {
    final composition = CompositionPresets.build(
      presetId: 'minimal',
      locales: ['en-US', 'it-IT'],
      slotName: 'Home',
    );
    final project = StudioProject(
      name: 'test',
      deviceIds: ['iphone_15_pro'],
      locales: ['en-US', 'it-IT'],
      slots: const [
        StoreSlot(
          id: 'home',
          name: 'Home',
          presetId: 'minimal',
          rawCaptureId: 'home',
        ),
      ],
      compositions: {
        '*|*|home': composition,
      },
    );

    final en = lookupComposition(
      project: project,
      locale: 'en-US',
      deviceId: 'iphone_15_pro',
      slotId: 'home',
    );
    final it = lookupComposition(
      project: project,
      locale: 'it-IT',
      deviceId: 'iphone_15_pro',
      slotId: 'home',
    );

    expect(en.elements.first.frame, it.elements.first.frame);
    expect(
      en.elements
          .firstWhere((e) => e.type == ElementType.text)
          .properties['text'],
      it.elements
          .firstWhere((e) => e.type == ElementType.text)
          .properties['text'],
    );
  });

  test('lookup uses device override without locale', () {
    final defaultComp = CompositionPresets.build(
      presetId: 'minimal',
      locales: ['en-US'],
      slotName: 'A',
    );
    const overrideComp = Composition(
      elements: [
        SceneElement(
          id: 'title',
          type: ElementType.text,
          frame: ElementFrame(x: 10, y: 20, width: 100, height: 50),
          properties: {
            'text': {'en-US': 'Override'},
          },
        ),
      ],
    );

    final project = StudioProject(
      name: 'test',
      deviceIds: ['iphone_15_pro', 'pixel_8'],
      locales: ['en-US'],
      slots: const [
        StoreSlot(
          id: 'a',
          name: 'A',
          presetId: 'minimal',
          rawCaptureId: 'a',
        ),
      ],
      compositions: {
        '*|*|a': defaultComp,
        '*|pixel_8|a': overrideComp,
      },
    );

    final pixel = lookupComposition(
      project: project,
      locale: 'en-US',
      deviceId: 'pixel_8',
      slotId: 'a',
    );
    expect(pixel.elements.first.frame.x, 10);
    expect(hasDeviceOverride(project, 'pixel_8', 'a'), isTrue);
    expect(hasDeviceOverride(project, 'iphone_15_pro', 'a'), isFalse);
  });
}
