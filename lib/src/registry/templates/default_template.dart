import 'package:flutter/widgets.dart';

/// A simple default template that draws a colored background with a title and subtitle.
Widget defaultTemplate(Map<String, dynamic> variables) {
  final title = variables['title'] as String? ?? 'Title';
  final subtitle = variables['subtitle'] as String? ?? 'Subtitle';
  final fontFamily = variables['fontFamily'] as String?;
  
  // Simple color parser for MVP
  Color parseColor(String? hex, Color fallback) {
    if (hex == null || !hex.startsWith('#') || hex.length != 7) return fallback;
    return Color(int.parse('FF${hex.substring(1)}', radix: 16));
  }
  
  final bgColor = parseColor(variables['backgroundColor'] as String?, const Color(0xFF000000));

  return Directionality(
    textDirection: TextDirection.ltr,
    child: Container(
      color: bgColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: const Color(0xFFFFFFFF),
                fontSize: 48,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              subtitle,
              style: TextStyle(
                color: const Color(0xFFFFFFFF),
                fontSize: 24,
                fontFamily: fontFamily,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
