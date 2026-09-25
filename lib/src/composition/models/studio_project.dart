import '../composition_capture.dart';
import 'composition.dart';
import 'composition_key.dart';
import 'store_slot.dart';

/// In-memory design project (GUI source of truth).
class StudioProject {
  static const referenceDeviceId = 'iphone_15_pro';
  static const generatedDirName = 'lib/store_screenshots/generated';

  final String name;
  final List<String> deviceIds;
  final List<String> locales;
  final List<StoreSlot> slots;
  final Map<String, Composition> compositions;
  final String rawScreenshotsPath;

  const StudioProject({
    required this.name,
    required this.deviceIds,
    required this.locales,
    required this.slots,
    required this.compositions,
    this.rawScreenshotsPath = 'raw_screenshots',
  });

  List<StoreSlot> get activeSlots => slots;

  Composition compositionForKey(CompositionKey key) {
    return compositions[key.mapKey] ?? const Composition();
  }

  bool hasDeviceOverride(String deviceId, String slotId) {
    return compositions.containsKey(
      CompositionKey.deviceOverride(deviceId: deviceId, slotId: slotId).mapKey,
    );
  }

  StoreSlot? slotById(String id) {
    for (final slot in slots) {
      if (slot.id == id) return slot;
    }
    return null;
  }

  Iterable<String> configuredRawCaptureIds() => collectConfiguredRawCaptureIds(this);

  StudioProject copyWith({
    String? name,
    List<String>? deviceIds,
    List<String>? locales,
    List<StoreSlot>? slots,
    Map<String, Composition>? compositions,
    String? rawScreenshotsPath,
  }) {
    return StudioProject(
      name: name ?? this.name,
      deviceIds: deviceIds ?? this.deviceIds,
      locales: locales ?? this.locales,
      slots: slots ?? this.slots,
      compositions: compositions ?? this.compositions,
      rawScreenshotsPath: rawScreenshotsPath ?? this.rawScreenshotsPath,
    );
  }
}
