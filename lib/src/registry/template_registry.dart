import 'package:flutter/widgets.dart';

typedef TemplateBuilder = Widget Function(Map<String, dynamic> variables);

class TemplateRegistry {
  static final Map<String, TemplateBuilder> _templates = {};

  static void register(String name, TemplateBuilder builder) {
    _templates[name] = builder;
  }

  static Widget build(String name, Map<String, dynamic> variables) {
    final builder = _templates[name];
    if (builder == null) {
      throw Exception('Template "$name" not found in registry. Did you forget to register it?');
    }
    return builder(variables);
  }
}
