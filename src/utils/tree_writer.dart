import 'dart:io';
import '../types/parsing_tree/tree_node.dart';
import 'common.dart';

void saveToDotFile(List<List<Node>> layers, File file) {
  final buffer = StringBuffer();
  buffer.writeln('digraph G {');
  buffer.writeln('rankdir=TB;'); // Оставляем направление сверху вниз
  buffer.writeln('node [shape=plaintext];');

  // Перебор слоев в обратном порядке, чтобы нулевой слой был внизу
  for (int i = layers.length - 1; i >= 0; i--) {
    buffer.write('{ rank=same; ');
    List<Node> layer = layers[i];
    for (int j = 0; j < layer.length; j++) {
      String nodeId = 'node_${i}_$j';
      buffer.write('$nodeId [label="${layer[j].toString()}"]; ');
    }
    buffer.writeln('}');
  }

  for (int i = 0; i < layers.length - 1; i++) {
    List<Node> currentLayer = layers[i];
    var pairs = slidingPairs(currentLayer);
    for (int j = 0; j < pairs.length; j++) {
      var (node1, node2) = pairs[j];
      String node1Id = 'node_${i}_${currentLayer.indexOf(node1)}';
      String node2Id = 'node_${i}_${currentLayer.indexOf(node2)}';
      String targetNodeId = 'node_${i + 1}_$j';

      buffer.writeln('$node1Id -> $targetNodeId;');
      buffer.writeln('$node2Id -> $targetNodeId;');
    }
  }

  buffer.writeln('}');

  file.writeAsStringSync(buffer.toString());
}
