import 'package:flutter_test/flutter_test.dart';
import 'package:interview_vault/src/models/interview.dart';

void main() {
  test('un entretien conserve ses données lors de la sérialisation', () {
    final source = Interview(
      id: 'iv-1',
      position: 'Développeuse Flutter',
      company: 'Acme',
      date: DateTime(2026, 7, 15, 10, 30),
      status: InterviewStatus.confirme,
      type: InterviewType.visioconference,
    );

    final restored = Interview.fromMap(source.toMap());

    expect(restored.position, 'Développeuse Flutter');
    expect(restored.company, 'Acme');
    expect(restored.status, InterviewStatus.confirme);
    expect(restored.date, DateTime(2026, 7, 15, 10, 30));
    expect(restored.checklist, isNotEmpty);
  });
}
