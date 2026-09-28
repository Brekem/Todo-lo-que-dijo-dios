import 'package:flutter_test/flutter_test.dart';
import 'package:todo_lo_que_dios_dijo/domain/personalization/offline_personalizer.dart';
import 'package:todo_lo_que_dios_dijo/domain/personalization/personalization_service.dart';

import '../helpers.dart';

void main() {
  final passage = loadContent().passageById('isa-41-10')!;

  test('personaliza explicación, aplicación y oración', () async {
    final r = await const OfflinePersonalizer().personalize(
      passage: passage,
      userSituation: 'Tengo ansiedad por mi trabajo',
    );
    expect(r.generatedByAi, isFalse);
    expect(r.explanation, contains('Tengo ansiedad por mi trabajo'));
    expect(r.application, startsWith('Si hoy estás enfrentando'));
    expect(r.application, contains('Respira'));
    expect(r.prayer, startsWith('Señor,'));
  });

  test('añade aviso de ayuda ante señales de crisis', () async {
    expect(isCrisis('ya no quiero vivir'), isTrue);
    final r = await const OfflinePersonalizer().personalize(
      passage: passage,
      userSituation: 'Ya no quiero vivir',
    );
    expect(r.application, contains(crisisNotice));
  });
}
