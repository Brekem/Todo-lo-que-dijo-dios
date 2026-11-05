import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/boricua_providers.dart';
import '../../core/theme/app_palette.dart';
import '../../shared/widgets/glossary_chips.dart';

/// Teología simple: cada término explicado en palabras sencillas, agrupado
/// por tema.
class GlossaryScreen extends ConsumerWidget {
  const GlossaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resources = ref.watch(boricuaResourcesProvider).value;
    final palette = AppPalette.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Teología simple')),
      body: resources == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final theme in resources.themes)
                  if (resources.glossary
                          .where((g) => g.theme == theme.id)
                          .toList()
                      case final terms when terms.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 16, 8, 4),
                      child: Text(
                        theme.title.toUpperCase(),
                        style: Theme.of(context).textTheme.labelLarge
                            ?.copyWith(color: palette.gold, letterSpacing: 1.5),
                      ),
                    ),
                    for (final t in terms)
                      ListTile(
                        key: Key('term-${t.term}'),
                        title: Text(t.term),
                        subtitle: Text(t.short),
                        onTap: () => showTermSheet(context, t),
                      ),
                  ],
              ],
            ),
    );
  }
}
