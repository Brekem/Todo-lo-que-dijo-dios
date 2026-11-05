import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../domain/search/search_engine.dart';
import '../features/categories/category_screen.dart';
import '../features/favorites/saved_words_screen.dart';
import '../features/home/home_screen.dart';
import '../features/journey/journey_screen.dart';
import '../features/listen/listen_screen.dart';
import '../features/passage/passage_screen.dart';
import '../features/passage/personalize_screen.dart';
import '../features/search/search_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/stats/stats_screen.dart';
import '../features/welcome/welcome_screen.dart';
import '../core/config/edition.dart';
import '../features/assistant/assistant_screen.dart';
import '../features/bible/bible_screen.dart';
import '../features/bible/bible_search_screen.dart';
import '../features/bible/chapter_screen.dart';
import '../features/bible/my_notes_screen.dart';
import '../features/glossary/glossary_screen.dart';
import '../features/plans/plans_screen.dart';
import '../features/school/school_screen.dart';
import 'shell.dart';

abstract final class Routes {
  static const welcome = '/';
  static const home = '/inicio';
  static const journey = '/recorrido';
  static const saved = '/guardadas';
  static const stats = '/progreso';
  static const search = '/buscar';
  static const settings = '/ajustes';
  static const listen = '/escuchar';

  // Biblia Boricua
  static const bible = '/biblia';
  static const bibleSearch = '/biblia/buscar';
  static const myNotes = '/biblia/notas';
  static const plans = '/planes';
  static const school = '/escuela';
  static const assistant = '/asistente';
  static const glossary = '/glosario';

  static String chapter(String bookId, int chapter, {int? verse}) =>
      '/biblia/$bookId/$chapter${verse == null ? '' : '?v=$verse'}';
  static String plan(String id) => '/planes/$id';
  static String lesson(String id) => '/escuela/$id';

  static String listenFrom(String passageId) => '$listen?desde=$passageId';

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
      branches: Edition.current.hasFullBible
          ? _boricuaBranches()
          : [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: Routes.home,
                    builder: (_, _) => const HomeScreen(),
                  ),
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
                  GoRoute(
                    path: Routes.stats,
                    builder: (_, _) => const StatsScreen(),
                  ),
                ],
              ),
            ],
    ),
    if (Edition.current.hasFullBible) ..._boricuaRoutes(),
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
      path: Routes.listen,
      parentNavigatorKey: _rootKey,
      pageBuilder: (context, state) => _fadePage(
        state,
        ListenScreen(startPassageId: state.uri.queryParameters['desde']),
      ),
    ),
    GoRoute(
      path: Routes.settings,
      parentNavigatorKey: _rootKey,
      pageBuilder: (context, state) => _fadePage(state, const SettingsScreen()),
    ),
  ],
);

/// Pestañas de la Biblia Boricua: Inicio, Biblia, Escuela, Asistente y
/// Guardadas.
List<StatefulShellBranch> _boricuaBranches() => [
  StatefulShellBranch(
    routes: [GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen())],
  ),
  StatefulShellBranch(
    routes: [
      GoRoute(path: Routes.bible, builder: (_, _) => const BibleScreen()),
    ],
  ),
  StatefulShellBranch(
    routes: [
      GoRoute(path: Routes.school, builder: (_, _) => const SchoolScreen()),
    ],
  ),
  StatefulShellBranch(
    routes: [
      GoRoute(
        path: Routes.assistant,
        builder: (_, _) => const AssistantScreen(),
      ),
    ],
  ),
  StatefulShellBranch(
    routes: [
      GoRoute(path: Routes.saved, builder: (_, _) => const SavedWordsScreen()),
    ],
  ),
];

List<RouteBase> _boricuaRoutes() => [
  GoRoute(
    path: Routes.bibleSearch,
    parentNavigatorKey: _rootKey,
    pageBuilder: (context, state) => _fadePage(
      state,
      BibleSearchScreen(initialQuery: state.uri.queryParameters['q'] ?? ''),
    ),
  ),
  GoRoute(
    path: Routes.myNotes,
    parentNavigatorKey: _rootKey,
    pageBuilder: (context, state) => _fadePage(state, const MyNotesScreen()),
  ),
  GoRoute(
    path: '/biblia/:book/:chapter',
    parentNavigatorKey: _rootKey,
    pageBuilder: (context, state) => _fadePage(
      state,
      ChapterScreen(
        key: ValueKey(state.uri.toString()),
        bookId: state.pathParameters['book']!,
        chapter: int.tryParse(state.pathParameters['chapter']!) ?? 1,
        verse: int.tryParse(state.uri.queryParameters['v'] ?? ''),
      ),
    ),
  ),
  GoRoute(
    path: Routes.plans,
    parentNavigatorKey: _rootKey,
    pageBuilder: (context, state) => _fadePage(state, const PlansScreen()),
  ),
  GoRoute(
    path: '/planes/:id',
    parentNavigatorKey: _rootKey,
    pageBuilder: (context, state) =>
        _fadePage(state, PlanScreen(planId: state.pathParameters['id']!)),
  ),
  GoRoute(
    path: '/escuela/:id',
    parentNavigatorKey: _rootKey,
    pageBuilder: (context, state) =>
        _fadePage(state, LessonScreen(lessonId: state.pathParameters['id']!)),
  ),
  GoRoute(
    path: Routes.glossary,
    parentNavigatorKey: _rootKey,
    pageBuilder: (context, state) => _fadePage(state, const GlossaryScreen()),
  ),
];
