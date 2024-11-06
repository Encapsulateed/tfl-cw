List<(T, T)> slidingPairs<T>(List<T> list) {
  if (list.length < 2) return [];
  return List.generate(
      list.length - 1, (index) => (list[index], list[index + 1]));
}
