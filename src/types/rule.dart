import 'state.dart';

class Rule implements Comparable {
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
    if (conjuncts.any((conj) => conj.length == 1)) return false;

    var b = q1.left;
    var c = q2.right;
    var X = q1.generating;
    var Y = q2.generating;

    // Получим нетерминалы B1...Bm
    var B = conjuncts
        .where((conj) => conj.first == b)
        .map((conj) => conj.last)
        .toSet();

    // Получим нетерминалы C1...Cn
    var C = conjuncts
        .where((conj) => conj.last == c)
        .map((conj) => conj.first)
        .toSet();

    if (B.length + C.length != conjuncts.length) return false;

    if (C.isEmpty && B.isEmpty) return false;

    return Y.containsAll(B) && X.containsAll(C);
  }

  @override
  String toString() {
    return '$left -> ${conjuncts.map((conj) => conj.join(' ')).join(' & ')}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Rule) return false;

    return _areConjunctsEqual(conjuncts, other.conjuncts);
  }

  bool _areConjunctsEqual(List<List<String>> conj1, List<List<String>> conj2) {
    if (conj1.length != conj2.length) return false;

    for (int i = 0; i < conj1.length; i++) {
      if (conj1[i].length != conj2[i].length) {
        return false;
      }
      for (int j = 0; j < conj1[i].length; j++) {
        if (conj1[i][j] != conj2[i][j]) {
          return false;
        }
      }
    }

    return true;
  }

  @override
  int get hashCode {
    var sortedConjuncts =
        conjuncts.map((conj) => List<String>.from(conj)..sort()).toList();
    sortedConjuncts.sort((a, b) => a.toString().compareTo(b.toString()));
    return left.hashCode ^ _hashConjuncts(sortedConjuncts);
  }

  int _hashConjuncts(List<List<String>> conjuncts) {
    int result = 1;
    for (var conj in conjuncts) {
      result = 31 * result + conj.join(',').hashCode;
    }
    return result;
  }

  @override
  int compareTo(other) {
    if (other is! Rule) {
      throw ArgumentError();
    }

    String left1 = left;
    String left2 = other.left;

    RegExp exp = RegExp(r'^([A-Za-z]+)(\d+)$');
    var match1 = exp.firstMatch(left1);
    var match2 = exp.firstMatch(left2);

    if (match1 != null && match2 != null) {
      int prefixComparison = match1.group(1)!.compareTo(match2.group(1)!);
      if (prefixComparison != 0) return prefixComparison;

      int num1 = int.parse(match1.group(2)!);
      int num2 = int.parse(match2.group(2)!);
      return num1.compareTo(num2);
    } else {
      return left1.compareTo(left2);
    }
  }
}
