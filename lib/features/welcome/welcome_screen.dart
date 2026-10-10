import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/config/edition.dart';
import '../../core/theme/app_palette.dart';
import '../../shared/widgets/fade_slide_in.dart';
import '../../shared/widgets/sacred_background.dart';

/// Umbral de la "biblioteca sagrada".
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: SacredBackground(
        child: SafeArea(
          child: LayoutBuilder(
            // Desplazable solo si no cabe (móviles pequeños, letra grande).
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(flex: 3),
                        FadeSlideIn(
                          duration: const Duration(milliseconds: 1400),
                          child: Container(
                            width: 40,
                            height: 1.2,
                            color: palette.gold,
                          ),
                        ),
                        const SizedBox(height: 28),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 300),
                          duration: const Duration(milliseconds: 1600),
                          child: Text(
                            'Todo lo que\n${Edition.current.speaker} dijo',
                            style: theme.textTheme.displayLarge?.copyWith(
                              fontSize: constraints.maxHeight < 720 ? 44 : 56,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 1100),
                          duration: const Duration(milliseconds: 1400),
                          child: Text(
                            'Explora cada palabra pronunciada por ${Edition.current.speaker} y descubre su significado para tu vida.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: palette.warmGray,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const Spacer(flex: 4),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 1800),
                          child: SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () => context.go(Routes.home),
                              child: const Text('Comenzar recorrido'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 2200),
                          child: Center(
                            child: Text(
                              Edition.current.milestones,
                              style: theme.textTheme.labelSmall,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
