import 'models/composition.dart';
import 'models/composition_key.dart';
import 'models/element_type.dart';

/// Keeps per-locale title strings in sync with [ProjectConfig.locales].
class CompositionLocaleText {
  static Map<String, Composition> applyLocaleList({
    required Map<String, Composition> compositions,
    required List<String> locales,
    required Map<String, String> slotNamesById,
  }) {
    if (locales.isEmpty) return compositions;

    final updated = Map<String, Composition>.from(compositions);
    for (final entry in updated.entries.toList()) {
      final parsed = CompositionKey.parseMapKey(entry.key);
      if (parsed == null || !parsed.isLocaleAgnostic) continue;
      updated[entry.key] = extendLocaleTexts(
        entry.value,
        locales: locales,
        defaultText: slotNamesById[parsed.slotId] ?? parsed.slotId,
      );
    }
    return updated;
  }

  static Composition extendLocaleTexts(
    Composition composition, {
    required List<String> locales,
    required String defaultText,
  }) {
    final localeSet = locales.toSet();
    final elements = composition.elements.map((element) {
      if (element.type != ElementType.text) return element;
      final textMap = Map<String, String>.from(
        (element.properties['text'] as Map?)?.map(
              (k, v) => MapEntry(k.toString(), v.toString()),
            ) ??
            {},
      );
      final fallback = textMap.values.firstOrNull ?? defaultText;
      for (final locale in locales) {
        textMap.putIfAbsent(locale, () => fallback);
      }
      textMap.removeWhere((k, _) => !localeSet.contains(k));
      return element.copyWith(properties: {...element.properties, 'text': textMap});
    }).toList();
    return composition.copyWith(elements: elements);
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}
