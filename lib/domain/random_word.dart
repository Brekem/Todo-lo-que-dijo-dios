import 'dart:math';

import '../data/models/passage.dart';

/// Elige una palabra al azar de [passages], distinta de [except] si se puede.
Passage? pickRandom(List<Passage> passages, Random random, {Passage? except}) {
  if (passages.isEmpty) return null;
  if (passages.length == 1) return passages.first;
  while (true) {
    final p = passages[random.nextInt(passages.length)];
    if (p != except) return p;
  }
}
