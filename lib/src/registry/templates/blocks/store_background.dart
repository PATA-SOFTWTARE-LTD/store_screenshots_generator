import 'package:flutter/widgets.dart';
import '../../template_context.dart';

class StoreBackground extends StatelessWidget {
  final Widget child;
  final TemplateContext context;
  final Color fallbackBgColor;
  final Color fallbackGradientTop;
  final Color fallbackGradientBottom;

  const StoreBackground({
    super.key,
    required this.child,
    required this.context,
    this.fallbackBgColor = const Color(0xFF000000),
    this.fallbackGradientTop = const Color(0x00000000),
    this.fallbackGradientBottom = const Color(0x00000000),
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = this.context.color('backgroundColor', fallback: fallbackBgColor);
    final gradTop = this.context.color('gradientTop', fallback: fallbackGradientTop);
    final gradBottom = this.context.color('gradientBottom', fallback: fallbackGradientBottom);

    BoxDecoration decoration;
    if (gradTop.alpha != 0 && gradBottom.alpha != 0) {
      decoration = BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [gradTop, gradBottom],
        ),
      );
    } else {
      decoration = BoxDecoration(color: bgColor);
    }

    return Container(
      decoration: decoration,
      child: child,
    );
  }
}
