import 'package:flutter/widgets.dart';
import '../template_context.dart';
import 'blocks/blocks.dart';
import 'layouts/layouts.dart';

Widget solidBackgroundTemplate(TemplateContext context) {
  final hasImage = context.imagePath != null;

  return StoreBackground(
    context: context,
    fallbackBgColor: const Color(0xFFF0F0F0),
    child: TopTextLayout(
      textPaddingTop: 140.0,
      spacing: 32.0,
      devicePadding: const EdgeInsets.only(left: 100.0, right: 100.0, bottom: 60.0),
      title: context.string('title').isNotEmpty 
        ? StoreText(
            text: context.string('title'),
            context: context,
            styleKey: 'title',
            defaultFontSize: 96,
            defaultFontWeight: FontWeight.w900,
            defaultColor: const Color(0xFF111111),
          )
        : const SizedBox.shrink(),
      subtitle: context.string('subtitle').isNotEmpty
        ? StoreText(
            text: context.string('subtitle'),
            context: context,
            styleKey: 'subtitle',
            defaultFontSize: 48,
            defaultFontWeight: FontWeight.w500,
            defaultColor: const Color(0xFF444444),
          )
        : const SizedBox.shrink(),
      deviceMockup: hasImage
          ? Container(
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color(0x44000000),
                    blurRadius: 40,
                    offset: Offset(0, 30),
                  )
                ],
              ),
              child: DeviceMockup.fromContext(context),
            )
          : null,
    ),
  );
}
