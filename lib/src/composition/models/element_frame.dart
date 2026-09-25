class ElementFrame {
  final double x;
  final double y;
  final double width;
  final double height;
  final double rotation;

  const ElementFrame({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.rotation = 0,
  });

  ElementFrame copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    double? rotation,
  }) {
    return ElementFrame(
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      rotation: rotation ?? this.rotation,
    );
  }
}
