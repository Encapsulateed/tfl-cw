import 'package:test/test.dart';

import '../src/types/rule.dart';

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
}
