class State {
  late String left;
  late String right;
  late Set<String> generating;

  State.create(String w1, Set<String> nonTerms, String w2) {
    left = w1;
    right = w2;
    generating = Set.from(nonTerms);
  }
}
