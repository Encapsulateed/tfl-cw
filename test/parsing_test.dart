import 'package:test/test.dart';
import 'dart:io';
import '../src/types/grammar.dart';
import '../src/types/parsing_tree/tree.dart';
import '../src/types/trellis_automaton.dart';

void main() async {
  var ita_grammar = File('${Directory.systemTemp.path}/ita_grammar.txt');

  await ita_grammar.writeAsString(
      "S -> K a & a R \nK -> a A | K a \nP -> a A \nA -> P b | b\nR -> B a | a R \nQ -> B a \nB -> b Q | b ");

  var grammar = Grammar.fromFile(ita_grammar);

  var trellis = TrellisAutomaton.build(grammar);

  bool explanation = false;
  group('Грамматика Охотина (ita)', () {
    test('aba', () {
      var tree = ParsingTree.create('aba', trellis, explanation);

      expect(true, tree.isRecognizing());
    });

    test('abba', () {
      var tree = ParsingTree.create('abba', trellis, explanation);

      expect(false, tree.isRecognizing());
    });

    test('aabbbaaa', () {
      var tree = ParsingTree.create('aabbbaaa', trellis, explanation);

      expect(false, tree.isRecognizing());
    });

    test('aaaaaaaaaabbbbbbbbbbaaaaaaaaaa', () {
      var tree = ParsingTree.create(
          'aaaaaaaaaabbbbbbbbbbaaaaaaaaaa', trellis, explanation);

      expect(true, tree.isRecognizing());
    });
  });

  await ita_grammar.delete();
}
