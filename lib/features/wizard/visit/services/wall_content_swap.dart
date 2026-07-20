void swapMapEntries<T>(
  Map<String, T> values,
  String firstKey,
  String secondKey,
) {
  if (firstKey == secondKey) return;

  final hasFirst = values.containsKey(firstKey);
  final hasSecond = values.containsKey(secondKey);
  final firstValue = values.remove(firstKey);
  final secondValue = values.remove(secondKey);

  if (hasFirst) values[secondKey] = firstValue as T;
  if (hasSecond) values[firstKey] = secondValue as T;
}
