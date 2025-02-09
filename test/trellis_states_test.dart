import 'package:test/test.dart';
import 'dart:io';
import '../src/types/grammar.dart';
import '../src/types/state.dart';
import '../src/types/trellis_automaton.dart';

void main() async {
  var path = '${Directory.systemTemp.path}/input2.txt';
  var tempFile = File(path);

  await tempFile.writeAsString(
      "S -> K a & a R \nK -> a A | K a \nP -> a A \nA -> P b | b\nR -> B a | a R \nQ -> B a \nB -> b Q | b ");

  var grammar = Grammar();
  grammar.loadFromFile(path);

  var trellis = TrellisAutomaton.build(grammar);

  group('Проверка корректности получения множества состояний', () {
    test('Грамматика Охотина (ita 2004)', () {
      var q0 = State.create('a', {}, 'a');
      var q1 = State.create('a', {}, 'b');
      var q2 = State.create('a', {'S', 'K', 'R'}, 'a');
      var q3 = State.create('a', {'K'}, 'a');
      var q4 = State.create('a', {'K', 'P'}, 'b');
      var q5 = State.create('a', {'K', 'P', 'A'}, 'b');
      var q6 = State.create('a', {'A'}, 'b');
      var q7 = State.create('a', {'R'}, 'a');
      var q8 = State.create('b', {}, 'a');
      var q9 = State.create('b', {}, 'b');
      var q10 = State.create('b', {'A', 'B'}, 'b');
      var q11 = State.create('b', {'R', 'Q'}, 'a');
      var q12 = State.create('b', {'R', 'Q', 'B'}, 'a');
      var q13 = State.create('b', {'B'}, 'a');

      var expected_set = {
        q0,
        q1,
        q2,
        q3,
        q4,
        q5,
        q6,
        q7,
        q8,
        q9,
        q10,
        q11,
        q12,
        q13
      };

      expect(
          true,
          trellis.states.containsAll(expected_set) &&
              trellis.states.length == expected_set.length);
    });
  });
  await tempFile.delete();
}
