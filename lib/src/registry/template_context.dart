import 'package:flutter/widgets.dart';
import '../config/models/device_spec.dart';

class TemplateContext {
  final Map<String, dynamic> variables;
  final DeviceSpec device;
  final String? imagePath;
  final String locale;

  TemplateContext({
    required this.variables,
    required this.device,
    this.imagePath,
    required this.locale,
  });

  Color color(String key, {Color fallback = const Color(0xFF000000)}) {
    final value = variables[key];
    if (value is! String || !value.startsWith('#')) return fallback;
    final hex = value.substring(1);
    try {
      if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
      if (hex.length == 8) return Color(int.parse(hex, radix: 16));
    } catch (_) {}
    return fallback;
  }

  String string(String key, {String fallback = ''}) {
    return variables[key]?.toString() ?? fallback;
  }

  double number(String key, {double fallback = 0.0}) {
    final value = variables[key];
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  String? font(String key) {
    return variables[key] as String?;
  }
}
