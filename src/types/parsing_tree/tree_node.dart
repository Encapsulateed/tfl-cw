import '../state.dart';

class Node {
  late String value;
  late State related_state;

  Node.create(this.value, this.related_state);

  @override
  String toString() {
    return value;
  }
}
