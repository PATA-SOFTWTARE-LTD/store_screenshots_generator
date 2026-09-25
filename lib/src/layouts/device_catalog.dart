import '../config/models/device_spec.dart';

/// Fastlane-oriented device metadata for export folder naming.
extension DeviceSpecFastlane on DeviceSpec {
  String get fastlaneName => DeviceCatalog.fastlaneNameFor(id);
}

class DeviceCatalog {
  static List<DeviceSpec> get all => DeviceRegistry.devices.values.toList();

  static List<String> get allIds => DeviceRegistry.devices.keys.toList();

  static DeviceSpec getById(String id) => DeviceRegistry.getById(id);

  static const String defaultIosMobileId = 'iphone_15_pro';
  static const String defaultAndroidMobileId = 'pixel_8';

  static const Map<String, String> _fastlaneNames = {
    'iphone_15_pro': 'iPhone15Pro',
    'iphone_13_pro_max': 'iPhone13ProMax',
    'ipad_pro_13': 'iPadPro13',
    'pixel_8': 'Pixel8',
    'pixel_4_xl': 'Pixel4XL',
  };

  static String fastlaneNameFor(String deviceId) =>
      _fastlaneNames[deviceId] ?? deviceId;

  static List<String> defaultDeviceIds() => [
        defaultIosMobileId,
        defaultAndroidMobileId,
      ];

  static String defaultDeviceId() => defaultDeviceIds().first;
}

/// Default locales until the package exposes a registry.
const List<String> kDefaultLocales = ['en-US', 'it-IT'];
