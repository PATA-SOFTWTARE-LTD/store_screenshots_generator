import 'dart:io';

/// Paths for decorative image assets stored in the host Flutter app.
class CompositionAssetPaths {
  CompositionAssetPaths._();

  static const assetsFolder = 'store_screenshots_assets';

  static String assetsRoot(String hostRootPath) =>
      '$hostRootPath${Platform.pathSeparator}$assetsFolder';

  static String resolveImagePath({
    required String hostRootPath,
    required String assetPath,
  }) =>
      '${assetsRoot(hostRootPath)}${Platform.pathSeparator}$assetPath';

  static String fileNameFromAssetPath(String assetPath) {
    final normalized = assetPath.replaceAll('\\', '/');
    final index = normalized.lastIndexOf('/');
    return index < 0 ? normalized : normalized.substring(index + 1);
  }
}
