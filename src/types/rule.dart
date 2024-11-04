import 'state.dart';

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

  // let q = f(q1,q1) where is f: Q2 -> Q a transit function
  // q = (q1.left == b, Z, q2.right == c)
  // Z = {A | exists A -> b B1 & .. & b Bm & C1 c & .. & Cn c}
  // where B1...Bm in q2.Generating == X and C1...Cn in q1.Generating == Y

  bool applicableForTransition(State q1, State q2) {
    var b = q1.left;
    var c = q2.right;
    var X = q1.generating;
    var Y = q2.generating;

    if (!conjuncts.every((conj) => conj.length == 2)) return false;

    // Получим нетеременалы B1...Bm
    var B = conjuncts
        .where((conj) => conj.first == b)
        .map((conj) => conj.last)
        .toSet();

    // Получим нетеременалы C1...Cn
    var C = conjuncts
        .where((conj) => conj.last == c)
        .map((conj) => conj.first)
        .toList()
        .toSet();

    if (C.length == 0 && B.length == 0) return false;

    return X.containsAll(C) && Y.containsAll(B);
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
