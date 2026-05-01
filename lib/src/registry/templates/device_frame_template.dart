import 'package:flutter/widgets.dart';
import '../template_context.dart';
import 'blocks/blocks.dart';
import 'layouts/layouts.dart';

Widget deviceFrameTemplate(TemplateContext context) {
  final hasImage = context.imagePath != null;

  return StoreBackground(
    context: context,
    fallbackGradientTop: const Color(0xFFF3E7D3),
    fallbackGradientBottom: const Color(0xFF5CD5D5),
    child: TopTextLayout(
      textPaddingTop: 120.0,
      spacing: 24.0,
      title: context.string('title').isNotEmpty
        ? StoreText(
            text: context.string('title'),
            context: context,
            styleKey: 'title',
            defaultFontSize: 84,
            defaultFontWeight: FontWeight.w800,
            defaultColor: const Color(0xFF1E88E5),
          )
        : const SizedBox.shrink(),
      subtitle: context.string('subtitle').isNotEmpty
        ? StoreText(
            text: context.string('subtitle'),
            context: context,
            styleKey: 'subtitle',
            defaultFontSize: 44,
            defaultFontWeight: FontWeight.w500,
            defaultColor: const Color(0xFF111111),
          )
        : const SizedBox.shrink(),
      deviceMockup: hasImage
          ? DeviceMockup.fromContext(context)
          : null,
    ),
  );
}
