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
    var nt_set = generating.length != 0 ? '{${generating.join(' ')}}' : '∅';
    return '($left, $nt_set, $right)';
  }

  @override
  bool operator ==(Object other) {
    if (other is! State) return false;
    if (identical(this, other)) return true;

    if (this.left == other.left && this.right == other.right) {
      return this.generating.length == other.generating.length &&
          this.generating.containsAll(other.generating);
    }

    return false;
  }
}
