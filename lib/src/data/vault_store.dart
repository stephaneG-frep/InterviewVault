import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/interview.dart';

class VaultStore extends ChangeNotifier {
  late Box<dynamic> _box;
  final interviews = <Interview>[];
  final preparationCards = <Map<String, dynamic>>[];
  final simulations = <Map<String, dynamic>>[];
  ThemeMode themeMode = ThemeMode.system;
  Color seedColor = const Color(0xFF2563EB);
  static const _starterCards = [
    {
      'title': 'Pitch de 30 secondes',
      'category': 'Présentation',
      'content': 'Qui je suis, ce que je sais faire et ce que je recherche.',
    },
    {
      'title': 'Méthode STAR',
      'category': 'Comportemental',
      'content': 'Situation · Tâche · Action · Résultat',
    },
    {
      'title': 'Questions au recruteur',
      'category': 'Questions',
      'content': 'Quels seront les critères de réussite après 6 mois ?',
    },
  ];

  Future<void> initialize() async {
    _box = await Hive.openBox<dynamic>('interview_vault');
    themeMode = ThemeMode.values.byName(
      _box.get('themeMode', defaultValue: ThemeMode.system.name) as String,
    );
    seedColor = Color(_box.get('seedColor', defaultValue: 0xFF2563EB) as int);
    for (final v in _box.get('interviews', defaultValue: const []) as List) {
      interviews.add(Interview.fromMap(Map<dynamic, dynamic>.from(v as Map)));
    }
    for (final v
        in _box.get('preparation', defaultValue: _starterCards) as List) {
      preparationCards.add(Map<String, dynamic>.from(v as Map));
    }
    for (final v in _box.get('simulations', defaultValue: const []) as List) {
      simulations.add(Map<String, dynamic>.from(v as Map));
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    await _box.put('themeMode', mode.name);
    notifyListeners();
  }

  Future<void> setSeedColor(Color color) async {
    seedColor = color;
    await _box.put('seedColor', color.toARGB32());
    notifyListeners();
  }

  Future<void> saveInterview(Interview item) async {
    final i = interviews.indexWhere((e) => e.id == item.id);
    if (i < 0) {
      interviews.add(item);
    } else {
      interviews[i] = item;
    }
    await _box.put('interviews', interviews.map((e) => e.toMap()).toList());
    notifyListeners();
  }

  Future<void> deleteInterview(String id) async {
    interviews.removeWhere((e) => e.id == id);
    await _box.put('interviews', interviews.map((e) => e.toMap()).toList());
    notifyListeners();
  }

  Future<void> addCard(String title, String category, String content) async {
    preparationCards.add({
      'title': title,
      'category': category,
      'content': content,
    });
    await _box.put('preparation', preparationCards);
    notifyListeners();
  }

  Future<void> addSimulation(int score, int seconds, String category) async {
    simulations.insert(0, {
      'score': score,
      'seconds': seconds,
      'category': category,
      'date': DateTime.now().toIso8601String(),
    });
    await _box.put('simulations', simulations);
    notifyListeners();
  }
}
