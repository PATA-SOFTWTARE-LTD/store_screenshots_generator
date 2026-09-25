import 'package:flutter/material.dart';

int defaultSolidBackgroundColor() => 0xFF1A8BD7;

Color colorFromProperty(dynamic value, {Color fallback = const Color(0xFF1A8BD7)}) {
  if (value is int) return Color(value);
  if (value is String) {
    var hex = value.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    final parsed = int.tryParse(hex, radix: 16);
    if (parsed != null) return Color(parsed);
  }
  return fallback;
}

int colorToProperty(Color color) => color.toARGB32();
