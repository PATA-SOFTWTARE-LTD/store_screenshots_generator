import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_screenshots_generator/store_screenshots_generator.dart';

void main() {
  group('DeviceCatalog', () {
    test('resolves known devices and fastlane folder names', () {
      expect(DeviceCatalog.getById('iphone_15_pro').id, 'iphone_15_pro');
      expect(DeviceCatalog.fastlaneNameFor('iphone_15_pro'), 'iPhone15Pro');
      expect(DeviceCatalog.fastlaneNameFor('pixel_8'), 'Pixel8');
      expect(DeviceCatalog.defaultDeviceIds(), contains('iphone_15_pro'));
    });
  });

  group('StoreScreenshotCanvas', () {
    testWidgets('sizes to device resolution', (tester) async {
      final device = DeviceCatalog.getById('iphone_15_pro');
      const key = ValueKey('boundary');

      await tester.binding.setSurfaceSize(device.resolution);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: StoreScreenshotCanvas(
            device: device,
            boundaryKey: key,
            child: const ColoredBox(color: Color(0xFF0000FF)),
          ),
        ),
      );

      final sized = tester.getSize(find.byType(SizedBox).first);
      expect(sized.width, device.resolution.width);
      expect(sized.height, device.resolution.height);
    });
  });
}
