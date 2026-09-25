/// A store screenshot slot defined in Layout Studio (not in YAML).
class StoreSlot {
  final String id;
  final String name;
  final String? presetId;
  final String? rawCaptureId;

  const StoreSlot({
    required this.id,
    required this.name,
    this.presetId,
    this.rawCaptureId,
  });

  bool get isConfigured => rawCaptureId != null;

  StoreSlot copyWith({
    String? id,
    String? name,
    String? presetId,
    String? rawCaptureId,
    bool clearPresetId = false,
    bool clearRawCaptureId = false,
  }) {
    return StoreSlot(
      id: id ?? this.id,
      name: name ?? this.name,
      presetId: clearPresetId ? null : (presetId ?? this.presetId),
      rawCaptureId:
          clearRawCaptureId ? null : (rawCaptureId ?? this.rawCaptureId),
    );
  }
}
