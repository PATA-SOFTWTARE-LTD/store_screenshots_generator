import 'package:flutter_test/flutter_test.dart';
import 'package:store_screenshots_generator/src/config/models/screenshot_config.dart';

void main() {
  group('ProjectConfig', () {
    test('fromJson should parse correctly', () {
      final json = {
        'devices': ['iphone_15_pro', 'ipad_pro_13'],
        'locales': ['en-US', 'it-IT'],
        'screens': [
          {
            'id': 'welcome',
            'template': 'default',
            'variables': {
              'title': {
                'en-US': 'Hello',
                'it-IT': 'Ciao'
              }
            }
          }
        ]
      };

      final config = ProjectConfig.fromJson(json);

      expect(config.devices.length, 2);
      expect(config.devices[0], 'iphone_15_pro');
      expect(config.locales.length, 2);
      expect(config.locales[0], 'en-US');
      expect(config.screens.length, 1);
      expect(config.screens[0].id, 'welcome');
      expect(config.screens[0].templateName, 'default');
      expect((config.screens[0].variables['title'] as Map)['it-IT'], 'Ciao');
    });

    test('fromJson should handle empty lists and fallback to default', () {
      final config = ProjectConfig.fromJson({'devices': [], 'locales': [], 'screens': []});
      // Default to iphone_15_pro and en-US if empty
      expect(config.devices, ['iphone_15_pro']);
      expect(config.locales, ['en-US']);
      expect(config.screens, isEmpty);
    });

    test('fromJson should handle missing variables', () {
      final json = {
        'screens': [
          {
            'id': 'empty',
            'template': 'minimal',
          }
        ]
      };

      final config = ProjectConfig.fromJson(json);
      expect(config.screens.length, 1);
      expect(config.screens[0].variables, isEmpty);
    });
  });

  group('ScreenshotConfig', () {
    test('fromJson should parse primitive values', () {
      final json = {
        'id': 'test',
        'template': 'tmpl',
        'variables': {
          'key': 'value',
          'num': 123,
        }
      };

      final config = ScreenshotConfig.fromJson(json);
      expect(config.id, 'test');
      expect(config.templateName, 'tmpl');
      expect(config.variables['key'], 'value');
      expect(config.variables['num'], 123);
    });
  });
}
