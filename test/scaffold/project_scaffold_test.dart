import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:store_screenshots_generator/store_screenshots_generator.dart';

void main() {
  test('ProjectScaffold writes expected files', () {
    final temp = Directory.systemTemp.createTempSync('ssg_scaffold_');
    addTearDown(() => temp.deleteSync(recursive: true));

    File('${temp.path}${Platform.pathSeparator}pubspec.yaml').writeAsStringSync('''
name: my_test_app
environment:
  sdk: ^3.0.0
''');

    final written = ProjectScaffold.ensure(hostRoot: temp.path);
    expect(written, isNotEmpty);
    expect(
      File('${temp.path}${Platform.pathSeparator}screenshots.yaml').existsSync(),
      isTrue,
    );
    expect(
      File(
        '${temp.path}${Platform.pathSeparator}test${Platform.pathSeparator}store_screenshots_test.dart',
      ).readAsStringSync(),
      contains('runStoreScreenshotExportTests'),
    );
    expect(
      File(
        '${temp.path}${Platform.pathSeparator}test${Platform.pathSeparator}store_screenshots_test.dart',
      ).readAsStringSync(),
      contains('package:my_test_app/store_screenshots/layout_registry.dart'),
    );
  });

  test('ProjectScaffold.ensure skips existing files without force', () {
    final temp = Directory.systemTemp.createTempSync('ssg_scaffold_skip_');
    addTearDown(() => temp.deleteSync(recursive: true));

    File('${temp.path}${Platform.pathSeparator}pubspec.yaml').writeAsStringSync('''
name: skip_app
environment:
  sdk: ^3.0.0
''');

    ProjectScaffold.ensure(hostRoot: temp.path);
    final second = ProjectScaffold.ensure(hostRoot: temp.path);
    expect(second, isEmpty);
  });

  test('needsScaffold detects missing files', () {
    final temp = Directory.systemTemp.createTempSync('ssg_scaffold_need_');
    addTearDown(() => temp.deleteSync(recursive: true));

    File('${temp.path}${Platform.pathSeparator}pubspec.yaml').writeAsStringSync('''
name: need_app
environment:
  sdk: ^3.0.0
''');

    expect(ProjectScaffold.needsScaffold(temp.path), isTrue);
    ProjectScaffold.ensure(hostRoot: temp.path);
    expect(ProjectScaffold.needsScaffold(temp.path), isFalse);
  });
}
