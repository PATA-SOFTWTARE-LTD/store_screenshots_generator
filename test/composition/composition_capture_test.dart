import 'package:flutter_test/flutter_test.dart';
import 'package:store_screenshots_generator/store_screenshots_generator.dart';

import 'package:store_screenshots_generator/src/composition/composition_capture.dart';
import 'package:store_screenshots_generator/src/composition/models/composition.dart';
import 'package:store_screenshots_generator/src/composition/models/element_frame.dart';
import 'package:store_screenshots_generator/src/composition/models/element_type.dart';
import 'package:store_screenshots_generator/src/composition/models/scene_element.dart';
import 'package:store_screenshots_generator/src/composition/models/store_slot.dart';
import 'package:store_screenshots_generator/src/composition/models/studio_project.dart';

void main() {
  test('captureIdForElement prefers element property over slot fallback', () {
    const element = SceneElement(
      id: 'screenshot_1',
      type: ElementType.rawScreenshot,
      frame: ElementFrame(x: 0, y: 0, width: 100, height: 100),
      properties: {'captureId': 'minimal'},
    );

    expect(
      captureIdForElement(element, slotFallback: 'legacy'),
      'minimal',
    );
  });

  test('slotIsExportable accepts composition-only slots', () {
    const project = StudioProject(
      name: 'test',
      deviceIds: ['iphone_15_pro'],
      locales: ['en-US'],
      slots: [StoreSlot(id: 'home', name: 'Home')],
      compositions: {
        '*|*|home': Composition(
          elements: [
            SceneElement(
              id: 'screenshot_1',
              type: ElementType.rawScreenshot,
              frame: ElementFrame(x: 0, y: 0, width: 100, height: 100),
              properties: {'captureId': 'minimal'},
            ),
          ],
        ),
      },
    );

    expect(slotIsExportable(project, project.slots.first), isTrue);
  });

  test('collectConfiguredRawCaptureIds reads element properties', () {
    const project = StudioProject(
      name: 'test',
      deviceIds: ['iphone_15_pro'],
      locales: ['en-US'],
      slots: [StoreSlot(id: 'home', name: 'Home')],
      compositions: {
        '*|*|home': Composition(
          elements: [
            SceneElement(
              id: 'screenshot_1',
              type: ElementType.rawScreenshot,
              frame: ElementFrame(x: 0, y: 0, width: 100, height: 100),
              properties: {'captureId': 'minimal'},
            ),
            SceneElement(
              id: 'screenshot_2',
              type: ElementType.rawScreenshot,
              frame: ElementFrame(x: 0, y: 0, width: 100, height: 100),
              properties: {'captureId': 'title_frame'},
            ),
          ],
        ),
      },
    );

    expect(
      project.configuredRawCaptureIds().toSet(),
      {'minimal', 'title_frame'},
    );
  });
}
