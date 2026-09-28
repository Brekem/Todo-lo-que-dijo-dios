import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../domain/search/search_engine.dart';
import '../features/categories/category_screen.dart';
import '../features/favorites/saved_words_screen.dart';
import '../features/home/home_screen.dart';
import '../features/journey/journey_screen.dart';
import '../features/passage/passage_screen.dart';
import '../features/passage/personalize_screen.dart';
import '../features/search/search_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/stats/stats_screen.dart';
import '../features/welcome/welcome_screen.dart';
import 'shell.dart';

abstract final class Routes {
  static const welcome = '/';
  static const home = '/inicio';
  static const journey = '/recorrido';
  static const saved = '/guardadas';
  static const stats = '/progreso';
  static const search = '/buscar';
  static const settings = '/ajustes';

  static String passage(String id) => '/palabra/$id';
  static String personalize(String id) => '/palabra/$id/para-mi';
  static String category(String id) => '/tema/$id';
  static String searchWith({String? query, SearchMode? mode}) => Uri(
    path: search,
    queryParameters: {
      if (query != null && query.isNotEmpty) 'q': query,
      if (mode != null) 'modo': mode.name,
    },
  ).toString();
}

final _rootKey = GlobalKey<NavigatorState>();

/// Transición de fundido lento para pantallas de lectura.
CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 550),
      reverseTransitionDuration: const Duration(milliseconds: 350),
      transitionsBuilder: (context, animation, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      ),
    );

GoRouter createRouter() => GoRouter(
  navigatorKey: _rootKey,
  initialLocation: Routes.welcome,
  routes: [
    GoRoute(
      path: Routes.welcome,
      pageBuilder: (context, state) => _fadePage(state, const WelcomeScreen()),
    ),
    StatefulShellRoute.indexedStack(
      pageBuilder: (context, state, shell) =>
          _fadePage(state, AppShell(shell: shell)),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.journey,
              builder: (_, _) => const JourneyScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.saved,
              builder: (_, _) => const SavedWordsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: Routes.stats, builder: (_, _) => const StatsScreen()),
          ],
        ),
      ],
    ),
    GoRoute(
      path: Routes.search,
      parentNavigatorKey: _rootKey,
      pageBuilder: (context, state) => _fadePage(
        state,
        SearchScreen(
          initialQuery: state.uri.queryParameters['q'] ?? '',
          initialMode: SearchMode.values.firstWhere(
            (m) => m.name == state.uri.queryParameters['modo'],
            orElse: () => SearchMode.all,
          ),
        ),
      ),
    ),
    GoRoute(
      path: '/palabra/:id',
      parentNavigatorKey: _rootKey,
      pageBuilder: (context, state) => _fadePage(
        state,
        PassageScreen(passageId: state.pathParameters['id']!),
      ),
      routes: [
        GoRoute(
          path: 'para-mi',
          parentNavigatorKey: _rootKey,
          pageBuilder: (context, state) => _fadePage(
            state,
            PersonalizeScreen(passageId: state.pathParameters['id']!),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/tema/:id',
      parentNavigatorKey: _rootKey,
      pageBuilder: (context, state) => _fadePage(
        state,
        CategoryScreen(categoryId: state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: Routes.settings,
      parentNavigatorKey: _rootKey,
      pageBuilder: (context, state) => _fadePage(state, const SettingsScreen()),
    ),
  ],
);
