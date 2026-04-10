import 'dart:ui';
import 'package:flutter/widgets.dart';

class DeviceSpec {
  final String id;
  final String name;
  final Size resolution;
  final double cornerRadius;

  /// Path to a PNG frame asset.
  final String? frameAsset;

  /// Insets for the screen content inside the [frameAsset].
  final EdgeInsets framePadding;

  const DeviceSpec({
    required this.id,
    required this.name,
    required this.resolution,
    this.cornerRadius = 40.0,
    this.frameAsset,
    this.framePadding = EdgeInsets.zero,
  });

  double get aspectRatio => resolution.width / resolution.height;
}

class DeviceRegistry {
  static const Map<String, DeviceSpec> devices = {
    'iphone_15_pro': DeviceSpec(
      id: 'iphone_15_pro',
      name: 'iPhone 15 Pro',
      resolution: Size(1179, 2556),
      cornerRadius: 55.0,
      frameAsset: 'assets/frames/iphone_15_pro.png',
      framePadding: EdgeInsets.all(50.0),
    ),
    'iphone_13_pro_max': DeviceSpec(
      id: 'iphone_13_pro_max',
      name: 'iPhone 13 Pro Max',
      resolution: Size(1284, 2778),
      cornerRadius: 50.0,
      frameAsset: 'assets/frames/iphone_13_pro_max.png',
      framePadding: EdgeInsets.all(38.0),
    ),
    'pixel_8_pro': DeviceSpec(
      id: 'pixel_8_pro',
      name: 'Google Pixel 8 Pro',
      resolution: Size(1344, 2992),
      cornerRadius: 45.0,
      frameAsset: 'assets/frames/pixel_8_pro.png',
      framePadding: EdgeInsets.all(32.0),
    ),
    'pixel_4_xl': DeviceSpec(
      id: 'pixel_4_xl',
      name: 'Google Pixel 4 XL',
      resolution: Size(1440, 3040),
      cornerRadius: 24.0,
      frameAsset: 'assets/frames/pixel_4_xl.png',
      framePadding: EdgeInsets.only(top: 100.0, left: 60.0, right: 60.0),
    ),
    'ipad_pro_13': DeviceSpec(
      id: 'ipad_pro_13',
      name: 'iPad Pro 13-inch',
      resolution: Size(2064, 2752),
      cornerRadius: 30.0,
      frameAsset: 'assets/frames/ipad_pro_13.png',
      framePadding: EdgeInsets.all(40.0),
    ),
  };

  static DeviceSpec getById(String id) {
    return devices[id] ?? devices['iphone_15_pro']!;
  }
}
