import 'package:flutter/material.dart';

import '../../core/config/edition.dart';
import '../../core/theme/app_palette.dart';
import '../../data/models/passage.dart';

/// Los versículos completos, con su número. Lo que dice Dios va en dorado y
/// en negrita; lo que cuenta el narrador, en letra normal.
class VersesText extends StatelessWidget {
  const VersesText({super.key, required this.verses, this.style});

  final List<VerseText> verses;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final base =
        style ??
        Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6) ??
        const TextStyle();
    final number = base.copyWith(
      fontSize: (base.fontSize ?? 16) * 0.7,
      color: palette.warmGray,
      fontWeight: FontWeight.w600,
    );
    final god = base.copyWith(
      color: Color.lerp(palette.gold, palette.ink, 0.25),
      fontWeight: FontWeight.w700,
    );
    return Text.rich(
      TextSpan(
        children: [
          for (final (i, verse) in verses.indexed) ...[
            if (verse.number > 0)
              TextSpan(
                text: '${i == 0 ? '' : ' '}${verse.number} ',
                style: number,
              ),
            for (final (j, part) in verse.parts.indexed)
              TextSpan(
                text: j == 0 ? part.text : ' ${part.text}',
                style: part.god ? god : base,
              ),
          ],
        ],
      ),
    );
  }
}

/// Tarjeta con los versículos completos de una palabra. Los pasajes largos
/// se muestran recortados (siempre en versículos enteros) hasta que se pide
/// ver todo.
class FullVersesCard extends StatefulWidget {
  const FullVersesCard({super.key, required this.passage});

  final Passage passage;

  @override
  State<FullVersesCard> createState() => _FullVersesCardState();
}

class _FullVersesCardState extends State<FullVersesCard> {
  static const _preview = 6;
  bool _all = false;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final theme = Theme.of(context);
    final verses = widget.passage.verses;
    final long = verses.length > _preview + 2;
    final shown = long && !_all ? verses.take(_preview).toList() : verses;
    return Container(
      key: const Key('full-verses'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
      decoration: BoxDecoration(
        color: palette.parchment.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LOS VERSÍCULOS COMPLETOS',
            style: theme.textTheme.labelMedium?.copyWith(
              color: palette.gold,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.passage.fullReference,
            style: theme.textTheme.labelLarge?.copyWith(
              color: palette.warmGray,
            ),
          ),
          const SizedBox(height: 12),
          VersesText(verses: shown),
          if (long)
            TextButton.icon(
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              onPressed: () => setState(() => _all = !_all),
              icon: Icon(
                _all ? Icons.expand_less_rounded : Icons.expand_more_rounded,
              ),
              label: Text(
                _all ? 'Ver menos' : 'Ver los ${verses.length} versículos',
              ),
            ),
          if (widget.passage.hasGodWords && !widget.passage.id.startsWith('v-'))
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: palette.gold,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Resaltado, lo que dice ${Edition.current.speaker}. Al escucharlo suena la '
                      'campana y habla con su propia voz.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: palette.warmGray,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
