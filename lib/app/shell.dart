import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Navegación inferior discreta entre las cuatro secciones principales.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: shell,
    bottomNavigationBar: NavigationBar(
      selectedIndex: shell.currentIndex,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      onDestinationSelected: (i) =>
          shell.goBranch(i, initialLocation: i == shell.currentIndex),
      destinations: const [
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
  );
}
