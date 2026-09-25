import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_screenshots_generator/store_screenshots_generator.dart';

void main() {
  testWidgets('text respects maxLines within frame box', (tester) async {
    const composition = Composition(
      elements: [
        SceneElement(
          id: 'title',
          type: ElementType.text,
          frame: ElementFrame(x: 0, y: 0, width: 200, height: 400),
          properties: {
            'text': {'en-US': 'Line one\nLine two\nLine three'},
            'fontSize': 48,
            'color': 0xFFFFFFFF,
            'maxLines': 2,
            'overflow': 'ellipsis',
            'verticalAlign': 'top',
          },
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
          ),
        ),
      ),
    );

    final text = tester.widget<Text>(find.byType(Text));
    expect(text.maxLines, 2);
    expect(text.overflow, TextOverflow.ellipsis);
    expect(text.softWrap, isTrue);
  });

  testWidgets('text horizontal align expands to full box width', (tester) async {
    const composition = Composition(
      elements: [
        SceneElement(
          id: 'title',
          type: ElementType.text,
          frame: ElementFrame(x: 0, y: 0, width: 400, height: 200),
          properties: {
            'text': {'en-US': 'Hello'},
            'fontSize': 48,
            'color': 0xFFFFFFFF,
            'textAlign': 'left',
          },
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
          ),
        ),
      ),
    );

    final text = tester.widget<Text>(find.text('Hello'));
    expect(text.textAlign, TextAlign.left);
  });

  test('textStyleFromProperties applies opacity and shadow', () {
    final style = textStyleFromProperties({
      'fontSize': 64,
      'color': 0xFFFFFFFF,
      'opacity': 0.5,
      'shadowColor': 0xFF000000,
      'shadowBlur': 8.0,
      'shadowOffsetX': 2.0,
      'shadowOffsetY': 4.0,
    });

    expect(style.fontSize, 64);
    expect(style.color!.a, closeTo(0.5, 0.01));
    expect(style.decoration, TextDecoration.none);
    expect(style.fontStyle, FontStyle.normal);
    expect(style.shadows, isNotNull);
    expect(style.shadows!.single.blurRadius, 8);
  });

  test('textStyleFromProperties applies italic underline strikethrough', () {
    final style = textStyleFromProperties({
      'fontSize': 48,
      'color': 0xFFFF0000,
      'italic': true,
      'underline': true,
      'strikethrough': true,
    });

    expect(style.fontStyle, FontStyle.italic);
    expect(style.decoration, isNot(TextDecoration.none));
    expect(style.decoration!.contains(TextDecoration.underline), isTrue);
    expect(style.decoration!.contains(TextDecoration.lineThrough), isTrue);
  });

  testWidgets('text has no yellow fallback underline without Material', (
    tester,
  ) async {
    const composition = Composition(
      elements: [
        SceneElement(
          id: 'title',
          type: ElementType.text,
          frame: ElementFrame(x: 0, y: 0, width: 400, height: 200),
          properties: {
            'text': {'en-US': 'Hello'},
            'fontSize': 48,
            'color': 0xFFFF0000,
          },
        ),
      ],
    );

    // No MaterialApp / DefaultTextStyle — same isolation as Overlay export.
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: CompositionArtboard(
          width: 400,
          height: 800,
          composition: composition,
        ),
      ),
    );

    final text = tester.widget<Text>(find.text('Hello'));
    final effective = DefaultTextStyle.of(
      tester.element(find.text('Hello')),
    ).style.merge(text.style);
    expect(effective.decoration, TextDecoration.none);
  });
}
