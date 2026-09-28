import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../core/analytics.dart';
import '../../data/models/passage.dart';
import '../../domain/random_word.dart';

/// Abre una palabra al azar de [passages].
void openRandomWord(
  BuildContext context,
  WidgetRef ref,
  List<Passage> passages,
) {
  final passage = pickRandom(passages, ref.read(randomProvider));
  if (passage == null) return;
  HapticFeedback.mediumImpact();
  Analytics.log('random_word', {'id': passage.id});
  context.push(Routes.passage(passage.id));
}

/// Botón «Palabra al azar» (icono de mezclar) para barras de título.
class RandomWordAction extends ConsumerWidget {
  const RandomWordAction({
    super.key,
    required this.passages,
    this.tooltip = 'Palabra al azar',
  });

  final List<Passage> passages;
  final String tooltip;

  @override
  Widget build(BuildContext context, WidgetRef ref) => IconButton(
    tooltip: tooltip,
    icon: const Icon(Icons.shuffle_rounded),
    onPressed: passages.isEmpty
        ? null
        : () => openRandomWord(context, ref, passages),
  );
}
