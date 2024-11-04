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
    Transition = _build_transitions(List<Rule>.from(g.rules));
    states.addAll(alphabet.map((t) => Init(t)));
  }

  // TODO написать тесты для инит функции
  State Function(String) _build_init(List<Rule> rules) {
    return (String w) => State.create(
        w, rules.where((r) => r.deducible(w)).map((r) => r.left).toSet(), w);
  }

// TODO написать тесты для функции построения переходов
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
}
