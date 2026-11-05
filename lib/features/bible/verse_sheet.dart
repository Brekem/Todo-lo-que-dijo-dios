import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/boricua_providers.dart';
import '../../app/router.dart';
import '../../core/config/edition.dart';
import '../../core/theme/app_palette.dart';
import '../../data/models/bible.dart';
import '../../data/models/bible_user_data.dart';
import '../../domain/bible/verse_explainer.dart';
import '../../shared/widgets/glossary_chips.dart';
import '../../shared/widgets/section_label.dart';
import 'chapter_screen.dart' show highlightColor;

Future<void> showVerseSheet(BuildContext context, VerseRef verse) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (context, scroll) =>
            VerseStudyView(verse: verse, scroll: scroll),
      ),
    );

/// Las cinco partes de cada versículo: texto bíblico, paráfrasis boricua,
/// explicación simple, aplicación práctica y oración sugerida.
class VerseStudyView extends ConsumerWidget {
  const VerseStudyView({super.key, required this.verse, this.scroll});

  final VerseRef verse;
  final ScrollController? scroll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = AppPalette.of(context);
    final theme = Theme.of(context);
    final bible = ref.watch(bibleProvider).value;
    final text = bible?.text(verse) ?? '';
    final reference = bible?.reference(verse) ?? verse.key;
    final explanation = ref.watch(verseExplanationProvider(verse));
    final annotation = ref.watch(
      bibleUserProvider.select((d) => d.annotations[verse.key]),
    );
    final user = ref.read(bibleUserProvider.notifier);

    return ListView(
      key: const Key('verse-study'),
      controller: scroll,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      children: [
        Text(
          reference,
          style: theme.textTheme.titleLarge?.copyWith(color: palette.gold),
        ),
        const SizedBox(height: 16),
        const SectionLabel('Texto bíblico'),
        const SizedBox(height: 8),
        Text(text, style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
        Text(
          'Reina-Valera 1909',
          style: theme.textTheme.labelSmall?.copyWith(color: palette.warmGray),
        ),
        const SizedBox(height: 16),
        _Actions(
          annotation: annotation,
          onHighlight: (h) => user.setHighlight(verse, h),
          onBookmark: () => user.toggleBookmark(verse),
          onNote: () => _editNote(context, ref, annotation?.note),
          onShare: () => SharePlus.instance.share(
            ShareParams(
              text:
                  '«$text»\n— $reference\n\n'
                  '${explanation.value?.paraphrase ?? ''}\n\n'
                  'Compartido desde «${Edition.current.appName}».',
            ),
          ),
        ),
        if (annotation?.note != null) ...[
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(Icons.sticky_note_2_outlined, color: palette.blue),
              title: const Text('Mi nota'),
              subtitle: Text(annotation!.note!),
              onTap: () => _editNote(context, ref, annotation.note),
            ),
          ),
        ],
        const SizedBox(height: 24),
        explanation.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text('No se pudo explicar este versículo: $e'),
          data: (x) => x == null ? const _NoExplanation() : _Explanation(x),
        ),
      ],
    );
  }

  Future<void> _editNote(
    BuildContext context,
    WidgetRef ref,
    String? current,
  ) async {
    final saved = await showDialog<String>(
      context: context,
      builder: (_) => _NoteDialog(current: current),
    );
    if (saved != null) {
      ref.read(bibleUserProvider.notifier).setNote(verse, saved);
    }
  }
}

/// El cuadro de la nota es dueño de su texto: lo libera al terminar de
/// cerrarse, no antes.
class _NoteDialog extends StatefulWidget {
  const _NoteDialog({this.current});

  final String? current;

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  late final _controller = TextEditingController(text: widget.current);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Mi nota'),
    content: TextField(
      key: const Key('note-field'),
      controller: _controller,
      autofocus: true,
      maxLines: 5,
      decoration: const InputDecoration(
        hintText: '¿Qué te dice Dios con este versículo?',
      ),
    ),
    actions: [
      if (widget.current != null)
        TextButton(
          onPressed: () => Navigator.pop(context, ''),
          child: const Text('Borrar'),
        ),
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        key: const Key('note-save'),
        onPressed: () => Navigator.pop(context, _controller.text),
        child: const Text('Guardar'),
      ),
    ],
  );
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.annotation,
    required this.onHighlight,
    required this.onBookmark,
    required this.onNote,
    required this.onShare,
  });

  final VerseAnnotation? annotation;
  final ValueChanged<Highlight?> onHighlight;
  final VoidCallback onBookmark;
  final VoidCallback onNote;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final current = annotation?.highlight;
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final h in Highlight.values)
          InkResponse(
            key: Key('highlight-${h.name}'),
            onTap: () => onHighlight(current == h ? null : h),
            radius: 22,
            child: Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: highlightColor(h, palette),
                border: Border.all(
                  color: current == h
                      ? palette.ink
                      : palette.warmGray.withValues(alpha: 0.4),
                  width: current == h ? 2 : 1,
                ),
              ),
            ),
          ),
        IconButton(
          key: const Key('bookmark'),
          tooltip: 'Marcador',
          onPressed: onBookmark,
          icon: Icon(
            (annotation?.bookmarked ?? false)
                ? Icons.bookmark
                : Icons.bookmark_border,
            color: palette.gold,
          ),
        ),
        IconButton(
          key: const Key('note'),
          tooltip: 'Nota',
          onPressed: onNote,
          icon: Icon(Icons.edit_note, color: palette.blue),
        ),
        IconButton(
          tooltip: 'Compartir',
          onPressed: onShare,
          icon: Icon(Icons.share_outlined, color: palette.warmGray),
        ),
      ],
    );
  }
}

class _Explanation extends StatelessWidget {
  const _Explanation(this.x);

  final VerseExplanation x;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final theme = Theme.of(context);
    Widget block(String label, String text, {Key? key}) => Padding(
      key: key,
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(label),
          const SizedBox(height: 8),
          Text(text, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          key: const Key('paraphrase'),
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          margin: const EdgeInsets.only(bottom: 22),
          decoration: BoxDecoration(
            color: palette.blueSoft,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PARÁFRASIS BORICUA',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: palette.blue,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                x.paraphrase,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        block('Explicación simple', x.explanation),
        GlossaryChips(text: '${x.paraphrase} ${x.explanation}'),
        const SizedBox(height: 22),
        block('Aplicación práctica', x.application),
        block('Oración sugerida', x.prayer),
        Text(
          x.source == ExplanationSource.study
              ? 'Escrito a mano para la Biblia Boricua.'
              : 'Explicación generada con IA. Compárala siempre con tu Biblia.',
          style: theme.textTheme.labelSmall?.copyWith(color: palette.warmGray),
        ),
        if (x.study case final study?) ...[
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const Key('open-study'),
            onPressed: () => context.push(Routes.passage(study.id)),
            icon: const Icon(Icons.school_outlined),
            label: Text('Estudio completo: ${study.reference}'),
          ),
        ],
      ],
    );
  }
}

class _NoExplanation extends StatelessWidget {
  const _NoExplanation();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = AppPalette.of(context);
    return Card(
      key: const Key('no-explanation'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_stories_outlined, color: palette.gold),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    'Paráfrasis boricua',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Este versículo todavía no tiene un estudio escrito a mano. '
              'Cuando la app esté conectada a la nube, la paráfrasis boricua, la '
              'explicación, la aplicación y la oración aparecerán aquí. Mientras '
              'tanto, busca los estudios de la pantalla de inicio o pregúntale al '
              'asistente.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
