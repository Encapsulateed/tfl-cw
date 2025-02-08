import 'dart:io';
import 'src/types/grammar.dart';
import 'src/types/parsing_tree/tree.dart';
import 'src/types/trellis_automaton.dart';
import 'src/utils/table_writer.dart';
import 'src/utils/tree_writer.dart';

// dart main.dart input.txt grammar.txt output.txt parse.dot -e
// dart main.dart input.txt output.txt output.txt parse.dot -e -m

void main(List<String> arguments) {
  const DEBUG = false;

  if (arguments.length < 3) throw 'Invalid amount of arguments!';

  var input_word = File(arguments[0]);
  var input_file = File(arguments[1]);
  var out_file = File(arguments[2]);
  var dot_file = File(arguments[3]);

  bool explanations = false;
  bool use_automaton = false;

  if (arguments.contains('-e')) explanations = true;
  if (arguments.contains('-m')) use_automaton = true;

  if (!input_file.existsSync()) throw 'Input file does not exist!';

  if (!DEBUG) {
    TrellisAutomaton ta;

    if (use_automaton) {
      ta = TrellisAutomaton.fromFile(input_file);
      ta.toGrammar();
      print(ta);
    } else {
      var g = Grammar.fromFile(input_file);
      g.convertToLNF();
      g.writeGrammarToFile(File('LNF_grammar.txt'));

      ta = TrellisAutomaton.build(g);
    }

    dump_automaton_details(out_file, ta);

    var tree = ParsingTree.create(
        input_word.readAsStringSync().replaceAll(' ', ''), ta, explanations);

    saveToDotFile(tree.layers, dot_file);
    print(tree.isRecognizing());
  }
}
