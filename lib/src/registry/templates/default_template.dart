import 'package:flutter/widgets.dart';

/// A simple default template that draws a colored background with a title and subtitle.
Widget defaultTemplate(Map<String, dynamic> variables) {
  final title = variables['title'] as String? ?? 'Title';
  final subtitle = variables['subtitle'] as String? ?? 'Subtitle';
  
  // Custom font families from variables
  final titleFont = variables['titleFont'] as String?;
  final subtitleFont = variables['subtitleFont'] as String?;
  
  // Simple color parser
  Color parseColor(dynamic value, Color fallback) {
    if (value is! String || !value.startsWith('#')) return fallback;
    final hex = value.substring(1);
    if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
    if (hex.length == 8) return Color(int.parse(hex, radix: 16));
    return fallback;
  }
  
  final bgColor = parseColor(variables['backgroundColor'], const Color(0xFF000000));
  final titleColor = parseColor(variables['titleColor'], const Color(0xFFFFFFFF));
  final subtitleColor = parseColor(variables['subtitleColor'], const Color(0xFFEEEEEE));
  
  final gradTop = variables['gradientTop'];
  final gradBottom = variables['gradientBottom'];

  BoxDecoration decoration;
  if (gradTop != null && gradBottom != null) {
    decoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          parseColor(gradTop, bgColor),
          parseColor(gradBottom, bgColor),
        ],
      ),
    );
  } else {
    decoration = BoxDecoration(color: bgColor);
  }

  return Directionality(
    textDirection: TextDirection.ltr,
    child: Container(
      decoration: decoration,
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: titleColor,
                fontSize: 64,
                fontWeight: FontWeight.bold,
                fontFamily: titleFont,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: subtitleColor,
                fontSize: 32,
                fontFamily: subtitleFont,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
