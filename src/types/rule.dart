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

    if (C.isEmpty && B.isEmpty) return false;
    if (C.isEmpty) return Y.containsAll(B);
    if (B.isEmpty) return X.containsAll(C);

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

  @override
  int compareTo(other) {
    if (other is! Rule) {
      throw ArgumentError("Можно сравнивать только объекты класса Rule");
    }

    String left1 = left;
    String left2 = other.left;

    // Регулярное выражение для разделения на буквенную и числовую части.
    RegExp exp = RegExp(r'^([A-Za-z]+)(\d+)$');
    var match1 = exp.firstMatch(left1);
    var match2 = exp.firstMatch(left2);

    if (match1 != null && match2 != null) {
      // Сравниваем буквенные префиксы.
      int prefixComparison = match1.group(1)!.compareTo(match2.group(1)!);
      if (prefixComparison != 0) return prefixComparison;

      // Префиксы равны: сравниваем числовые части как числа.
      int num1 = int.parse(match1.group(2)!);
      int num2 = int.parse(match2.group(2)!);
      return num1.compareTo(num2);
    } else {
      // Если не удалось выделить числовую часть, выполняем обычное лексикографическое сравнение.
      return left1.compareTo(left2);
    }
  }
}
