import 'package:flutter/widgets.dart';
import '../template_context.dart';
import 'blocks/blocks.dart';
import 'layouts/layouts.dart';

Widget splitScreenTemplate(TemplateContext context) {
  final hasImage = context.imagePath != null;
  final color1 = context.color('backgroundColor1', fallback: context.color('gradientTop', fallback: const Color(0xFFF0F0F0)));
  final color2 = context.color('backgroundColor2', fallback: context.color('gradientBottom', fallback: const Color(0xFFE0E0E0)));

  return Stack(
    children: [
      // Split Background
      Column(
        children: [
          Expanded(child: Container(color: color1)),
          Expanded(child: Container(color: color2)),
        ],
      ),
      // Content
      TopTextLayout(
        textPaddingTop: 120.0,
        spacing: 20.0,
        devicePadding: const EdgeInsets.only(left: 100.0, right: 100.0, bottom: 60.0),
        title: context.string('title').isNotEmpty
          ? StoreText(
              text: context.string('title'),
              context: context,
              styleKey: 'title',
              defaultFontSize: 88,
              defaultFontWeight: FontWeight.w900,
              defaultColor: const Color(0xFF111111),
            )
          : const SizedBox.shrink(),
        subtitle: context.string('subtitle').isNotEmpty
          ? StoreText(
              text: context.string('subtitle'),
              context: context,
              styleKey: 'subtitle',
              defaultFontSize: 40,
              defaultFontWeight: FontWeight.w500,
              defaultColor: const Color(0xFF444444),
            )
          : const SizedBox.shrink(),
        deviceMockup: hasImage
            ? Container(
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 40,
                      offset: Offset(0, 20),
                    )
                  ],
                ),
                child: DeviceMockup.fromContext(context),
              )
            : null,
      ),
    ],
  );
}
