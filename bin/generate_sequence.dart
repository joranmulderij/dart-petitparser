import 'dart:io';

/// Number of parsers that can be combined.
final int min = 2;
final int max = 9;

/// Export file.
final File exportFile = File('lib/src/parser/combinator/sequence_map.dart');

/// Implementation file.
File implementationFile(int i) =>
    File('lib/src/parser/combinator/generated/sequence_$i.dart');

/// Test file.
final File testFile = File('test/generated/sequence_test.dart');

/// Pretty prints and cleans up a dart file.
Future<void> format(File file) async =>
    Process.run('dart', ['format', '--fix', file.absolute.path]);

/// Generate the variable names.
List<String> generateValues(String prefix, int i) =>
    List.generate(i, (i) => '$prefix${i + 1}');

void generateWarning(StringSink out) {
  out.writeln('// AUTO-GENERATED CODE: DO NOT EDIT');
  out.writeln();
}

Future<void> generateExport() async {
  final file = exportFile;
  final out = file.openWrite();
  generateWarning(out);
  for (var i = min; i <= max; i++) {
    out.writeln('export \'generated/sequence_$i.dart\';');
  }
  await out.close();
  await format(file);
}

Future<void> generateImplementation(int index) async {
  final file = implementationFile(index);
  final out = file.openWrite();
  final parserNames = generateValues('parser', index);
  final resultTypes = generateValues('R', index);
  final resultNames = generateValues('result', index);
  final valueTypes = generateValues('T', index);
  final valueNames = generateValues('value', index);

  generateWarning(out);
  out.writeln('import \'package:meta/meta.dart\';');
  out.writeln();
  out.writeln('import \'../../../context/context.dart\';');
  out.writeln('import \'../../../context/result.dart\';');
  out.writeln('import \'../../../core/parser.dart\';');
  out.writeln('import \'../../action/map.dart\';');
  out.writeln('import \'../../utils/sequential.dart\';');
  out.writeln();

  // Constructor function
  out.writeln('/// Creates a parser that consumes a sequence of $index parsers '
      'and returns a ');
  out.writeln('/// typed sequence [Sequence$index].');
  out.writeln('Parser<Sequence$index<${resultTypes.join(', ')}>> '
      'seq$index<${resultTypes.join(', ')}>(');
  for (var i = 0; i < index; i++) {
    out.writeln('Parser<${resultTypes[i]}> ${parserNames[i]},');
  }
  out.writeln(') => SequenceParser$index<${resultTypes.join(', ')}>(');
  for (var i = 0; i < index; i++) {
    out.writeln('${parserNames[i]},');
  }
  out.writeln(');');
  out.writeln();

  // Parser implementation.
  out.writeln('/// A parser that consumes a sequence of $index typed parsers '
      'and returns a typed ');
  out.writeln('/// sequence [Sequence$index].');
  out.writeln('class SequenceParser$index<${resultTypes.join(', ')}> '
      'extends Parser<Sequence$index<${resultTypes.join(', ')}>> '
      'implements SequentialParser {');
  out.writeln('SequenceParser$index('
      '${parserNames.map((each) => 'this.$each').join(', ')});');
  out.writeln();
  for (var i = 0; i < index; i++) {
    out.writeln('Parser<${resultTypes[i]}> ${parserNames[i]};');
  }
  out.writeln();
  out.writeln('@override');
  out.writeln('Result<Sequence$index<${resultTypes.join(', ')}>> '
      'parseOn(Context context) {');
  for (var i = 0; i < index; i++) {
    out.writeln('final ${resultNames[i]} = ${parserNames[i]}'
        '.parseOn(${i == 0 ? 'context' : resultNames[i - 1]});');
    out.writeln('if (${resultNames[i]}.isFailure) '
        'return ${resultNames[i]}.failure(${resultNames[i]}.message);');
  }
  out.writeln('return ${resultNames[index - 1]}.success('
      'Sequence$index<${resultTypes.join(', ')}>'
      '(${resultNames.map((each) => '$each.value').join(', ')}));');
  out.writeln('}');
  out.writeln();
  out.writeln('@override');
  out.writeln('int fastParseOn(String buffer, int position) {');
  for (var i = 0; i < index; i++) {
    out.writeln('position = ${parserNames[i]}.fastParseOn(buffer, position);');
    out.writeln('if (position < 0) return -1;');
  }
  out.writeln('return position;');
  out.writeln('}');
  out.writeln();
  out.writeln('@override');
  out.writeln('List<Parser> get children => [${parserNames.join(', ')}];');
  out.writeln();
  out.writeln('@override');
  out.writeln('void replace(Parser source, Parser target) {');
  out.writeln('super.replace(source, target);');
  for (var i = 0; i < index; i++) {
    out.writeln('if (${parserNames[i]} == source) '
        '${parserNames[i]} = target as Parser<${resultTypes[i]}>;');
  }
  out.writeln('}');
  out.writeln();
  out.writeln('@override');
  out.writeln('SequenceParser$index<${resultTypes.join(', ')}> copy() => '
      'SequenceParser$index<${resultTypes.join(', ')}>'
      '(${parserNames.join(', ')});');
  out.writeln('}');
  out.writeln();

  /// Data class implementation.
  out.writeln('/// Immutable typed sequence with $index values.');
  out.writeln('@immutable');
  out.writeln('class Sequence$index<${valueTypes.join(', ')}> {');
  out.writeln('Sequence$index('
      '${valueNames.map((each) => 'this.$each').join(', ')});');
  out.writeln();
  for (var i = 0; i < index; i++) {
    out.writeln('final ${valueTypes[i]} ${valueNames[i]};');
  }
  out.writeln();
  out.writeln('@override');
  out.writeln('int get hashCode => Object.hash(${valueNames.join(', ')});');
  out.writeln();
  out.writeln('@override');
  out.writeln('bool operator ==(Object other) => '
      'other is Sequence$index<${valueTypes.join(', ')}> && '
      '${valueNames.map((each) => '$each == other.$each').join(' && ')};');
  out.writeln();
  out.writeln('@override');
  out.writeln('String toString() => \'\${super.toString()}'
      '(${valueNames.map((each) => '\$$each').join(', ')})\';');
  out.writeln('}');
  out.writeln();

  // Mapping extension.
  out.writeln(
      'extension ParserSequenceExtension$index<${valueTypes.join(', ')}>'
      ' on Parser<Sequence$index<${valueTypes.join(', ')}>> {');
  out.writeln('/// Maps a typed sequence to [R] using the provided [callback].');
  out.writeln(
      'Parser<R> map$index<R>(R Function(${valueTypes.join(', ')}) callback) => '
      'map((sequence) => callback(${valueNames.map((each) => 'sequence.$each').join(', ')}));');
  out.writeln('}');
  out.writeln();

  await out.close();
  await format(file);
}

Future<void> generateTest() async {
  final file = testFile;
  final out = file.openWrite();
  generateWarning(out);
  out.writeln('import \'package:petitparser/petitparser.dart\';');
  out.writeln('import \'package:test/test.dart\';');
  out.writeln();
  out.writeln('import \'../utils/assertions.dart\';');
  out.writeln('import \'../utils/matchers.dart\';');
  out.writeln();
  out.writeln('void main() {');
  for (var i = min; i <= max; i++) {
    final chars =
        List.generate(i, (i) => String.fromCharCode('a'.codeUnitAt(0) + i));
    final string = chars.join();
    out.writeln('group(\'seqMap$i\', () {');
    out.writeln('final parser = seq$i('
        '${chars.map((each) => 'char(\'$each\')').join(',')});');
    out.writeln('expectParserInvariants(parser);');
    out.writeln('test(\'success\', () {');
    out.writeln('final mappedParser = parser.map$i((${chars.join(',')}) => '
        '\'${chars.map((each) => '\$$each').join()}\');');
    out.writeln(
        'expect(mappedParser, isParseSuccess(\'$string\', \'$string\'));');
    out.writeln(
        'expect(mappedParser, isParseSuccess(\'$string*\', \'$string\', position: $i));');
    out.writeln('});');
    for (var j = 0; j < i; j++) {
      out.writeln('test(\'failure at $j\', () {');
      out.writeln('expect(parser, isParseFailure(\''
          '${string.substring(0, j)}\', '
          'message: \'"${chars[j]}" expected\', '
          'position: $j));');
      out.writeln('expect(parser, isParseFailure(\''
          '${string.substring(0, j)}*\', '
          'message: \'"${chars[j]}" expected\', '
          'position: $j));');
      out.writeln('});');
    }
    out.writeln('});');
  }
  out.writeln('}');
  await out.close();
  await format(file);
}

Future<void> main() => Future.wait([
      generateExport(),
      for (var i = min; i <= max; i++) generateImplementation(i),
      generateTest(),
    ]);
