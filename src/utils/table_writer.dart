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
      var newState = ta.parsing_table[(stateList[i], stateList[j])];
      var newIndex = newState != null ? stateList.indexOf(newState) : -1;
      row.add(newIndex.toString().padLeft(4));
    }

    sink.writeln(row.join(' '));
  }

  sink.writeln('\nСписок состояния -> индекс:');
  for (var i = 0; i < stateList.length; i++) {
    sink.writeln('$i: ${stateList[i].toString()}');
  }

  sink.writeln('\nПринимающие состояния:');
  for (var finalState in ta.finals) {
    var finalIndex = stateList.indexOf(finalState);
    sink.writeln('$finalIndex: ${finalState.toString()}');
  }

  sink.close();
}
