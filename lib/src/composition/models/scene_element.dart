import 'element_frame.dart';
import 'element_type.dart';

class SceneElement {
  final String id;
  final ElementType type;
  final ElementFrame frame;
  final Map<String, dynamic> properties;

  const SceneElement({
    required this.id,
    required this.type,
    required this.frame,
    this.properties = const {},
  });

  SceneElement copyWith({
    String? id,
    ElementType? type,
    ElementFrame? frame,
    Map<String, dynamic>? properties,
  }) {
    return SceneElement(
      id: id ?? this.id,
      type: type ?? this.type,
      frame: frame ?? this.frame,
      properties: properties ?? this.properties,
    );
  }
}
