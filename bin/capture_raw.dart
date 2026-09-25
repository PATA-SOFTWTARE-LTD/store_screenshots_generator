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
      help: 'Path to the screenshots configuration file (YAML/JSON).',
      defaultsTo: 'screenshots.yaml',
    )
    ..addOption(
      'test-file',
      abbr: 't',
      help: 'Path to the test file to execute.',
      defaultsTo: 'test/raw_screenshots_test.dart',
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
      print('Store Screenshots Generator - Raw Capture\n');
      print(
        'Usage: dart run store_screenshots_generator:capture_raw [arguments]\n',
      );
      print(parser.usage);
      exit(0);
    }

    final configPath = results['config'] as String;
    final testFile = results['test-file'] as String;

    final packageRoot = findFlutterProjectRoot(Directory.current.path);
    ensureScaffoldIfNeeded(packageRoot);

    final configFile = File(configPath);
    final configInHost = File(
      '$packageRoot${Platform.pathSeparator}${File(configPath).uri.pathSegments.last}',
    );
    final configToRead = configFile.existsSync()
        ? configFile
        : configInHost.existsSync()
        ? configInHost
        : configFile;

    if (!configToRead.existsSync()) {
      print('Error: Config file not found at $configPath');
      exit(1);
    }

    final configStr = await configToRead.readAsString();
    final doc = loadYamlDocument(configStr).contents.value as YamlMap;

    final devicesNodes = doc['devices'] as YamlList?;
    final localesNodes = doc['locales'] as YamlList?;
    final statusBarRaw = doc['statusBar']?.toString();

    final devices = devicesNodes?.map((e) => e.toString()).toList() ?? [];
    final locales = localesNodes?.map((e) => e.toString()).toList() ?? [];
    final statusBarMode = _parseStatusBarMode(statusBarRaw);

    if (devices.isEmpty || locales.isEmpty) {
      print(
        'Warning: No devices or locales defined in $configPath. Check your configuration.',
      );
      exit(1);
    }

    final testFileAbsolute = File(testFile).existsSync()
        ? File(testFile).absolute.path
        : File(
            '$packageRoot${Platform.pathSeparator}$testFile',
          ).absolute.path;

    if (!File(testFileAbsolute).existsSync()) {
      print('Error: Test file not found at $testFileAbsolute');
      exit(1);
    }

    print(
      'Discovered ${devices.length} devices and ${locales.length} locales. Beginning raw capture...',
    );

    for (final device in devices) {
      for (final locale in locales) {
        print('\nCapturing for device: $device, locale: $locale...');

        final process = await Process.start(
          'flutter',
          [
            'test',
            testFileAbsolute,
            '--dart-define=DEVICE=$device',
            '--dart-define=LOCALE=$locale',
            '--dart-define=STATUS_BAR_MODE=$statusBarMode',
          ],
          workingDirectory: packageRoot,
          runInShell: true,
        );

        process.stdout.transform(utf8.decoder).listen(stdout.write);
        process.stderr.transform(utf8.decoder).listen(stderr.write);

        final exitCode = await process.exitCode;

        if (exitCode == 0) {
          print('Capture success for $device ($locale)');
        } else {
          print('Capture failed for $device ($locale) with exit code $exitCode');
        }
      }
    }

    print('\nAll captures completed.');
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

String _parseStatusBarMode(String? value) {
  if (value == null || value.trim().isEmpty) {
    throw FormatException(
      'Missing required "statusBar" in YAML config. Use one of: hidden, light, dark.',
    );
  }

  switch (value.trim().toLowerCase()) {
    case 'light':
      return 'light';
    case 'dark':
      return 'dark';
    case 'hidden':
      return 'hidden';
    default:
      throw FormatException(
        'Invalid "statusBar": "$value". Valid values: hidden, light, dark.',
      );
  }
}
