// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Optional integration hook: set HOST_ROOT to a host app path to validate
/// that its export test file and screenshots.yaml exist.
///
/// Plain `flutter test` in the package root skips the heavy path (no HOST_ROOT).
void main() {
  final hostRoot = const String.fromEnvironment('HOST_ROOT');
  if (hostRoot.isEmpty) {
    test('export store screenshots runner skipped without HOST_ROOT', () {});
    return;
  }

  test('export store screenshots from host project', () async {
    final testFile =
        '$hostRoot${Platform.pathSeparator}test${Platform.pathSeparator}store_screenshots_test.dart';
    expect(File(testFile).existsSync(), isTrue);

    final configFile =
        File('$hostRoot${Platform.pathSeparator}screenshots.yaml');
    expect(configFile.existsSync(), isTrue);

    print('HOST_ROOT=$hostRoot');
    print('test file: $testFile');
  });
}
