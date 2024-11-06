import 'rule.dart';
import 'state.dart';
import 'grammar.dart';

import 'dart:collection';

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

    finals =
        states.where((q) => q.generating.contains(g.startNonTerminal)).toSet();

    _build_parsing_table();
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
        var newState = Transition(q1, q2);
        parsing_table[(q1, q2)] = newState;
      }
    }
  }

  int getStateIndex(State state) {
    var stateList = states.toList();
    return stateList.indexOf(state);
  }
}
