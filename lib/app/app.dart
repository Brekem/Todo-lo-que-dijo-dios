import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/config/app_config.dart';
import '../core/theme/app_theme.dart';
import 'providers.dart';
import 'router.dart';

class TodoLoQueDiosDijoApp extends ConsumerStatefulWidget {
  const TodoLoQueDiosDijoApp({super.key});

  @override
  ConsumerState<TodoLoQueDiosDijoApp> createState() => _AppState();
}

class _AppState extends ConsumerState<TodoLoQueDiosDijoApp> {
  late final GoRouter _router = createRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final textScale = ref.watch(textScaleProvider);
    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      themeAnimationDuration: const Duration(milliseconds: 600),
      routerConfig: _router,
      locale: const Locale('es'),
      supportedLocales: const [Locale('es')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            // Tamaño del sistema × preferencia del lector, con límites legibles.
            textScaler: TextScaler.linear(media.textScaler.scale(1) * textScale)
                .clamp(minScaleFactor: 0.8, maxScaleFactor: 2.0),
          ),
          child: child!,
        );
      },
    );
  }
}
