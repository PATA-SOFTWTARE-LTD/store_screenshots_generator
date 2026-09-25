import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('init CLI scaffolds a host app', () async {
    final temp = Directory.systemTemp.createTempSync('ssg_init_cli_');
    addTearDown(() {
      if (temp.existsSync()) temp.deleteSync(recursive: true);
    });

    File('${temp.path}${Platform.pathSeparator}pubspec.yaml').writeAsStringSync('''
name: init_cli_host
environment:
  sdk: ^3.0.0
''');

    final result = await Process.run(
      'dart',
      [
        'run',
        'store_screenshots_generator:init',
        '--root',
        temp.path,
      ],
      workingDirectory: Directory.current.path,
      runInShell: true,
    );

    expect(
      result.exitCode,
      0,
      reason: 'stdout:\n${result.stdout}\nstderr:\n${result.stderr}',
    );
    expect(
      File('${temp.path}${Platform.pathSeparator}screenshots.yaml').existsSync(),
      isTrue,
    );
    expect(
      File(
        '${temp.path}${Platform.pathSeparator}lib'
        '${Platform.pathSeparator}store_screenshots'
        '${Platform.pathSeparator}layout_registry.dart',
      ).existsSync(),
      isTrue,
    );
    expect(
      File(
        '${temp.path}${Platform.pathSeparator}test'
        '${Platform.pathSeparator}store_screenshots_test.dart',
      ).readAsStringSync(),
      contains('runStoreScreenshotExportTests'),
    );
  });
}
