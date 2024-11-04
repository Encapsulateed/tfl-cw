import 'package:test/test.dart';
import 'dart:io';
import '../src/types/grammar.dart';
import '../src/types/state.dart';
import '../src/types/trellis_automaton.dart';

void main() async {
  var tempFile = File('${Directory.systemTemp.path}/input1.txt');

  await tempFile.writeAsString(
      "S -> K a & a R \nK -> a A | K a \nP -> a A \nA -> P b | b\nR -> B a | a R \nQ -> B a \nB -> b Q | b ");

  var grammar = Grammar.fromFile(tempFile);

  var trellis = TrellisAutomaton.build(grammar);
  group('Работа функции Init', () {
    test('1', () {
      var init = trellis.Init('a');

      var q = State.create('a', {}, 'a');

      expect(true, init == q);
    });

    test('2', () {
      var init = trellis.Init('b');

      var q = State.create('b', {'A', 'B'}, 'b');

      expect(true, init == q);
    });
  });

  group('Тестирование функции Transition', () {
    test('1', () {
      var q1 = State.create('a', {}, 'a');
      var q2 = State.create('b', {'A', 'B'}, 'b');

      var expected = State.create('a', {'K', 'P'}, 'b');
      expect(true, trellis.Transition(q1, q2) == expected);
    });

    test('2', () {
      var q1 = State.create('a', {}, 'a');
      var q2 = State.create('b', {'A', 'B'}, 'b');

      var expected = State.create('b', {'R', 'Q'}, 'a');
      expect(true, trellis.Transition(q2, q1) == expected);
    });

    test('3', () {
      var q1 = State.create('a', {'K', 'P'}, 'b');
      var q2 = State.create('a', {'S', 'K', 'R'}, 'a');

      var expected = q2;
      expect(true, trellis.Transition(q1, q2) == expected);
    });

    test('4', () {
      var q1 = State.create('b', {'R', 'Q'}, 'a');
      var q2 = State.create('b', {'R', 'Q', 'B'}, 'a');

      var expected = State.create('b', {'B'}, 'a');
      expect(true, trellis.Transition(q1, q2) == expected);
    });

    test('5', () {
      var q1 = State.create('a', {'K', 'P'}, 'b');
      var q2 = State.create('b', {'A', 'B'}, 'b');

      var expected = State.create('a', {'K', 'P', 'A'}, 'b');
      expect(true, trellis.Transition(q1, q2) == expected);
    });
  });

  await tempFile.delete();
}
