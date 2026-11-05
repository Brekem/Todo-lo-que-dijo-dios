import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/boricua_providers.dart';
import '../../core/theme/app_palette.dart';
import '../../data/models/boricua_resources.dart';
import '../../domain/bible/glossary_linker.dart';

/// Los términos de teología que aparecen en [text], explicados con un toque.
class GlossaryChips extends ConsumerWidget {
  const GlossaryChips({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glossary = ref.watch(boricuaResourcesProvider).value?.glossary;
    if (glossary == null) return const SizedBox.shrink();
    final terms = GlossaryLinker.termsIn(text, glossary);
    if (terms.isEmpty) return const SizedBox.shrink();
    final palette = AppPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Palabras clave:',
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: palette.warmGray),
          ),
          for (final t in terms)
            ActionChip(
              avatar: Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: palette.gold,
              ),
              label: Text(t.term),
              onPressed: () => showTermSheet(context, t),
            ),
        ],
      ),
    );
  }
}

Future<void> showTermSheet(BuildContext context, GlossaryTerm term) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final palette = AppPalette.of(context);
        final theme = Theme.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(term.term, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 12),
                Text(
                  '«${term.short}»',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: palette.blue,
                  ),
                ),
                const SizedBox(height: 12),
                Text(term.long, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 12),
                Text(
                  term.reference,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: palette.gold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
