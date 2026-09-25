class CompositionKey {
  static const wildcardDevice = '*';
  static const wildcardLocale = '*';

  final String locale;
  final String deviceId;
  final String slotId;

  const CompositionKey({
    required this.locale,
    required this.deviceId,
    required this.slotId,
  });

  /// Locale-agnostic default layout for [slotId] (reference device).
  factory CompositionKey.layoutDefault({required String slotId}) {
    return CompositionKey(
      locale: wildcardLocale,
      deviceId: wildcardDevice,
      slotId: slotId,
    );
  }

  /// Locale-agnostic device-specific layout override.
  factory CompositionKey.deviceOverride({
    required String deviceId,
    required String slotId,
  }) {
    return CompositionKey(
      locale: wildcardLocale,
      deviceId: deviceId,
      slotId: slotId,
    );
  }

  String get mapKey => '$locale|$deviceId|$slotId';

  bool get isDeviceOverride => deviceId != wildcardDevice;

  bool get isLocaleAgnostic => locale == wildcardLocale;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompositionKey &&
          locale == other.locale &&
          deviceId == other.deviceId &&
          slotId == other.slotId;

  @override
  int get hashCode => Object.hash(locale, deviceId, slotId);

  static CompositionKey? parseMapKey(String key) {
    final parts = key.split('|');
    if (parts.length != 3) return null;
    return CompositionKey(
      locale: parts[0],
      deviceId: parts[1],
      slotId: parts[2],
    );
  }
}
