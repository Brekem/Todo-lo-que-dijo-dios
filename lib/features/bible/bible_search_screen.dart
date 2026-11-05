import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/boricua_providers.dart';
import '../../app/router.dart';
import '../../core/theme/app_palette.dart';
import '../../data/models/bible.dart';
import '../../domain/bible/bible_search.dart';

/// Busca en los 31,102 versículos: por palabras («no temas») o por cita
/// («Juan 3:16», «sal 23»).
class BibleSearchScreen extends ConsumerStatefulWidget {
  const BibleSearchScreen({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  ConsumerState<BibleSearchScreen> createState() => _BibleSearchScreenState();
}

class _BibleSearchScreenState extends ConsumerState<BibleSearchScreen> {
  late final _controller = TextEditingController(text: widget.initialQuery);
  late String _query = widget.initialQuery;
  Testament? _testament;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final theme = Theme.of(context);
    final index = ref.watch(bibleIndexProvider);
    final bible = ref.watch(bibleProvider).value;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          key: const Key('bible-search-field'),
          controller: _controller,
          autofocus: widget.initialQuery.isEmpty,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Palabras o cita: «paz», «Juan 3:16»',
            border: InputBorder.none,
          ),
          onSubmitted: (q) => setState(() => _query = q),
          onChanged: (q) {
            if (q.trim().length >= 3 || q.isEmpty) setState(() => _query = q);
          },
        ),
      ),
      body: index.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (index) {
          if (_query.trim().isEmpty || bible == null) {
            return const _Hints();
          }
          final jump = index.reference(_query);
          final hits = index.search(_query, testament: _testament);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              if (jump != null)
                Card(
                  color: palette.blueSoft,
                  child: ListTile(
                    key: const Key('jump-reference'),
                    leading: Icon(Icons.arrow_forward, color: palette.blue),
                    title: Text(
                      '${jump.book.name} ${jump.chapter}'
                      '${jump.verse == null ? '' : ':${jump.verse}'}',
                    ),
                    subtitle: const Text('Ir a la cita'),
                    onTap: () => context.push(
                      Routes.chapter(
                        jump.book.id,
                        jump.chapter,
                        verse: jump.verse,
                      ),
                    ),
                  ),
                ),
              Wrap(
                spacing: 8,
                children: [
                  for (final t in [null, ...Testament.values])
                    ChoiceChip(
                      label: Text(t?.title ?? 'Toda la Biblia'),
                      selected: _testament == t,
                      onSelected: (_) => setState(() => _testament = t),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  hits.isEmpty
                      ? 'No se encontraron versículos.'
                      : hits.length >= 200
                      ? 'Los primeros 200 versículos'
                      : '${hits.length} versículos',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: palette.warmGray,
                  ),
                ),
              ),
              for (final h in hits) _HitTile(hit: h, bible: bible),
            ],
          );
        },
      ),
    );
  }
}

class _HitTile extends StatelessWidget {
  const _HitTile({required this.hit, required this.bible});

  final BibleHit hit;
  final Bible bible;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      title: Text(
        bible.reference(hit.ref),
        style: TextStyle(color: palette.gold, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(hit.text),
      onTap: () => context.push(
        Routes.chapter(hit.ref.bookId, hit.ref.chapter, verse: hit.ref.verse),
      ),
    );
  }
}

class _Hints extends StatelessWidget {
  const _Hints();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        'Escribe palabras («no temas», «paz», «perdón») para buscarlas en toda '
        'la Biblia, o una cita («Juan 3:16», «Salmos 23», «1 Co 13») para ir '
        'directo.',
        style: theme.textTheme.bodyLarge,
      ),
    );
  }
}
