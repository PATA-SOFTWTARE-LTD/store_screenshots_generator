import '../layouts/raw_path_resolver.dart';

/// Lists raw PNG captures available on disk (the raw pool).
class RawCaptureCatalog {
  static List<String> listCaptureIds({
    required String hostRootPath,
    required String rawScreenshotsPath,
    required String locale,
    required String deviceId,
  }) {
    return RawPathResolver.listCaptureIds(
      hostRootPath: hostRootPath,
      rawScreenshotsPath: rawScreenshotsPath,
      locale: locale,
      deviceId: deviceId,
    );
  }
}
