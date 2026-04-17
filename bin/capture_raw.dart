import 'dart:io';
import 'dart:convert';
import 'package:args/args.dart';
import 'package:yaml/yaml.dart';

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
      'status-bar',
      help: 'Include a simulated status bar (time, wifi, battery) in the capture.',
      defaultsTo: true,
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
    final includeStatusBar = results['status-bar'] as bool;

    final configFile = File(configPath);
    if (!configFile.existsSync()) {
      print('Error: Config file not found at $configPath');
      exit(1);
    }

    final configStr = await configFile.readAsString();
    final doc = loadYamlDocument(configStr).contents.value as YamlMap;

    final devicesNodes = doc['devices'] as YamlList?;
    final localesNodes = doc['locales'] as YamlList?;

    final devices = devicesNodes?.map((e) => e.toString()).toList() ?? [];
    final locales = localesNodes?.map((e) => e.toString()).toList() ?? [];

    if (devices.isEmpty || locales.isEmpty) {
      print(
        'Warning: No devices or locales defined in $configPath. Check your configuration.',
      );
      exit(1);
    }

    final testFileAbsolute = File(testFile).absolute.path;
    final packageRoot = _findPackageRoot(testFileAbsolute);

    print(
      'Discovered ${devices.length} devices and ${locales.length} locales. Beginning raw capture...',
    );

    for (final device in devices) {
      for (final locale in locales) {
        print('\n🚀 Capturing for device: $device, locale: $locale...');

        // Eseguiamo il comando dal package root del test
        final process = await Process.start(
          'flutter',
          [
            'test',
            testFileAbsolute,
            '--dart-define=DEVICE=$device',
            '--dart-define=LOCALE=$locale',
            '--dart-define=INCLUDE_STATUS_BAR=$includeStatusBar',
          ],
          workingDirectory: packageRoot,
          runInShell: true,
        );

        // Pipe stdout and stderr
        process.stdout.transform(utf8.decoder).listen(stdout.write);
        process.stderr.transform(utf8.decoder).listen(stderr.write);

        final exitCode = await process.exitCode;

        if (exitCode == 0) {
          print('✅ Capture success for $device ($locale)');
        } else {
          print('❌ Capture failed for $device ($locale) with exit code $exitCode');
        }
      }
    }

    print('\n🎉 All captures completed.');
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

String _findPackageRoot(String testFilePath) {
  var currentDir = Directory(testFilePath).parent;

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

  return Directory.current.path;
}
