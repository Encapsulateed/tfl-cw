class State {
  late String left;
  late String right;
  late Set<String> generating;

  State.create(String w1, Set<String> nonTerms, String w2) {
    left = w1;
    right = w2;
    generating = Set.from(nonTerms);
  }

  @override
  String toString() {
    var nt_set = generating.isNotEmpty ? '{${generating.join(' ')}}' : '∅';
    return '($left, $nt_set, $right)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! State) return false;

    return left == other.left &&
        right == other.right &&
        generating.length == other.generating.length &&
        generating.containsAll(other.generating);
  }

  @override
  int get hashCode {
    var result = 17;
    result = 37 * result + left.hashCode;
    result = 37 * result + right.hashCode;
    result = 37 * result +
        generating.fold(0, (hash, element) => hash + element.hashCode);
    return result;
  }
}
