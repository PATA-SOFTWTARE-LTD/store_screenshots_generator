import 'package:flutter/widgets.dart';
import 'template_context.dart';

typedef TemplateBuilder = Widget Function(TemplateContext context);

class TemplateRegistry {
  static final Map<String, TemplateBuilder> _templates = {};

  static void register(String name, TemplateBuilder builder) {
    _templates[name] = builder;
  }

  static Widget build(String name, TemplateContext context) {
    final builder = _templates[name];
    if (builder == null) {
      throw Exception('Template "$name" not found in registry. Did you forget to register it?');
    }
    return builder(context);
  }
}
