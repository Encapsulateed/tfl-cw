import 'package:test/test.dart';

import '../src/types/rule.dart';
import '../src/types/state.dart';

void main() {
  group('Тестирование выводимости w из правила', () {
    test('Выводимо', () {
      var rule = Rule('A', [
        ['w']
      ]);

      expect(true, rule.deducible('w'));
    });

    test('Невыводимо', () {
      var rule = Rule('A', [
        ['w']
      ]);

      expect(false, rule.deducible('c'));
    });

    test('Невыводимо по длинне правила', () {
      var rule = Rule('A', [
        ['w']
      ]);

      expect(false, rule.deducible('c'));
    });
  });

  group('Тестирование сложных выводов из правила', () {
    test('Выводимо', () {
      var q1 = State.create('b', {'X'}, 'x');
      var q2 = State.create('z', {'Y'}, 'c');

      var rule = Rule('A', [
        ['b', 'Y'],
        ['X', 'c']
      ]);

      expect(true, rule.applicableForTransition(q1, q2));
    });
    test('Выводимо', () {
      var q1 = State.create('x', {'X', 'Y', 'Z'}, 'y');
      var q2 = State.create('w', {'W', 'V', 'G', 'P', 'Z'}, 'z');

      var rule = Rule('A', [
        ['x', 'W'],
        ['x', 'V'],
        ['x', 'G'],
        ['x', 'P'],
        ['x', 'Z'],
        ['Z', 'w'],
        ['X', 'w'],
        ['Y', 'w'],
      ]);

      expect(true, rule.applicableForTransition(q1, q2));
    });
  });
}
