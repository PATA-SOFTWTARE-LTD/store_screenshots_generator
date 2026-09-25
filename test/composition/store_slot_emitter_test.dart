import 'package:flutter_test/flutter_test.dart';
import 'package:store_screenshots_generator/studio.dart';

void main() {
  test('emitter round-trips StoreSlot presetId and rawCaptureId', () {
    final project = StudioProject(
      name: 'demo',
      deviceIds: ['iphone_15_pro'],
      locales: ['en-US'],
      slots: const [
        StoreSlot(
          id: 'promo_home',
          name: 'Home',
          presetId: 'title_and_frame',
          rawCaptureId: 'title_frame',
        ),
      ],
      compositions: const {},
    );

    final emitter = CompositionDartEmitter();
    final parser = CompositionDartParser();
    final source = emitter.emitProject(project);
    final parsed = parser.parseProject(source, const {});

    expect(parsed.slots.length, 1);
    expect(parsed.slots.first.id, 'promo_home');
    expect(parsed.slots.first.name, 'Home');
    expect(parsed.slots.first.presetId, 'title_and_frame');
    expect(parsed.slots.first.rawCaptureId, 'title_frame');
  });
}
