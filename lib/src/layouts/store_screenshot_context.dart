import 'dart:typed_data';

/// Runtime context for rendering a store screenshot layout.
class StoreScreenshotContext {
  final String locale;
  final String deviceId;

  /// Store slot id (export artifact key).
  final String slotId;

  /// Raw PNG stem in the capture pool (`raw_screenshots/.../{captureId}.png`).
  final String rawCaptureId;

  final String hostRootPath;
  final String rawScreenshotsPath;

  /// Pre-loaded file bytes keyed by absolute path (headless export).
  final Map<String, Uint8List>? fileImageCache;

  const StoreScreenshotContext({
    required this.locale,
    required this.deviceId,
    required this.slotId,
    required this.rawCaptureId,
    required this.hostRootPath,
    this.rawScreenshotsPath = 'raw_screenshots',
    this.fileImageCache,
  });

  String localizedTitle(Map<String, String> titles, {String fallback = 'Title'}) {
    return titles[locale] ??
        titles.values.firstOrNull ??
        fallback;
  }

  StoreScreenshotContext withFileCache(Map<String, Uint8List> cache) {
    return StoreScreenshotContext(
      locale: locale,
      deviceId: deviceId,
      slotId: slotId,
      rawCaptureId: rawCaptureId,
      hostRootPath: hostRootPath,
      rawScreenshotsPath: rawScreenshotsPath,
      fileImageCache: cache,
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}
