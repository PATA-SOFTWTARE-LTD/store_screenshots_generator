import 'package:flutter_test/flutter_test.dart';
import 'package:store_screenshots_generator/src/config/models/screenshot_config.dart';

void main() {
  group('ProjectConfig', () {
    test('fromJson should parse correctly', () {
      final json = {
        'locales': [
          {
            'locale': 'en-US',
            'screenshots': [
              {
                'id': 'welcome',
                'template': 'default',
                'variables': {
                  'title': 'Hello',
                }
              }
            ]
          }
        ]
      };

      final config = ProjectConfig.fromJson(json);

      expect(config.locales.length, 1);
      expect(config.locales[0].locale, 'en-US');
      expect(config.locales[0].screenshots.length, 1);
      expect(config.locales[0].screenshots[0].id, 'welcome');
      expect(config.locales[0].screenshots[0].templateName, 'default');
      expect(config.locales[0].screenshots[0].variables['title'], 'Hello');
    });

    test('fromJson should handle empty locales', () {
      final config = ProjectConfig.fromJson({'locales': []});
      expect(config.locales, isEmpty);
    });

    test('fromJson should handle missing variables', () {
      final json = {
        'locales': [
          {
            'locale': 'it-IT',
            'screenshots': [
              {
                'id': 'empty',
                'template': 'minimal',
              }
            ]
          }
        ]
      };

      final config = ProjectConfig.fromJson(json);
      expect(config.locales[0].screenshots[0].variables, isEmpty);
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
