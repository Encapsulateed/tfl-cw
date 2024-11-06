import 'dart:io';
import 'src/types/grammar.dart';
import 'src/types/parsing_tree/tree.dart';
import 'src/types/trellis_automaton.dart';
import 'src/utils/table_writer.dart';
import 'src/utils/tree_writer.dart';

// dart main.dart input.txt grammar.txt output.txt parse.dot -e
void main(List<String> arguments) {
  if (arguments.length < 3) throw 'Invalid amount of arguments!';

  var input_word = File(arguments[0]);
  var input_grammar = File(arguments[1]);
  var out_file = File(arguments[2]);
  var dot_file = File(arguments[3]);
  bool explanations = false;

  if (arguments.length == 5 && arguments[4] == '-e') explanations = true;

  if (!input_grammar.existsSync()) throw 'File does not exist!';

  var g = Grammar.fromFile(input_grammar);

  print(g);

  var ta = TrellisAutomaton.build(g);

  dump_transition_table(out_file, ta);

  var tree =
      ParsingTree.create(input_word.readAsStringSync(), ta, explanations);
  print(tree.layers);
  saveToDotFile(tree.layers, dot_file);
  print(tree.isRecognizing());
}
