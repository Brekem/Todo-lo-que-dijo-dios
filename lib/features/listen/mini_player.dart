import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../core/theme/app_palette.dart';
import '../../domain/listening/listening_controller.dart';

/// Barra discreta que aparece sobre la navegación mientras se escucha.
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(listeningProvider);
    final content = ref.watch(contentProvider).value;
    final visible = state.isActive && content != null;
    final palette = AppPalette.of(context);
    final theme = Theme.of(context);

    return AnimatedSize(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      child: !visible
          ? const SizedBox(width: double.infinity)
          : Material(
              color: palette.parchment,
              child: InkWell(
                onTap: () => context.push(Routes.listen),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: palette.gold.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
                  child: Row(
                    children: [
                      Icon(Icons.graphic_eq_rounded, color: palette.gold),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              content
                                  .passages[state.passageIndex.clamp(
                                    0,
                                    content.passages.length - 1,
                                  )]
                                  .reference,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall,
                            ),
                            Text(
                              'Palabra ${state.passageIndex + 1} de ${content.passages.length} · ${state.section.title}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: state.isPlaying ? 'Pausar' : 'Continuar',
                        onPressed: ref.read(listeningProvider.notifier).toggle,
                        icon: Icon(
                          state.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
