enum InterviewType {
  presentiel,
  telephone,
  visioconference,
  testTechnique,
  assessment,
  autre,
}

enum InterviewStatus { prevu, confirme, realise, annule, refuse, accepte }

enum InterviewPriority { basse, normale, haute }

class Interview {
  Interview({
    required this.id,
    required this.position,
    required this.company,
    required this.date,
    this.recruiter = '',
    this.recruiterRole = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.videoLink = '',
    this.durationMinutes = 60,
    this.type = InterviewType.visioconference,
    this.status = InterviewStatus.prevu,
    this.priority = InterviewPriority.normale,
    this.salary = '',
    this.description = '',
    this.notes = '',
    this.positives = '',
    this.improvements = '',
    this.feeling = 3,
    List<String>? checklist,
    List<String>? checkedItems,
  }) : checklist = checklist ?? List.of(defaultChecklist),
       checkedItems = checkedItems ?? [];

  final String id;
  String position,
      company,
      recruiter,
      recruiterRole,
      phone,
      email,
      address,
      videoLink;
  DateTime date;
  int durationMinutes;
  InterviewType type;
  InterviewStatus status;
  InterviewPriority priority;
  String salary, description, notes, positives, improvements;
  int feeling;
  List<String> checklist, checkedItems;

  static const defaultChecklist = [
    'Relire l’offre',
    'Vérifier le CV',
    'Préparer les questions',
    'Tester la visioconférence',
    'Vérifier le trajet',
    'Préparer les documents',
    'Vérifier la tenue',
    'Vérifier les horaires',
  ];

  Map<String, dynamic> toMap() => {
    'id': id,
    'position': position,
    'company': company,
    'recruiter': recruiter,
    'recruiterRole': recruiterRole,
    'phone': phone,
    'email': email,
    'address': address,
    'videoLink': videoLink,
    'date': date.toIso8601String(),
    'durationMinutes': durationMinutes,
    'type': type.name,
    'status': status.name,
    'priority': priority.name,
    'salary': salary,
    'description': description,
    'notes': notes,
    'positives': positives,
    'improvements': improvements,
    'feeling': feeling,
    'checklist': checklist,
    'checkedItems': checkedItems,
  };

  factory Interview.fromMap(Map<dynamic, dynamic> m) => Interview(
    id: m['id'] as String,
    position: m['position'] as String? ?? '',
    company: m['company'] as String? ?? '',
    recruiter: m['recruiter'] as String? ?? '',
    recruiterRole: m['recruiterRole'] as String? ?? '',
    phone: m['phone'] as String? ?? '',
    email: m['email'] as String? ?? '',
    address: m['address'] as String? ?? '',
    videoLink: m['videoLink'] as String? ?? '',
    date: DateTime.tryParse(m['date'] as String? ?? '') ?? DateTime.now(),
    durationMinutes: m['durationMinutes'] as int? ?? 60,
    type: InterviewType.values.byName(
      m['type'] as String? ?? 'visioconference',
    ),
    status: InterviewStatus.values.byName(m['status'] as String? ?? 'prevu'),
    priority: InterviewPriority.values.byName(
      m['priority'] as String? ?? 'normale',
    ),
    salary: m['salary'] as String? ?? '',
    description: m['description'] as String? ?? '',
    notes: m['notes'] as String? ?? '',
    positives: m['positives'] as String? ?? '',
    improvements: m['improvements'] as String? ?? '',
    feeling: m['feeling'] as int? ?? 3,
    checklist: List<String>.from(m['checklist'] as List? ?? defaultChecklist),
    checkedItems: List<String>.from(m['checkedItems'] as List? ?? const []),
  );
}

extension InterviewLabels on Object {
  String get label =>
      const {
        InterviewType.presentiel: 'Présentiel',
        InterviewType.telephone: 'Téléphone',
        InterviewType.visioconference: 'Visioconférence',
        InterviewType.testTechnique: 'Test technique',
        InterviewType.assessment: 'Assessment Center',
        InterviewType.autre: 'Autre',
        InterviewStatus.prevu: 'Prévu',
        InterviewStatus.confirme: 'Confirmé',
        InterviewStatus.realise: 'Réalisé',
        InterviewStatus.annule: 'Annulé',
        InterviewStatus.refuse: 'Refusé',
        InterviewStatus.accepte: 'Accepté',
        InterviewPriority.basse: 'Basse',
        InterviewPriority.normale: 'Normale',
        InterviewPriority.haute: 'Haute',
      }[this] ??
      toString();
}
