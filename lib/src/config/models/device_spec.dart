import 'package:flutter/widgets.dart';

/// Package che contiene i PNG in [DeviceSpec.frameAsset] (`pubspec`: `assets/frames/`).
/// Non usare `File(assetPath)` dalla root del progetto host: i file vivono nel package.
const String kDeviceFrameAssetPackage = 'store_screenshots_generator';

class DeviceSpec {
  final String id;
  final String name;
  final Size resolution;
  final double pixelRatio;
  final double cornerRadius;

  /// Path to a PNG frame asset.
  final String? frameAsset;

  /// Insets for the screen content inside the [frameAsset].
  final EdgeInsets framePadding;

  /// Physical pixel safe area insets (to match [resolution]).
  final EdgeInsets safeArea;

  const DeviceSpec({
    required this.id,
    required this.name,
    required this.resolution,
    this.pixelRatio = 3.0,
    this.cornerRadius = 40.0,
    this.frameAsset,
    this.framePadding = EdgeInsets.zero,
    this.safeArea = EdgeInsets.zero,
  });

  double get aspectRatio => resolution.width / resolution.height;
}

class DeviceRegistry {
  static const Map<String, DeviceSpec> devices = {
    'iphone_15_pro': DeviceSpec(
      id: 'iphone_15_pro',
      name: 'iPhone 15 Pro',
      resolution: Size(1179, 2556),
      pixelRatio: 3.0,
      cornerRadius: 55.0,
      frameAsset: 'assets/frames/iphone_15_pro.png',
      framePadding: EdgeInsets.all(50.0),
      safeArea: EdgeInsets.only(top: 177, bottom: 102),
    ),
    'iphone_13_pro_max': DeviceSpec(
      id: 'iphone_13_pro_max',
      name: 'iPhone 13 Pro Max',
      resolution: Size(1284, 2778),
      pixelRatio: 3.0,
      cornerRadius: 50.0,
      frameAsset: 'assets/frames/iphone_13_pro_max.png',
      framePadding: EdgeInsets.all(38.0),
      safeArea: EdgeInsets.only(top: 141, bottom: 102),
    ),
    'pixel_8': DeviceSpec(
      id: 'pixel_8',
      name: 'Google Pixel 8',
      resolution: Size(1344, 2992),
      pixelRatio: 3.5,
      cornerRadius: 45.0,
      frameAsset: 'assets/frames/pixel_8.png',
      framePadding: EdgeInsets.all(32.0),
      safeArea: EdgeInsets.only(top: 112, bottom: 84),
    ),
    'pixel_4_xl': DeviceSpec(
      id: 'pixel_4_xl',
      name: 'Google Pixel 4 XL',
      resolution: Size(1440, 3040),
      pixelRatio: 3.5,
      cornerRadius: 24.0,
      frameAsset: 'assets/frames/pixel_4_xl.png',
      framePadding: EdgeInsets.only(
        left: 50.0,
        right: 50.0,
        top: 120.0,
        bottom: 70.0,
      ),
      safeArea: EdgeInsets.only(top: 112, bottom: 84),
    ),
    'ipad_pro_13': DeviceSpec(
      id: 'ipad_pro_13',
      name: 'iPad Pro 13-inch',
      resolution: Size(2064, 2752),
      pixelRatio: 2.0,
      cornerRadius: 30.0,
      frameAsset: 'assets/frames/ipad_pro_13.png',
      framePadding: EdgeInsets.all(40.0),
      safeArea: EdgeInsets.only(top: 48, bottom: 40),
    ),
  };

  static DeviceSpec getById(String id) {
    return devices[id] ?? devices['iphone_15_pro']!;
  }
}
