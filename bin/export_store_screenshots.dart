import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:yaml/yaml.dart';

import 'scaffold_util.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'config',
      abbr: 'c',
      help: 'Path to screenshots.yaml.',
      defaultsTo: 'screenshots.yaml',
    )
    ..addOption(
      'root',
      help: 'Host Flutter project root (defaults to config file directory).',
    )
    ..addOption(
      'test-file',
      abbr: 't',
      help: 'Path to the store export test file.',
      defaultsTo: 'test/store_screenshots_test.dart',
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
      print('Store Screenshots Generator - Store Export\n');
      print(
        'Usage: dart run store_screenshots_generator:export_store_screenshots [arguments]\n',
      );
      print(parser.usage);
      exit(0);
    }

    final configPath = results['config'] as String;
    final rootArg = results['root'] as String?;
    final testFile = results['test-file'] as String;

    final configFile = File(configPath);
    final hostRoot = rootArg != null && rootArg.isNotEmpty
        ? File(rootArg).absolute.path
        : configFile.existsSync()
        ? configFile.parent.absolute.path
        : findFlutterProjectRoot(Directory.current.path);

    ensureScaffoldIfNeeded(hostRoot);

    if (!configFile.existsSync()) {
      final configInHost = File(
        '$hostRoot${Platform.pathSeparator}${configFile.uri.pathSegments.last}',
      );
      if (!configInHost.existsSync()) {
        print('Error: Config file not found at $configPath');
        exit(1);
      }
    }

    final configInHost = File(
      '$hostRoot${Platform.pathSeparator}${File(configPath).uri.pathSegments.last}',
    );

    final configStr = await configInHost.readAsString();
    final doc = loadYamlDocument(configStr).contents.value as YamlMap;

    final devices =
        (doc['devices'] as YamlList?)?.map((e) => e.toString()).toList() ??
        [];
    final locales =
        (doc['locales'] as YamlList?)?.map((e) => e.toString()).toList() ??
        [];

    if (devices.isEmpty || locales.isEmpty) {
      print('Error: No devices or locales defined in screenshots.yaml.');
      exit(1);
    }

    final testFileAbsolute = File(
      '$hostRoot${Platform.pathSeparator}$testFile',
    ).absolute.path;
    if (!File(testFileAbsolute).existsSync()) {
      print('Error: Test file not found at $testFileAbsolute');
      exit(1);
    }

    print(
      'Exporting ${devices.length} devices × ${locales.length} locales from $hostRoot',
    );

    for (final device in devices) {
      for (final locale in locales) {
        print('\nExporting device: $device, locale: $locale...');

        final process = await Process.start(
          'flutter',
          [
            'test',
            testFileAbsolute,
            '--dart-define=DEVICE=$device',
            '--dart-define=LOCALE=$locale',
          ],
          workingDirectory: hostRoot,
          runInShell: true,
        );

        process.stdout.transform(utf8.decoder).listen(stdout.write);
        process.stderr.transform(utf8.decoder).listen(stderr.write);

        final exitCode = await process.exitCode;
        if (exitCode == 0) {
          print('Export success for $device ($locale)');
        } else {
          print('Export failed for $device ($locale) with exit code $exitCode');
          exit(exitCode);
        }
      }
    }

    print('\nAll store screenshots exported.');
  } on ArgParserException catch (e) {
    print(e.message);
    print(parser.usage);
    exit(1);
  } catch (e, st) {
    print('An unexpected error occurred: $e');
    print(st);
    exit(1);
  }
}
