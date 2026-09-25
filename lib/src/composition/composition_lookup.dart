import '../config/models/device_spec.dart';
import 'composition_scaler.dart';
import 'models/composition.dart';
import 'models/composition_key.dart';
import 'models/studio_project.dart';

Composition lookupComposition({
  required StudioProject project,
  required String locale,
  required String deviceId,
  required String slotId,
}) {
  final overrideKey = CompositionKey.deviceOverride(
    deviceId: deviceId,
    slotId: slotId,
  );
  final override = project.compositions[overrideKey.mapKey];
  if (override != null) {
    return override;
  }

  final defaultKey = CompositionKey.layoutDefault(slotId: slotId);
  final defaultComposition =
      project.compositions[defaultKey.mapKey] ?? const Composition();

  if (deviceId == StudioProject.referenceDeviceId) {
    return defaultComposition;
  }

  final fromDevice = CompositionScaler.referenceDevice();
  final toDevice = DeviceRegistry.getById(deviceId);
  return CompositionScaler.scaleToDevice(
    defaultComposition,
    fromDevice,
    toDevice,
  );
}

bool hasDeviceOverride(
  StudioProject project,
  String deviceId,
  String slotId,
) {
  return project.compositions.containsKey(
    CompositionKey.deviceOverride(deviceId: deviceId, slotId: slotId).mapKey,
  );
}
