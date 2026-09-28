import 'package:flutter_test/flutter_test.dart';
import 'package:todo_lo_que_dios_dijo/data/models/reading_progress.dart';

void main() {
  test('cuenta días seguidos hasta hoy', () {
    final p = ReadingProgress(
      activeDays: {'2026-09-26', '2026-09-27', '2026-09-28', '2026-09-20'},
    );
    expect(p.streak(DateTime(2026, 9, 28)), 3);
  });

  test('la racha sigue viva si hoy aún no hubo lectura', () {
    final p = ReadingProgress(activeDays: {'2026-09-26', '2026-09-27'});
    expect(p.streak(DateTime(2026, 9, 28, 9)), 2);
    expect(p.streak(DateTime(2026, 9, 30)), 0);
  });

  test('se serializa y deserializa', () {
    const p = ReadingProgress(
      readIds: {'a'},
      prayedIds: {'a'},
      prayersCount: 2,
      activeDays: {'2026-01-01'},
      lastReadId: 'a',
    );
    final back = ReadingProgress.fromJson(p.toJson());
    expect(back.readIds, {'a'});
    expect(back.prayersCount, 2);
    expect(back.lastReadId, 'a');
  });
}
