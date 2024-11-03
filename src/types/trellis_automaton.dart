import 'rule.dart';
import 'state.dart';
import 'grammar.dart';

class TrellisAutomaton {
  Set<String> alphabet = {};
  Set<State> states = {};
  Set<State> finals = {};
  late State Function(String) Init;
  late State Function(State q1, State q2) Transition;

  TrellisAutomaton.build(Grammar g) {
    alphabet = Set.from(g.terminals);
    Init = _build_init(List<Rule>.from(g.rules));
  }

  State Function(String) _build_init(List<Rule> rules) {
    return (String w) => State.create(
        w, rules.where((r) => r.deducible(w)).map((r) => r.left).toSet(), w);
  }
}
