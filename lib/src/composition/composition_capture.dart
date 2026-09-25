import 'models/composition_key.dart';
import 'models/element_type.dart';
import 'models/scene_element.dart';
import 'models/store_slot.dart';
import 'models/studio_project.dart';

/// Resolves the raw PNG stem for a [SceneElement], with optional slot-level fallback.
String? captureIdForElement(SceneElement element, {String? slotFallback}) {
  if (element.type != ElementType.rawScreenshot &&
      element.type != ElementType.deviceFrame) {
    return null;
  }
  final fromElement = element.properties['captureId'];
  if (fromElement is String && fromElement.isNotEmpty) return fromElement;
  return slotFallback;
}

/// All raw capture ids referenced by [project] (slot binding + element properties).
Iterable<String> collectConfiguredRawCaptureIds(StudioProject project) sync* {
  for (final slot in project.slots) {
    final id = slot.rawCaptureId;
    if (id != null) yield id;
  }
  for (final comp in project.compositions.values) {
    for (final el in comp.elements) {
      final id = captureIdForElement(el);
      if (id != null) yield id;
    }
  }
}

/// Whether [slot] has exportable layout content.
bool slotIsExportable(StudioProject project, StoreSlot slot) {
  if (slot.rawCaptureId != null) return true;
  final comp = project.compositionForKey(
    CompositionKey.layoutDefault(slotId: slot.id),
  );
  return comp.elements.isNotEmpty;
}

/// Legacy slot binding or first capture id on [composition] (export context fallback).
String fallbackCaptureId(StoreSlot slot, Iterable<SceneElement> elements) {
  if (slot.rawCaptureId != null) return slot.rawCaptureId!;
  for (final el in elements) {
    final id = captureIdForElement(el);
    if (id != null) return id;
  }
  return '';
}
