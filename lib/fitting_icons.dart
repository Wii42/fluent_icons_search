import 'package:fluent_ui/fluent_ui.dart';

import 'gen/fluent_icon_collection.g.dart';

class FittingIcons {
  FittingIcons._();

  static Map<String, IconData> fittingIcons(String filter) {
    return Map.of(FluentIcons.allIcons)
      ..addAll(FluentIconCollection.asMap)
      ..removeWhere((key, value) => !matches(key, filter));
  }

  static bool matches(String key, String filter) =>
      canonicalize(key).contains(canonicalize(filter));

  static String canonicalize(String key) =>
      key.toLowerCase().replaceAll(RegExp(r'[\s-_]'), '');
}
