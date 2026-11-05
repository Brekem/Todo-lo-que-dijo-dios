import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/boricua_providers.dart';
import '../../app/router.dart';
import '../../core/theme/app_palette.dart';
import '../../data/models/bible.dart';
import '../../data/models/bible_user_data.dart';
import 'chapter_screen.dart' show highlightColor;

/// Notas, marcadores, resaltados e historial.
class MyNotesScreen extends ConsumerWidget {
  const MyNotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(bibleUserProvider);
    final bible = ref.watch(bibleProvider).value;
    final sorted = data.annotations.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mis notas'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Notas'),
              Tab(text: 'Marcadores'),
              Tab(text: 'Resaltados'),
              Tab(text: 'Historial'),
            ],
          ),
        ),
        body: bible == null
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _List(bible, sorted.where((a) => a.note != null).toList()),
                  _List(bible, sorted.where((a) => a.bookmarked).toList()),
                  _List(
                    bible,
                    sorted.where((a) => a.highlight != null).toList(),
                  ),
                  _History(bible, data.history),
                ],
              ),
      ),
    );
  }
}

class _List extends StatelessWidget {
  const _List(this.bible, this.items);

  final Bible bible;
  final List<VerseAnnotation> items;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Todavía no hay nada aquí. Toca un versículo en la Biblia para '
            'guardarlo, resaltarlo o escribir una nota.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final a = items[i];
        final ref = VerseRef.parse(a.key);
        return ListTile(
          leading: a.highlight == null
              ? null
              : CircleAvatar(
                  radius: 8,
                  backgroundColor: highlightColor(a.highlight!, palette),
                ),
          title: Text(
            bible.reference(ref),
            style: TextStyle(color: palette.gold, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            a.note ?? bible.text(ref) ?? '',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => context.push(
            Routes.chapter(ref.bookId, ref.chapter, verse: ref.verse),
          ),
        );
      },
    );
  }
}

class _History extends StatelessWidget {
  const _History(this.bible, this.visits);

  final Bible bible;
  final List<ChapterVisit> visits;

  @override
  Widget build(BuildContext context) {
    if (visits.isEmpty) {
      return const Center(child: Text('Todavía no has leído ningún capítulo.'));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final v in visits)
          ListTile(
            leading: const Icon(Icons.history),
            title: Text(
              '${bible.book(v.bookId)?.name ?? v.bookId} ${v.chapter}',
            ),
            subtitle: Text(
              MaterialLocalizations.of(context).formatShortDate(v.at),
            ),
            onTap: () => context.push(Routes.chapter(v.bookId, v.chapter)),
          ),
      ],
    );
  }
}
