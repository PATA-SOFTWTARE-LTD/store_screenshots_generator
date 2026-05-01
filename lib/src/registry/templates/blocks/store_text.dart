import 'package:flutter/widgets.dart';
import '../../template_context.dart';

class StoreText extends StatelessWidget {
  final String text;
  final TemplateContext context;
  final String styleKey;
  final double defaultFontSize;
  final FontWeight defaultFontWeight;
  final Color defaultColor;
  final double defaultHeight;
  final TextAlign textAlign;

  const StoreText({
    super.key,
    required this.text,
    required this.context,
    required this.styleKey,
    this.defaultFontSize = 40,
    this.defaultFontWeight = FontWeight.normal,
    this.defaultColor = const Color(0xFFFFFFFF),
    this.defaultHeight = 1.2,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    final color = this.context.color('${styleKey}Color', fallback: defaultColor);
    final fontFamily = this.context.font('${styleKey}Font');

    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        color: color,
        fontSize: defaultFontSize,
        fontWeight: defaultFontWeight,
        fontFamily: fontFamily,
        height: defaultHeight,
      ),
    );
  }
}
