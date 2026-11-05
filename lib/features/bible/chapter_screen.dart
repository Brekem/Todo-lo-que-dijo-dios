import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/boricua_providers.dart';
import '../../app/router.dart';
import '../../core/theme/app_palette.dart';
import '../../data/models/bible.dart';
import '../../data/models/bible_user_data.dart';
import 'chapter_reader.dart';
import 'verse_sheet.dart';

Color highlightColor(Highlight h, AppPalette palette) => switch (h) {
  Highlight.yellow => const Color(0x66F5C518),
  Highlight.green => const Color(0x5546B77A),
  Highlight.blue => palette.blue.withValues(alpha: 0.22),
  Highlight.pink => const Color(0x55F06292),
};

/// Un capítulo de la Biblia. Tocar un versículo abre su estudio: texto,
/// paráfrasis boricua, explicación, aplicación y oración.
class ChapterScreen extends ConsumerStatefulWidget {
  const ChapterScreen({
    super.key,
    required this.bookId,
    required this.chapter,
    this.verse,
  });

  final String bookId;
  final int chapter;

  /// Versículo al que se llega (desde una búsqueda o un plan).
  final int? verse;

  @override
  ConsumerState<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends ConsumerState<ChapterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(bibleUserProvider.notifier).visit(widget.bookId, widget.chapter);
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final theme = Theme.of(context);
    final book = ref.watch(bookProvider(widget.bookId)).value;
    final user = ref.watch(bibleUserProvider);
    final reader = ref.watch(chapterReaderProvider);
    if (book == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final verses = book.chapter(widget.chapter);
    final reading = reader.isReading(book.id, widget.chapter);
    return Scaffold(
      appBar: AppBar(
        title: Text('${book.name} ${widget.chapter}'),
        actions: [
          IconButton(
            key: const Key('chapter-listen'),
            tooltip: reading ? 'Detener' : 'Escuchar el capítulo',
            icon: Icon(reading ? Icons.stop_circle_outlined : Icons.headphones),
            onPressed: () => reading
                ? ref.read(chapterReaderProvider.notifier).stop()
                : ref
                      .read(chapterReaderProvider.notifier)
                      .play(book, widget.chapter),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        itemCount: verses.length + 1,
        itemBuilder: (context, i) {
          if (i == verses.length) {
            return _ChapterNav(book: book, chapter: widget.chapter);
          }
          final ref0 = VerseRef(book.id, widget.chapter, i + 1);
          final a = user.annotations[ref0.key];
          final current =
              reader.isReading(book.id, widget.chapter) &&
              reader.verse == i + 1;
          final target = widget.verse == i + 1;
          return InkWell(
            key: Key('verse-${i + 1}'),
            borderRadius: BorderRadius.circular(10),
            onTap: () => showVerseSheet(context, ref0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: current
                    ? palette.goldSoft
                    : a?.highlight != null
                    ? highlightColor(a!.highlight!, palette)
                    : target
                    ? palette.blueSoft
                    : null,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${i + 1} ',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: palette.gold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(text: verses[i]),
                    if (a?.bookmarked ?? false)
                      WidgetSpan(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.bookmark,
                            size: 16,
                            color: palette.gold,
                          ),
                        ),
                      ),
                    if (a?.note != null)
                      WidgetSpan(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.sticky_note_2_outlined,
                            size: 16,
                            color: palette.blue,
                          ),
                        ),
                      ),
                  ],
                ),
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.55),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ChapterNav extends StatelessWidget {
  const _ChapterNav({required this.book, required this.chapter});

  final BibleBook book;
  final int chapter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Row(
        children: [
          if (chapter > 1)
            OutlinedButton.icon(
              onPressed: () =>
                  context.pushReplacement(Routes.chapter(book.id, chapter - 1)),
              icon: const Icon(Icons.chevron_left),
              label: Text('Capítulo ${chapter - 1}'),
            ),
          const Spacer(),
          if (chapter < book.chapterCount)
            FilledButton.icon(
              key: const Key('next-chapter'),
              onPressed: () =>
                  context.pushReplacement(Routes.chapter(book.id, chapter + 1)),
              icon: const Icon(Icons.chevron_right),
              label: Text('Capítulo ${chapter + 1}'),
            ),
        ],
      ),
    );
  }
}
