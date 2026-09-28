import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/providers.dart';
import '../../core/analytics.dart';
import '../../core/theme/app_palette.dart';
import '../../data/models/passage.dart';
import '../../data/models/saved_word.dart';
import '../../shared/widgets/fade_slide_in.dart';
import '../../shared/widgets/golden_shimmer.dart';
import '../../shared/widgets/sacred_background.dart';
import '../../shared/widgets/section_label.dart';
import 'reading_blocks.dart';

const _suggestions = [
  'Tengo miedo al futuro',
  'Me siento solo',
  'La ansiedad no me deja dormir',
  'No puedo perdonarme',
  'Perdí a un ser querido',
  'Me cuesta perdonar a alguien',
  'Siento que mi fe se apaga',
];

/// "Necesito esta palabra para mí": la IA adapta explicación, aplicación y
/// oración a lo que el usuario está viviendo.
class PersonalizeScreen extends ConsumerStatefulWidget {
  const PersonalizeScreen({super.key, required this.passageId});

  final String passageId;

  @override
  ConsumerState<PersonalizeScreen> createState() => _PersonalizeScreenState();
}

class _PersonalizeScreenState extends ConsumerState<PersonalizeScreen> {
  final _controller = TextEditingController();
  Personalization? _result;
  var _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit(Passage passage) async {
    final text = _controller.text.trim();
    if (text.length < 3) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _result = null;
    });
    final result = await ref
        .read(personalizationServiceProvider)
        .personalize(passage: passage, userSituation: text);
    Analytics.log('personalize', {
      'id': passage.id,
      'ai': result.generatedByAi.toString(),
    });
    if (mounted) {
      setState(() {
        _loading = false;
        _result = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final passage = ref.watch(passageProvider(widget.passageId));
    final palette = AppPalette.of(context);
    final theme = Theme.of(context);
    if (passage == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
      );
    }
    final result = _result;
    return Scaffold(
      appBar: AppBar(title: const Text('Esta palabra para mí')),
      body: ListView(
        key: const Key('personalize-list'),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 48),
        children: [
          Text(
            '«${passage.quote}»',
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              fontStyle: FontStyle.italic,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            passage.reference,
            style: theme.textTheme.labelLarge?.copyWith(color: palette.gold),
          ),
          const SizedBox(height: 32),
          Text(
            '¿Qué estás enfrentando hoy?',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Escríbelo con tus palabras. Recibirás una explicación, una aplicación y una oración pensadas para tu situación.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: palette.warmGray,
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _controller,
            minLines: 2,
            maxLines: 5,
            maxLength: 400,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Por ejemplo: tengo miedo de perder mi trabajo…',
              filled: true,
              fillColor: palette.parchment,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: palette.warmGray.withValues(alpha: 0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: palette.warmGray.withValues(alpha: 0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: palette.gold),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in _suggestions)
                ActionChip(
                  label: Text(s),
                  onPressed: () => setState(() => _controller.text = s),
                ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _loading || _controller.text.trim().length < 3
                ? null
                : () => _submit(passage),
            icon: const Icon(Icons.auto_awesome_outlined),
            label: const Text('Recibir esta palabra'),
          ),
          const SizedBox(height: 32),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 700),
            child: _loading
                ? const _Listening()
                : result == null
                ? const SizedBox.shrink()
                : _ResultView(
                    key: ValueKey(result),
                    passage: passage,
                    result: result,
                  ),
          ),
        ],
      ),
    );
  }
}

class _Listening extends StatelessWidget {
  const _Listening();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: SizedBox(
        height: 180,
        child: SacredBackground(
          particles: 24,
          child: Center(
            child: Text(
              'Meditando esta palabra para ti…',
              style: theme.textTheme.titleLarge?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultView extends ConsumerWidget {
  const _ResultView({super.key, required this.passage, required this.result});

  final Passage passage;
  final Personalization result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = AppPalette.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FadeSlideIn(
          child: ReadingSection(
            label: 'Para tu situación',
            text: result.explanation,
          ),
        ),
        const SizedBox(height: 28),
        FadeSlideIn(
          delay: const Duration(milliseconds: 400),
          child: ApplicationCard(
            title: 'Tu aplicación para hoy',
            text: result.application,
          ),
        ),
        const SizedBox(height: 24),
        FadeSlideIn(
          delay: const Duration(milliseconds: 800),
          child: GoldenShimmer(
            delay: const Duration(milliseconds: 1400),
            child: PrayerBlock(
              title: 'Tu oración',
              prayer: result.prayer,
              onAmen: () =>
                  ref.read(progressProvider.notifier).markPrayed(passage.id),
            ),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.tonalIcon(
          onPressed: () {
            ref
                .read(savedWordsProvider.notifier)
                .save(passage.id, personalization: result);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Guardada con tu oración en «Las palabras que guardé»',
                ),
              ),
            );
          },
          icon: const Icon(Icons.bookmark_add_outlined),
          label: const Text('Guardar versículo, aplicación y oración'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => SharePlus.instance.share(
            ShareParams(
              text:
                  '«${passage.quote}»\n— ${passage.reference}\n\n'
                  '${result.application}\n\nOración:\n${result.prayer}\n\n'
                  'Compartido desde «Todo lo que Dios Dijo».',
            ),
          ),
          icon: const Icon(Icons.ios_share_outlined),
          label: const Text('Compartir'),
        ),
        const SizedBox(height: 20),
        SectionLabel(
          result.generatedByAi ? 'Generado con IA' : 'Generado sin conexión',
        ),
        const SizedBox(height: 8),
        Text(
          'Esta reflexión es un acompañamiento devocional y no sustituye el consejo '
          'pastoral, médico o psicológico. Contrasta siempre con la Escritura.',
          style: theme.textTheme.bodySmall?.copyWith(color: palette.warmGray),
        ),
      ],
    );
  }
}
