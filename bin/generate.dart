import 'dart:io';
import 'package:args/args.dart';
import 'package:store_screenshots_generator/src/cli/command_runner.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'config',
      abbr: 'c',
      help: 'Path to the screenshots configuration file (YAML/JSON).',
      defaultsTo: 'screenshots.yaml',
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
      print('Store Screenshots Generator\n');
      print('Usage: dart run store_screenshots_generator:generate [arguments]\n');
      print(parser.usage);
      exit(0);
    }

    final configPath = results['config'] as String;
    
    // Delegate to the main runner
    await runConfigGeneration(configPath);
    
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
