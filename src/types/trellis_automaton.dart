import '../utils/common.dart';
import 'rule.dart';
import 'state.dart';
import 'grammar.dart';

import 'dart:collection';
import 'dart:io';

class TrellisAutomaton {
  Set<String> alphabet = {};
  HashSet<State> states = HashSet<State>();
  Set<State> finals = {};
  late State Function(String) Init;
  late State Function(State q1, State q2) Transition;
  late HashMap<(State, State), State> parsing_table;

  TrellisAutomaton.build(Grammar g) {
    parsing_table = HashMap<(State, State), State>();
    alphabet = Set.from(g.terminals);
    Init = _build_init(List<Rule>.from(g.rules));
    Transition = _build_transitions(List<Rule>.from(g.rules));
    states = _build_states(alphabet);

    finals = states.where((q) => q.generating.contains(g.startSymbol)).toSet();

    _build_parsing_table();
  }

  TrellisAutomaton.fromFile(File file) {
    var lines = file.readAsLinesSync();

    int lineIndex = 0;

    while (lineIndex < lines.length && lines[lineIndex].trim().isEmpty) {
      lineIndex++;
    }

    if (lines[lineIndex].startsWith('Алфавит:')) {
      lineIndex++;
      alphabet = lines[lineIndex].split(',').map((e) => e.trim()).toSet();
      lineIndex++;
    } else {
      throw StateError('Alphabet section is missing in the input file.');
    }

    while (lineIndex < lines.length && lines[lineIndex].trim().isEmpty) {
      lineIndex++;
    }

    var initMapping = <String, State>{};
    if (lines[lineIndex].startsWith('Init функция:')) {
      lineIndex++;
      while (lineIndex < lines.length && lines[lineIndex].contains('->')) {
        var parts = lines[lineIndex].split('->');
        var symbol = parts[0].trim();
        var stateInfo = parts[1].trim();
        var components =
            stateInfo.substring(1, stateInfo.length - 1).split(',');
        initMapping[symbol] = State.create(
          components[0].trim(),
          _cleanBraces(components[1].trim()).split(' ').toSet(),
          components[2].trim(),
        );
        lineIndex++;
      }
      Init = (String w) =>
          initMapping[w] ??
          (throw ArgumentError('Init mapping for symbol "$w" not found.'));
    } else {
      throw StateError('Init function section is missing in the input file.');
    }

    while (lineIndex < lines.length && lines[lineIndex].trim().isEmpty) {
      lineIndex++;
    }

    var stateList = <State>[];
    if (lines[lineIndex].startsWith('Индекс -> Список состояний:')) {
      lineIndex++;
      while (lineIndex < lines.length && lines[lineIndex].contains(':')) {
        var parts = lines[lineIndex].split(':');
        var stateInfo = parts[1].trim();
        var components =
            stateInfo.substring(1, stateInfo.length - 1).split(',');
        var state = State.create(
          components[0].trim(),
          _cleanBraces(components[1].trim()).split(' ').toSet(),
          components[2].trim(),
        );
        stateList.add(state);
        states.add(state);
        lineIndex++;
      }
    } else {
      throw StateError('State list section is missing in the input file.');
    }

    while (lineIndex < lines.length && lines[lineIndex].trim().isEmpty) {
      lineIndex++;
    }

    if (lines[lineIndex].startsWith('Принимающие состояния:')) {
      lineIndex++;
      while (lineIndex < lines.length && lines[lineIndex].contains(':')) {
        var parts = lines[lineIndex].split(':');
        var index = int.parse(parts[0].trim());
        if (index < 0 || index >= stateList.length) {
          throw RangeError('Final state index $index is out of bounds.');
        }
        finals.add(stateList[index]);
        lineIndex++;
      }
    } else {
      throw StateError('Final states section is missing in the input file.');
    }

    while (lineIndex < lines.length && lines[lineIndex].trim().isEmpty) {
      lineIndex++;
    }

    parsing_table = HashMap();
    if (lines[lineIndex].startsWith('Таблица переходов:')) {
      lineIndex++;
      while (lineIndex < lines.length && lines[lineIndex].trim().isNotEmpty) {
        var row = lines[lineIndex].trim().split(RegExp(r'\s+'));
        var fromIndex = int.parse(row[0]);
        if (fromIndex < 0 || fromIndex >= stateList.length) {
          throw RangeError(
              'Transition table row index $fromIndex is out of bounds.');
        }
        var fromState = stateList[fromIndex];
        for (int i = 1; i < row.length; i++) {
          var toIndex = int.parse(row[i]);
          if (toIndex != -1) {
            if (toIndex < 0 || toIndex >= stateList.length) {
              throw RangeError(
                  'Transition table column index $toIndex is out of bounds.');
            }
            var toState = stateList[toIndex];
            parsing_table[(fromState, stateList[i - 1])] = toState;
          }
        }
        lineIndex++;
      }
    } else {
      throw StateError(
          'Transition table section is missing in the input file.');
    }
  }

  State Function(String) _build_init(List<Rule> rules) {
    return (String w) => State.create(
        w, rules.where((r) => r.deducible(w)).map((r) => r.left).toSet(), w);
  }

  State Function(State q1, State q2) _build_transitions(List<Rule> rules) {
    return (State q1, State q2) {
      return State.create(
          q1.left,
          rules
              .where((r) => r.applicableForTransition(q1, q2))
              .map((r) => r.left)
              .toSet(),
          q2.right);
    };
  }

  HashSet<State> _build_states(Set<String> terms) {
    var initialStates = terms.map((t) => Init(t)).toSet();
    var reachableStates = HashSet<State>.from(initialStates);
    var newStates = HashSet<State>();

    do {
      newStates.clear();
      for (var q1 in reachableStates) {
        for (var q2 in reachableStates) {
          var newState = Transition(q1, q2);

          if (!reachableStates.contains(newState) &&
              !newStates.contains(newState)) {
            newStates.add(newState);
          }
        }
      }

      reachableStates.addAll(newStates);
    } while (newStates.isNotEmpty);

    return reachableStates;
  }

  void _build_parsing_table() {
    for (var q1 in states) {
      for (var q2 in states) {
        parsing_table[(q1, q2)] = Transition(q1, q2);
      }
    }
  }

  int getStateIndex(State state) {
    var stateList = states.toList();
    return stateList.indexOf(state);
  }

  String _cleanBraces(String input) {
    while (input.contains('{{') && input.contains('}}')) {
      input = input
          .replaceAll(RegExp(r'\{\{+'), '{')
          .replaceAll(RegExp(r'\}\}+'), '}');
    }
    return input;
  }

  Grammar toGrammar() {
    var grammar = Grammar();
    var stateList = states.toList();
    stateList.sort((a, b) => a.toString().compareTo(b.toString()));

    for (var i = 0; i < stateList.length; i++) {
      grammar.nonTerminals.add('A$i');
    }

    grammar.terminals.addAll(alphabet);

    for (var q1 in states) {
      for (var q2 in states) {
        var q = parsing_table[(q1, q2)]!;

        var q1idx = stateList.indexOf(q1);
        var q2idx = stateList.indexOf(q2);

        var qidx = stateList.indexOf(q);

        var b = q1.left;
        var c = q2.right;
        grammar.rules.add(Rule(
          'A$qidx',
          [
            [b, 'A$q2idx'],
            ['A$q1idx', c]
          ],
        ));
      }
    }

    for (var finalState in finals) {
      var finalStateIndex = stateList.indexOf(finalState);
      grammar.rules.add(
        Rule('S', [
          ['A$finalStateIndex']
        ]),
      );
    }

    var initGeneratedStates = alphabet.map((a) => Init(a)).toSet();

    for (var term in alphabet) {
      var relatedInitState = initGeneratedStates
          .where((s) => s.left == term && s.right == term)
          .firstOrNull!;

      var stateIndex = stateList.indexOf(relatedInitState);
      var rule = Rule('A$stateIndex', [
        [term]
      ]);
      grammar.rules.add(rule);
    }

    grammar.nonTerminals.add('S');
    grammar.startSymbol = 'S';

    grammar.rules.sort();

    grammar.saveToFile('grammar.txt');

    return grammar;
  }

  void saveGrammarToFile(Grammar grammar, File outputFile) {
    var sink = outputFile.openWrite();

    var startRules =
        grammar.rules.where((rule) => rule.left == grammar.startSymbol);
    for (var rule in startRules) {
      var ruleStr = '${rule.left} -> ' +
          rule.conjuncts.map((conj) => conj.join(' ')).join(' & ');
      sink.writeln(ruleStr);
    }

    var otherRules =
        grammar.rules.where((rule) => rule.left != grammar.startSymbol);
    for (var rule in otherRules) {
      var ruleStr = '${rule.left} -> ' +
          rule.conjuncts.map((conj) => conj.join(' ')).join(' & ');
      sink.writeln(ruleStr);
    }

    sink.close();
  }

  @override
  String toString() {
    var stateList = states.toList();

    var initGeneratedStates = alphabet
        .map((a) => Init(a))
        .where((state) => stateList.contains(state))
        .toSet();

    var str = '';

    str =
        'Alf : ${alphabet} \nINIT : ${initGeneratedStates} \nSTATES : ${stateList}';
    return str;
  }
}
