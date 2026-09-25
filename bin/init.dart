import 'dart:io';

import 'package:args/args.dart';
import 'package:store_screenshots_generator/src/scaffold/project_scaffold.dart';

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addOption(
      'root',
      help: 'Flutter app root (defaults to current directory).',
      defaultsTo: '.',
    )
    ..addFlag(
      'force',
      abbr: 'f',
      help: 'Overwrite scaffold files even if they already exist.',
      negatable: false,
    )
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Prints usage information.',
    );

  try {
    final results = parser.parse(arguments);

    if (results['help'] as bool) {
      print('Store Screenshots Generator - Init\n');
      print(
        'Usage: dart run store_screenshots_generator:init [arguments]\n',
      );
      print(parser.usage);
      exit(0);
    }

    final hostRoot = Directory(results['root'] as String).absolute.path;
    final force = results['force'] as bool;

    final written = ProjectScaffold.ensure(hostRoot: hostRoot, force: force);

    if (written.isEmpty) {
      print('Scaffold already present in $hostRoot (use --force to replace).');
    } else {
      print('Scaffolded ${written.length} file(s) in $hostRoot:');
      for (final path in written) {
        print('  + $path');
      }
      print('');
      print('Next steps:');
      print('  1. Edit test/raw_screenshots_test.dart (routes + capture ids)');
      print('  2. dart run store_screenshots_generator:capture_raw');
      print('  3. Layout Studio → design slots → export');
    }
  } on ArgParserException catch (e) {
    print(e.message);
    print(parser.usage);
    exit(1);
  } catch (e, st) {
    print('Error: $e');
    print(st);
    exit(1);
  }
}
