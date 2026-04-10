import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_screenshots_generator/src/registry/template_registry.dart';

void main() {
  group('TemplateRegistry', () {
    test('register and build should work', () {
      bool builderCalled = false;
      
      TemplateRegistry.register('test_tmpl', (vars) {
        builderCalled = true;
        expect(vars['title'], 'Hello');
        return Container();
      });

      final widget = TemplateRegistry.build('test_tmpl', {'title': 'Hello'});
      
      expect(widget, isA<Container>());
      expect(builderCalled, true);
    });

    test('build should throw exception for unknown template', () {
      expect(
        () => TemplateRegistry.build('non_existent', {}),
        throwsException,
      );
    });

    test('register should overwrite existing template', () {
      TemplateRegistry.register('dupe', (vars) => Container(key: const ValueKey('1')));
      TemplateRegistry.register('dupe', (vars) => Container(key: const ValueKey('2')));

      final widget = TemplateRegistry.build('dupe', {});
      expect((widget as Container).key, const ValueKey('2'));
    });
  });
}
