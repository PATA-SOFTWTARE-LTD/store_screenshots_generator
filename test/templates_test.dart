import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:store_screenshots_generator/src/registry/templates/default_template.dart';

void main() {
  group('DefaultTemplate', () {
    testWidgets('renders title and subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(
        defaultTemplate({
          'title': 'Test Title',
          'subtitle': 'Test Subtitle',
          'backgroundColor': '#FF0000',
        }),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Subtitle'), findsOneWidget);
      
      final container = tester.widget<Container>(find.byType(Container));
      expect((container.decoration as BoxDecoration?)?.color ?? container.color, const Color(0xFFFF0000));
    });

    testWidgets('renders defaults when variables missing', (WidgetTester tester) async {
      await tester.pumpWidget(
        defaultTemplate({}),
      );

      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Subtitle'), findsOneWidget);
    });
  });
}
