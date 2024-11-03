class Rule {
  String left;
  List<List<String>> conjuncts;

  Rule(this.left, this.conjuncts);

  // выводим ли терминал w из правила r
  // Является ли правилом вида A -> w
  bool deducible(String w) {
    return conjuncts.length == 1 &&
        conjuncts.every((conj) => conj.join("") == w);
  }

  @override
  String toString() {
    return '$left -> ${conjuncts.map((conj) => conj.join(' ')).join(' & ')}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Rule) return false;
    return left == other.left && conjuncts == other.conjuncts;
  }

  @override
  int get hashCode => left.hashCode ^ conjuncts.hashCode;
}
