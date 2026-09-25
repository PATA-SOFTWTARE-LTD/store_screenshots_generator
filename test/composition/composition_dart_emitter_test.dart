import 'package:flutter_test/flutter_test.dart';
import 'package:store_screenshots_generator/studio.dart';

void main() {
  test('emitter and parser round-trip background gradient lists', () {
    const composition = Composition(
      elements: [
        SceneElement(
          id: 'background',
          type: ElementType.solidBackground,
          frame: ElementFrame(x: 0, y: 0, width: 100, height: 200),
          properties: {
            'fillKind': 'linear',
            'gradientStopColors': [0xFFFF0000, 0xFF0000FF],
            'gradientStops': [0.0, 1.0],
            'gradientAngle': 180.0,
          },
        ),
      ],
    );

    final emitted = CompositionDartEmitter().emitCompositions({
      'test': composition,
    });
    final parsed = CompositionDartParser().parseCompositions(emitted);
    final element = parsed['test']!.elements.single;

    expect(element.properties['fillKind'], 'linear');
    expect(element.properties['gradientStopColors'], [0xFFFF0000, 0xFF0000FF]);
    expect(element.properties['gradientStops'], [0.0, 1.0]);
    expect(element.properties['gradientAngle'], 180.0);

    final fill = BackgroundFill.fromProperties(element.properties);
    expect(fill.kind, BackgroundFillKind.linearGradient);
    expect(fill.stops.length, 2);
  });

  test('emitter and parser round-trip text typography properties', () {
    const composition = Composition(
      elements: [
        SceneElement(
          id: 'title',
          type: ElementType.text,
          frame: ElementFrame(x: 48, y: 120, width: 900, height: 200),
          properties: {
            'text': {'en-US': 'Hello', 'it-IT': 'Ciao'},
            'fontSize': 84.0,
            'color': 0xFF1A8BD7,
            'fontWeight': 'w800',
            'textAlign': 'left',
            'lineHeight': 1.2,
            'letterSpacing': -1.5,
            'fontFamily': 'StatusBarRoboto',
            'verticalAlign': 'top',
            'opacity': 0.9,
            'maxLines': 2,
            'overflow': 'ellipsis',
            'italic': true,
            'underline': true,
            'strikethrough': false,
            'shadowColor': 0x80000000,
            'shadowBlur': 6.0,
            'shadowOffsetX': 1.0,
            'shadowOffsetY': 3.0,
          },
        ),
      ],
    );

    final emitted = CompositionDartEmitter().emitCompositions({
      'text_slot': composition,
    });
    final parsed = CompositionDartParser().parseCompositions(emitted);
    final props = parsed['text_slot']!.elements.single.properties;

    expect(props['text'], {'en-US': 'Hello', 'it-IT': 'Ciao'});
    expect(props['fontSize'], 84.0);
    expect(props['fontWeight'], 'w800');
    expect(props['textAlign'], 'left');
    expect(props['lineHeight'], 1.2);
    expect(props['letterSpacing'], -1.5);
    expect(props['fontFamily'], 'StatusBarRoboto');
    expect(props['verticalAlign'], 'top');
    expect(props['opacity'], 0.9);
    expect(props['maxLines'], 2);
    expect(props['overflow'], 'ellipsis');
    expect(props['italic'], true);
    expect(props['underline'], true);
    expect(props['strikethrough'], false);
    expect(props['shadowColor'], 0x80000000);
    expect(props['shadowBlur'], 6.0);
    expect(props['shadowOffsetX'], 1.0);
    expect(props['shadowOffsetY'], 3.0);
  });
}
