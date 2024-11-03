import 'dart:io';
import 'rule.dart';

class Grammar {
  Set<String> terminals = {};
  Set<String> nonTerminals = {};
  List<Rule> rules = [];
  String startNonTerminal = '';

  Grammar();

  Grammar.make(List<Rule> prd, Set<String> NT, Set<String> T) {
    this.nonTerminals = NT.map((e) => e.toUpperCase()).toSet();
    this.terminals = T.map((e) => e.toLowerCase()).toSet();
    this.rules = prd;
  }

  Grammar.fromFile(File inputFile) {
    _readGrammarFromFile(inputFile);
  }

  Grammar.fromRuleList(List<Rule> prd) {
    for (var rule in prd) {
      nonTerminals.add(rule.left.toUpperCase());
      if (startNonTerminal.isEmpty) {
        startNonTerminal = rule.left.toUpperCase();
      }

      for (var symbol in rule.conjuncts.expand((conj) => conj)) {
        if (_isNonTerminal(symbol)) {
          nonTerminals.add(symbol.toUpperCase());
        } else {
          terminals.add(symbol.toLowerCase());
        }
      }
    }
    this.rules = prd;
  }

  void _readGrammarFromFile(File inputFile) {
    try {
      var lines = inputFile.readAsStringSync().split('\n');

      for (var line in lines) {
        if (line.trim().isNotEmpty) {
          var parts = line.split('->').map((part) => part.trim()).toList();
          var left = parts[0].toUpperCase();

          // Добавляем левую часть как нетерминал
          nonTerminals.add(left);

          // Обработка альтернатив, разделенных символом |
          var alternatives = parts[1].split('|').map((alt) => alt.trim());

          for (var alternative in alternatives) {
            // Разбиваем альтернативу на слова по пробелам
            var conjuncts = alternative
                .split('&')
                .map((conj) => conj
                    .trim()
                    .split(RegExp(r'\s+'))
                    .where((word) => word.isNotEmpty)
                    .toList())
                .toList();

            conjuncts.expand((conj) => conj).forEach((symbol) {
              // Проверяем, является ли слово нетерминалом (все заглавные буквы)
              if (_isNonTerminal(symbol)) {
                nonTerminals.add(symbol);
              } else {
                // Если слово в нижнем регистре, оно считается терминалом
                terminals.add(symbol);
              }
            });

            rules.add(Rule(left, conjuncts));
          }
        }
      }
      startNonTerminal = nonTerminals.first;
    } catch (e) {
      print('Произошла ошибка при чтении файла: $e');
    }
  }

  bool _isNonTerminal(String symbol) {
    // Проверяем, состоит ли слово только из заглавных букв
    return RegExp(r'^[A-Z]+$').hasMatch(symbol);
  }

  @override
  String toString() {
    return 'TERMINALS: ${terminals.join(' ')}\nNON TERMINALS: ${nonTerminals.join(' ')}\nSTART: $startNonTerminal\nRULES:\n${rules.join('\n')}';
  }

  int getRuleIndex(Rule rule) {
    return rules.indexOf(rule);
  }
}
