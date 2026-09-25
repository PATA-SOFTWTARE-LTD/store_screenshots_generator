import 'scene_element.dart';

class Composition {
  final List<SceneElement> elements;

  const Composition({this.elements = const []});

  Composition copyWith({List<SceneElement>? elements}) {
    return Composition(elements: elements ?? this.elements);
  }
}
