import 'package:flutter_test/flutter_test.dart';
import 'package:store_screenshots_generator/store_screenshots_generator.dart';

void main() {
  group('CompositionScaler', () {
    test('scaleBy scales frames and text paint properties', () {
      const composition = Composition(
        elements: [
          SceneElement(
            id: 'title',
            type: ElementType.text,
            frame: ElementFrame(x: 10, y: 20, width: 100, height: 50),
            properties: {
              'fontSize': 100.0,
              'shadowBlur': 20.0,
              'shadowOffsetX': 4.0,
              'shadowOffsetY': 8.0,
              'letterSpacing': 2.0,
              'color': 0xFFFFFFFF,
            },
          ),
          SceneElement(
            id: 'bg',
            type: ElementType.solidBackground,
            frame: ElementFrame(x: 0, y: 0, width: 200, height: 400),
            properties: {'color': 0xFF0000FF},
          ),
        ],
      );

      final scaled = CompositionScaler.scaleBy(composition, 0.5, 0.5);
      final title = scaled.elements.firstWhere((e) => e.id == 'title');
      final bg = scaled.elements.firstWhere((e) => e.id == 'bg');

      expect(title.frame.x, 5);
      expect(title.frame.y, 10);
      expect(title.frame.width, 50);
      expect(title.frame.height, 25);
      expect(title.properties['fontSize'], 50.0);
      expect(title.properties['shadowBlur'], 10.0);
      expect(title.properties['shadowOffsetX'], 2.0);
      expect(title.properties['shadowOffsetY'], 4.0);
      expect(title.properties['letterSpacing'], 1.0);

      expect(bg.frame.width, 100);
      expect(bg.frame.height, 200);
      expect(bg.properties['color'], 0xFF0000FF);
    });

    test('scaleToDevice scales typography between devices', () {
      final from = DeviceRegistry.getById('iphone_15_pro');
      final to = DeviceRegistry.getById('pixel_8');
      const composition = Composition(
        elements: [
          SceneElement(
            id: 'title',
            type: ElementType.text,
            frame: ElementFrame(x: 0, y: 0, width: 100, height: 40),
            properties: {'fontSize': 100.0, 'shadowBlur': 20.0},
          ),
        ],
      );

      final scaled = CompositionScaler.scaleToDevice(composition, from, to);
      final title = scaled.elements.single;
      final sx = to.resolution.width / from.resolution.width;
      final sy = to.resolution.height / from.resolution.height;
      final textScale = (sx + sy) / 2;

      expect(title.frame.width, closeTo(100 * sx, 0.01));
      expect(title.properties['fontSize'], closeTo(100 * textScale, 0.01));
      expect(title.properties['shadowBlur'], closeTo(20 * textScale, 0.01));
    });
  });
}
