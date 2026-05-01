import 'package:flutter/widgets.dart';

class TopTextLayout extends StatelessWidget {
  final Widget title;
  final Widget subtitle;
  final Widget? deviceMockup;
  final double textPaddingTop;
  final double spacing;
  final EdgeInsetsGeometry titlePadding;
  final EdgeInsetsGeometry subtitlePadding;
  final EdgeInsetsGeometry devicePadding;

  const TopTextLayout({
    super.key,
    required this.title,
    required this.subtitle,
    this.deviceMockup,
    this.textPaddingTop = 120.0,
    this.spacing = 24.0,
    this.titlePadding = const EdgeInsets.symmetric(horizontal: 48.0),
    this.subtitlePadding = const EdgeInsets.symmetric(horizontal: 64.0),
    this.devicePadding = const EdgeInsets.symmetric(horizontal: 80.0),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: textPaddingTop),
        Padding(
          padding: titlePadding,
          child: title,
        ),
        SizedBox(height: spacing),
        Padding(
          padding: subtitlePadding,
          child: subtitle,
        ),
        const SizedBox(height: 80),
        if (deviceMockup != null)
          Expanded(
            child: Padding(
              padding: devicePadding,
              child: deviceMockup,
            ),
          )
        else
          const Spacer(),
      ],
    );
  }
}
