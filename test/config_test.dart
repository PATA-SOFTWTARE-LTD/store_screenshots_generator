import 'package:flutter_test/flutter_test.dart';
import 'package:store_screenshots_generator/src/config/models/screenshot_config.dart';
import 'package:store_screenshots_generator/src/widgets/fake_status_bar.dart';

void main() {
  group('ProjectConfig', () {
    test('fromJson should parse capture manifest scope only', () {
      final json = {
        'devices': ['iphone_15_pro', 'ipad_pro_13'],
        'locales': ['en-US', 'it-IT'],
        'rawScreenshotsPath': 'raw_screenshots',
        'statusBar': 'light',
      };

      final config = ProjectConfig.fromJson(json);

      expect(config.devices.length, 2);
      expect(config.devices[0], 'iphone_15_pro');
      expect(config.locales.length, 2);
      expect(config.locales[0], 'en-US');
      expect(config.rawScreenshotsPath, 'raw_screenshots');
      expect(config.statusBar, 'light');
    });

    test('fromJson ignores legacy screens and preset fields', () {
      final json = {
        'devices': ['iphone_15_pro'],
        'locales': ['en-US'],
        'screens': [
          {'id': 'welcome', 'name': 'Welcome', 'preset': 'title_and_frame'},
        ],
        'defaultPreset': 'title_and_frame',
      };

      final config = ProjectConfig.fromJson(json);
      expect(config.devices, ['iphone_15_pro']);
      expect(config.locales, ['en-US']);
    });

    test('fromJson should handle empty lists and fallback to default', () {
      final config = ProjectConfig.fromJson({'devices': [], 'locales': []});
      expect(config.devices, ['iphone_15_pro']);
      expect(config.locales, ['en-US']);
    });
  });

  group('StatusBarMode', () {
    test('fromConfigValue should accept valid values', () {
      expect(StatusBarMode.fromConfigValue('light'), StatusBarMode.light);
      expect(StatusBarMode.fromConfigValue('dark'), StatusBarMode.dark);
      expect(StatusBarMode.fromConfigValue('hidden'), StatusBarMode.hidden);
    });

    test('fromConfigValue should throw on invalid value', () {
      expect(
        () => StatusBarMode.fromConfigValue('invalid'),
        throwsArgumentError,
      );
    });
  });
}
