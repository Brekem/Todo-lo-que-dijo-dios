import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_palette.dart';
import '../../data/models/content_bundle.dart';
import '../../domain/listening/listening_controller.dart';
import '../../domain/listening/narration.dart';
import '../../shared/widgets/async_content.dart';
import '../../shared/widgets/sacred_background.dart';
import '../../shared/widgets/section_label.dart';

/// "Escuchar la Voz de Dios": lee en voz alta las palabras de la 1 a la última,
/// con cita, contexto, explicación, aplicación y oración.
class ListenScreen extends ConsumerStatefulWidget {
  const ListenScreen({super.key, this.startPassageId});

  /// Si se indica, empieza a leer desde esta palabra.
  final String? startPassageId;

  @override
  ConsumerState<ListenScreen> createState() => _ListenScreenState();
}

class _ListenScreenState extends ConsumerState<ListenScreen> {
  @override
  void initState() {
    super.initState();
    final id = widget.startPassageId;
    if (id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final content = await ref.read(contentProvider.future);
        final passage = content.passageById(id);
        if (passage != null && mounted) {
          ref
              .read(listeningProvider.notifier)
              .playFrom(content.indexOf(passage));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Escuchar'),
      ),
      body: SacredBackground(
        particles: 26,
        child: SafeArea(
          child: AsyncContent(
            builder: (context, content) => _ListenBody(
              content: content,
              startedFromWord: widget.startPassageId != null,
            ),
          ),
        ),
      ),
    );
  }
}

class _ListenBody extends ConsumerWidget {
  const _ListenBody({required this.content, required this.startedFromWord});

  final ContentBundle content;
  final bool startedFromWord;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(listeningProvider);
    final controller = ref.read(listeningProvider.notifier);
    final palette = AppPalette.of(context);
    final theme = Theme.of(context);
    final total = content.passages.length;
    final index = state.passageIndex.clamp(0, total - 1);
    final length = state.length(total);
    final step = state.step.clamp(0, length - 1);
    final query = state.searchQuery;
    final passage = content.passages[index];
    final era = content.eraById(passage.era)?.title ?? '';
    final sectionText =
        Narration.segments(
          passage,
          position: index + 1,
          total: total,
          eraTitle: era,
        )[state.section.index]
        // El rótulo ya se muestra arriba: no repetirlo en el texto.
        .replaceFirst(
          RegExp('^${RegExp.escape(state.section.title)}[.]?\\s*'),
          '',
        );

    // Al abrir: "Te quedaste en…" con continuar o comenzar de nuevo.
    final showResume =
        !startedFromWord &&
        state.status != ListeningStatus.playing &&
        state.hasSavedPosition &&
        state.started;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      children: [
        Text('Escuchar la\nVoz de Dios', style: theme.textTheme.displaySmall),
        const SizedBox(height: 10),
        Text(
          state.fromSearch
              ? 'Las $length ${length == 1 ? 'palabra' : 'palabras'} de tu '
                    'búsqueda «$query», una tras otra, con su explicación, '
                    'aplicación y oración. Se guarda dónde te quedas.'
              : state.shuffle
              ? 'Las $total palabras en orden aleatorio, cada una con su '
                    'explicación, aplicación y oración. Se guarda dónde te quedas.'
              : 'Las $total palabras, de Génesis a Apocalipsis, con su '
                    'explicación, aplicación y oración. Se guarda dónde te quedas.',
          style: theme.textTheme.bodyMedium?.copyWith(color: palette.warmGray),
        ),
        if (state.fromSearch)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              onPressed: controller.leaveSearch,
              icon: const Icon(Icons.close_rounded, size: 18),
              label: Text('Escuchar las $total palabras'),
            ),
          ),
        const SizedBox(height: 24),
        if (state.status == ListeningStatus.finished)
          _Banner(
            icon: Icons.celebration_outlined,
            title: 'Completaste el recorrido',
            subtitle: state.fromSearch
                ? 'Escuchaste las $length palabras de tu búsqueda «$query».'
                : 'Escuchaste las $total palabras de Dios.',
            primaryLabel: 'Comenzar de nuevo',
            onPrimary: controller.restart,
          )
        else if (showResume)
          _Banner(
            icon: Icons.bookmark_added_outlined,
            title: 'Te quedaste en la palabra ${index + 1} de $total',
            subtitle: state.fromSearch
                ? '${passage.reference} · ${state.section.title}\n'
                      'Búsqueda «$query»: vas por la ${step + 1} de $length'
                : state.shuffle
                ? '${passage.reference} · ${state.section.title}\n'
                      'Orden aleatorio: vas por la ${step + 1} de $total'
                : '${passage.reference} · ${state.section.title}',
            primaryLabel: 'Continuar',
            onPrimary: controller.play,
            secondaryLabel: 'Comenzar de nuevo',
            onSecondary: controller.restart,
          ),
        if (state.status == ListeningStatus.error)
          _Banner(
            icon: Icons.record_voice_over_outlined,
            title: 'No se pudo usar la voz del teléfono',
            subtitle:
                'Instala o activa una voz en español en Ajustes del '
                'teléfono → Texto a voz, y vuelve a intentarlo.',
            primaryLabel: 'Reintentar',
            onPrimary: controller.play,
          ),
        const SizedBox(height: 16),
        // Palabra actual
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  [
                    state.fromSearch
                        ? 'BÚSQUEDA · ${step + 1} DE $length'
                        : state.shuffle
                        ? 'ALEATORIO · ${step + 1} DE $total'
                        : 'PALABRA ${index + 1} DE $total',
                    if (state.repeat != ListenRepeat.off)
                      state.repetitions > 0
                          ? 'REPETIDA ${state.repetitions} '
                                '${state.repetitions == 1 ? 'VEZ' : 'VECES'}'
                          : 'EN REPETICIÓN',
                    era.toUpperCase(),
                  ].join(' · '),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: palette.gold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '«${passage.quote}»',
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  passage.reference,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: palette.gold,
                  ),
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value:
                        (step +
                            (state.section.index + 1) /
                                NarrationSection.values.length) /
                        length,
                    minHeight: 3,
                    color: palette.gold,
                    backgroundColor: palette.warmGray.withValues(alpha: 0.15),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Sección que se está leyendo (para seguir con la vista).
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          child: Container(
            key: ValueKey('$index-${state.section.index}'),
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
            decoration: BoxDecoration(
              color: state.section == NarrationSection.prayer
                  ? palette.blueSoft
                  : state.section == NarrationSection.problem
                  ? palette.goldSoft
                  : palette.parchment.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionLabel(state.section.title),
                const SizedBox(height: 10),
                Text(sectionText, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        // Controles
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: state.shuffle
                  ? 'Quitar orden aleatorio'
                  : 'Escuchar en orden aleatorio',
              iconSize: 26,
              isSelected: state.shuffle,
              style: IconButton.styleFrom(foregroundColor: palette.warmGray),
              onPressed: () {
                controller.toggleShuffle();
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        state.shuffle
                            ? 'Orden cronológico: de Génesis a Apocalipsis'
                            : state.fromSearch
                            ? 'Orden aleatorio: dejas la búsqueda y se mezclan '
                                  'las $total palabras'
                            : 'Orden aleatorio: las $total palabras mezcladas',
                      ),
                    ),
                  );
              },
              icon: const Icon(Icons.shuffle_rounded),
              selectedIcon: Icon(Icons.shuffle_on_rounded, color: palette.gold),
            ),
            const SizedBox(width: 6),
            IconButton(
              tooltip: 'Palabra anterior',
              iconSize: 32,
              onPressed: step == 0 ? null : controller.previousWord,
              icon: const Icon(Icons.skip_previous_rounded),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 76,
              height: 76,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: EdgeInsets.zero,
                  backgroundColor: palette.gold,
                  foregroundColor: const Color(0xFF1B1609),
                ),
                onPressed: controller.toggle,
                child: Icon(
                  state.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  size: 40,
                  semanticLabel: state.isPlaying ? 'Pausar' : 'Escuchar',
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              tooltip: 'Palabra siguiente',
              iconSize: 32,
              onPressed: step >= length - 1 ? null : controller.nextWord,
              icon: const Icon(Icons.skip_next_rounded),
            ),
            const SizedBox(width: 6),
            IconButton(
              tooltip: state.fromSearch
                  ? 'Comenzar de nuevo la búsqueda'
                  : state.shuffle
                  ? 'Comenzar de nuevo con otro orden'
                  : 'Comenzar de nuevo desde la palabra 1',
              iconSize: 26,
              style: IconButton.styleFrom(foregroundColor: palette.warmGray),
              onPressed: controller.restart,
              icon: const Icon(Icons.replay_rounded),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Center(
          child: Text(
            state.fromSearch
                ? 'Resultados de «$query», en orden'
                : state.shuffle
                ? 'Orden aleatorio'
                : 'Orden cronológico · de Génesis a Apocalipsis',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              color: state.shuffle || state.fromSearch
                  ? palette.gold
                  : palette.warmGray,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: _RepeatButton(
            mode: state.repeat,
            onPressed: () {
              final next = state.repeat.next;
              controller.setRepeat(next);
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(switch (next) {
                      ListenRepeat.off => 'Sin repetir: sigue con la siguiente',
                      ListenRepeat.word =>
                        'Se repetirá esta palabra una y otra vez',
                      ListenRepeat.quote =>
                        'Se repetirá solo lo que Dios dijo, una y otra vez',
                    }),
                  ),
                );
            },
          ),
        ),
        const SizedBox(height: 18),
        Center(
          child: SegmentedButton<double>(
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: palette.goldSoft,
            ),
            segments: const [
              ButtonSegment(value: 0.8, label: Text('Lenta')),
              ButtonSegment(value: 1.0, label: Text('Normal')),
              ButtonSegment(value: 1.25, label: Text('Rápida')),
            ],
            selected: {state.rate},
            onSelectionChanged: (s) => controller.setRate(s.first),
          ),
        ),
      ],
    );
  }
}

/// Sin repetir → repetir la palabra → repetir solo lo que Dios dijo.
class _RepeatButton extends StatelessWidget {
  const _RepeatButton({required this.mode, required this.onPressed});

  final ListenRepeat mode;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final on = mode != ListenRepeat.off;
    return OutlinedButton.icon(
      key: const Key('repeat-button'),
      style: OutlinedButton.styleFrom(
        foregroundColor: on ? palette.gold : palette.warmGray,
        backgroundColor: on ? palette.goldSoft : null,
        side: BorderSide(
          color: on ? palette.gold : palette.warmGray.withValues(alpha: 0.4),
        ),
      ),
      onPressed: onPressed,
      icon: Icon(switch (mode) {
        ListenRepeat.off => Icons.repeat_rounded,
        ListenRepeat.word => Icons.repeat_one_rounded,
        ListenRepeat.quote => Icons.repeat_one_on_rounded,
      }),
      label: Text(mode.label),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
      decoration: BoxDecoration(
        color: palette.goldSoft,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.gold.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: palette.gold),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              FilledButton(onPressed: onPrimary, child: Text(primaryLabel)),
              if (secondaryLabel != null)
                OutlinedButton(
                  onPressed: onSecondary,
                  child: Text(secondaryLabel!),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
