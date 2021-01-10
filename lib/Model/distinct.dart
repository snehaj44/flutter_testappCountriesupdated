Iterable<T> distinct<T>(Iterable<T> elements) sync* {
  final visited = <T>{};
  for (final el in elements) {
    if (visited.contains(el)) continue;
    yield el;
    visited.add(el);
  }
}
