import 'package:flutter_test/flutter_test.dart';
import 'package:store_screenshots_generator/src/engine/headless_runner.dart';

void main() {
  group('HeadlessRunner', () {
    test('buildScaffoldedTestFile should inject the correct config path', () {
      final runner = HeadlessRunner(configPath: 'my/custom/config.yaml');
      final script = runner.buildScaffoldedTestFile();

      expect(script, contains("final configPath = 'my/custom/config.yaml';"));
      expect(script, contains("import 'package:store_screenshots_generator/src/config/models/screenshot_config.dart';"));
      expect(script, contains("testWidgets("));
    });

    test('buildScaffoldedTestFile should handle backslashes in path', () {
      final runner = HeadlessRunner(configPath: r'C:\Users\tester\config.yaml');
      final script = runner.buildScaffoldedTestFile();

      // Should be normalized to forward slashes in the Dart script string
      expect(script, contains("final configPath = 'C:/Users/tester/config.yaml';"));
    });
  });
}
