import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/config/app_config.dart';
import '../../core/theme/app_palette.dart';
import '../../shared/widgets/section_label.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final textScale = ref.watch(textScaleProvider);
    final firebase = ref.watch(firebaseReadyProvider);
    final content = ref.watch(contentProvider).value;
    final palette = AppPalette.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        children: [
          const SectionLabel('Apariencia'),
          const SizedBox(height: 16),
          SegmentedButton<ThemeMode>(
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: palette.goldSoft,
            ),
            segments: const [
              ButtonSegment(
                value: ThemeMode.system,
                icon: Icon(Icons.brightness_auto_outlined),
                label: Text('Sistema'),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                icon: Icon(Icons.light_mode_outlined),
                label: Text('Claro'),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                icon: Icon(Icons.dark_mode_outlined),
                label: Text('Oscuro'),
              ),
            ],
            selected: {themeMode},
            onSelectionChanged: (s) =>
                ref.read(themeModeProvider.notifier).set(s.first),
          ),
          const SizedBox(height: 28),
          Text('Tamaño de lectura', style: theme.textTheme.titleMedium),
          Slider(
            value: textScale,
            min: 0.85,
            max: 1.4,
            divisions: 11,
            label: '${(textScale * 100).round()} %',
            onChanged: (v) => ref.read(textScaleProvider.notifier).set(v),
          ),
          Text(
            '«No temas, porque yo estoy contigo.»',
            style: theme.textTheme.titleLarge?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 40),
          const SectionLabel('Contenido'),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.offline_pin_outlined, color: palette.gold),
            title: const Text('Lectura sin conexión'),
            subtitle: Text(
              'Todas las palabras están guardadas en tu dispositivo'
              '${content == null ? '' : ' (versión ${content.version}, ${content.passages.length} palabras)'}.',
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              firebase ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
              color: palette.gold,
            ),
            title: const Text('Sincronización'),
            subtitle: Text(
              firebase
                  ? 'Activa: las nuevas palabras llegan automáticamente.'
                  : 'Sin configurar: la app funciona completamente offline.',
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.menu_book_outlined, color: palette.gold),
            title: const Text('Texto bíblico'),
            subtitle: Text(content?.translation ?? ''),
          ),
          const SizedBox(height: 28),
          const SectionLabel('Privacidad'),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.restart_alt, color: palette.crimson),
            title: const Text('Reiniciar mi camino'),
            subtitle: const Text(
              'Borra palabras leídas, días seguidos y oraciones.',
            ),
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('¿Reiniciar tu camino?'),
                  content: const Text('Tus palabras guardadas se conservarán.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Reiniciar'),
                    ),
                  ],
                ),
              );
              if (ok ?? false) ref.read(progressProvider.notifier).reset();
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.info_outline, color: palette.gold),
            title: const Text('Acerca de'),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: AppConfig.appName,
              applicationVersion: '3.4.0',
              applicationLegalese:
                  'Textos bíblicos: ${content?.translation ?? ''}.\n\n'
                  'Tus favoritos y tu progreso se guardan solo en tu dispositivo. '
                  'Cuando usas «Necesito esta palabra para mí», el texto que escribes '
                  'se envía a Firebase AI Logic (Google) únicamente para generar tu reflexión.',
            ),
          ),
        ],
      ),
    );
  }
}
