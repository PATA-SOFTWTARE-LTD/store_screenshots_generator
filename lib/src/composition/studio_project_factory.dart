import '../config/models/screenshot_config.dart';
import 'models/composition.dart';
import 'models/store_slot.dart';
import 'models/studio_project.dart';

/// Builds a [StudioProject] from YAML manifest scope + saved generated data.
class StudioProjectFactory {
  static StudioProject fromManifest({
    required ProjectConfig manifest,
    required String name,
    Map<String, Composition>? compositions,
    List<StoreSlot>? slots,
  }) {
    return StudioProject(
      name: name,
      deviceIds: manifest.devices,
      locales: manifest.locales,
      slots: slots ?? const [],
      compositions: compositions ?? const {},
      rawScreenshotsPath: manifest.rawScreenshotsPath,
    );
  }
}
