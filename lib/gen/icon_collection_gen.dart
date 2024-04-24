import 'dart:io';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/syntactic_entity.dart';
import 'package:package_config/package_config.dart';
import 'package:path/path.dart' as path;

void main() async {
  final String filePath =
      await getDependencyFilePath('fluentui_system_icons', 'fluent_icons.dart');
  final sourceCode = File(filePath).readAsStringSync();

  final ParseStringResult parseResult = parseString(content: sourceCode);
  final compilationUnit = parseResult.unit;

  final List<VariableDeclaration> staticConstVariables = [];

  for (CompilationUnitMember declaration in compilationUnit.declarations) {
    if (declaration is! ClassDeclaration) {
      continue;
    }
    for (ClassMember member in declaration.members) {
      staticConstVariables.addAll(_getVariablesInClassMember(member));
    }
  }
  final generatedCode = _generateCode(staticConstVariables);

  final outputPath = path.join('lib','gen', 'fluent_icon_collection.g.dart');
  File(outputPath).writeAsStringSync(generatedCode);

  print('Generated file: $outputPath');
}

Iterable<VariableDeclaration> _getVariablesInClassMember(ClassMember member) {
  List<VariableDeclaration> variables = [];
  VariableDeclarationList? variableList =
      _getStaticConstIconDataVariableFromMember(member);
  if (variableList == null) {
    return variables;
  }
  for (VariableDeclaration variable in variableList.variables) {
    variables.add(variable);
  }
  return variables;
}

VariableDeclarationList? _getStaticConstIconDataVariableFromMember(
    ClassMember member) {
  if (member.firstTokenAfterCommentAndMetadata.toString() != 'static' ||
      member.childEntities.toList()[1].toString() != 'static' ||
      member.childEntities.toList().length < 3) {
    return null;
  }
  SyntacticEntity inner = member.childEntities.toList()[2];
  if (inner is! VariableDeclarationList) {
    return null;
  }
  if (!inner.isConst || inner.type.toString() != 'IconData') {
    return null;
  }
  return inner;
}

String _generateCode(List<VariableDeclaration> variables) {
  final buffer = StringBuffer();
  buffer.writeln(
      "import 'package:fluentui_system_icons/fluentui_system_icons.dart';");
  buffer.writeln("import 'package:flutter/widgets.dart';");
  buffer.writeln();
  buffer.writeln(
      '/// Auto-generated Utility class for [FluentIcons] from fluentui_system_icon package, for accessing all icons as a list or map.');
  buffer.writeln('extension FluentIconCollection on FluentIcons {');
  buffer.writeln('  // Generated code: do not hand-edit.\n');

  buffer.writeln('  /// List of all [FluentIcons] as [IconData].');
  buffer.writeln('  static const List<IconData> asList = [');
  for (var variable in variables) {
    String varName = variable.name.lexeme;
    buffer.writeln('    FluentIcons.$varName,');
  }
  buffer.writeln('  ];');

  buffer.writeln();
  buffer.writeln(
      '  /// Map of all [FluentIcons] as [IconData]. Key is the variable name.');
  buffer.writeln('  static const Map<String, IconData> asMap = {');
  for (var variable in variables) {
    String varName = variable.name.lexeme;
    buffer.writeln("    '$varName': FluentIcons.$varName,");
  }
  buffer.writeln('  };');
  buffer.writeln('}');

  return buffer.toString();
}

Future<String> getDependencyFilePath(
    String packageName, String relativeFilePath) async {
  // Get the package config
  final packageConfig = await findPackageConfig(Directory.current);

  // Find the package in the package config
  final package = packageConfig?.packages.firstWhere(
    (p) => p.name == packageName,
    orElse: () => throw Exception('Dependency not found in package config.'),
  );

  if (package != null) {
    // Construct the path to the file within the package
    final String packagePath = package.packageUriRoot.toFilePath();
    final filePath = File(path.join(packagePath, 'src', relativeFilePath));

    if (await filePath.exists()) {
      return filePath.path;
    } else {
      throw FileSystemException('File not found in dependency.', filePath.path);
    }
  } else {
    throw Exception('Dependency not found in package config.');
  }
}
