import 'dart:io';

import 'package:store_screenshots_generator/src/scaffold/project_scaffold.dart';

/// Auto-scaffolds missing host files before capture/export CLIs run.
void ensureScaffoldIfNeeded(String hostRoot) {
  if (!ProjectScaffold.needsScaffold(hostRoot)) return;

  print('Missing store screenshot scaffold — creating files in $hostRoot...');
  final written = ProjectScaffold.ensure(hostRoot: hostRoot);
  for (final path in written) {
    print('  + $path');
  }
  if (written.contains('test/raw_screenshots_test.dart')) {
    print('  → Edit test/raw_screenshots_test.dart with your routes.');
  }
}

String findFlutterProjectRoot(String startPath) {
  var currentDir = Directory(startPath).absolute;
  if (!currentDir.existsSync()) {
    currentDir = File(startPath).absolute.parent;
  }

  while (true) {
    final pubspec = File(
      '${currentDir.path}${Platform.pathSeparator}pubspec.yaml',
    );
    if (pubspec.existsSync()) {
      return currentDir.path;
    }

    final parent = currentDir.parent;
    if (parent.path == currentDir.path) break;
    currentDir = parent;
  }

  return Directory.current.absolute.path;
}
