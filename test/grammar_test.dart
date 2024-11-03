import 'package:test/test.dart';
import 'dart:io';

import '../src/types/grammar.dart';

void main() {
  group('Тестирование корректности введения грамматик', () {
    test('Файловый ввод 1', () async {
      var tempFile = File('${Directory.systemTemp.path}/input.txt');
      await tempFile.writeAsString("S -> A a & B b\nA -> a\nB -> b");

      var grammar = Grammar.fromFile(tempFile);

      expect(grammar.nonTerminals, equals(List.from(['S', 'A', 'B'])));
      expect(grammar.terminals, equals(List.from(['a', 'b'])));

      expect(
          grammar.rules[0].conjuncts,
          equals(List<List<String>>.from([
            ['A', 'a'],
            ['B', 'b']
          ])));

      expect(
          grammar.rules[1].conjuncts,
          equals(List<List<String>>.from([
            ['a']
          ])));
      expect(
          grammar.rules[2].conjuncts,
          equals(List<List<String>>.from([
            ['b']
          ])));

      await tempFile.delete();
    });

    test('Файловый ввод 2', () async {
      var tempFile = File('${Directory.systemTemp.path}/input.txt');
      await tempFile.writeAsString(
          "S -> A a &                          B b\nA ->    a\n      B -> b");

      var grammar = Grammar.fromFile(tempFile);

      expect(grammar.nonTerminals, equals(List.from(['S', 'A', 'B'])));
      expect(grammar.terminals, equals(List.from(['a', 'b'])));

      expect(
          grammar.rules[0].conjuncts,
          equals(List<List<String>>.from([
            ['A', 'a'],
            ['B', 'b']
          ])));

      expect(
          grammar.rules[1].conjuncts,
          equals(List<List<String>>.from([
            ['a']
          ])));
      expect(
          grammar.rules[2].conjuncts,
          equals(List<List<String>>.from([
            ['b']
          ])));

      await tempFile.delete();
    });

    test('Файловый ввод 3', () async {
      var tempFile = File('${Directory.systemTemp.path}/input.txt');
      await tempFile.writeAsString("S -> eps & a b | START | c");

      var grammar = Grammar.fromFile(tempFile);

      expect(grammar.nonTerminals, equals(List.from(['S', 'START'])));
      expect(grammar.terminals, equals(List.from(['eps', 'a', 'b', 'c'])));

      expect(
          grammar.rules[0].conjuncts,
          equals(List<List<String>>.from([
            ['eps'],
            ['a', 'b']
          ])));

      expect(
          grammar.rules[1].conjuncts,
          equals(List<List<String>>.from([
            ['START']
          ])));
      expect(
          grammar.rules[2].conjuncts,
          equals(List<List<String>>.from([
            ['c']
          ])));

      await tempFile.delete();
    });
  });
}
