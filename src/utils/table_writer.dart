import '../types/trellis_automaton.dart';
import 'dart:io';

void dump_automaton_details(File file, TrellisAutomaton ta) {
  var sink = file.openWrite();
  var stateList = ta.states.toList();
  var numStates = stateList.length;
  // Вывод алфавита
  sink.writeln('Алфавит:');
  sink.writeln(ta.alphabet.join(', '));

  // Вывод Init функции
  sink.writeln('\nInit функция:');
  for (var symbol in ta.alphabet) {
    var state = ta.Init(symbol);
    sink.writeln('$symbol -> ${state.toString()}');
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
  // Вывод переходной таблицы
  sink.writeln('\nТаблица переходов:');

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
  sink.close();
}
