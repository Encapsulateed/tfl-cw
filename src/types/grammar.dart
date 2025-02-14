import 'dart:io';
import 'rule.dart';

class Grammar {
  Set<String> terminals = {};
  Set<String> nonTerminals = {};
  List<Rule> rules = [];
  String startSymbol = '';

  Grammar();

  void convertToLNF() {
    processEpsRules(computeNullable());
    _eliminateUnitConjuncts();
    removeUselessConjuncts();
    removeDuplicateConjuncts();
    processRules();
    MergeRules();
    _processStartSymbol();
    removeUnusedNonTerminals();
  }

  String NonTerm() {
    String candidate;
    var counter = 0;
    counter = counter++;
    while (true) {
      candidate = "N$counter";
      if (!nonTerminals.contains(candidate)) {
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

            nonTerminals.add(nonterm);
            rules.add(rule);
          } else {
            var term = conj[conj.length - 1];
            var nonterm = NonTerm();

            var Conj = [nonterm, term];

            var rule =
                Rule(nonterm, List.from([conj.sublist(0, conj.length - 1)]));

            output = Conj;

            rules.add(rule);
            nonTerminals.add(nonterm);
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
    String newStartSymbol = "S'";
    if (computeNullable().contains(startSymbol)) {
      nonTerminals.add(newStartSymbol);

      if (!rules.any((rule) =>
          rule.left == newStartSymbol && rule.conjuncts.contains(["ε"]))) {
        rules.add(Rule(newStartSymbol, [
          ["ε"]
        ]));
      }

      var currentRules = List<Rule>.from(rules);

      rules.removeWhere((rule) => rule.left == startSymbol);

      for (var rule in currentRules.where((rule) => rule.left == startSymbol)) {
        if (!rules.any((r) => r.left == newStartSymbol && r == rule)) {
          rules.add(Rule(newStartSymbol, List.from(rule.conjuncts)));
        }
      }
      var prevStart = startSymbol;
      startSymbol = newStartSymbol;

      for (var i = 0; i < rules.length; i++) {
        rules[i] = Rule(
          rules[i].left,
          rules[i].conjuncts.map((conj) {
            return conj.map((symbol) {
              return symbol == prevStart ? newStartSymbol : symbol;
            }).toList();
          }).toList(),
        );
      }
    }
  }

  @override
  String toString() {
    var buffer = StringBuffer();
    buffer.writeln('TERMINALS: ${terminals.join(' ')}');
    buffer.writeln('NON TERMINALS: ${nonTerminals.join(' ')}');
    buffer.writeln('START: $startSymbol');
    buffer.writeln('RULES:');

    var groups = <String, List<Rule>>{};
    for (var rule in rules) {
      groups.putIfAbsent(rule.left, () => []).add(rule);
    }

    groups.forEach((left, ruleList) {
      List<String> alternatives = ruleList.map((rule) {
        List<String> conjunctStrings =
            rule.conjuncts.map((conj) => conj.join(" ")).toList();
        return conjunctStrings.join(" & ");
      }).toList();
      buffer.writeln("$left -> " + alternatives.join(" | "));
    });

    return buffer.toString();
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

    for (var rule in rules.where((rule) => rule.left == startSymbol)) {
      if (!Rules.any(
          (r) => r.left == rule.left && r.conjuncts.contains(rule.conjuncts))) {
        Rules.add(rule);
      }
    }

    for (var rule in rules) {
      if (rule.left == startSymbol) {
        continue;
      }
      List<List<String>> Conjuncts = [];
      if (rule.left == startSymbol) {
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

  void _eliminateUnitConjuncts() {
    final orderedNonTerminals = nonTerminals.toList();
    for (int j = 0; j < orderedNonTerminals.length; j++) {
      final currentSymbol = orderedNonTerminals[j];

      final nonUnitRules = rules
          .where((rule) => rule.left == currentSymbol)
          .where((rule) => !rule.conjuncts.any((conj) =>
              conj.length == 1 &&
              _isNonTerminal(conj[0]) &&
              orderedNonTerminals.indexOf(conj[0]) <= j))
          .toList();

      final affectedRules = rules
          .where((rule) => rule.conjuncts
              .any((conj) => conj.length == 1 && conj[0] == currentSymbol))
          .toList();

      for (final affectedRule in affectedRules) {
        rules.remove(affectedRule);

        for (final replacementRule in nonUnitRules) {
          for (final replacementConjunct in replacementRule.conjuncts) {
            final newConjuncts = affectedRule.conjuncts.map((conj) {
              return (conj.length == 1 && conj[0] == currentSymbol)
                  ? replacementConjunct
                  : conj;
            }).toList();

            if (replacementRule.conjuncts.length == 1) {
              rules.add(Rule(affectedRule.left, newConjuncts));
            } else {
              rules.add(Rule(affectedRule.left, replacementRule.conjuncts));
            }
          }
        }
      }
    }

    rules.removeWhere((rule) =>
        rule.conjuncts.any((c) => c.length == 1 && c[0] == rule.left));
  }

  void removeUselessConjuncts() {
    bool isUsless(Rule r) {
      var conjs = r.conjuncts;

      var containsTerminalinConj = conjs
              .any((c) => c.length == 1 && terminals.contains(c.first)) &&
          conjs
              .any((c) => c.any((conjItem) => nonTerminals.contains(conjItem)));

      return containsTerminalinConj;
    }

    rules = List.from(rules.where((r) => !isUsless(r)));
  }

  void removeDuplicateConjuncts() {
    rules = rules.toSet().toList();
  }

  void removeDuplicateAlternatives() {
    final Map<String, List<Rule>> groupedRules = {};
    for (final rule in rules) {
      groupedRules.putIfAbsent(rule.left, () => []).add(rule);
    }

    rules.clear();
    groupedRules.forEach((left, ruleGroup) {
      final Set<String> uniqueConjuncts = {};
      final List<List<String>> mergedConjuncts = [];

      for (final rule in ruleGroup) {
        for (final conjunct in rule.conjuncts) {
          final normalized = List<String>.from(conjunct)..sort();
          final key = normalized.join(' ');

          if (!uniqueConjuncts.contains(key)) {
            mergedConjuncts.add(conjunct);
            uniqueConjuncts.add(key);
          }
        }
      }

      if (mergedConjuncts.isNotEmpty) {
        rules.add(Rule(left, mergedConjuncts));
      }
    });
  }

  void groupAndMergeEqualRules() {
    List<Rule> rulesWithAlternatives = [];
    List<Rule> rulesWithoutAlternatives = [];

    Map<String, List<Rule>> groupedByLeft = {};

    for (var rule in rules) {
      if (!groupedByLeft.containsKey(rule.left)) {
        groupedByLeft[rule.left] = [];
      }
      groupedByLeft[rule.left]!.add(rule);
    }

    groupedByLeft.forEach((left, group) {
      if (group.length > 1) {
        rulesWithAlternatives.addAll(group);
      } else {
        rulesWithoutAlternatives.addAll(group);
      }
    });

    Map<String, Set<String>> equals = {};

    for (var rule in rulesWithoutAlternatives) {
      for (var rule2 in rulesWithoutAlternatives) {
        if (equals[rule.left] == null) {
          equals[rule.left] = {rule.left};
        }

        if (rule.left == rule2.left) {
          continue;
        }

        if (rule == rule2) {
          equals[rule.left]!.add(rule2.left);
        }
      }
    }

    Map<String, Set<String>> cleanedEquals = {};
    for (var k1 in equals.keys) {
      var set1 = equals[k1]!;
      bool alreadyMerged = cleanedEquals.values
          .any((s) => s.containsAll(set1) && set1.containsAll(s));

      if (!alreadyMerged) {
        cleanedEquals[k1] = set1;
      }
    }
    Map<String, String> replacementMap = {};
    cleanedEquals.forEach((key, value) {
      for (var v in value) {
        replacementMap[v] = key;
      }
    });

    List<Rule> updatedRules = [];

    for (var rule in rulesWithAlternatives) {
      var updatedConjuncts = rule.conjuncts.map((conj) {
        return conj.map((symbol) {
          return replacementMap.containsKey(symbol)
              ? replacementMap[symbol]!
              : symbol;
        }).toList();
      }).toList();

      updatedRules.add(Rule(rule.left, updatedConjuncts));
    }

    Map<String, Rule> finalRulesMap = {};

    for (var rule in rulesWithoutAlternatives) {
      String newLeft = replacementMap.containsKey(rule.left)
          ? replacementMap[rule.left]!
          : rule.left;

      var updatedConjuncts = rule.conjuncts.map((conj) {
        return conj.map((symbol) {
          return replacementMap.containsKey(symbol)
              ? replacementMap[symbol]!
              : symbol;
        }).toList();
      }).toList();

      finalRulesMap[newLeft] = Rule(newLeft, updatedConjuncts);
    }

    updatedRules.addAll(finalRulesMap.values);

    rules = updatedRules;
  }

  void MergeRules() {
    Set<String> previousRules = {};
    Set<String> currentRules = {};
    do {
      previousRules = rules.map((r) => r.toString()).toSet();
      groupAndMergeEqualRules();
      currentRules = rules.map((r) => r.toString()).toSet();
    } while (previousRules.length != currentRules.length);
    removeUnusedNonTerminals();
  }

  void removeUnusedNonTerminals() {
    Set<String> usedNonTerminals = rules.map((rule) => rule.left).toSet();
    nonTerminals
        .removeWhere((nonTerminal) => !usedNonTerminals.contains(nonTerminal));
  }

  void loadFromFile(String path) {
    try {
      var inputFile = File(path);
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
      startSymbol = nonTerminals.first;
    } catch (e) {
      print('Произошла ошибка при чтении файла: $e');
    }
  }

  void saveToFile(String path) {
    var outputFile = File(path);
    var buffer = StringBuffer();

    var groups = <String, List<Rule>>{};
    for (var rule in rules) {
      groups.putIfAbsent(rule.left, () => []).add(rule);
    }

    if (groups.containsKey(startSymbol)) {
      var ruleList = groups[startSymbol]!;
      List<String> alternatives = ruleList.map((rule) {
        List<String> conjunctStrings =
            rule.conjuncts.map((conj) => conj.join(" ")).toList();
        return conjunctStrings.join(" & ");
      }).toList();
      buffer.writeln("$startSymbol -> " + alternatives.join(" | "));
      groups.remove(startSymbol);
    }

    groups.forEach((left, ruleList) {
      List<String> alternatives = ruleList.map((rule) {
        List<String> conjunctStrings =
            rule.conjuncts.map((conj) => conj.join(" ")).toList();
        return conjunctStrings.join(" & ");
      }).toList();
      buffer.writeln("$left -> " + alternatives.join(" | "));
    });

    outputFile.writeAsStringSync(buffer.toString());
  }

  bool _isNonTerminal(String symbol) {
    return RegExp(r'^[A-Z]+[0-9]*$').hasMatch(symbol);
  }
}
