import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/boricua_providers.dart';
import '../../data/models/bible.dart';
import '../../domain/listening/listening_background.dart';
import '../../domain/listening/listening_controller.dart';

/// Biblia en audio: lee un capítulo entero, versículo por versículo, con la
/// voz del teléfono. Sigue con la pantalla apagada (servicio de reproducción).
class ChapterReaderState {
  const ChapterReaderState({this.bookId, this.chapter, this.verse});

  final String? bookId;
  final int? chapter;

  /// Versículo que se está leyendo (desde 1), o `null` si no se lee nada.
  final int? verse;

  bool isReading(String book, int ch) =>
      verse != null && bookId == book && chapter == ch;
}

class ChapterReader extends Notifier<ChapterReaderState> {
  int _run = 0;

  @override
  ChapterReaderState build() => const ChapterReaderState();

  Future<void> play(BibleBook book, int chapter, {int from = 1}) async {
    final run = ++_run;
    // La lectura de palabras y la del capítulo usan la misma voz.
    await ref.read(listeningProvider.notifier).stop();
    final engine = ref.read(ttsEngineProvider);
    final audio = ref.read(backgroundAudioProvider);
    audio?.attach((
      play: () async => play(book, chapter, from: state.verse ?? 1),
      pause: stop,
      next: () async {},
      previous: () async {},
      stop: stop,
    ));
    final verses = book.chapter(chapter);
    if (from == 1) {
      state = ChapterReaderState(bookId: book.id, chapter: chapter, verse: 1);
      await audio?.show(
        playing: true,
        title: '${book.name} $chapter',
        subtitle: 'Biblia en audio',
      );
      await engine.speak('${book.name}, capítulo $chapter.');
    }
    for (var v = from; v <= verses.length; v++) {
      if (run != _run || !ref.mounted) return;
      state = ChapterReaderState(bookId: book.id, chapter: chapter, verse: v);
      await engine.speak(verses[v - 1]);
    }
    if (run == _run && ref.mounted) await stop();
  }

  Future<void> stop() async {
    _run++;
    state = const ChapterReaderState();
    await ref.read(ttsEngineProvider).stop();
    await ref.read(backgroundAudioProvider)?.hide();
    // La notificación vuelve a manejar la escucha de palabras.
    ref.invalidate(listeningBackgroundProvider);
  }
}

final chapterReaderProvider =
    NotifierProvider<ChapterReader, ChapterReaderState>(ChapterReader.new);

/// Para que la pantalla del capítulo no dependa de la Biblia cargada.
final bookProvider = FutureProvider.family<BibleBook?, String>(
  (ref, id) async => (await ref.watch(bibleProvider.future)).book(id),
);
