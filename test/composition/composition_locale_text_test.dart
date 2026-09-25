import 'package:flutter_test/flutter_test.dart';
import 'package:store_screenshots_generator/store_screenshots_generator.dart';

void main() {
  test('extendLocaleTexts adds and prunes locale keys', () {
    const comp = Composition(
      elements: [
        SceneElement(
          id: 'title',
          type: ElementType.text,
          frame: ElementFrame(x: 0, y: 0, width: 100, height: 40),
          properties: {
            'text': {'en-US': 'Hello'},
          },
        ),
      ],
    );

    final extended = CompositionLocaleText.extendLocaleTexts(
      comp,
      locales: ['en-US', 'it-IT', 'fr-FR'],
      defaultText: 'Fallback',
    );
    final text =
        extended.elements.first.properties['text'] as Map<String, String>;
    expect(text['en-US'], 'Hello');
    expect(text['it-IT'], 'Hello');
    expect(text['fr-FR'], 'Hello');

    final pruned = CompositionLocaleText.extendLocaleTexts(
      extended,
      locales: ['en-US'],
      defaultText: 'Fallback',
    );
    final prunedText =
        pruned.elements.first.properties['text'] as Map<String, String>;
    expect(prunedText.keys, {'en-US'});
  });
}
