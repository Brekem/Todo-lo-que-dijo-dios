import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/boricua_providers.dart';
import '../../core/theme/app_palette.dart';
import '../../domain/assistant/assistant_service.dart';
import '../../shared/widgets/glossary_chips.dart';
import '../../shared/widgets/section_label.dart';
import '../passage/reading_blocks.dart';

/// Asistente cristiano: preguntas de la vida diaria con respuesta bíblica.
class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final _controller = TextEditingController();
  AssistantReply? _reply;
  bool _thinking = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _ask(String question) async {
    if (question.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _thinking = true;
      _controller.text = question;
    });
    final service = await ref.read(assistantProvider.future);
    final reply = await service.ask(question);
    if (!mounted) return;
    setState(() {
      _reply = reply;
      _thinking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final theme = Theme.of(context);
    final resources = ref.watch(boricuaResourcesProvider).value;
    return Scaffold(
      appBar: AppBar(title: const Text('Asistente cristiano')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Text(
            '¿Qué estás pasando? Pregunta con tus propias palabras y te contesto '
            'con la Biblia.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('assistant-field'),
            controller: _controller,
            minLines: 1,
            maxLines: 4,
            textInputAction: TextInputAction.send,
            onSubmitted: _ask,
            decoration: InputDecoration(
              hintText: '¿Cómo perdono? ¿Por qué sufro?…',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                key: const Key('assistant-send'),
                icon: const Icon(Icons.send),
                onPressed: () => _ask(_controller.text),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (resources != null && _reply == null)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final a in resources.assistant.take(10))
                  ActionChip(
                    label: Text(a.question),
                    onPressed: () => _ask(a.question),
                  ),
              ],
            ),
          if (_thinking)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (_reply case final r? when !_thinking) ...[
            const SizedBox(height: 16),
            if (r.help != null)
              Card(
                color: palette.goldSoft,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.support_agent, color: palette.gold),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          r.help!,
                          key: const Key('assistant-help'),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: palette.onGoldSoft,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            const SectionLabel('1. Pasaje bíblico'),
            const SizedBox(height: 8),
            Text(
              '«${r.text}»',
              key: const Key('assistant-passage'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            Text(r.reference, style: TextStyle(color: palette.gold)),
            const SizedBox(height: 22),
            ReadingSection(
              label: '2. Explicación sencilla',
              text: r.explanation,
            ),
            GlossaryChips(text: r.explanation),
            const SizedBox(height: 22),
            ApplicationCard(
              title: '3. Aplicación práctica',
              text: r.application,
            ),
            const SizedBox(height: 22),
            PrayerBlock(title: '4. Oración sugerida', prayer: r.prayer),
            const SizedBox(height: 22),
            Card(
              child: ListTile(
                leading: Icon(Icons.flag_outlined, color: palette.gold),
                title: const Text('5. Próximo paso'),
                subtitle: Text(r.nextStep),
              ),
            ),
            if (r.fromAi)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Respuesta generada con IA. Compárala con la Biblia y habla con tu pastor.',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: palette.warmGray,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => setState(() {
                _reply = null;
                _controller.clear();
              }),
              icon: const Icon(Icons.refresh),
              label: const Text('Hacer otra pregunta'),
            ),
          ],
        ],
      ),
    );
  }
}
