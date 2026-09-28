import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../core/analytics.dart';
import '../../core/theme/app_palette.dart';
import '../../data/models/content_bundle.dart';
import '../../domain/listening/listening_controller.dart';
import '../../domain/search/search_engine.dart';
import '../../shared/widgets/async_content.dart';
import '../../shared/widgets/fade_slide_in.dart';
import '../../shared/widgets/passage_tile.dart';
import '../../shared/widgets/rotating_search_bar.dart';
import '../../shared/widgets/section_label.dart';

/// Búsqueda inteligente por palabra, problema, tema o personaje bíblico.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({
    super.key,
    this.initialQuery = '',
    this.initialMode = SearchMode.all,
  });

  final String initialQuery;
  final SearchMode initialMode;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final _controller = TextEditingController(text: widget.initialQuery);
  late SearchMode _mode = widget.initialMode;
  late String _query = widget.initialQuery;
  Timer? _debounce;

  static const _modeLabels = {
    SearchMode.all: 'Todo',
    SearchMode.problem: 'Problema',
    SearchMode.topic: 'Tema',
    SearchMode.person: 'Personaje',
  };

  static const _modeHints = {
    SearchMode.all: 'Buscar una palabra de Dios…',
    SearchMode.problem: '¿Qué estás enfrentando? Miedo, culpa…',
    SearchMode.topic: 'Buscar sobre fe, amor, esperanza…',
    SearchMode.person: 'Moisés, Elías, Pedro, María…',
  };

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 220), () {
      setState(() => _query = value);
      if (value.trim().length > 2) {
        Analytics.log('search', {'mode': _mode.name});
      }
    });
  }

  void _useSuggestion(String value) {
    _controller.text = value;
    setState(() => _query = value);
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: TextField(
            controller: _controller,
            autofocus: widget.initialQuery.isEmpty,
            textInputAction: TextInputAction.search,
            onChanged: _onChanged,
            onSubmitted: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: _mode == SearchMode.all
                  ? kSearchHints.first
                  : _modeHints[_mode],
              filled: true,
              fillColor: palette.parchment,
              prefixIcon: Icon(Icons.search, color: palette.gold),
              suffixIcon: _controller.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Borrar',
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _controller.clear();
                        setState(() => _query = '');
                      },
                    ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<SearchMode>(
                showSelectedIcon: false,
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: palette.goldSoft,
                  side: BorderSide(
                    color: palette.warmGray.withValues(alpha: 0.2),
                  ),
                ),
                segments: [
                  for (final m in SearchMode.values)
                    ButtonSegment(
                      value: m,
                      label: Text(_modeLabels[m]!, maxLines: 1),
                    ),
                ],
                selected: {_mode},
                onSelectionChanged: (s) => setState(() => _mode = s.first),
              ),
            ),
          ),
        ),
      ),
      body: AsyncContent(
        builder: (context, content) {
          final engine = ref.watch(searchEngineProvider);
          if (_query.trim().isEmpty || engine == null) {
            return _Suggestions(
              content: content,
              mode: _mode,
              onPick: _useSuggestion,
            );
          }
          final results = engine.search(_query, mode: _mode);
          if (results.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Text(
                  'No encontramos palabras para «$_query».\nPrueba con otra palabra o un sinónimo.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(color: palette.warmGray),
                ),
              ),
            );
          }
          // Escuchar los resultados uno tras otro, desde [start].
          void listen(int start) {
            ref.read(listeningProvider.notifier).playSearch(_query, [
              for (final r in results) content.indexOf(r.passage),
            ], start: start);
            Analytics.log('listen_search', {'mode': _mode.name});
            context.push(Routes.listen);
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            itemCount: results.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              if (i == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionLabel(
                      '${results.length} ${results.length == 1 ? 'palabra encontrada' : 'palabras encontradas'}',
                    ),
                    const SizedBox(height: 10),
                    FilledButton.tonalIcon(
                      onPressed: () => listen(0),
                      icon: const Icon(Icons.headphones_outlined),
                      label: Text(
                        results.length == 1
                            ? 'Escuchar'
                            : 'Escuchar todas, una tras otra',
                      ),
                    ),
                  ],
                );
              }
              final passage = results[i - 1].passage;
              return FadeSlideIn(
                key: ValueKey('${_query}_${passage.id}'),
                delay: Duration(milliseconds: 40 * (i - 1).clamp(0, 8)),
                duration: const Duration(milliseconds: 500),
                child: PassageTile(
                  passage: passage,
                  onTap: () => context.push(Routes.passage(passage.id)),
                  trailing: IconButton(
                    tooltip: 'Escuchar desde esta palabra',
                    color: palette.gold,
                    onPressed: () => listen(i - 1),
                    icon: const Icon(Icons.headphones_outlined),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _Suggestions extends StatelessWidget {
  const _Suggestions({
    required this.content,
    required this.mode,
    required this.onPick,
  });

  final ContentBundle content;
  final SearchMode mode;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    Widget group(String title, List<String> values) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(title),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final v in values)
              ActionChip(label: Text(v), onPressed: () => onPick(v)),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      children: [
        if (mode == SearchMode.all || mode == SearchMode.problem)
          group(
            'Buscar por problema',
            content.allProblems.take(mode == SearchMode.all ? 12 : 60).toList(),
          ),
        if (mode == SearchMode.all || mode == SearchMode.topic)
          group(
            'Buscar por tema',
            content.allTopics.take(mode == SearchMode.all ? 12 : 60).toList(),
          ),
        if (mode == SearchMode.all || mode == SearchMode.person)
          group(
            'Buscar por personaje bíblico',
            content.allPeople.take(mode == SearchMode.all ? 12 : 80).toList(),
          ),
      ],
    );
  }
}
