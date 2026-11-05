import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/config/edition.dart';
import '../features/listen/mini_player.dart';

/// Navegación inferior discreta entre las cuatro secciones principales.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: shell,
    bottomNavigationBar: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const MiniPlayer(),
        NavigationBar(
          selectedIndex: shell.currentIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (i) =>
              shell.goBranch(i, initialLocation: i == shell.currentIndex),
          destinations: Edition.current.hasFullBible
              ? const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: 'Inicio',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.menu_book_outlined),
                    selectedIcon: Icon(Icons.menu_book),
                    label: 'Biblia',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.school_outlined),
                    selectedIcon: Icon(Icons.school),
                    label: 'Escuela',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.forum_outlined),
                    selectedIcon: Icon(Icons.forum),
                    label: 'Asistente',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.bookmark_outline),
                    selectedIcon: Icon(Icons.bookmark),
                    label: 'Guardadas',
                  ),
                ]
              : const [
                  NavigationDestination(
                    icon: Icon(Icons.auto_stories_outlined),
                    selectedIcon: Icon(Icons.auto_stories),
                    label: 'Inicio',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.timeline_outlined),
                    selectedIcon: Icon(Icons.timeline),
                    label: 'Recorrido',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.bookmark_outline),
                    selectedIcon: Icon(Icons.bookmark),
                    label: 'Guardadas',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.insights_outlined),
                    selectedIcon: Icon(Icons.insights),
                    label: 'Mi camino',
                  ),
                ],
        ),
      ],
    ),
  );
}
