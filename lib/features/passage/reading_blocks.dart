import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';
import '../../shared/widgets/praying_hands_icon.dart';
import '../../shared/widgets/section_label.dart';

/// Bloques visuales reutilizados por la lectura y la personalización.

class ReadingSection extends StatelessWidget {
  const ReadingSection({
    super.key,
    required this.label,
    required this.text,
    this.icon,
  });

  final String label;
  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label),
        const SizedBox(height: 14),
        Text(text, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

/// Tarjeta desplegable (contexto histórico, qué estaba pasando).
class ExpandableCard extends StatefulWidget {
  const ExpandableCard({
    super.key,
    required this.title,
    required this.icon,
    required this.text,
    this.initiallyExpanded = false,
  });

  final String title;
  final IconData icon;
  final String text;
  final bool initiallyExpanded;

  @override
  State<ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard> {
  late bool _open = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => setState(() => _open = !_open),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 18, 18),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(widget.icon, color: palette.gold, size: 22),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    AnimatedRotation(
                      turns: _open ? 0.5 : 0,
                      duration: const Duration(milliseconds: 420),
                      child: Icon(Icons.expand_more, color: palette.warmGray),
                    ),
                  ],
                ),
                if (_open) ...[
                  const SizedBox(height: 14),
                  AnimatedOpacity(
                    opacity: 1,
                    duration: const Duration(milliseconds: 600),
                    child: Text(widget.text, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tarjeta destacada dorada: "Dios estaba corrigiendo…".
class ProblemCard extends StatelessWidget {
  const ProblemCard({super.key, required this.items, required this.text});

  final List<String> items;
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
      decoration: BoxDecoration(
        color: palette.goldSoft,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.gold.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_fix_high_outlined, color: palette.gold, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Problema que Dios estaba tratando',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: palette.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Dios estaba corrigiendo:', style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: palette.gold,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _capitalize(item),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Text(text, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

/// "Aplicación para hoy", en formato práctico.
class ApplicationCard extends StatelessWidget {
  const ApplicationCard({
    super.key,
    required this.text,
    this.title = 'Aplicación para hoy',
  });

  final String text;
  final String title;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.wb_twilight_outlined, color: palette.gold, size: 22),
                const SizedBox(width: 12),
                Expanded(child: Text(title, style: theme.textTheme.titleLarge)),
              ],
            ),
            const SizedBox(height: 14),
            Text(text, style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

/// Bloque especial de oración: color distinto e icono de manos orando.
class PrayerBlock extends StatelessWidget {
  const PrayerBlock({
    super.key,
    required this.prayer,
    this.title = 'Oración de liberación',
    this.onAmen,
    this.prayed = false,
  });

  final String prayer;
  final String title;
  final VoidCallback? onAmen;
  final bool prayed;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(26, 28, 26, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            palette.blueSoft,
            Color.alphaBlend(
              palette.crimson.withValues(alpha: 0.05),
              palette.blueSoft,
            ),
          ],
        ),
        border: Border.all(color: palette.blue.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: palette.background.withValues(alpha: 0.6),
              border: Border.all(color: palette.gold.withValues(alpha: 0.5)),
            ),
            alignment: Alignment.center,
            child: PrayingHandsIcon(size: 30, color: palette.gold),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            prayer,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              fontSize: 21,
              height: 1.5,
            ),
          ),
          if (onAmen != null) ...[
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: prayed
                  ? Wrap(
                      key: const ValueKey('prayed'),
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: palette.gold,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Amén. Oraste esta palabra.',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: palette.gold,
                          ),
                        ),
                        TextButton(
                          onPressed: onAmen,
                          child: const Text('Orar de nuevo'),
                        ),
                      ],
                    )
                  : TextButton.icon(
                      key: const ValueKey('amen'),
                      onPressed: onAmen,
                      icon: Icon(
                        Icons.favorite_border,
                        color: palette.crimson,
                        size: 18,
                      ),
                      label: Text(
                        'Amén · hice esta oración',
                        style: TextStyle(color: palette.ink),
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}
