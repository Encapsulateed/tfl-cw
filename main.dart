import 'dart:io';

import 'src/types/grammar.dart';

import 'src/types/trellis_automaton.dart';
import 'src/utils/table_writer.dart';

void main(List<String> arguments) {
  if (arguments.length != 2) throw 'Invalid amount of arguments!';

  var input_file = File(arguments[0]);
  var out_file = File(arguments[1]);

  if (!input_file.existsSync() || !out_file.existsSync())
    throw 'File does not exist!';

  var g = Grammar.fromFile(input_file);

  print(g);

  var ta = TrellisAutomaton.build(g);

  dump_transition_table(out_file, ta);
}
