import 'dart:io';

import 'src/types/grammar.dart';
import 'src/types/trellis_automaton.dart';

void main(List<String> arguments) {
  if (arguments.length > 1) throw 'Invalid amount of arguments!';

  var input_file = File(arguments[0]);

  if (!input_file.existsSync()) throw 'File does not exist!';

  var g = Grammar.fromFile(input_file);

  print(g);

  var ta = TrellisAutomaton.build(g);
  print(ta.states);
}
