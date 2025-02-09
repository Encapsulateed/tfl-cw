import 'package:test/test.dart';
import 'dart:io';

import '../src/types/grammar.dart';

void main() {
  group('Тестирование корректности введения грамматик', () {
    var path = '${Directory.systemTemp.path}/input.txt';
    test('Файловый ввод 1', () async {
      var tempFile = File(path);
      await tempFile.writeAsString("S -> A a & B b\nA -> a\nB -> b");

      var grammar = Grammar();
      grammar.loadFromFile(path);

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
      var tempFile = File(path);
      await tempFile.writeAsString(
          "S -> A a &                          B b\nA ->    a\n      B -> b");

      var grammar = Grammar();
      grammar.loadFromFile(path);

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

    test('Файловый ввод 3 граматика Охотина (ita)', () async {
      var tempFile = File(path);

      await tempFile.writeAsString(
          "S -> K a & a R \nK -> a A | K a \nP -> a A \nA -> P b | b\nR -> B a | a R \nQ -> B a \nB -> b Q | b ");

      var grammar = Grammar();
      grammar.loadFromFile(path);

      expect(grammar.nonTerminals,
          equals(List.from(['S', 'K', 'R', 'A', 'P', 'B', 'Q'])));
      expect(
          grammar.terminals,
          equals(List.from([
            'a',
            'b',
          ])));

      expect(
          grammar.rules[0].conjuncts,
          equals(List<List<String>>.from([
            ['K', 'a'],
            ['a', 'R']
          ])));

      expect(
          grammar.rules[1].conjuncts,
          equals(List<List<String>>.from([
            ['a', 'A']
          ])));
      expect(
          grammar.rules[2].conjuncts,
          equals(List<List<String>>.from([
            ['K', 'a']
          ])));

      expect(
          grammar.rules[3].conjuncts,
          equals(List<List<String>>.from([
            ['a', 'A']
          ])));
      expect(
          grammar.rules[4].conjuncts,
          equals(List<List<String>>.from([
            ['P', 'b']
          ])));

      expect(
          grammar.rules[5].conjuncts,
          equals(List<List<String>>.from([
            ['b']
          ])));
      expect(
          grammar.rules[6].conjuncts,
          equals(List<List<String>>.from([
            ['B', 'a']
          ])));
      expect(
          grammar.rules[7].conjuncts,
          equals(List<List<String>>.from([
            ['a', 'R']
          ])));
      expect(
          grammar.rules[8].conjuncts,
          equals(List<List<String>>.from([
            ['B', 'a']
          ])));
      expect(
          grammar.rules[9].conjuncts,
          equals(List<List<String>>.from([
            ['b', 'Q']
          ])));
      expect(
          grammar.rules[10].conjuncts,
          equals(List<List<String>>.from([
            [
              'b',
            ]
          ])));
      await tempFile.delete();
    });
  });
}
