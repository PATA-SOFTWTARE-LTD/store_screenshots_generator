import '../config/models/device_spec.dart';
import 'models/composition.dart';
import 'models/element_frame.dart';
import 'models/element_type.dart';
import 'models/scene_element.dart';
import 'models/studio_project.dart';

class CompositionScaler {
  static Composition scaleToDevice(
    Composition composition,
    DeviceSpec fromDevice,
    DeviceSpec toDevice,
  ) {
    if (fromDevice.id == toDevice.id) return composition;

    final sx =
        toDevice.resolution.width / fromDevice.resolution.width;
    final sy =
        toDevice.resolution.height / fromDevice.resolution.height;

    return scaleBy(composition, sx, sy);
  }

  /// Scales frames and text paint properties by [sx]/[sy].
  ///
  /// Text size / blur use the average scale so glow stays proportional to
  /// glyphs when the artboard is resized (device adapt or editor preview).
  static Composition scaleBy(
    Composition composition,
    double sx,
    double sy,
  ) {
    if (_nearOne(sx) && _nearOne(sy)) return composition;

    return Composition(
      elements: composition.elements
          .map((e) => _scaleElement(e, sx, sy))
          .toList(),
    );
  }

  static SceneElement _scaleElement(
    SceneElement element,
    double sx,
    double sy,
  ) {
    final f = element.frame;
    return element.copyWith(
      frame: ElementFrame(
        x: f.x * sx,
        y: f.y * sy,
        width: f.width * sx,
        height: f.height * sy,
        rotation: f.rotation,
      ),
      properties: _scaleProperties(element.type, element.properties, sx, sy),
    );
  }

  static Map<String, dynamic> _scaleProperties(
    ElementType type,
    Map<String, dynamic> properties,
    double sx,
    double sy,
  ) {
    if (type != ElementType.text || properties.isEmpty) return properties;

    final textScale = (sx + sy) / 2;
    final out = Map<String, dynamic>.from(properties);
    _scaleNum(out, 'fontSize', textScale);
    _scaleNum(out, 'shadowBlur', textScale);
    _scaleNum(out, 'shadowOffsetX', sx);
    _scaleNum(out, 'shadowOffsetY', sy);
    _scaleNum(out, 'letterSpacing', sx);
    return out;
  }

  static void _scaleNum(Map<String, dynamic> map, String key, double factor) {
    final raw = map[key];
    if (raw is num) {
      map[key] = raw.toDouble() * factor;
    }
  }

  static bool _nearOne(double value) => (value - 1.0).abs() < 1e-9;

  static DeviceSpec referenceDevice() =>
      DeviceRegistry.getById(StudioProject.referenceDeviceId);
}
