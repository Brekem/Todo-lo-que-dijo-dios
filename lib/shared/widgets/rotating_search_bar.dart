import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_palette.dart';

const kSearchHints = [
  'Buscar una palabra de Dios…',
  'Buscar sobre ansiedad…',
  'Buscar sobre fe…',
  'Buscar sobre el perdón…',
  'Buscar por personaje: Moisés, Elías…',
  'Buscar sobre el miedo…',
];

/// Barra de búsqueda con sugerencias que cambian suavemente.
/// Al tocarla abre el buscador completo.
class RotatingSearchBar extends StatefulWidget {
  const RotatingSearchBar({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  State<RotatingSearchBar> createState() => _RotatingSearchBarState();
}

class _RotatingSearchBarState extends State<RotatingSearchBar> {
  Timer? _timer;
  var _index = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) setState(() => _index = (_index + 1) % kSearchHints.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Semantics(
      button: true,
      label: 'Buscar una palabra de Dios',
      child: Material(
        color: palette.parchment,
        shape: StadiumBorder(
          side: BorderSide(color: palette.warmGray.withValues(alpha: 0.18)),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: widget.onTap,
          child: SizedBox(
            height: 54,
            child: Row(
              children: [
                const SizedBox(width: 18),
                Icon(Icons.search, color: palette.gold),
                const SizedBox(width: 12),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 700),
                    transitionBuilder: (child, a) => FadeTransition(
                      opacity: a,
                      child: SlideTransition(
                        position: Tween(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(a),
                        child: child,
                      ),
                    ),
                    layoutBuilder: (current, previous) => Stack(
                      alignment: Alignment.centerLeft,
                      children: [...previous, ?current],
                    ),
                    child: Text(
                      kSearchHints[_index],
                      key: ValueKey(_index),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: palette.warmGray, fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
