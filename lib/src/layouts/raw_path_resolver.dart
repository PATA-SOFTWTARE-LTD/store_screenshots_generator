import 'dart:io';

/// Resolves raw screenshot paths from the host project layout.
class RawPathResolver {
  static String rawScreenshotPath({
    required String hostRootPath,
    required String rawScreenshotsPath,
    required String locale,
    required String deviceId,
    required String captureId,
  }) {
    final sep = Platform.pathSeparator;
    return '$hostRootPath$sep$rawScreenshotsPath$sep$locale$sep$deviceId$sep$captureId.png';
  }

  static bool rawExists({
    required String hostRootPath,
    required String rawScreenshotsPath,
    required String locale,
    required String deviceId,
    required String captureId,
  }) {
    return File(
      rawScreenshotPath(
        hostRootPath: hostRootPath,
        rawScreenshotsPath: rawScreenshotsPath,
        locale: locale,
        deviceId: deviceId,
        captureId: captureId,
      ),
    ).existsSync();
  }

  /// Lists capture ids (PNG stems) present for [locale] and [deviceId].
  static List<String> listCaptureIds({
    required String hostRootPath,
    required String rawScreenshotsPath,
    required String locale,
    required String deviceId,
  }) {
    final sep = Platform.pathSeparator;
    final dir = Directory(
      '$hostRootPath$sep$rawScreenshotsPath$sep$locale$sep$deviceId',
    );
    if (!dir.existsSync()) return const [];

    final ids = <String>[];
    for (final entity in dir.listSync()) {
      if (entity is! File) continue;
      final name = entity.uri.pathSegments.last;
      if (!name.endsWith('.png')) continue;
      ids.add(name.substring(0, name.length - 4));
    }
    ids.sort();
    return ids;
  }
}
