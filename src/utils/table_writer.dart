import '../types/trellis_automaton.dart';
import 'dart:io';

void dump_transition_table(File file, TrellisAutomaton ta) {
  var sink = file.openWrite();

  var stateList = ta.states.toList();
  var numStates = stateList.length;

  var header = [' '.padLeft(4)];
  header.addAll(List.generate(numStates, (i) => i.toString().padLeft(4)));
  sink.writeln(header.join(' '));

  for (var i = 0; i < numStates; i++) {
    var row = [i.toString().padLeft(4)];

    for (var j = 0; j < numStates; j++) {
      var newState = ta.Transition(stateList[i], stateList[j]);
      var newIndex = stateList.indexOf(newState);
      row.add(newIndex.toString().padLeft(4));
    }

    sink.writeln(row.join(' '));
  }

  sink.writeln('\n');

  for (var i = 0; i < stateList.length; i++) {
    sink.writeln('$i: ${stateList[i].toString()}');
  }

  sink.close();
}
