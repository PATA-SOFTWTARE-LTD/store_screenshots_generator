import 'dart:io';

class HeadlessRunner {
  final String configPath;

  HeadlessRunner({required this.configPath});

  Future<bool> generateScreenshots() async {
    // 1. We create the temporary directory to hold outputs if doesn't exist.
    final outputDir = Directory('output');
    if (!outputDir.existsSync()) {
      outputDir.createSync();
    }

    // 2. Generate the dynamic test file
    final testContent = buildScaffoldedTestFile();
    
    final testDir = Directory('test');
    if (!testDir.existsSync()) testDir.createSync();
    
    final testFile = File('test/temp_render_test.dart');
    await testFile.writeAsString(testContent);

    print('Generated test runner script. Invoking Flutter Test...');

    // 3. Shell out to flutter test
    final process = await Process.start(
      'flutter',
      ['test', 'test/temp_render_test.dart'],
      mode: ProcessStartMode.inheritStdio,
      runInShell: Platform.isWindows,
    );
    
    final exitCode = await process.exitCode;
    
    // 4. (Optional) Cleanup the temp test file
    if (testFile.existsSync()) {
      testFile.deleteSync();
    }

    return exitCode == 0;
  }

  String buildScaffoldedTestFile() {
    final targetConfigPath = configPath.replaceAll(r'\', '/');
    return '''
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

import 'package:store_screenshots_generator/src/config/models/device_spec.dart';
import 'package:store_screenshots_generator/src/config/models/screenshot_config.dart';
import 'package:store_screenshots_generator/src/registry/template_registry.dart';
import 'package:store_screenshots_generator/src/registry/templates/default_template.dart';
import 'package:store_screenshots_generator/src/registry/templates/device_frame_template.dart';

Future<void> main() async {
  // Manual registration for the test environment
  TemplateRegistry.register('default', defaultTemplate);
  TemplateRegistry.register('device_frame', deviceFrameTemplate);
  
  // Load actual config
  final configPath = '$targetConfigPath';
  final configFile = File(configPath);
  
  ProjectConfig config;
  if (configFile.existsSync() && configPath.endsWith('.yaml')) {
    final yamlString = configFile.readAsStringSync();
    final yamlMap = loadYaml(yamlString) as YamlMap;
    
    Map<String, dynamic> convertYamlMap(YamlMap map) {
      final Map<String, dynamic> result = {};
      for (final key in map.keys) {
        final value = map[key];
        if (value is YamlMap) {
          result[key.toString()] = convertYamlMap(value);
        } else if (value is YamlList) {
          result[key.toString()] = value.map((e) {
            if (e is YamlMap) return convertYamlMap(e);
            return e;
          }).toList();
        } else {
          result[key.toString()] = value;
        }
      }
      return result;
    }

    final jsonMap = convertYamlMap(yamlMap);
    config = ProjectConfig.fromJson(jsonMap);
  } else {
    config = ProjectConfig.mock;
    print('Warning: Config not found or invalid. Using mock configuration.');
  }

  // --- FONT LOADING ---
  String? fontFamily;
  final fontPath = config.fontPath ?? (Platform.isWindows ? 'C:/Windows/Fonts/arial.ttf' : null);
  if (fontPath != null && File(fontPath).existsSync()) {
    fontFamily = 'CustomFont';
    final fontData = File(fontPath).readAsBytesSync();
    final loader = FontLoader(fontFamily);
    loader.addFont(Future.value(fontData.buffer.asByteData()));
    await loader.load();
    print('Loaded font from: \$fontPath');
  }

  for (final deviceId in config.devices) {
    // Determine device resolution
    final device = DeviceRegistry.getById(deviceId);
    final surfaceSize = device.resolution;

    for (final locale in config.locales) {
      for (final screen in config.screens) {
        testWidgets('Generate screenshot \${screen.id} for \$locale on \$deviceId', (WidgetTester tester) async {
          // Resolve localization for variables
          final vars = <String, dynamic>{};
          for (final entry in screen.variables.entries) {
            if (entry.value is Map) {
               // Extract the value for current locale
               final mapVal = entry.value as Map;
               vars[entry.key] = mapVal[locale] ?? mapVal.values.first; // fallback to first if locale not found
            } else {
               vars[entry.key] = entry.value;
            }
          }
          
          if (fontFamily != null) vars['fontFamily'] = fontFamily;
          vars['deviceId'] = deviceId;
          
          final imagePath = '\${config.rawScreenshotsPath}/\$locale/\$deviceId/\${screen.id}.png';
          vars['imagePath'] = imagePath;

          tester.view.physicalSize = surfaceSize;
          tester.view.devicePixelRatio = 1.0;
          
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          final widget = TemplateRegistry.build(screen.templateName, vars);
          final repaintBoundaryKey = GlobalKey();

          // Wrap in a layout builder to have a context for precaching
          final app = Directionality(
            textDirection: TextDirection.ltr,
            child: MediaQuery(
              data: MediaQueryData(size: surfaceSize),
              child: RepaintBoundary(
                key: repaintBoundaryKey,
                child: SizedBox(
                  width: surfaceSize.width,
                  height: surfaceSize.height,
                  child: widget,
                ),
              ),
            ),
          );

          // --- PRECACHE IMAGES ---
          await tester.runAsync(() async {
            await tester.pumpWidget(app);
            
            // Precache screenshot image
            if (File(imagePath).existsSync()) {
              final provider = FileImage(File(imagePath));
              await precacheImage(provider, tester.element(find.byKey(repaintBoundaryKey)));
            } else {
              print('Warning: Raw screenshot not found at \$imagePath');
            }

            // Precache frame image
            if (device.frameAsset != null && File(device.frameAsset!).existsSync()) {
              final frameProvider = FileImage(File(device.frameAsset!));
              await precacheImage(frameProvider, tester.element(find.byKey(repaintBoundaryKey)));
            }
          });
          
          await tester.pumpAndSettle();
          
          // Capture image and write to disk outside the fake async zone
          await tester.runAsync(() async {
            final boundary = repaintBoundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
            final image = await boundary.toImage(pixelRatio: 1.0);
            final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
            final uint8list = byteData!.buffer.asUint8List();
            image.dispose();

            final dir = Directory('output/\$locale/\$deviceId');
            if (!dir.existsSync()) dir.createSync(recursive: true);
            
            final file = File('\${dir.path}/\${screen.id}.png');
            await file.writeAsBytes(uint8list);
            print('Exported: \${file.path}');
          });
        });
      }
    }
  }
}
''';
  }
}
