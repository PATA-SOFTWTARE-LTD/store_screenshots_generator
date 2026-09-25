import 'package:yaml/yaml.dart';

import 'models/screenshot_config.dart';

dynamic convertYamlNode(dynamic node) {
  if (node is YamlMap) {
    return node.map(
      (key, value) => MapEntry(key.toString(), convertYamlNode(value)),
    );
  }
  if (node is YamlList) {
    return node.map(convertYamlNode).toList();
  }
  return node;
}

ProjectConfig loadProjectConfigFromYaml(String yamlString) {
  final yamlMap = loadYaml(yamlString);
  if (yamlMap is! YamlMap) {
    throw FormatException('Root YAML must be a map');
  }
  final jsonMap = convertYamlNode(yamlMap) as Map<String, dynamic>;
  return ProjectConfig.fromJson(jsonMap);
}
