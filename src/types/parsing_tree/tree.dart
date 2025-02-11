import '../trellis_automaton.dart';
import 'tree_node.dart';
import '../state.dart';
import '../../utils/common.dart';

class ParsingTree {
  late List<Node> _zero_layer;
  List<List<Node>> layers = [];

  late Node Function(Node, Node) _compute_next;
  late bool _explanation;
  late TrellisAutomaton _ta;
  ParsingTree.create(String w, TrellisAutomaton ta, bool explanation) {
    _ta = ta;
    _explanation = explanation;

    _zero_layer = w
        .split('')
        .map((wi) => ta.Init(wi))
        .map((init) => Node.create(nodeToString(init), init))
        .toList();

    layers.add(_zero_layer);

    _compute_next = _build_next();
    compute_next_layer(_zero_layer);
  }

  void compute_next_layer(List<Node> prev) {
    if (prev.isEmpty) return;
    while (prev.length > 1) {
      List<Node> next = slidingPairs(prev)
          .map((pair) => _compute_next(pair.$1, pair.$2))
          .toList();
      layers.add(next);
      prev = next;
    }
  }

  Node Function(Node, Node) _build_next() {
    return (Node first, Node second) {
      try {
        State next =
            _ta.parsing_table[(first.related_state, second.related_state)]!;
        return Node.create(nodeToString(next), next);
      } catch (ex) {
        throw ('Unexpected terminal in input word!');
      }
    };
  }

  String nodeToString(State q) {
    return _explanation ? q.toString() : '${_ta.getStateIndex(q)}';
  }

  bool isRecognizing() {
    return _ta.finals.contains(layers.last.first.related_state);
  }
}
