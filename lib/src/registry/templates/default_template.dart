import 'package:flutter/widgets.dart';
import '../template_context.dart';
import 'blocks/blocks.dart';

/// A simple default template that draws a colored background with a title and subtitle.
Widget defaultTemplate(TemplateContext context) {
  return StoreBackground(
    context: context,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StoreText(
              text: context.string('title', fallback: 'Title'),
              context: context,
              styleKey: 'title',
              defaultFontSize: 64,
              defaultFontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 32),
            StoreText(
              text: context.string('subtitle', fallback: 'Subtitle'),
              context: context,
              styleKey: 'subtitle',
              defaultFontSize: 32,
            ),
          ],
        ),
      ),
    ),
  );
}
