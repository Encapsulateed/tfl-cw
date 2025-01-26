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

  Grammar.fromRulst(List<Rule> prd) {
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

          nonTerminals.add(left);

          var alternatives = parts[1].split('|').map((alt) => alt.trim());

          for (var alternative in alternatives) {
            var conjuncts = alternative
                .split('&')
                .map((conj) => conj
                    .trim()
                    .split(RegExp(r'\s+'))
                    .where((word) => word.isNotEmpty)
                    .toList())
                .toList();

            conjuncts.expand((conj) => conj).forEach((symbol) {
              if (_isNonTerminal(symbol)) {
                nonTerminals.add(symbol);
              } else {
                if (symbol != 'ε') {
                  terminals.add(symbol);
                }
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
    return RegExp(r'^[A-Z]+[0-9]*$').hasMatch(symbol);
  }

  void convertToLNF() {
    _processStartSymbol();
    removeDuplicateRules();

    processEpsRules(computeNullable());
    removeDuplicateRules();

    removeUnitConjuncts();
    removeDuplicateRules();

    processRules();
    removeDuplicateRules();
  }

  String NonTerm() {
    String candidate;
    var counter = 0;
    counter = counter++;
    while (true) {
      candidate = "N\$counter";
      if (!nonTerminals.contains(candidate)) {
        nonTerminals.add(candidate);
        return candidate;
      }

      counter++;
    }
  }

  void processRules() {
    bool isLNF(List<String> conj) {
      if (conj.length == 1)
        return terminals.contains(conj[0]) || conj[0] == 'ε';

      return conj.length == 2 &&
          ((terminals.contains(conj[0]) && nonTerminals.contains(conj[1])) ||
              (terminals.contains(conj[1]) && nonTerminals.contains(conj[0])));
    }

    List<String> reduceConj(List<String> conj) {
      {
        List<String> output = conj;
        if (!isLNF(conj)) {
          var isLeftConj = terminals.contains(conj[0]);

          if (isLeftConj) {
            var term = conj[0];
            var nonterm = NonTerm();

            var Conj = [term, nonterm];

            var rule = Rule(nonterm, List.from([conj.sublist(1)]));

            output = Conj;

            rules.add(rule);
            nonTerminals.add(NonTerm());
          } else {
            var term = conj[conj.length - 1];
            var nonterm = NonTerm();

            var Conj = [nonterm, term];

            var rule =
                Rule(nonterm, List.from([conj.sublist(0, conj.length - 1)]));

            output = Conj;

            rules.add(rule);
            nonTerminals.add(NonTerm());
          }
        }

        return output;
      }
    }

    bool changed = true;

    while (changed) {
      changed = false;

      for (var i = 0; i < rules.length; i++) {
        var rule = rules[i];
        var ntSetPrev = Set<String>.from(nonTerminals);

        var conjLst = rule.conjuncts.map((conj) => reduceConj(conj)).toList();

        rules[i] = Rule(rule.left, conjLst);

        if (!ntSetPrev.containsAll(nonTerminals) ||
            !nonTerminals.containsAll(ntSetPrev)) {
          changed = true;
        }
      }
    }
  }

  void _processStartSymbol() {
    if (computeNullable().contains(startNonTerminal)) {
      String newStartSymbol = "S'";
      nonTerminals.add(newStartSymbol);

      if (!rules.any((rule) =>
          rule.left == newStartSymbol && rule.conjuncts.contains(["ε"]))) {
        rules.add(Rule(newStartSymbol, [
          ["ε"]
        ]));
      }

      var currentRules = List<Rule>.from(rules);

      rules.removeWhere((rule) => rule.left == startNonTerminal);

      for (var rule
          in currentRules.where((rule) => rule.left == startNonTerminal)) {
        if (!rules.any((r) =>
            r.left == newStartSymbol &&
            _areConjunctsEqual(r.conjuncts, rule.conjuncts))) {
          rules.add(Rule(newStartSymbol, List.from(rule.conjuncts)));
        }
      }

      startNonTerminal = newStartSymbol;
    }
  }

  @override
  String toString() {
    return 'TERMINALS: ${terminals.join(' ')}\nNON TERMINALS: ${nonTerminals.join(' ')}\nSTART: $startNonTerminal\nRULES:\n${rules.join('\n')}';
  }

  int getRuleIndex(Rule rule) {
    return rules.indexOf(rule);
  }

  Set<String> computeNullable() {
    Set<String> nullable = {};
    bool changed = true;

    for (var rule in rules) {
      if (rule.deducible('ε')) {
        nullable.add(rule.left);
      }
    }

    if (nullable.isEmpty) return nullable;

    while (changed) {
      changed = false;
      for (var rule in rules) {
        for (var conj in rule.conjuncts) {
          if (conj
              .every((symbol) => nullable.contains(symbol) || symbol == 'ε')) {
            if (!nullable.contains(rule.left)) {
              nullable.add(rule.left);
              changed = true;
            }
          }
        }
      }
    }

    return nullable;
  }

  void processEpsRules(Set<String> nullable) {
    if (nullable.isEmpty) return;

    List<Rule> Rules = [];

    for (var rule in rules.where((rule) => rule.left == "S'")) {
      if (!Rules.any(
          (r) => r.left == rule.left && r.conjuncts.contains(rule.conjuncts))) {
        Rules.add(rule);
      }
    }

    for (var rule in rules) {
      if (rule.left == startNonTerminal) {
        continue;
      }
      List<List<String>> Conjuncts = [];
      if (rule.left == startNonTerminal) {
        if (!Rules.any((r) =>
            r.left == rule.left && r.conjuncts.contains(rule.conjuncts))) {
          Rules.add(rule);
        }
      }
      for (var conj in rule.conjuncts) {
        Set<List<String>> combinations = {List<String>.from(conj)};

        for (var i = 0; i < conj.length; i++) {
          if (nullable.contains(conj[i]) && conj[i] != 'ε') {
            var Combinations = Set<List<String>>.from(combinations);
            for (var combination in Combinations) {
              var temp = List<String>.from(combination);
              temp.removeAt(i);
              combinations.add(temp);
            }
          }
        }

        Conjuncts.addAll(combinations);
      }

      for (var Conj in Conjuncts) {
        if (!(Conj.length == 1 && Conj.first == 'ε')) {
          if (!Rules.any(
              (r) => r.left == rule.left && r.conjuncts.contains([Conj]))) {
            Rules.add(Rule(rule.left, [Conj]));
          }
        }
      }
    }

    rules.clear();
    rules.addAll(Rules);
  }

  void removeUnitConjuncts() {
    // Шаг 1: Создаем новый список для обновленных правил
    List<Rule> updatedRules = [];

    // Шаг 2: Проходим по всем правилам
    for (var rule in rules) {
      bool modified = false;

      // Шаг 3: Ищем unit conjunct в каждом конъюнкте
      for (var conjunct in rule.conjuncts) {
        if (conjunct.length == 1 && _isNonTerminal(conjunct[0])) {
          modified = true;
          String targetNonTerminal = conjunct[0];

          // Шаг 4: Находим все правила для целевого нетерминала
          for (var targetRule
              in rules.where((r) => r.left == targetNonTerminal)) {
            // Для каждой альтернативы создаем новое правило
            updatedRules.add(Rule(rule.left, [
              for (var originalConjunct in rule.conjuncts)
                if (originalConjunct != conjunct) originalConjunct,
              ...targetRule.conjuncts
            ]));
          }
        }
      }

      // Шаг 5: Если правило не было модифицировано, добавляем его как есть
      if (!modified) {
        updatedRules.add(rule);
      }
    }

    // Шаг 6: Удаляем дубликаты и обновляем правила
    rules = updatedRules;
    removeDuplicateRules();
  }

  void removeDuplicateRules() {
    List<Rule> uniqueRules = [];

    for (var rule in rules) {
      if (!uniqueRules.any((r) =>
          r.left == rule.left &&
          _areConjunctsEqual(r.conjuncts, rule.conjuncts))) {
        uniqueRules.add(rule);
      }
    }

    rules = uniqueRules;
    removeUnusedNonTerminals();
  }

  bool _areConjunctsEqual(
      List<List<String>> conjuncts1, List<List<String>> conjuncts2) {
    if (conjuncts1.length != conjuncts2.length) return false;

    for (var i = 0; i < conjuncts1.length; i++) {
      if (conjuncts1[i].length != conjuncts2[i].length ||
          !conjuncts1[i].every((symbol) => conjuncts2[i].contains(symbol))) {
        return false;
      }
    }

    return true;
  }

  void removeUnusedNonTerminals() {
    Set<String> usedNonTerminals = rules.map((rule) => rule.left).toSet();
    nonTerminals
        .removeWhere((nonTerminal) => !usedNonTerminals.contains(nonTerminal));
  }
}
