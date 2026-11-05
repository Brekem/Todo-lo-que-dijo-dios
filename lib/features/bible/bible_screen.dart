import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/boricua_providers.dart';
import '../../app/router.dart';
import '../../core/theme/app_palette.dart';
import '../../data/models/bible.dart';
import '../../shared/widgets/section_label.dart';

/// La Biblia completa: Antiguo y Nuevo Testamento, libro por libro.
class BibleScreen extends ConsumerStatefulWidget {
  const BibleScreen({super.key});

  @override
  ConsumerState<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends ConsumerState<BibleScreen> {
  Testament _testament = Testament.oldTestament;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final theme = Theme.of(context);
    final bible = ref.watch(bibleProvider);
    final last = ref.watch(bibleUserRepositoryProvider).lastChapter;
    ref.watch(bibleUserProvider); // se actualiza al leer un capítulo
    return Scaffold(
      appBar: AppBar(
        title: const Text('La Biblia'),
        actions: [
          IconButton(
            key: const Key('bible-search'),
            tooltip: 'Buscar en la Biblia',
            icon: const Icon(Icons.search),
            onPressed: () => context.push(Routes.bibleSearch),
          ),
          IconButton(
            tooltip: 'Mis notas y marcadores',
            icon: const Icon(Icons.bookmarks_outlined),
            onPressed: () => context.push(Routes.myNotes),
          ),
        ],
      ),
      body: bible.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('No se pudo abrir la Biblia: $e')),
        data: (bible) {
          final lastRef = last?.split('.');
          final lastBook = lastRef == null ? null : bible.book(lastRef[0]);
          final books = bible.testament(_testament);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              if (lastBook != null)
                Card(
                  child: ListTile(
                    leading: Icon(Icons.menu_book, color: palette.gold),
                    title: const Text('Seguir leyendo'),
                    subtitle: Text('${lastBook.name} ${lastRef![1]}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(
                      Routes.chapter(lastBook.id, int.parse(lastRef[1])),
                    ),
                  ),
                ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.event_note_outlined, color: palette.gold),
                  title: const Text('Planes de lectura'),
                  subtitle: const Text(
                    'Juan en 21 días, Salmos, la Biblia en un año…',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(Routes.plans),
                ),
              ),
              const SizedBox(height: 16),
              SegmentedButton<Testament>(
                segments: const [
                  ButtonSegment(
                    value: Testament.oldTestament,
                    label: Text('Antiguo'),
                  ),
                  ButtonSegment(
                    value: Testament.newTestament,
                    label: Text('Nuevo'),
                  ),
                ],
                selected: {_testament},
                onSelectionChanged: (s) => setState(() => _testament = s.first),
              ),
              const SizedBox(height: 20),
              SectionLabel(_testament.title),
              const SizedBox(height: 8),
              for (final b in books)
                ListTile(
                  key: Key('book-${b.id}'),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  leading: CircleAvatar(
                    backgroundColor: palette.blueSoft,
                    child: Text(
                      b.abbr,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: palette.blue,
                      ),
                    ),
                  ),
                  title: Text(b.name),
                  subtitle: Text(
                    b.chapterCount == 1
                        ? '1 capítulo'
                        : '${b.chapterCount} capítulos',
                  ),
                  onTap: () => b.chapterCount == 1
                      ? context.push(Routes.chapter(b.id, 1))
                      : _pickChapter(context, b),
                ),
            ],
          );
        },
      ),
    );
  }

  void _pickChapter(BuildContext context, BibleBook book) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(book.name, style: Theme.of(sheet).textTheme.titleLarge),
              const SizedBox(height: 12),
              Flexible(
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 6,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: [
                    for (var c = 1; c <= book.chapterCount; c++)
                      OutlinedButton(
                        key: Key('chapter-$c'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () {
                          Navigator.pop(sheet);
                          context.push(Routes.chapter(book.id, c));
                        },
                        child: Text('$c'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
